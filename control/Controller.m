//
//  Controller.m
//  OneWay
//
//  Copyright 2010 Nick Jensen <http://goto11.net>
//

#import "Controller.h"
#import "Controller+Toolbar.h"
#import "Controller+Growl.h"
#import "Controller+TransferMenu.h"
#import "OWConstants.h"
#import "FinderService.h"
#import "FinderItem.h"
#import "Location.h"
#import "LocationCell.h"
#import "TransferCell.h"
#import "WelcomeView.h"
#import "LocationSheet.h"
#import "UploadSheet.h"
#import "PasswordSheet.h"
#import "FailureSheet.h"
#import "EMKeychain.h"
#import "UploadName.h"
#import "LocationMessage.h"
#import "SystemVersion.h"
#import "MigrationUtil.h"


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
		
		
		// Contains uploads whos passwords we should save if they are correct
		passwordsToSave = [[NSMapTable alloc] initWithKeyOptions:NSPointerFunctionsZeroingWeakMemory 
													valueOptions:NSPointerFunctionsZeroingWeakMemory 
														capacity:-1];
		
		// Holds the users choices for how to handle unknown/mismatched host keys
		knownHosts		= [[NSMapTable alloc] initWithKeyOptions:NSPointerFunctionsZeroingWeakMemory
												valueOptions:NSPointerFunctionsZeroingWeakMemory 
														capacity:-1];
		
		// TODO, use NSPointerArray with weak keys for this too
		failedTransfers = [[NSMutableArray alloc] init];
		
		// Queue of transfers that are waiting to be retried
		retryQueue = [[NSPointerArray alloc] initWithOptions:NSPointerFunctionsZeroingWeakMemory];
		
		
		
		// Init the Sheets
		locationSheet = [[LocationSheet alloc] init];
		passwordSheet = [[PasswordSheet alloc] init];
		failureSheet = [[FailureSheet alloc] init];
		
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
	[failedTransfers release], failedTransfers = nil;
	[passwordsToSave release], passwordsToSave = nil;
	
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
	[self updateActiveTransfersLabel];
	
	// Init Growl
	[self initGrowl];
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
		
		BOOL versionNeedsFinderRestart = [[[[NSBundle mainBundle] infoDictionary] 
										   objectForKey:@"OWVersionRequiresFinderRestart"] boolValue];
		
		if ((version == nil || versionNeedsFinderRestart) && [SystemVersion isLeopard])
		{
			// If this is the first time, or an update that requires a Finder restart do it
			welcomeView = [[WelcomeView alloc] initRelativeToWindow:window];
			[NSApp runModalForWindow:[welcomeView window]];
		}
				
		// Run migration code, if any.
		[MigrationUtil migrateFromVersion:lastLaunchedVersion 
								toVersion:version 
							   controller:self];
		
		// Update the last launched version to this one
		[[NSUserDefaults standardUserDefaults] setObject:version forKey:@"lastLaunchedVersion"];
	}
	
	[FinderService updateForLocations:savedLocations];
	[FinderService reload];
}



/*
 * Applicatoin termination handler, update the context menu items and save all user data (transfers, locations)
 *
 */
- (void)applicationWillTerminate:(NSNotification *)aNotification
{
	[self updateContextMenu];
	[self saveUserData];
}



/*
 * Returns an upload client that can be used for a given location. If one already exists it is returned, otherwise
 * a new will be created and returned.
 *
 */
- (id <CurlClient>)uploadClientForType:(int)clientType
{
	for (int i = 0; i < [clients count]; i++)
	{
		if (clientType == [(id <CurlClient>)[clients objectAtIndex:i] clientType]) 
		{
			return (id <CurlClient>)[clients objectAtIndex:i];
		}
	}
	
	id <CurlClient>newClient;
	
	switch (clientType)
	{
		case CURL_CLIENT_SFTP:
			newClient = [[[CurlSFTP alloc] init] autorelease];
			break;
			
		case CURL_CLIENT_FTP:
			newClient = [[[CurlFTP alloc] init] autorelease];
			break;
			
		case CURL_CLIENT_S3:
			newClient = [[[CurlS3 alloc] init] autorelease];
			break;
				
		default:
			NSLog(@"uploadClientForLocation - Unknown Type %d",  clientType);
			return nil;
	}
	
	[newClient setDelegate:self];
	[newClient setShowProgress:YES];
	[newClient setVerbose:NO];
	
	[clients addObject:newClient];
	
	return newClient;
}



