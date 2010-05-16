//
//  NSMenu+Extras.m
//  OneWay
//
//  Copyright 2010 Nick Jensen <http://goto11.net>
//

#import "NSMenu+Extras.h"


@implementation NSMenu (Extras)


/*
 * Unfortunately this method only exists in 10.6, and supposedly it performs better
 * than doing it this way.
 */
- (void)removeAllItems
{
	while([[self itemArray] count] > 0)
	{
		[self removeItem:[[self itemArray] objectAtIndex:0]];
	}
}

@end
