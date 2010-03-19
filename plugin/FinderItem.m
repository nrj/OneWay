//
//  FinderItem.m
//  OneWay
//
//  Created by nrj on 3/18/10.
//  Copyright 2010 cocoaism.com. All rights reserved.
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