- (Upload *)startUpload:(NSArray *)fileList toLocation:(Location *)location
{
	NSLog(@"Starting upload of %d files to %@", [fileList count], [location hostname]);

	[self showTransfersView:nil];
	
	id <CurlClient>client = [self uploadClientForType:[location type]];
	
	if ([location password] == nil || [[location password] isEqualToString:@""])
	{
		[location setPassword:[self getPasswordFromKeychain:[location hostname] 
												   username:[location username] 
													   port:[location port] 
												   protocol:[location protocol]]];
	}
	
	Upload *record = [client uploadFilesAndDirectories:fileList 
												toHost:[location hostname] 
											  username:[location username]
											  password:[location password]
											 directory:[location directory]
												  port:[location port]];
	
	if ([location usePublicKeyAuth])
	{
		[record setUsePublicKeyAuth:YES];
		[record setPrivateKeyFile:[[location privateKeyFile] stringByExpandingTildeInPath]];
		[record setPublicKeyFile:[NSString stringWithFormat:@"%@.pub", [record privateKeyFile]]];
	}
	
	[record setName:[UploadName nameForFileList:fileList]];
	[record setStatusMessage:@"Queued"];
	
	if ([location webAccessible])
	{
		[record setUrl:[location baseUrl]];
	}

	[transferTable reloadData];
	[self updateActiveTransfersLabel];
	
	return record;
}



- (void)retryUpload:(Upload *)record
{	
	[self showTransfersView:nil];

	id <CurlClient>client = [self uploadClientForType:[record clientType]];
	
	[client upload:record];
	
	[record setStatusMessage:@"Queued"];
	
	[transferTable reloadData];	
	
	[self updateActiveTransfersLabel];
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
			Location *loc = [savedLocations objectAtIndex:i];
			
			[str appendFormat:@"%@\n", [FinderItem labelForLocation:loc]];
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


- (void)updateActiveTransfersLabel
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
	
	Upload *upload = [self startUpload:filepaths toLocation:loc];
	
	[transfers insertObject:upload atIndex:0];
	[transferTable reloadData];
}


- (void)handleQueueNewTransferNotification:(NSNotification *)note
{	
	NSArray *filepaths = (NSArray *)[[note userInfo] objectForKey:@"filepaths"];
	
	[window makeKeyAndOrderFront:nil];
	
	[self createLocationAndTransferFiles:filepaths];
}


#pragma mark UploadDelegate methods


/*
 * Called when curl starts the connection process.
 */
- (void)curlIsConnecting:(RemoteObject *)record
{	
	[record setStatusMessage:[NSString stringWithFormat:@"Connecting to %@ ...", [record hostname]]];
	
	[transferTable reloadData];
	[self updateActiveTransfersLabel];
}


/*
 * Called when curl has connected to the host.
 */
- (void)curlDidConnect:(RemoteObject *)record
{
	[record setStatusMessage:[NSString stringWithFormat:@"Connected to %@ ...", [record hostname]]];
	
	[transferTable reloadData];	
	[self updateActiveTransfersLabel];
}


/*
 * Called when the upload has started.
 */ 
- (void)uploadDidBegin:(Upload *)record
{
	[record setStatusMessage:[NSString stringWithFormat:@"Uploading (0%) %d files to %@", [record totalFiles], [record hostname]]];
	
	// password was correct, add it to the keychain if we're supposed to
	if ([passwordsToSave objectForKey:record]) 	
	{
		[self savePasswordToKeychain:[record password] 
						 forHostname:[record hostname] 
							username:[record username] 
								port:[record port] 
							protocol:[record protocol]];
		
		[passwordsToSave removeObjectForKey:record];
	}
	
	[self runAllQueuedUploadsWithURI:[record uri]];
	
	[transferTable reloadData];
	[self updateActiveTransfersLabel];
}



