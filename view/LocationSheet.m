//
//  LocationSheet.m
//  OneWay
//
//  Created by nrj on 9/1/09.
//  Copyright 2009. All rights reserved.
//

#import "LocationSheet.h"
#import "Location.h"
#import "NSString+Truncate.h"


@implementation LocationSheet

@synthesize subtitle;
@synthesize location;
@synthesize fileList;
@synthesize shouldSaveLocation;
@synthesize shouldShowSaveOption;

- (id)init
{
	if (self = [super initWithWindowNibName:@"LocationSheet" owner:self])
	{
		subtitle = [[NSString alloc] initWithFormat:@""];
	}
	return self;
}

- (void)awakeFromNib
{

}

- (void)dealloc
{
	[subtitle release];
	[location release];
	[fileList release];
	[super dealloc];
}

- (void)windowDidBecomeKey:(NSNotification *)notification
{	
	[subtitleLabel setStringValue:subtitle];
}

- (IBAction)closeSheetOK:(id)sender
{	
	[NSApp endSheet:[self window] returnCode:1];
}

- (IBAction)closeSheetCancel:(id)sender
{
	[NSApp endSheet:[self window] returnCode:0];
}

@end
