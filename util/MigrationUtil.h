//
//  MigrationUtil.h
//  OneWay
//
//  Copyright 2010 Nick Jensen <http://goto11.net>
//

#import <Cocoa/Cocoa.h>

@interface MigrationUtil : NSObject

+ (void)migrateFromVersion:(NSString *)fromVersion toVersion:(NSString *)toVersion controller:(id)ctrl;

@end