/*
 * Called when the upload has progressed, 1-100%.
 */
- (void)uploadDidProgress:(Upload *)record toPercent:(NSNumber *)percent
{	
	[record setStatusMessage:[NSString stringWithFormat:@"Uploading (%@%%) %d files to %@", percent, [record totalFiles], [record hostname]]];
	
	[transferTable reloadData];
}



/*
 * Called when the upload process has finished successfully.
 */
- (void)uploadDidFinish:(Upload *)record
{		
	[self displayGrowlNotification:@"Upload Finished" 
						   message:[NSString stringWithFormat:@"Finished uploading %d files to %@", 
									[record totalFiles], [record hostname]]];
	
	[record setStatusMessage:@"Finished"];
	
	[transferTable reloadData];
	[self updateActiveTransfersLabel];
}



/*
 * Called if the upload was cancelled.
 */
- (void)uploadWasCancelled:(Upload *)record
{	
	[record setStatusMessage:@"Cancelled"];
	
	[transferTable reloadData];
	[self updateActiveTransfersLabel];
}


/*
 * Called when the upload has failed. The message will contain a useful description of what went wrong.
 */
- (void)uploadDidFail:(Upload *)record message:(NSString *)message
{	
	NSLog(@"Upload Failed: %d %@", [record status], message);
	
	if ([record status] == TRANSFER_STATUS_FAILED)
	{
		[self displayGrowlNotification:@"Upload Failed" message:message];
	}
	
	[record setStatusMessage:message];
	
	[transferTable reloadData];	
	
	[failedTransfers addObject:record];

	if ([window attachedSheet] == nil)
	{
		[self displayNextError];
	}
	
	[self updateActiveTransfersLabel];
}



/*
 * Called when the remote host key is unknown.
 */
- (int)acceptUnknownHostFingerprint:(NSString *)fingerprint forUpload:(Upload *)record;
{	
	int choice = CURLKHSTAT_DEFER;
	
	if ([knownHosts objectForKey:record])
	{
		choice = [[knownHosts objectForKey:record] intValue];

		[knownHosts removeObjectForKey:record];
	}
	else
	{
		NSBeginAlertSheet([NSString stringWithFormat:@"The host '%@' is unknown to this system.", [record hostname]], 
						  @"Yes, add to known hosts", 
						  @"No", 
						  @"Yes",
						  window, 
						  self, 
						  @selector(hostKeySheetDidEnd:returnCode:contextInfo:), 
						  nil, 
						  record, 
						  [NSString stringWithFormat:@"RSA key fingerprint is %@.\n\nAre you sure you want to continue connecting?", fingerprint]);
	}
	
	[self updateActiveTransfersLabel];
	
	return choice;
}



/*
 * Called when the remote host key is unknown.
 */
- (int)acceptMismatchedHostFingerprint:(NSString *)fingerprint forUpload:(Upload *)record;
{
	int choice = CURLKHSTAT_DEFER;
	
	if ([knownHosts objectForKey:record])
	{
		choice = [[knownHosts objectForKey:record] intValue];
		
		[knownHosts removeObjectForKey:record];
	}
	else
	{
		NSBeginAlertSheet([NSString stringWithFormat:@"WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED!"], 
						  @"Yes, update known hosts", 
						  @"No", 
						  @"Yes", 
						  window, 
						  self, 
						  @selector(hostKeySheetDidEnd:returnCode:contextInfo:), 
						  nil, 
						  record, 
						  [NSString stringWithFormat:@"Someone could be eavesdropping on you right now (man-in-the-middle attack)! It is also possible that the RSA host key has just been changed. The fingerprint for the RSA key sent by '%@' is %@.\n\nAre you sure you want to continue connecting?", [record hostname], fingerprint]);
	}
	
	[self updateActiveTransfersLabel];
	
	return choice;
}


#pragma mark Sheet Handlers


