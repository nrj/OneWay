//
//  NSString+UUID.m
//  OneWay
//
//  Copyright 2010 Nick Jensen <http://goto11.net>
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
