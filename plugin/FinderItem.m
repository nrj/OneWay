//
//  FinderItem.m
//  OneWay
//
//  Copyright 2010 Nick Jensen <http://goto11.net>
//

#import "FinderItem.h"
#import "Location.h"
#import "OWConstants.h"


@implementation FinderItem


+ (NSString *)labelForNewLocation
{
	return @"Upload to ...";
}


+ (NSString *)labelForLocation:(Location *)location
{	
	NSMutableArray *locationInfo = [NSMutableArray arrayWithCapacity:2];
	
	NSString *uploadPath = [[location directory] lastPathComponent];
	
	[locationInfo addObject:[location protocolString]];
	[locationInfo addObject:uploadPath];
	
	return [NSString stringWithFormat:@"Upload to %@ (%@)", 
			[location hostname], [locationInfo componentsJoinedByString:@", "]];
}

@end
