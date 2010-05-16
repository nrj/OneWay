//
//  Upload+NSCopying.h
//  OneWay
//
//  Copyright 2010 Nick Jensen <http://goto11.net>
//

#import <Cocoa/Cocoa.h>
#import <objective-curl/objective-curl.h>

@interface Upload (NSCopying)

- (id)copyWithZone:(NSZone *)zone;

@end
