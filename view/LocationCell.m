//
//  LocationCell.m
//		
//
//  Copyright 2010 Nick Jensen <http://goto11.net>
//

#import "LocationCell.h"
#import "Location.h"
#import "OWConstants.h"


@implementation LocationCell


- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
	[super drawWithFrame:cellFrame inView:controlView];
	
	Location *location = (Location *)[self objectValue];
	
	// Make attributes for our strings
	NSMutableParagraphStyle *paragraphStyle = [[[NSMutableParagraphStyle alloc] init] autorelease];
	
	[paragraphStyle setLineBreakMode:NSLineBreakByTruncatingTail];
	
	
	NSMutableDictionary *titleAttributes = [[[NSMutableDictionary alloc] initWithObjectsAndKeys:
											 [NSColor blackColor], NSForegroundColorAttributeName,
											 [NSFont systemFontOfSize:11.0], NSFontAttributeName, 
											 paragraphStyle, NSParagraphStyleAttributeName, nil] autorelease];
	
	
	NSMutableDictionary * subtitleAttributes = [[[NSMutableDictionary alloc] initWithObjectsAndKeys:
											   [NSColor grayColor], NSForegroundColorAttributeName,
											   [NSFont systemFontOfSize:10.0],NSFontAttributeName,
											   paragraphStyle, NSParagraphStyleAttributeName, nil] autorelease];
	
	
	// Text will be white if selected 
	if(	[self isHighlighted] )
	{		
		[titleAttributes setValue:[NSColor whiteColor] forKey:NSForegroundColorAttributeName];
		[subtitleAttributes setValue:[NSColor whiteColor] forKey:NSForegroundColorAttributeName];
	}
	else
	{
		[titleAttributes setValue:[NSColor blackColor] forKey:NSForegroundColorAttributeName];
		[subtitleAttributes setValue:[NSColor grayColor] forKey:NSForegroundColorAttributeName];
	}
	
	
	const int HORIZONTAL_PADDING = 10;
	const int VERTICAL_PADDING = 3;
	
	
	// Outter most rectangle
	NSRect outterRect = NSInsetRect([self drawingRectForBounds:cellFrame], 10.5, 7.5);
	
	// Make the icon
	NSImage *icon = [NSImage imageNamed:@"networkDrive"];
	NSSize iconSize = NSMakeSize(32, 32);
	[icon setSize:iconSize];
	[icon setFlipped:YES];
	
	NSRect iconRect = NSMakeRect(outterRect.origin.x, 
								 outterRect.origin.y + ((outterRect.size.height / 2) - (iconSize.height / 2)),
								 iconSize.width, 
								 iconSize.height);
	
	[icon drawInRect:iconRect 
			fromRect:NSZeroRect 
		   operation:NSCompositeSourceOver 
			fraction:1.0];
	
	
	int fullWidth = outterRect.size.width - iconSize.width - HORIZONTAL_PADDING;
	
	
	// Make the hostname
	NSString *hostname = [location hostname];
	NSSize hostnameSize = [hostname sizeWithAttributes:titleAttributes];
	NSRect hostnameRect = NSMakeRect(outterRect.origin.x + iconSize.width + HORIZONTAL_PADDING, 
									 outterRect.origin.y,
									 fullWidth,
									 hostnameSize.height);
	
	[hostname drawInRect:hostnameRect withAttributes:titleAttributes];	
	
	// Draw the username
	NSString *username = [location username];
	NSSize usernameSize = [username sizeWithAttributes:subtitleAttributes];
	
	NSRect usernameRect = NSMakeRect(hostnameRect.origin.x,
								   hostnameRect.origin.y + usernameSize.height + VERTICAL_PADDING,
								   fullWidth,
								   usernameSize.height);
	
	[username drawInRect:usernameRect withAttributes:subtitleAttributes];
	
	// Draw the url string
	NSString *url;
	switch ([location type]) {
		case CURL_CLIENT_FTP:
			url = [NSString stringWithFormat:@"ftp://%@/%@", [location hostname], [location directory]];
			break;
		case CURL_CLIENT_SFTP:
			url = [NSString stringWithFormat:@"sftp://%@/%@", [location hostname], [location directory]];
			break;
		case CURL_CLIENT_S3:
			url = [NSString stringWithFormat:@"https://%@/%@", [location hostname], [location directory]];
			break;
		default:
			url= @"";
			break;
	}
	
	NSSize urlSize = [url sizeWithAttributes:subtitleAttributes];	
	NSRect urlRect = NSMakeRect(usernameRect.origin.x,
								usernameRect.origin.y + urlSize.height + VERTICAL_PADDING,
								fullWidth,
								urlSize.height);
	
	[url drawInRect:urlRect withAttributes:subtitleAttributes];
	
	
} 


@end