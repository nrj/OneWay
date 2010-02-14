//
//  TransferRenderer.m
//		
//
//  Created by nrj on 8/6/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "TransferCell.h"
#import "Location.h"
#import "ProgressGradients.h"
#import "OWConstants.h"


@implementation TransferCell


- (void) drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
	[super drawWithFrame:cellFrame inView:controlView];
	
//	Upload *record = (Upload *)[self objectValue];
//	Location *location = [record location];
	
	// Make attributes for our strings
	NSMutableParagraphStyle *paragraphStyle = [[[NSMutableParagraphStyle alloc] init] autorelease];
	
	[paragraphStyle setLineBreakMode:NSLineBreakByTruncatingTail];
	
	// Title attributes: system font, 14pt, black, truncate tail
	NSMutableDictionary *titleAttributes = [[[NSMutableDictionary alloc] initWithObjectsAndKeys:
											 [NSColor blackColor], NSForegroundColorAttributeName,
											 [NSFont systemFontOfSize:11.0], NSFontAttributeName, 
											 paragraphStyle, NSParagraphStyleAttributeName, nil] autorelease];
	
	
	// Subtitle attributes: system font, 10pt, gray, truncate tail
	NSMutableDictionary * statusAttributes = [[[NSMutableDictionary alloc] initWithObjectsAndKeys:
											   [NSColor grayColor], NSForegroundColorAttributeName,
											   [NSFont systemFontOfSize:9.0],NSFontAttributeName,
											   paragraphStyle, NSParagraphStyleAttributeName, nil] autorelease];
	
	
	// Text will be white if selected 
	if(	[self isHighlighted] )
	{		
		[titleAttributes setValue:[NSColor whiteColor] forKey:NSForegroundColorAttributeName];
		[statusAttributes setValue:[NSColor whiteColor] forKey:NSForegroundColorAttributeName];
	}
	else
	{
		[titleAttributes setValue:[NSColor blackColor] forKey:NSForegroundColorAttributeName];
		[statusAttributes setValue:[NSColor grayColor] forKey:NSForegroundColorAttributeName];
	}
	
	
	const int HORIZONTAL_PADDING = 10;
	const int VERTICAL_PADDING = 3;
	
	
	// Outter most rectangle
	NSRect outterRect = NSInsetRect([self drawingRectForBounds:cellFrame], 10.5, 7.5);
	
	// Make the icon
	NSImage *icon = [NSImage imageNamed:@"upArrow"];
	NSSize iconSize = NSMakeSize(32, 32);
	[icon setSize:iconSize];
	[icon setFlipped:YES];
	
	NSRect iconRect = NSMakeRect(outterRect.origin.x, 
								 outterRect.origin.y,
								 iconSize.width, 
								 iconSize.height);
	
	[icon drawInRect:iconRect 
			fromRect:NSZeroRect 
		   operation:NSCompositeSourceOver 
			fraction:1.0];
	

//	int fullWidth = outterRect.size.width - iconSize.width - HORIZONTAL_PADDING;
	
	
	// Make the title
//	NSString *title = [NSString stringWithString:[record name]];
	
//	NSSize titleSize = [title sizeWithAttributes:titleAttributes];
//	NSRect titleRect = NSMakeRect(outterRect.origin.x + iconSize.width + HORIZONTAL_PADDING, 
//								  outterRect.origin.y,
//								  fullWidth,
//								  titleSize.height);
	
//	[title drawInRect:titleRect withAttributes:titleAttributes];
	
	
	// Make the status
	//NSString *status = [NSString stringWithString:[[self objectValue] valueForKey:@"status"]];
	
//	NSMutableString *statusText;
//	if ([status isEqualToString:OWStatusUploading])
//	{
//		statusText = [NSMutableString stringWithFormat:@"%@ %d of %d files (%d%%) to %@", OWStatusUploading, [record totalFilesUploaded], [record totalFiles], [record progress], [location hostname]];
//	}
//	else if ([status isEqualToString:OWStatusConnecting])
//	{
//		statusText = [NSMutableString stringWithFormat:@"%@ to %@...", OWStatusConnecting, [location hostname]];
//	}
//	else
//	{
//		statusText = [NSMutableString stringWithString:status];	
//	}
	
//	NSSize statusSize = [status sizeWithAttributes:statusAttributes];
	
//	NSRect statusRect = NSMakeRect(titleRect.origin.x,
//								   titleRect.origin.y + statusSize.height + VERTICAL_PADDING,
//								   fullWidth,
//								   statusSize.height);
	
//	[statusText drawInRect:statusRect withAttributes:statusAttributes];
	
	
	// Make the progress bar
//	NSRect progressOutline = NSMakeRect(statusRect.origin.x,
//										statusRect.origin.y + statusSize.height + 1.5, 
//										fullWidth, 
//										NSProgressIndicatorPreferredSmallThickness);
	
//	[[ProgressGradients progressLightGrayGradient] drawInRect:progressOutline angle:90];
	
//	double progress = [record progress] * progressOutline.size.width / 100 - 1;
	
//	if (progress > 0)
//	{
//		NSRect progressFill = NSMakeRect(progressOutline.origin.x, 
//										 progressOutline.origin.y + 0.5,
//										 progress, NSProgressIndicatorPreferredSmallThickness - 1);
//		
//		if ([status isEqualToString:OWStatusUploading])
//		{
//			[[ProgressGradients progressBlueGradient] drawInRect:progressFill angle:90];
//		}
//		else if ([status isEqualToString:OWStatusCancelled])
//		{
//			[[ProgressGradients progressRedGradient] drawInRect:progressFill angle:90];
//		}
//		else if ([status isEqualToString:OWStatusFinished])
//		{
//			[[ProgressGradients progressLightGreenGradient] drawInRect:progressFill angle:90];
//		}
//	}
	
//	NSRect substatusRect = NSMakeRect(progressOutline.origin.x,
//									  progressOutline.origin.y + statusSize.height - 1.5,
//									  fullWidth,
//									  statusSize.height);
	
//	if ([status isEqualToString:OWStatusUploading])
//	{
//		NSString *substatus = [NSString stringWithFormat:@"File: %@", [[self objectValue] valueForKey:@"currentFile"]];
	
//		[substatus drawInRect:substatusRect withAttributes:statusAttributes];
//	}
	
} 


@end