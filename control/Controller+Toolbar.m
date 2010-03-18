//
//  Controller+Toolbar.m
//  OneWay
//
//  Created by nrj on 9/1/09.
//  Copyright 2009. All rights reserved.
//

#import "Controller+Toolbar.h"
#import "OWConstants.h"


@implementation Controller (Toolbar)


- (void)setupToolbar:(NSString *)identifier forWindow:(NSWindow *)theWindow 
{
    NSToolbar * toolbar = [[[NSToolbar alloc] initWithIdentifier:identifier] autorelease];
    
    [toolbar setAllowsUserCustomization: NO];
    [toolbar setAutosavesConfiguration: NO];
    [toolbar setDisplayMode: NSToolbarDisplayModeIconOnly];
	[toolbar setSizeMode:NSToolbarSizeModeSmall];
    [toolbar setDelegate:self];
	
    [theWindow setToolbar:toolbar];
}


- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSString *)itemIdent willBeInsertedIntoToolbar:(BOOL)willBeInserted 
{	
	NSToolbarItem *item = [[[NSToolbarItem alloc] initWithItemIdentifier:itemIdent] autorelease];
	
    if ([itemIdent isEqual:OWViewToggleMenuItem]) 
	{
		NSSegmentedControl *tv = toggleView ? toggleView : [self newToggleViewControl];
		[item setView:tv];
		[item setTarget: self];
		[item setAction: @selector(toggleView:)];
	}
	 	
	else if ([itemIdent isEqual:OWRetryTransfersMenuItem]) 
	{
        [item setLabel: @"Reload"];
        [item setPaletteLabel: @"Reload"];
        [item setToolTip: @"Reload Selected Transfers"];
        [item setImage: [NSImage imageNamed: @"retry.png"]];
        [item setTarget: self];
        [item setAction: @selector(retrySelectedTransfers:)];
	} 
	
	else if ([itemIdent isEqual:OWStopTransfersMenuItem]) 
	{
        [item setLabel: @"Stop"];
        [item setPaletteLabel: @"Stop"];
        [item setToolTip: @"Stop Selected Transfers"];
        [item setImage: [NSImage imageNamed: @"stop.png"]];
        [item setTarget: self];
        [item setAction: @selector(stopSelectedTransfers:)];
	} 
	
	else if ([itemIdent isEqual:OWClearTransfersMenuItem]) 
	{
        [item setLabel: @"Clear"];
        [item setPaletteLabel: @"Clear"];
        [item setToolTip: @"Clear Selected Transfers"];
        [item setImage: [NSImage imageNamed: @"clear.png"]];
        [item setTarget: self];
        [item setAction: @selector(clearSelectedTransfers:)];
	}
	
	else if ([itemIdent isEqual:OWCreateLocationMenuItem]) 
	{
        [item setLabel: @"New Menu Item"];
        [item setPaletteLabel: @"New Menu Item"];
        [item setToolTip: @"New Menu Item"];
        [item setImage: [NSImage imageNamed: @"add.png"]];
        [item setTarget: self];
        [item setAction: @selector(createLocation:)];
	}
	
	else if ([itemIdent isEqual:OWDeleteLocationMenuItem]) 
	{
        [item setLabel: @"Delete Menu Item"];
        [item setPaletteLabel: @"Delete Menu Item"];
        [item setToolTip: @"Delete Menu Item"];
        [item setImage: [NSImage imageNamed: @"delete.png"]];
        [item setTarget: self];
        [item setAction: @selector(deleteLocation:)];
	}
		
	else
	{
		return nil;
	}
	
	return item;
}


- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar*)toolbar 
{	
	if ([[toolbar identifier] isEqual:OWTransferToolbarIdentifier])
	{
		return [NSArray arrayWithObjects:	OWRetryTransfersMenuItem,
											OWStopTransfersMenuItem,
											OWClearTransfersMenuItem,
											NSToolbarFlexibleSpaceItemIdentifier,
											OWViewToggleMenuItem,
											NSToolbarFlexibleSpaceItemIdentifier,
											NSToolbarSpaceItemIdentifier,
											NSToolbarSpaceItemIdentifier,
											NSToolbarSpaceItemIdentifier,
											nil];
		
	}
	else
	{
		return [NSArray arrayWithObjects:	OWCreateLocationMenuItem,
											OWDeleteLocationMenuItem,
											NSToolbarFlexibleSpaceItemIdentifier,
											OWViewToggleMenuItem,
											NSToolbarFlexibleSpaceItemIdentifier,							
											NSToolbarSpaceItemIdentifier,
											NSToolbarSpaceItemIdentifier,
											nil];
	}	
}


- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar*)toolbar 
{	
	return [NSArray arrayWithObjects:	OWRetryTransfersMenuItem,
										OWStopTransfersMenuItem,
										OWClearTransfersMenuItem,
										OWCreateLocationMenuItem,
										OWDeleteLocationMenuItem,
										OWViewToggleMenuItem,
										NSToolbarFlexibleSpaceItemIdentifier,
										NSToolbarSpaceItemIdentifier,
										nil];
}


- (BOOL)validateToolbarItem:(NSToolbarItem *)toolbarItem 
{
    BOOL enable = NO;
	
    if ([[toolbarItem itemIdentifier] isEqual:OWStopTransfersMenuItem]) 
	{
		Upload *transfer;
		NSIndexSet *selection = [transferTable selectedRowIndexes];
		int i = [selection firstIndex];
		
		while (i != NSNotFound)
		{
			transfer = [transfers objectAtIndex:i];
			if ([transfer isActive])
			{
				enable = YES;
				break;
			}
			i = [selection indexGreaterThanIndex:i];
		}
    } 
	else if ([[toolbarItem itemIdentifier] isEqual:OWClearTransfersMenuItem])
	{
		Upload *transfer;
		NSIndexSet *selection = [transferTable selectedRowIndexes];
		int i = [selection firstIndex];
		
		while (i != NSNotFound)
		{
			transfer = [transfers objectAtIndex:i];
			if (![transfer isActive])
			{
				enable = YES;
				break;
			}
			i = [selection indexGreaterThanIndex:i];
		}
	}
	else if ([[toolbarItem itemIdentifier] isEqual:OWRetryTransfersMenuItem])
	{
		Upload *transfer;
		NSIndexSet *selection = [transferTable selectedRowIndexes];
		int i = [selection firstIndex];
		
		while (i != NSNotFound)
		{
			transfer = [transfers objectAtIndex:i];
			if (![transfer isActive])
			{
				enable = YES;
				break;
			}
			i = [selection indexGreaterThanIndex:i];
		}
	}
	
	else if ([[toolbarItem itemIdentifier] isEqual:OWDeleteLocationMenuItem])
	{
		NSIndexSet *selection = [menuTable selectedRowIndexes];
		if ([selection firstIndex] != NSNotFound)
		{
			enable = YES;
		}
	}
	else
	{
		enable = YES;
	}
    return enable;
}


- (NSSegmentedControl *)newToggleViewControl
{
	toggleView = [[NSSegmentedControl alloc] initWithFrame:NSMakeRect(0,0,175,25)];
	
	[toggleView setSegmentCount:2];
	[toggleView setSegmentStyle:NSSegmentStyleTexturedRounded];
	[toggleView setLabel:@"Transfers" forSegment:0];
	[toggleView setLabel:@"Bookmarks" forSegment:1];
	[toggleView setSelectedSegment:0];
	[[toggleView cell] setTrackingMode:NSSegmentSwitchTrackingSelectOne];
	
	return toggleView;
}


@end
