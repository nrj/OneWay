//
//  Controller.m
//  OneWay
//
//  Created by nrj on 7/18/09.
//  Copyright 2009. All rights reserved.
//

#import "Controller.h"
#import "Controller+Toolbar.h"
#import "Location.h"
#import "LocationSheet.h"
#import "PasswordSheet.h"
#import "WelcomeView.h"
#import "TransferCell.h"
#import "OWConstants.h"
#import "NSString+Truncate.h"


@implementation Controller

@synthesize transfers;
@synthesize savedLocations;
@synthesize totalTransfers;
@synthesize totalActiveTransfers;


- (id)init
{
	if (self = [super init])
	{
		// Initialize the clients array
		clients = [[NSMutableArray alloc] init];
		
		// Load any saved data
		savedLocations = [[NSKeyedUnarchiver unarchiveObjectWithFile:[OWSavedLocationsFile stringByExpandingTildeInPath]] retain];
		if (savedLocations == nil)
		{
			NSLog(@"No saved location data found.");
			savedLocations = [[NSMutableArray alloc] init];
		}
		
		// Load any saved transfers
		transfers = [[NSKeyedUnarchiver unarchiveObjectWithFile:[OWSavedTransfersFile stringByExpandingTildeInPath]] retain];
		if (transfers == nil)
		{
			NSLog(@"No saved transfer data found");
			transfers = [[NSMutableArray alloc] init];
		}
			
		// Init the Sheets
		locationSheet = [[LocationSheet alloc] init];
		passwordSheet = [[PasswordSheet alloc] init];
		
		// Subscribe to notifications
		NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
		
		[nc addObserver:self 
			   selector:@selector(handleQueueTransferNotification:) 
				   name:OWQueueTransferNotification 
				 object:nil];
		
		[nc addObserver:self 
			   selector:@selector(handleQueueNewTransferNotification:) 
				   name:OWQueueNewTransferNotification 
				 object:nil];
	}
	
	return self;
}


- (void)dealloc
{
	[savedLocations release], savedLocations = nil;
	[transfers release], transfers = nil;
	
	int count = [clients count];
	while (count--) { [[clients objectAtIndex:count] release]; }
	[clients release], clients = nil;
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[super dealloc];
}


- (void)awakeFromNib
{	
	// Setup the toolbar
	[self setupToolbarForWindow:window];
	
	// Set the footer gradient
	[window setContentBorderThickness:[viewStack frame].origin.y forEdge: NSMinYEdge];
	
	// Set the cell renderers
	NSTableColumn *col = [transferTable tableColumnWithIdentifier:@"transferColumn"];
	TransferCell *cell = [[[TransferCell alloc] init] autorelease];
	[col setDataCell:cell];
	
	[transferTable setIntercellSpacing:NSMakeSize(0, 0)];
	
	// Setup delegates and datasources
	[transferTable setDelegate:self];
	[transferTable setDataSource:self];
	[transferTable sizeToFit];
	
	[menuTable setDelegate:self];
	[menuTable setDataSource:self];
	[menuTable sizeToFit];
	
	// Update the status
	[self updateStatusLabel];
}


- (void)applicationDidFinishLaunching:(NSNotification *)notification 
{
	[self requireSettingsDirectory];
	
	// Register user defaults
	[[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWithObjectsAndKeys:nil, @"lastLaunchedVersion", nil]];
	
	// Check the current version
	NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
	NSString *lastLaunchedVersion = [[NSUserDefaults standardUserDefaults] stringForKey:@"lastLaunchedVersion"];

	NSLog(@"Launched OneWay version %@", version);
	NSLog(@"Last launched version was %@", lastLaunchedVersion);
	
	// Update the plugin source file
	NSFileManager *mgr = [NSFileManager defaultManager];
	NSString * pluginSource = [NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] bundlePath], OWPluginSourceFile];
	[mgr copyPath:pluginSource
		   toPath:[OWPluginDestinationFile stringByExpandingTildeInPath] 
		  handler:nil];
	
	if (![version isEqualToString:lastLaunchedVersion])
	{
		// First time launching the app, or we've updated to a new version
		
		BOOL versionNeedsFinderRestart = [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"OWVersionRequiresFinderRestart"] boolValue];
		
		if (version == nil || versionNeedsFinderRestart)
		{
			// If this is the first time, or an update that requires a Finder restart do it
			welcomeView = [[WelcomeView alloc] initRelativeToWindow:window];
			[NSApp runModalForWindow:[welcomeView window]];
		}
		
		// Update the last launched version to this one
		[[NSUserDefaults standardUserDefaults] setObject:version forKey:@"lastLaunchedVersion"];	
	}
}


