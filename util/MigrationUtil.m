//
//  MigrationUtil.m
//  OneWay
//
//  Copyright 2010 Nick Jensen <http://goto11.net>
//

#import "MigrationUtil.h"
#import "Controller.h"
#import "OWConstants.h"


const int ONEWAY_VERSION_0_5_4 = 54;


@implementation MigrationUtil


+ (void)migrateFromVersion:(NSString *)fromVersion toVersion:(NSString *)toVersion controller:(id)ctrl
{
	// Versions are the same or this is a brand new install...
	if ([toVersion isEqualToString:fromVersion] || fromVersion == nil) return;
	
	NSNumberFormatter *fmt = [[NSNumberFormatter alloc] init];
	[fmt setNumberStyle:NSNumberFormatterScientificStyle];

	NSNumber *fv = [fmt numberFromString:[fromVersion stringByReplacingOccurrencesOfString:@"." withString:@""]];
	NSNumber *tv = [fmt numberFromString:[toVersion stringByReplacingOccurrencesOfString:@"." withString:@""]];
	
	[fmt release];

	// The 'clientType' property was introduced in 0.5.4 and the application now relies on
	// it to reload transfers. Easies solution is to just clear out any saved transfers.
	if ([tv intValue] == ONEWAY_VERSION_0_5_4 && [fv intValue] < ONEWAY_VERSION_0_5_4) {
		
		NSLog(@"Running migration code for %@ -> %@", fromVersion, toVersion);
		
		[(Controller *)ctrl forceClearAllTransfers];
		[(Controller *)ctrl saveUserData];
	}	
}


@end
