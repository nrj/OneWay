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
#import "LocationCell.h"
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
	[self setupToolbar:OWTransferToolbarIdentifier forWindow:window];
	
	// Set the footer gradient
	[window setContentBorderThickness:[viewStack frame].origin.y forEdge: NSMinYEdge];
	
	// Set the cell renderers
	NSTableColumn *transferColumn = [transferTable tableColumnWithIdentifier:@"transferColumn"];
	TransferCell *transferCell = [[[TransferCell alloc] init] autorelease];
	[transferColumn setDataCell:transferCell];
	
	[transferTable setIntercellSpacing:NSMakeSize(0, 0)];
	
	NSTableColumn *locationColumn = [menuTable tableColumnWithIdentifier:@"locationColumn"];
	LocationCell *locationCell = [[[LocationCell alloc] init] autorelease];
	[locationColumn setDataCell:locationCell];
	
	[menuTable setIntercellSpacing:NSMakeSize(0, 0)];
	
	
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
	[newClient setVerbose:NO];
	
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
	
	
	[record setStatusMessage:@"Queued"];
	
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
			if ([rec type] == OWLocationTypeSFTP)
			{
				[str appendFormat:@"sftp://%@/%@\n", [rec hostname], [rec directory]];
			}
			else if ([rec type] == OWLocationTypeFTP)
			{
				[str appendFormat:@"ftp://%@/%@\n", [rec hostname], [rec directory]];
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



#pragma mark UploadDelegate methods



/*
 * Called when the upload starts the connection process.
 */
- (void)uploadIsConnecting:(Upload *)record
{
	NSLog(@"uploadIsConnecting");
	
	[record setStatusMessage:[NSString stringWithFormat:@"Connecting to %@ ...", [record hostname]]];
	
	[transferTable reloadData];
	[self updateStatusLabel];
}



/*
 * Called when the upload has started.
 */ 
- (void)uploadDidBegin:(Upload *)record
{
	NSLog(@"uploadDidBegin");
	
	[record setStatusMessage:[NSString stringWithFormat:@"Uploading %d files to %@", [record totalFiles], [record hostname]]];
	
	[transferTable reloadData];
	[self updateStatusLabel];
}



/*
 * Called when the upload has progressed, 1-100%.
 */
- (void)uploadDidProgress:(Upload *)record toPercent:(NSNumber *)percent
{
	NSLog(@"uploadDidProgress:toPercent:%@", percent);
	
	[record setStatusMessage:[NSString stringWithFormat:@"Uploading (%@%%) %d files to %@", percent, [record totalFiles], [record hostname]]];
	
	[transferTable reloadData];
}



/*
 * Called when the upload process has finished successfully.
 */
- (void)uploadDidFinish:(Upload *)record
{
	NSLog(@"uploadDidFinish");
	
	[record setStatusMessage:@"Finished"];
	
	[transferTable reloadData];
	[self updateStatusLabel];
}



/*
 * Called if the upload was cancelled.
 */
- (void)uploadWasCancelled:(Upload *)record
{
	NSLog(@"uploadWasCancelled");
	
	[record setStatusMessage:@"Cancelled"];
	
	[transferTable reloadData];
	[self updateStatusLabel];
}



/*
 * Called if the upload has failed because of authentication.
 */
- (void)uploadDidFailAuthentication:(Upload *)record message:(NSString *)message
{
	NSLog(@"uploadDidFailAuthentication: %@", message);
	
	[record setStatusMessage:message];
	
	[transferTable reloadData];
	[self updateStatusLabel];
}



/*
 * Called when the upload has failed. The message will contain a useful description of what went wrong.
 */
- (void)uploadDidFail:(Upload *)record message:(NSString *)message
{
	NSLog(@"uploadDidFail: %@", message);		
	
	[record setStatusMessage:message];
	
	[transferTable reloadData];	
	[self updateStatusLabel];
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
	int tag = [aTableView tag];
	if (tag == OWTableViewTransfers)
	{
		return (Upload *)[transfers objectAtIndex:rowIndex];
	}
	else if (tag == OWTableViewMenuItems)
	{
		return (Location *)[savedLocations objectAtIndex:rowIndex];
	}
	
	return nil;
}



#pragma mark Toolbar Actions



- (void)stopSelectedTransfers:(id)sender
{	
	NSLog(@"Stopping selected transfers...");
	
	int i = [[transferTable selectedRowIndexes] firstIndex];
	
	while (i != NSNotFound)
	{
		Upload *record = (Upload *)[transfers objectAtIndex:i];
		
		if ([record isActive])
		{		
			[record setCancelled:YES];
		}
		
		i = [[transferTable selectedRowIndexes] indexGreaterThanIndex:i];
	}
	
	[transferTable deselectAll:nil];
	[transferTable reloadData];	
	[self updateStatusLabel];
}



- (void)clearSelectedTransfers:(id)sender
{	
	NSLog(@"Clearing selected transfers...");
	
	int i = [[transferTable selectedRowIndexes] firstIndex];
	NSMutableArray *discardedItems = [NSMutableArray array];
	
	while (i != NSNotFound)
	{
		Upload *record = (Upload *)[transfers objectAtIndex:i];
		
		if (![record isActive])
		{
			[discardedItems addObject:record];
			i = [[transferTable selectedRowIndexes] indexGreaterThanIndex:i];
		}
	}
	
	[transfers removeObjectsInArray:discardedItems];	
	[transferTable deselectAll:nil];
	[transferTable reloadData];
	[self updateStatusLabel];
}



- (void)showTransfersView
{
	[self setupToolbar:OWTransferToolbarIdentifier forWindow:window];
	[viewStack selectTabViewItemAtIndex:0]; 
}



- (void)showLocationsView
{
	[self setupToolbar:OWLocationToolbarIdentifier forWindow:window];
	[viewStack selectTabViewItemAtIndex:1];
}



#pragma mark Location CRUD



- (IBAction)createLocation:(id)sender
{
	Location *newLocation = [[Location alloc] initWithType:OWLocationTypeSFTP 
												  hostname:@"" 
												  username:@"" 
												  password:@"" 
												 directory:@"~/"];
	
	[locationSheet setSubtitle:[NSString stringWithFormat:@"New Location"]];
	[locationSheet setLocation:newLocation];
	[locationSheet setShouldShowSaveOption:NO];
	[locationSheet setShouldSaveLocation:YES];
	
	[NSApp beginSheet:[locationSheet window]
	   modalForWindow:window
		modalDelegate:self
	   didEndSelector:@selector(locationSheetDidEnd:returnCode:contextInfo:)
		  contextInfo:[NSNumber numberWithInt:OWContextCreateLocation]];
	
	[newLocation release];
}



- (void)createLocationAndTransferFiles:(NSArray *)fileList
{
	Location *newLocation = [[Location alloc] initWithType:OWLocationTypeSFTP 
												  hostname:@"localhost" 
												  username:@"nrj"
												  password:@"yaynocops"
												 directory:@"~/"];

	[locationSheet setFileList:fileList];
	[locationSheet setLocation:newLocation];
	[locationSheet setShouldShowSaveOption:YES];
	[locationSheet setShouldSaveLocation:YES];
		
	[NSApp beginSheet:[locationSheet window]
	   modalForWindow:window
		modalDelegate:self
	   didEndSelector:@selector(locationSheetDidEnd:returnCode:contextInfo:)
		  contextInfo:[NSNumber numberWithInt:OWContextCreateLocationAndTransferFiles]];
	
	[newLocation release];
}



- (IBAction)updateLocation:(id)sender
{
	if ([menuTable selectedRow] > -1)
	{
		Location *loc = [savedLocations objectAtIndex:[menuTable selectedRow]];
		
		[locationSheet setSubtitle:[NSString stringWithFormat:@"Edit Location"]];
		[locationSheet setLocation:loc];
		
		[NSApp beginSheet:[locationSheet window]
		   modalForWindow:window
			modalDelegate:self
		   didEndSelector:@selector(locationSheetDidEnd:returnCode:contextInfo:)
			  contextInfo:[NSNumber numberWithInt:OWContextUpdateLocation]];
	}
}



- (IBAction)deleteLocation:(id)sender
{
	if ([menuTable selectedRow] > -1)
	{
		Location *loc = [savedLocations objectAtIndex:[menuTable selectedRow]];		
		NSBeginAlertSheet(@"Confirm Delete", 
						  @"Delete", 
						  @"Cancel", 
						  nil, 
						  window, 
						  self, 
						  @selector(locationSheetDidEnd:returnCode:contextInfo:), 
						  nil, 
						  [NSNumber numberWithInt:OWContextDeleteLocation], 
						  [NSString stringWithFormat:@"Are you sure you want to delete \"%@:%@\" from your context menu?", [loc hostname], [loc directory]]);
	}
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
			// Create a new location, and transfer files to it.
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
			
			// Create a new location.
			case OWContextCreateLocation:
			{
				[savedLocations addObject:location];
				[menuTable reloadData];
				[self updateContextMenu];
				break;
			}

			// Updated an existing location
			case OWContextUpdateLocation:
			{
				[menuTable reloadData];
				[self updateContextMenu];
				break;
			}
				
			// Delete a location
			case OWContextDeleteLocation:
			{
				[savedLocations removeObjectAtIndex:[menuTable selectedRow]];
				[menuTable reloadData];
				[self updateContextMenu];
				break;
			}
			
			// Invalid context...	
			default:
				NSLog(@"Unknown context in locationSheetDidEnd:returnCode:contextInfo:");
				break;
		}
	}
	
	[locationSheet reset];
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



- (void)runUploadTest
{	
	NSLog(@"Running Test");
	Location *l = [savedLocations objectAtIndex:0];
	[self startTransfer:[NSArray arrayWithObject:@"/Users/nrj/Desktop/test-upload"] toLocation:l];
}


@end