/*
 * Applicatoin termination handler, update the context menu items and save all user data (transfers, locations)
 *
 */
- (void)applicationWillTerminate:(NSNotification *)aNotification
{
	NSLog(@"Exiting... Saving user data...");
	
	[self updateContextMenu];
	[self saveUserData];
}


/*
 * Returns an upload client that can be used for a given location. If one already exists it is returned, otherwise
 * a new will be created and returned.
 *
 */
- (id <CurlClient>)clientForLocation:(Location *)location
{
	for (int i = 0; i < [clients count]; i++)
	{
		if (([location type] == OWLocationTypeSFTP && [[clients objectAtIndex:i] isMemberOfClass:[CurlSFTP class]]) ||
			([location type] == OWLocationTypeFTP && [[clients objectAtIndex:i] isMemberOfClass:[CurlFTP class]]))
		{
			return (id <CurlClient>)[clients objectAtIndex:i];
		}
	}
	
	id <CurlClient>newClient;
	
	switch ([location type])
	{
		case OWLocationTypeSFTP:
			newClient = [[[CurlSFTP alloc] init] autorelease];
			break;
			
		case OWLocationTypeFTP:
			newClient = [[[CurlFTP alloc] init] autorelease];
			break;
				
		default:
			NSLog(@"Unknown location type %d in clientForLocation:", [location type]);
			break;
	}
	
	[newClient setDelegate:self];
	[newClient setShowProgress:YES];
	[newClient setVerbose:YES];
	
	[clients addObject:newClient];
	
	return newClient;
}






- (void)startTransfer:(NSArray *)fileList toLocation:(Location *)aLocation
{
	NSLog(@"Starting upload of %d files to %@", [fileList count], [aLocation hostname]);

	[self showTransfersView];
	
	id <CurlClient>client = [self clientForLocation:aLocation];
	
	Upload *record = [client uploadFilesAndDirectories:fileList 
												toHost:[aLocation hostname] 
											  username:[aLocation username]
											  password:[aLocation password]
											 directory:[aLocation directory]
												  port:[[aLocation port] intValue]];

	[transfers addObject:record];
	[transferTable reloadData];
	
	[self updateStatusLabel];
}







- (void)saveUserData
{
	[self requireSettingsDirectory];
	
	// Serialize and save the locations
	[NSKeyedArchiver archiveRootObject:savedLocations 
								toFile:[OWSavedLocationsFile stringByExpandingTildeInPath]];
	
	// Serialize and save the transfers
	[NSKeyedArchiver archiveRootObject:transfers 
								toFile:[OWSavedTransfersFile stringByExpandingTildeInPath]];
}


- (void)updateContextMenu
{	
	[self requireSettingsDirectory];
	
	NSFileManager *mgr = [[NSFileManager alloc] init];
	
	// Save the menu items to a file
	if ([savedLocations count] > 0)
	{
		[mgr createFileAtPath:[OWMenuItemsFile stringByExpandingTildeInPath]
					 contents:nil 
				   attributes:nil];
		
		NSFileHandle *fh = [NSFileHandle fileHandleForWritingAtPath:[OWMenuItemsFile stringByExpandingTildeInPath]];
		NSMutableString *str = [[NSMutableString alloc] init];
		
		for (int i = 0; i < [savedLocations count]; i++)
		{
			Location *rec = [savedLocations objectAtIndex:i];
			if ([rec type] == kSecProtocolTypeSSH)
			{
				[str appendFormat:@"sftp://%@:%@\n", [rec hostname], [rec directory]];
			}
			else if ([rec type] == kSecProtocolTypeFTP)
			{
				[str appendFormat:@"ftp://%@:%@\n", [rec hostname], [rec directory]];
			}
		}
		
		[fh writeData:[str dataUsingEncoding:NSUTF8StringEncoding]];
		[fh closeFile];
	}
	else if ([savedLocations count] == 0 && [mgr fileExistsAtPath:[OWMenuItemsFile stringByExpandingTildeInPath]])
	{
		[mgr removeFileAtPath:[OWMenuItemsFile stringByExpandingTildeInPath] handler:nil];
	}
	
	[mgr release];
}


