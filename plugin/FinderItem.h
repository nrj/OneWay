//
//  FinderItem.h
//  OneWay
//
//  Created by nrj on 3/18/10.
//  Copyright 2010 cocoaism.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class Location;

@interface FinderItem : NSObject

+ (NSString *)labelForNewLocation;

+ (NSString *)labelForLocation:(Location *)location;

@end
