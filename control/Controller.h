//
//  Controller.h
//  OneWay
//
//  Created by nrj on 7/18/09.
//  Copyright 2009. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <objective-curl/objective-curl.h>

@class Location, WelcomeView, LocationSheet, PasswordSheet, FailureSheet;

@interface Controller : NSObject 
{	
	IBOutlet NSWindow *window;
	IBOutlet NSDrawer *drawer;
	
	NSMutableArray *clients;
	NSMutableArray *transfers;
	NSMutableArray *savedLocations;	
	
	WelcomeView *welcomeView;
	LocationSheet *locationSheet;
	PasswordSheet *passwordSheet;
	FailureSheet *failureSheet;
	
	IBOutlet NSTabView *viewStack;
	IBOutlet NSTableView *transferTable;
	IBOutlet NSTableView *menuTable;
	
	IBOutlet NSButton *createButton;
	IBOutlet NSButton *updateButton;
	IBOutlet NSButton *deleteButton;
	
	IBOutlet NSTextField *statusLabel;
		
	int totalTransfers;
	int totalActiveTransfers;
		
@private
	NSStatusItem *_statusItem;
}

@property(nonatomic, readwrite, retain) NSMutableArray *transfers;
@property(nonatomic, readwrite, retain) NSMutableArray *savedLocations;
@property(readwrite, assign) int totalTransfers;
@property(readwrite, assign) int totalActiveTransfers;

- (id <CurlClient>)uploadClientForLocation:(Location *)location;

- (void)retryUpload:(Upload *)record;
- (void)startUpload:(NSArray *)fileList toLocation:(Location *)aLocation;

- (void)createLocationAndTransferFiles:(NSArray *)fileList;
- (IBAction)createLocation:(id)sender;
- (IBAction)updateLocation:(id)sender;
- (IBAction)deleteLocation:(id)sender;

- (void)saveUserData;
- (void)updateContextMenu;
- (void)updateStatusLabel;

- (void)showTransfersView;
- (void)showLocationsView;

- (void)requireSettingsDirectory;

/*
 *
 */
- (void)runUploadTest;

@end
