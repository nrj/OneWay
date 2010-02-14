//
//  NSString+UUID.m
//  OneWay
//
//  Created by nrj on 9/4/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "NSString+UUID.h"


@implementation NSString (UUID)

+ (NSString *)stringWithNewUUID
{
    CFUUIDRef uniqueId = CFUUIDCreate(kCFAllocatorDefault);
    CFStringRef uniqueIdString = CFUUIDCreateString(kCFAllocatorDefault, uniqueId);
	
    NSString *result = [NSString stringWithFormat:@"%@", (NSString *)uniqueIdString];
    CFRelease(uniqueId);
    CFRelease(uniqueIdString);
    return result;	
}

@end