- (void)locationSheetDidEnd:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{	
	if (returnCode == 1)
	{
		Location *location = [locationSheet location];
		NSArray *fileList = [[locationSheet fileList] retain];
		int context = [(NSNumber *)contextInfo intValue];
		
		switch (context)
		{
			// Create a new location, and transfer files to it.
			case OWContextCreateLocationAndTransferFiles:			
			{
				if ([locationSheet shouldSaveLocation])
				{
					[savedLocations addObject:location];
					
					[FinderService createServiceForLocation:location 
													atIndex:[savedLocations count] - 1];
					[FinderService reload];
				}

				Upload *upload = [self startUpload:fileList toLocation:location];
				
				if ([location savePassword])
				{
					[passwordsToSave setObject:[NSNumber numberWithInt:1] 
										forKey:upload];
				}
				
				[transfers insertObject:upload atIndex:0];
				
				break;
			}
				
			// Create a new location.
			case OWContextCreateLocation:
			{
				[savedLocations addObject:location];
				
				[FinderService createServiceForLocation:location 
												atIndex:[savedLocations count] - 1];
				[FinderService reload];
				
				break;
			}

				
			// Delete a location
			case OWContextDeleteLocation:
			{				
				[FinderService removeServiceAtIndex:[savedLocations count] - 1];				
				[savedLocations removeObjectAtIndex:[menuTable selectedRow]];
				[FinderService reload];
				break;
			}
				
			
			// Updated an existing location
			case OWContextUpdateLocation:
			{
				[FinderService updateForLocations:savedLocations];
				[FinderService reload];
				break;
			}
			
				
			default:
				NSLog(@"Unknown context in locationSheetDidEnd:returnCode:contextInfo:");
				break;
		}
		
		[transferTable reloadData];
		[menuTable reloadData];
		
		[self updateContextMenu];
		[self saveUserData];
	}
}


- (void)hostKeySheetDidEnd:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
	Upload *record = (Upload *)contextInfo;
	
	if (returnCode == 1)   // Add to known_hosts
	{
		[knownHosts setObject:[NSNumber numberWithInt:CURLKHSTAT_FINE_ADD_TO_FILE] 
					   forKey:record];
	}
	else if (returnCode == -1) // Continue.
	{
		[knownHosts setObject:[NSNumber numberWithInt:CURLKHSTAT_FINE] 
					   forKey:record];		
	}
	else
	{
		[self cancelQueuedUploadsWithURI:[record uri] 
								  status:[record status] 
								 message:[record statusMessage]];
		return;
	}
	
	[self retryUpload:record];
}


- (void)passwordSheetDidEnd:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{	
	Upload *upload = [passwordSheet upload];
	
	if (returnCode == 1)		// Try Again
	{
		if ([passwordSheet savePassword])
		{
			[passwordsToSave setObject:[NSNumber numberWithInt:1] 
								forKey:upload];
		}

		[self updateQueuedUploadsUsername:[upload username] 
							  andPassword:[upload password]
								  withURI:[upload uri]];
	
		[self retryUpload:upload];
	}
	else if (returnCode == 0)	// Cancel
	{
		[self runNextQueuedUploadWithURI:[upload uri]];
	}
	else						// Cancel All
	{	
		[self cancelQueuedUploadsWithURI:[upload uri] 
								  status:[upload status] 
								 message:[upload statusMessage]];
	}

	
	[transferTable reloadData];
	
	[self displayNextError];
}


- (void)failureSheetDidEnd:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{		
	Upload *record = [failureSheet upload];
	
	if (returnCode == 1)		// Try Again
	{		
		[self retryUpload:record];
	}
	else if (returnCode == 0)	// Cancel
	{
		[self runNextQueuedUploadWithURI:[record uri]];
	}
	else						// Cancel All
	{
		[self cancelQueuedUploadsWithURI:[record uri] 
								  status:[record status] 
								 message:[record statusMessage]];
	}
	
	[transferTable reloadData];
	
	[self displayNextError];
}