- (void)updateStatusLabel
{
	int activeTransfers = 0;
	Upload *t;
	
	for (int i = 0; i < [transfers count]; i++)
	{
		t = [transfers objectAtIndex:i];
		if ([t isActive])
			activeTransfers++;
	}
	
	[self setTotalTransfers:[transfers count]];
	[self setTotalActiveTransfers:activeTransfers];
}

#pragma mark Notification Handlers


- (void)handleQueueTransferNotification:(NSNotification *)note
{	
	Location *loc = (Location *)[note object];
	NSArray *filepaths = (NSArray *)[[note userInfo] objectForKey:@"filepaths"];
	
	[window makeKeyAndOrderFront:nil];
	
	[self startTransfer:filepaths toLocation:loc];
}


- (void)handleQueueNewTransferNotification:(NSNotification *)note
{	
	NSArray *filepaths = (NSArray *)[[note userInfo] objectForKey:@"filepaths"];
	
	[window makeKeyAndOrderFront:nil];
	
	[self createLocationAndTransferFiles:filepaths];
}


#pragma mark Location CRUD


- (IBAction)createLocation:(id)sender
{
//	Location *newLocation = [[Location alloc] initWithType:OWLocationTypeSFTP 
//												  hostname:@"" 
//												  username:@"" 
//												  password:@"" 
//												 directory:@"~/"];
//	
//	[locationSheet setSubtitle:[NSString stringWithFormat:@"New Location"]];
//	[locationSheet setLocation:newLocation];
//	[locationSheet setShouldShowSaveOption:NO];
//	
//	[NSApp beginSheet:[locationSheet window]
//	   modalForWindow:window
//		modalDelegate:self
//	   didEndSelector:@selector(locationSheetDidEnd:returnCode:contextInfo:)
//		  contextInfo:OWContextCreateLocation];
//	
//	[newLocation release];
}


- (void)createLocationAndTransferFiles:(NSArray *)fileList
{
	Location *newLocation = [[Location alloc] initWithType:OWLocationTypeSFTP 
												  hostname:@"" 
												  username:@"" 
												  password:@"" 
												 directory:@"~/"];
	NSString *fileString;
	if ([fileList count] == 1)
	{
		fileString = [NSString stringWithFormat:@"\"%@\"", [[[fileList objectAtIndex:0] lastPathComponent] stringWithTruncatingToLength:25]];
	}
	else if ([fileList count] == 2)
	{
		fileString = [NSString stringWithFormat:@"\"%@\" & 1 other", [[[fileList objectAtIndex:0] lastPathComponent] stringWithTruncatingToLength:17]];
	}
	else if ([fileList count] < 99)
	{
		fileString = [NSString stringWithFormat:@"\"%@\" & %d others", [[[fileList objectAtIndex:0] lastPathComponent] stringWithTruncatingToLength:16], [fileList count] - 1];
	}
	else
	{
		fileString = [NSString stringWithFormat:@"\"%@\" & %d others", [[[fileList objectAtIndex:0] lastPathComponent] stringWithTruncatingToLength:15], [fileList count] - 1];		
	}
	
	[locationSheet setSubtitle:[NSString stringWithFormat:@"Upload %@ to New Location", fileString]];
	[locationSheet setLocation:newLocation];
	[locationSheet setFileList:fileList];
	[locationSheet setShouldSaveLocation:YES];
	[locationSheet setShouldShowSaveOption:YES];
		
	[NSApp beginSheet:[locationSheet window]
	   modalForWindow:window
		modalDelegate:self
	   didEndSelector:@selector(locationSheetDidEnd:returnCode:contextInfo:)
		  contextInfo:[NSNumber numberWithInt:OWContextCreateLocationAndTransferFiles]];
	
	[newLocation release];
}




