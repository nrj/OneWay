//
//  QueueNewScriptCommand.m
//  OneWay
//
//  Copyright 2010 Nick Jensen <http://goto11.net>
//

#import "QueueNewScriptCommand.h"
#import "OWConstants.h"


@implementation QueueNewScriptCommand

- (id)performDefaultImplementation;
{	
	NSArray *filepaths = (NSArray *)[self directParameter];
	
	// Bring the app to the front
	[NSApp activateIgnoringOtherApps:YES];
	
	
	// Post Queue Notification
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	NSDictionary *info = [NSDictionary dictionaryWithObject:filepaths 
													 forKey:@"filepaths"];
	
	[nc postNotificationName:OWQueueNewTransferNotification
					  object:self
					userInfo:info];
	
	return nil;
}


@end