- (void)displayNextError
{	
	if ([failedTransfers count] > 0)
	{
		Upload *record = [failedTransfers objectAtIndex:0];
		id <UploadSheet>sheet = nil;
		SEL callback = nil;
		int numberInQueue = [self numberOfQueuedUploadsForURI:[record uri]];
		
		switch ([record status])
		{
			case TRANSFER_STATUS_LOGIN_DENIED:
				sheet = passwordSheet;
				callback = @selector(passwordSheetDidEnd:returnCode:contextInfo:);
				break;
				
			default:
				sheet = failureSheet;
				callback = @selector(failureSheetDidEnd:returnCode:contextInfo:);
				break;
		}
		
		[sheet setNumberInQueue:numberInQueue];
		[sheet setUpload:record];
		
		[failedTransfers removeObjectAtIndex:0];
		
		[NSApp beginSheet:[sheet window]
		   modalForWindow:window
			modalDelegate:self
		   didEndSelector:callback
			  contextInfo:nil];
	}
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


- (IBAction)retrySelectedTransfers:(id)sender
{	
	NSLog(@"Retrying selected transfers...");
	
	int i = [[transferTable selectedRowIndexes] firstIndex];
	
	NSMapTable *selectedTransfers = [NSMapTable mapTableWithWeakToWeakObjects]; 

	while (i != NSNotFound)
	{
		Upload *record = (Upload *)[transfers objectAtIndex:i];
		
		if (![selectedTransfers objectForKey:[record uri]])
		{
			[selectedTransfers setObject:record forKey:[record uri]];
			[self retryUpload:record];
		}
		else
		{
			[retryQueue addPointer:record];
			[record setStatus:TRANSFER_STATUS_QUEUED];
			[record setStatusMessage:@"Queued"];
		}
		
		i = [[transferTable selectedRowIndexes] indexGreaterThanIndex:i];
	}
									 
	[transferTable reloadData];	
	
	[self updateActiveTransfersLabel];
}


- (IBAction)stopSelectedTransfers:(id)sender
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
	[self updateActiveTransfersLabel];
}



- (IBAction)clearSelectedTransfers:(id)sender
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
		}
		
		i = [[transferTable selectedRowIndexes] indexGreaterThanIndex:i];
	}
	
	[transfers removeObjectsInArray:discardedItems];	
	[transferTable deselectAll:nil];
	[transferTable reloadData];
	[self updateActiveTransfersLabel];
}



- (IBAction)clearAllTransfers:(id)sender
{	
	NSLog(@"Clearing all active transfers...");
	
	NSMutableArray *discardedItems = [NSMutableArray array];
	
	for (int i = 0; i < [transfers count]; i++)
	{
		Upload *record = (Upload *)[transfers objectAtIndex:i];
		
		if (![record isActive])
		{
			[discardedItems addObject:record];
		}
	}
	
	[transfers removeObjectsInArray:discardedItems];	
	[transferTable deselectAll:nil];
	[transferTable reloadData];
	[self updateActiveTransfersLabel];
}



- (void)toggleView:(id)sender
{	
	int selected = [toggleView selectedSegment];
	
	switch (selected)
	{
		case 0:
			[self showTransfersView:nil];
			break;
		case 1:
			[self showLocationsView:nil];
			break;
		default:
			break;
	}
}


- (IBAction)bringToFront:(id)sender
{
	[window makeKeyAndOrderFront:nil];
}

- (IBAction)showTransfersView:(id)sender
{
	[self bringToFront:nil];
	[toggleView setSelectedSegment:0];
	[viewStack selectTabViewItemAtIndex:0];
	[self setupToolbar:OWTransferToolbarIdentifier forWindow:window];
}