- (void)locationSheetDidEnd:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
    [sheet orderOut:self];

	if (returnCode == 1)
	{
		Location *location = [locationSheet location];
		int context = [(NSNumber *)contextInfo intValue];
		
		switch (context)
		{
			case OWContextCreateLocationAndTransferFiles:			
			{
				NSArray *fileList = [[locationSheet fileList] retain];
				
				if ([locationSheet shouldSaveLocation])
				{
					[savedLocations addObject:location];
					[menuTable reloadData];
					[self updateContextMenu];
					[self saveUserData];
				}

				[self startTransfer:fileList toLocation:location];
				
				break;
			}
				
			default:
				NSLog(@"Unknown context in locationSheetDidEnd:returnCode:contextInfo:");
				break;
				
		}
//		if (contextInfo == OWContextCreateLocation)
//		{
//			[savedLocations addObject:location];
//			[menuTable reloadData];
//			[self updateContextMenu];
//		}
//		else if (contextInfo == OWContextCreateLocationAndTransferFiles)
//		{	
//			if ([locationSheet shouldSaveLocation])
//			{
//				[savedLocations addObject:location];
//				[menuTable reloadData];
//				[self updateContextMenu];
//				[self saveUserData];
//			}
//			NSArray *fileList = [[locationSheet fileList] retain];
//			[self startTransfer:fileList toLocation:location];
//		}
//		else if (contextInfo == OWContextUpdateLocation)
//		{
//			[menuTable reloadData];
//			[self updateContextMenu];			
//		}
//		else if (contextInfo == OWContextUpdateLocationAndTransferFiles)
//		{
//			[menuTable reloadData];
//			[self updateContextMenu];			
//		}
//		else if (contextInfo == OWContextDeleteLocation)
//		{
//			[savedLocations removeObjectAtIndex:[menuTable selectedRow]];
//			[menuTable reloadData];
//			[self updateContextMenu];				
//		}
	}
//	
	[locationSheet setLocation:nil];
	[locationSheet setFileList:nil];
}





- (IBAction)updateLocation:(id)sender
{
//	if ([menuTable selectedRow] > -1)
//	{
//		Location *loc = [savedLocations objectAtIndex:[menuTable selectedRow]];
//		
//		[locationSheet setSubtitle:[NSString stringWithFormat:@"Edit Location"]];
//		[locationSheet setLocation:loc];
//		
//		[NSApp beginSheet:[locationSheet window]
//		   modalForWindow:window
//			modalDelegate:self
//		   didEndSelector:@selector(locationSheetDidEnd:returnCode:contextInfo:)
//			  contextInfo:OWContextUpdateLocation];
//	}
}


- (IBAction)deleteLocation:(id)sender
{
//	if ([menuTable selectedRow] > -1)
//	{
//		Location *loc = [savedLocations objectAtIndex:[menuTable selectedRow]];		
//		NSBeginAlertSheet(@"Confirm Delete", 
//						  @"Delete", 
//						  @"Cancel", 
//						  nil, 
//						  window, 
//						  self, 
//						  @selector(locationSheetDidEnd:returnCode:contextInfo:), 
//						  nil, 
//						  OWContextDeleteLocation, 
//						  [NSString stringWithFormat:@"Are you sure you want to delete \"%@:%@\" from your context menu?", [loc hostname], [loc directory]]);
//	}
}


//- (void)passwordSheetDidEnd:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
//{
//	[sheet orderOut:self];	
	
//	if (returnCode == 1)
//	{
//		id task = (id <UploadTask>)contextInfo;
//		
//		if ([passwordSheet shouldSaveInKeychain])
//		{
//			[task setPasswordFromPrompt:[passwordSheet password]];
//		}
//		
//		[task writeToPrompt:[passwordSheet password]];
//	}
//}

//- (void)hostKeySheetDidEnd:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
//{
//	[sheet orderOut:self];	
//	
//	id task = (AbstractUploadTask *)contextInfo;
//	
//	if (returnCode == 1)
//	{		
//		[task writeToPrompt:@"yes"];
//	}
//	else
//	{
//		[task writeToPrompt:@"no"];
//	}
//}


#pragma mark TransferDelegate methods


//- (void)transfer:(id <TransferRecord>)aRecord requiresAuthentication:(id <UploadTask>)task
//{
//	Location *loc = [aRecord location];
//	NSLog(@"transfer: %@ requiresAuthentication: %@@%@", [aRecord name], [loc username], [loc hostname]);
//	
//	[passwordSheet setTitleString:[NSString stringWithFormat:@"Password for \"%@@%@\"", [loc username], [loc hostname]]];
//	
//	[NSApp beginSheet:[passwordSheet window]
//	   modalForWindow:window
//		modalDelegate:self
//	   didEndSelector:@selector(passwordSheetDidEnd:returnCode:contextInfo:)
//		  contextInfo:task];
//	
//	[[passwordSheet window] makeKeyAndOrderFront:nil];
//	
//	[self updateStatusLabel];
//}

