//
//  FinderItem.h
//  OneWay
//

//  Copyright 2010 Nick Jensen <http://goto11.net>
//

#import <Cocoa/Cocoa.h>

@class Location;

@interface FinderItem : NSObject

+ (NSString *)labelForNewLocation;

+ (NSString *)labelForLocation:(Location *)location;

@end
