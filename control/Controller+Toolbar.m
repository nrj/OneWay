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
	[toolbar setSizeMode:NSToolbarSizeModeRegular];
    [toolbar setDelegate:self];
	
    [theWindow setToolbar:toolbar];
}


- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSString *)itemIdent willBeInsertedIntoToolbar:(BOOL)willBeInserted 
{	
    if ([itemIdent isEqual:OWShowTransfersMenuItem]) 
	{
		NSToolbarItem *item = [[NSToolbarItem alloc] initWithItemIdentifier:OWShowTransfersMenuItem];
		
        [item setLabel: @"Transfers"];
        [item setPaletteLabel: @"Transfers"];
        [item setToolTip: @"Show Transfers"];
        [item setImage: [NSImage imageNamed: @"transfers.png"]];
        [item setTarget: self];
        [item setAction: @selector(showTransfersView)];
		
		return item;
	}
	
	else if ([itemIdent isEqual:OWShowLocationsMenuItem]) 
	{
		NSToolbarItem *item = [[NSToolbarItem alloc] initWithItemIdentifier:OWShowLocationsMenuItem];
		
        [item setLabel: @"Menu"];
        [item setPaletteLabel: @"Menu"];
        [item setToolTip: @"Show Menu Items"];
        [item setImage: [NSImage imageNamed: @"menu.png"]];
        [item setTarget: self];
        [item setAction: @selector(showLocationsView)];
		
		return item;
	} 	
	
	else if ([itemIdent isEqual:OWStopTransfersMenuItem]) 
	{
		NSToolbarItem *item = [[NSToolbarItem alloc] initWithItemIdentifier:OWStopTransfersMenuItem];
		
        [item setLabel: @"Stop"];
        [item setPaletteLabel: @"Stop"];
        [item setToolTip: @"Stop Selected Transfers"];
        [item setImage: [NSImage imageNamed: @"stop.png"]];
        [item setTarget: self];
        [item setAction: @selector(stopSelectedTransfers:)];
		
		return item;
	} 
	
	else if ([itemIdent isEqual:OWClearTransfersMenuItem]) 
	{
		NSToolbarItem *item = [[NSToolbarItem alloc] initWithItemIdentifier:OWClearTransfersMenuItem];
		
        [item setLabel: @"Clear"];
        [item setPaletteLabel: @"Clear"];
        [item setToolTip: @"Clear Selected Transfers"];
        [item setImage: [NSImage imageNamed: @"clear.png"]];
        [item setTarget: self];
        [item setAction: @selector(clearSelectedTransfers:)];
		
		return item;
	}
	
	else if ([itemIdent isEqual:OWCreateLocationMenuItem]) 
	{
		NSToolbarItem *item = [[NSToolbarItem alloc] initWithItemIdentifier:OWCreateLocationMenuItem];
		
        [item setLabel: @"New Menu Item"];
        [item setPaletteLabel: @"New Menu Item"];
        [item setToolTip: @"New Menu Item"];
        [item setImage: [NSImage imageNamed: @"add.png"]];
        [item setTarget: self];
        [item setAction: @selector(createLocation:)];
		
		return item;
	}
	
	else if ([itemIdent isEqual:OWDeleteLocationMenuItem]) 
	{
		NSToolbarItem *item = [[NSToolbarItem alloc] initWithItemIdentifier:OWDeleteLocationMenuItem];
		
        [item setLabel: @"Delete Menu Item"];
        [item setPaletteLabel: @"Delete Menu Item"];
        [item setToolTip: @"Delete Menu Item"];
        [item setImage: [NSImage imageNamed: @"delete.png"]];
        [item setTarget: self];
        [item setAction: @selector(deleteLocation:)];
		
		return item;
	}
		
	else if ([itemIdent isEqual:NSToolbarFlexibleSpaceItemIdentifier])
	{
		NSToolbarItem *item = [[NSToolbarItem alloc] initWithItemIdentifier:NSToolbarFlexibleSpaceItemIdentifier];
		return item;
	}

	else if ([itemIdent isEqual:OWTestMenuItem]) 
	{
		NSToolbarItem *item = [[NSToolbarItem alloc] initWithItemIdentifier:OWTestMenuItem];
		
        [item setLabel: @"Test"];
        [item setPaletteLabel: @"Test"];
        [item setToolTip: @"Run Upload Test"];
        [item setImage: [NSImage imageNamed: @"log.png"]];
        [item setTarget: self];
        [item setAction: @selector(runUploadTest)];
		
		return item;
	}
	
	return nil;
}


- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar*)toolbar 
{	
	if ([[toolbar identifier] isEqual:OWTransferToolbarIdentifier])
	{
		return [NSArray arrayWithObjects:	OWShowTransfersMenuItem,
											OWShowLocationsMenuItem,
											NSToolbarFlexibleSpaceItemIdentifier,
											OWTestMenuItem,
											OWStopTransfersMenuItem,
											OWClearTransfersMenuItem, 
											nil];
	}
	else
	{
		return [NSArray arrayWithObjects:	OWShowTransfersMenuItem,
											OWShowLocationsMenuItem,
											NSToolbarFlexibleSpaceItemIdentifier,
											OWCreateLocationMenuItem,
											OWDeleteLocationMenuItem,
											nil];
	}	
}


- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar*)toolbar 
{	
		return [NSArray arrayWithObjects:OWShowTransfersMenuItem,
				OWShowLocationsMenuItem,
				NSToolbarFlexibleSpaceItemIdentifier,
				OWTestMenuItem,
				OWStopTransfersMenuItem,
				OWClearTransfersMenuItem, 
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

@end