- (IBAction)showLocationsView:(id)sender
{	
	[self bringToFront:nil];
	[toggleView setSelectedSegment:1];
	[viewStack selectTabViewItemAtIndex:1];
	[self setupToolbar:OWLocationToolbarIdentifier forWindow:window];
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


#pragma mark Keychain Functions


- (NSString *)getPasswordFromKeychain:(NSString *)hostname username:(NSString *)username port:(int)port protocol:(SecProtocolType)protocol
{
	EMInternetKeychainItem *keychainItem = [EMInternetKeychainItem internetKeychainItemForServer:hostname 
																					withUsername:username
																							path:@""
																							port:port 
																						protocol:protocol];
	
	return [keychainItem password] ? [keychainItem password] : @"";	
}



- (void)savePasswordToKeychain:(NSString *)password forHostname:(NSString *)hostname username:(NSString *)username port:(int)port protocol:(SecProtocolType)protocol
{
	[EMInternetKeychainItem addInternetKeychainItemForServer:hostname 
												withUsername:username
													password:password
														path:@""
														port:port
													protocol:protocol];
}




#pragma mark Transfer Queue Functions


- (void)updateQueuedUploadsUsername:(NSString *)username andPassword:(NSString *)password withURI:(NSString *)uri
{
	for (int i = 0; i < [retryQueue count]; i++)
	{
		Upload *queuedUpload = [retryQueue pointerAtIndex:i];
		
		if ([[queuedUpload uri] isEqualToString:uri])
		{
			[queuedUpload setUsername:username];
			[queuedUpload setPassword:password];
		}
	}		
}


- (void)runAllQueuedUploadsWithURI:(NSString *)uri
{
	int i = 0;
	while (i < [retryQueue count])
	{
		Upload *queuedUpload = [retryQueue pointerAtIndex:i];

		if ([[queuedUpload uri] isEqualToString:uri])
		{
			[self retryUpload:queuedUpload];
			[retryQueue removePointerAtIndex:i];
			continue;
		}
		
		i++;
	}	
}


- (void)runNextQueuedUploadWithURI:(NSString *)uri
{
	int i = 0;
	while (i < [retryQueue count])
	{
		Upload *queuedUpload = [retryQueue pointerAtIndex:i];
		
		if ([[queuedUpload uri] isEqualToString:uri])
		{
			[self retryUpload:queuedUpload];
			[retryQueue removePointerAtIndex:i];
			return;
		}
		
		i++;
	}	
}


- (int)numberOfQueuedUploadsForURI:(NSString *)uri
{
	int total = 0;
	
	for (int i = 0; i < [retryQueue count]; i++)
	{
		Upload *queuedUpload = [retryQueue pointerAtIndex:i];
		
		if ([[queuedUpload uri] isEqualToString:uri])
		{
			total++;
		}
	}
	
	return total;
}


- (void)cancelQueuedUploadsWithURI:(NSString *)uri status:(int)status message:(NSString *)message
{
	int i = 0;
	while (i < [retryQueue count])
	{
		Upload *queuedUpload = [retryQueue pointerAtIndex:i];
		
		if ([[queuedUpload uri] isEqualToString:uri])
		{
			[queuedUpload setStatus:status];
			[queuedUpload setStatusMessage:message];
			[retryQueue removePointerAtIndex:i];
			continue;
		}
		 
		i++;
	}	
}


#pragma mark Location CRUD


- (IBAction)createLocation:(id)sender
{
	[self showLocationsView:nil];
	
	Location *newLocation = [[Location alloc] initWithType:CURL_CLIENT_SFTP 
												  hostname:@"" 
												  username:@"" 
												  password:@"" 
												 directory:@"~/"];
	
	[locationSheet setMessage:[LocationMessage newLocationMessage]];
	[locationSheet setShouldShowSaveOption:NO];
	[locationSheet setShouldSaveLocation:YES];
	
	[locationSheet setLocation:newLocation];
	
	[NSApp beginSheet:[locationSheet window]
	   modalForWindow:window
		modalDelegate:self
	   didEndSelector:@selector(locationSheetDidEnd:returnCode:contextInfo:)
		  contextInfo:[NSNumber numberWithInt:OWContextCreateLocation]];
	
	[newLocation release];
}



- (void)createLocationAndTransferFiles:(NSArray *)fileList
{
	Location *newLocation = [[Location alloc] initWithType:CURL_CLIENT_SFTP 
												  hostname:@"" 
												  username:@""
												  password:@""
												 directory:@"~/"];
	
	[locationSheet setMessage:[LocationMessage uploadFilesToNewLocationMessage:fileList]];
	[locationSheet setShouldShowSaveOption:YES];
	[locationSheet setShouldSaveLocation:YES];
	
	[locationSheet setFileList:fileList];
	[locationSheet setLocation:newLocation];
	
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
		
		[locationSheet setMessage:[LocationMessage editLocationMessage]];
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

@end