//- (void)transfer:(id <TransferRecord>)aRecord requiresHostKeyAcceptance:(id <UploadTask>)task message:(NSString *)aMessage
//{
//	Location *loc = [aRecord location];
//	
//	NSLog(@"transfer: %@ requiresHostKeyAcceptance: %@", [aRecord name], aMessage);
//
//	NSBeginAlertSheet([NSString stringWithFormat:@"Unknown host key for \"%@\"", [loc hostname]], 
//					  @"Allow", 
//					  @"Deny", 
//					  nil, 
//					  window, 
//					  self, 
//					  @selector(hostKeySheetDidEnd:returnCode:contextInfo:), 
//					  nil, 
//					  task, 
//					  aMessage);
//
//	[self updateStatusLabel];
//}


#pragma mark Toolbar Actions


- (void)stopSelectedTransfers:(id)sender
{	
	//	NSLog(@"Stopping selected transfers...");
	//	int i = [[transferTable selectedRowIndexes] firstIndex];
	
	//	while (i != NSNotFound)
	//	{
	//		id <TransferRecord> record = [transfers objectAtIndex:i];
	//		
	//		if ([record isActiveTransfer])
	//		{		
	//			[[record task] cancelUpload];
	//		}
	//		i = [[transferTable selectedRowIndexes] indexGreaterThanIndex:i];
	//	}
	
	//	[transferTable deselectAll:nil];
	//	[transferTable reloadData];	
	//	[self updateStatusLabel];
}


- (void)clearSelectedTransfers:(id)sender
{	
	NSLog(@"Clearing selected transfers...");
	int i = [[transferTable selectedRowIndexes] firstIndex];
	NSMutableArray *discardedItems = [NSMutableArray array];
	
	while (i != NSNotFound)
	{
		//		id <TransferRecord> record = [transfers objectAtIndex:i];
		//		
		//		if (![record isActiveTransfer])
		//		{
		//			[discardedItems addObject:record];
		//			i = [[transferTable selectedRowIndexes] indexGreaterThanIndex:i];
		//		}
	}
	
	[transfers removeObjectsInArray:discardedItems];	
	[transferTable deselectAll:nil];
	[transferTable reloadData];
	[self updateStatusLabel];
}


- (void)showTransfersView
{
	[viewStack selectTabViewItemAtIndex:0]; 
}

- (void)showLocationsView
{
	[viewStack selectTabViewItemAtIndex:1];
}


#pragma mark TableView Delegate methods


- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
	int tag = [aTableView tag];
	if (tag == OWTableViewTransfers)
	{
		return [transfers count];
	}
	else if (tag == OWTableViewMenuItems)
	{
		return [savedLocations count];
	}
	return -1;
}


- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
//	int tag = [aTableView tag];
//	if (tag == OWTableViewMenuItems)
//	{
//		Location *location = [savedLocations objectAtIndex:rowIndex];
//		NSString *typeString = nil;
//		switch ([location type])
//		{
//			case OWLocationTypeSFTP: 
//				typeString = [NSString stringWithString:@"sftp"]; 
//				break;
//			case OWLocationTypeSCP: 
//				typeString = [NSString stringWithString:@"scp"]; 
//				break;
//		}
//		return [NSString stringWithFormat:@"%@://%@  %@", typeString, [location hostname], [location directory]];
//	}
//	else if (tag == OWTableViewTransfers)
//	{
////		return (id <TransferRecord>)[transfers objectAtIndex:rowIndex];
//	}
	return nil;
}


#pragma mark Convenience Methods


- (void)requireSettingsDirectory
{
	// Make sure the settings directory exists and create it if it doesn't.
	NSFileManager *mgr = [[NSFileManager alloc] init];

	if (![mgr fileExistsAtPath:[OWSettingsDirectory stringByExpandingTildeInPath]])
	{
		[mgr createDirectoryAtPath:[OWSettingsDirectory stringByExpandingTildeInPath]
						attributes:nil];
	}
	if (![mgr fileExistsAtPath:[OWPluginDirectory stringByExpandingTildeInPath]])
	{
		[mgr createDirectoryAtPath:[OWPluginDirectory stringByExpandingTildeInPath]
						attributes:nil];
	}
	[mgr release];
}


@end