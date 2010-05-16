//
//  TransferTable.m
//  OneWay
//
//  Created by nrj on 5/13/10.
//  Copyright 2010 cocoaism.com. All rights reserved.
//

#import "TransferTable.h"


@implementation TransferTable

- (NSMenu*)menuForEvent:(NSEvent*)event
{
	[[self window] makeFirstResponder:self];

	NSPoint menuPoint = [self convertPoint:[event locationInWindow] fromView:nil];
	
	int row = [self rowAtPoint:menuPoint];
	
	BOOL currentRowIsSelected = [[self selectedRowIndexes] containsIndex:row];

	if (!currentRowIsSelected)
	{
		[self selectRowIndexes:[NSIndexSet indexSetWithIndex:row] byExtendingSelection:NO];
	}
	
	if ([self numberOfSelectedRows] <= 0)
	{
		NSMenu* tableViewMenu = [[self menu] copy];
		
		int i;
		
		for (i = 0; i < [tableViewMenu numberOfItems]; i++)
		{
			[[tableViewMenu itemAtIndex:i] setEnabled:NO];
		}
		
		return [tableViewMenu autorelease];
	}
	else
	{
		return [self menu];
	}
}


@end
