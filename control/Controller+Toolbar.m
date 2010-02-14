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


- (void)setupToolbarForWindow:(NSWindow *)theWindow 
{
    NSToolbar * toolbar = [[[NSToolbar alloc] initWithIdentifier:OWTransferToolbarIdentifier] autorelease];
    
    [toolbar setAllowsUserCustomization: NO];
    [toolbar setAutosavesConfiguration: YES];
    [toolbar setDisplayMode: NSToolbarDisplayModeIconOnly];
	[toolbar setSizeMode:NSToolbarSizeModeRegular];
    [toolbar setDelegate: self];
	
    [theWindow setToolbar:toolbar];
}


- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSString *)itemIdent willBeInsertedIntoToolbar:(BOOL)willBeInserted 
{	
    if ([itemIdent isEqual:OWTransferToolbarStopItem]) 
	{
		NSToolbarItem *item = [[NSToolbarItem alloc] initWithItemIdentifier:OWTransferToolbarStopItem];
		
        [item setLabel: @"Stop"];
        [item setPaletteLabel: @"Stop"];
        [item setToolTip: @"Stop"];
        [item setImage: [NSImage imageNamed: @"stop.png"]];
        [item setTarget: self];
        [item setAction: @selector(stopSelectedTransfers:)];
		
		return item;
	} 
	else if ([itemIdent isEqual:OWTransferToolbarClearItem]) 
	{
		NSToolbarItem *item = [[NSToolbarItem alloc] initWithItemIdentifier:OWTransferToolbarClearItem];
		
        [item setLabel: @"Clear"];
        [item setPaletteLabel: @"Clear"];
        [item setToolTip: @"Clear"];
        [item setImage: [NSImage imageNamed: @"clear.png"]];
        [item setTarget: self];
        [item setAction: @selector(clearSelectedTransfers:)];
		
		return item;
	} 
	else if ([itemIdent isEqual:NSToolbarFlexibleSpaceItemIdentifier])
	{
		NSToolbarItem *item = [[NSToolbarItem alloc] initWithItemIdentifier:NSToolbarFlexibleSpaceItemIdentifier];
		return item;
	}
	else if ([itemIdent isEqual:OWTransferToolbarLogItem]) 
	{
		NSToolbarItem *item = [[NSToolbarItem alloc] initWithItemIdentifier:OWTransferToolbarLogItem];
		
        [item setLabel: @"Log"];
        [item setPaletteLabel: @"Log"];
        [item setToolTip: @"Show Log"];
        [item setImage: [NSImage imageNamed: @"log.png"]];
        [item setTarget: self];
        [item setAction: @selector(showLog)];
		
		return item;
	}
	else if ([itemIdent isEqual:OWTransferToolbarTransfersItem]) 
	{
		NSToolbarItem *item = [[NSToolbarItem alloc] initWithItemIdentifier:OWTransferToolbarTransfersItem];
		
        [item setLabel: @"Transfers"];
        [item setPaletteLabel: @"Transfers"];
        [item setToolTip: @"Show Transfers"];
        [item setImage: [NSImage imageNamed: @"transfers.png"]];
        [item setTarget: self];
        [item setAction: @selector(showTransfersView)];
		
		return item;
	} 
	else if ([itemIdent isEqual:OWTransferToolbarDrawerItem]) 
	{
		NSToolbarItem *item = [[NSToolbarItem alloc] initWithItemIdentifier:OWTransferToolbarDrawerItem];
		
        [item setLabel: @"Menu"];
        [item setPaletteLabel: @"Menu"];
        [item setToolTip: @"Show Menu Items"];
        [item setImage: [NSImage imageNamed: @"menu.png"]];
        [item setTarget: self];
        [item setAction: @selector(showLocationsView)];
		
		return item;
	} 
	
	return nil;
}


- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar*)toolbar 
{
    return [NSArray arrayWithObjects:	OWTransferToolbarStopItem,
										OWTransferToolbarClearItem,
										NSToolbarFlexibleSpaceItemIdentifier,
										OWTransferToolbarLogItem,
										OWTransferToolbarTransfersItem,
										OWTransferToolbarDrawerItem, 
										nil];
}


- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar*)toolbar 
{
    return [NSArray arrayWithObjects:	OWTransferToolbarStopItem, 
										OWTransferToolbarClearItem,
										NSToolbarFlexibleSpaceItemIdentifier,
										OWTransferToolbarLogItem,
										OWTransferToolbarTransfersItem,
										OWTransferToolbarDrawerItem, 
										nil];
	
}


- (BOOL)validateToolbarItem:(NSToolbarItem *)toolbarItem 
{
    BOOL enable = NO;
	Upload *transfer;
	NSIndexSet *selection = [transferTable selectedRowIndexes];
	int i = [selection firstIndex];
	
    if ([[toolbarItem itemIdentifier] isEqual:OWTransferToolbarStopItem]) 
	{
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
	else if ([[toolbarItem itemIdentifier] isEqual:OWTransferToolbarClearItem])
	{
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
	else
	{
		enable = YES;
	}
    return enable;
}

@end
