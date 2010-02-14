//
//  Location+Scripting.m
//  OneWay
//
//  Created by nrj on 7/22/09.
//  Copyright 2009. All rights reserved.
//

#import "Location+Scripting.h"
#import "OWConstants.h"


@implementation Location (Scripting)


- (NSScriptObjectSpecifier *)objectSpecifier
{
	NSScriptClassDescription *containerClassDesc = (NSScriptClassDescription *)
    [NSScriptClassDescription classDescriptionForClass:[NSApp class]];
	return [[[NSNameSpecifier alloc] initWithContainerClassDescription:containerClassDesc
													containerSpecifier:nil 
																   key:@"savedLocations"
																  name:[self uid]] autorelease];
}

- (void)queueTransfer:(NSScriptCommand*)command 
{
	NSArray *filepaths = (NSArray *)[[command evaluatedArguments] valueForKey:@"theFiles"];
	
	[NSApp activateIgnoringOtherApps:YES];
	
	// Post Queue Notification
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	NSDictionary *info = [NSDictionary dictionaryWithObject:filepaths 
													 forKey:@"filepaths"];
	
	[nc postNotificationName:OWQueueTransferNotification
					  object:self
					userInfo:info];
}

@end