//
//  Location+Scripting.m
//  OneWay
//
//  Copyright 2010 Nick Jensen <http://goto11.net>
//

#import "Location+Scripting.h"
#import "OWConstants.h"


@implementation Location (Scripting)


- (NSScriptObjectSpecifier *)objectSpecifier 
{ 
    NSScriptClassDescription *appDesc = (NSScriptClassDescription*)[NSApp classDescription]; 
    return [[[NSNameSpecifier alloc] initWithContainerClassDescription:appDesc 
													containerSpecifier:nil 
																   key:@"savedLocations" 
																  name:[self uid]] autorelease]; 
} 

- (NSString *)locationName 
{
	return uid;
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

- (void) returnError:(int)n string:(NSString*)s { 
    NSScriptCommand* c = [NSScriptCommand currentCommand]; 
    [c setScriptErrorNumber:n]; 
    if (s) [c setScriptErrorString:s]; 
} 


@end