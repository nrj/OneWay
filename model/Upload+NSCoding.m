//
//  Upload+NSCoding.m
//  OneWay
//
//  Created by nrj on 2/14/10.
//  Copyright 2010 cocoaism.com. All rights reserved.
//

#import "Upload+NSCoding.h"


@implementation Upload (NSCoding)


- (id)initWithCoder:(NSCoder *)decoder
{
	protocol	= [decoder decodeInt32ForKey:@"protocol"];
	protocolPrefix = [[decoder decodeObjectForKey:@"protocolPrefix"] retain];
	hostname	= [[decoder decodeObjectForKey:@"hostname"] retain];
	username	= [[decoder decodeObjectForKey:@"username"] retain];
	path		= [[decoder decodeObjectForKey:@"path"] retain];
	port		= [decoder decodeIntForKey:@"port"];
	status		= [decoder decodeIntForKey:@"status"];
	connected	= [decoder decodeBoolForKey:@"connected"];
	cancelled	= [decoder decodeBoolForKey:@"cancelled"];
	name		= [[decoder decodeObjectForKey:@"name"] retain];
	statusMessage = [[decoder decodeObjectForKey:@"statusMessage"] retain];
	currentFile	= [[decoder decodeObjectForKey:@"currentFile"] retain];
	localFiles	= [[decoder decodeObjectForKey:@"localFiles"] retain];
	progress	= [decoder decodeIntForKey:@"progress"];
	totalFiles	= [decoder decodeIntForKey:@"totalFiles"];
	totalFilesUploaded = [decoder decodeIntForKey:@"totalFilesUploaded"];
	
	return self;
}


- (void)encodeWithCoder:(NSCoder *)encoder
{
	if ([self isActive])
	{
		[self setStatus:TRANSFER_STATUS_CANCELLED];
		[self setStatusMessage:@"Cancelled"];
	}
	[encoder encodeInt32:protocol forKey:@"protocol"];
	[encoder encodeObject:protocolPrefix forKey:@"protocolPrefix"];
	[encoder encodeObject:hostname forKey:@"hostname"];
	[encoder encodeObject:username forKey:@"username"];
	[encoder encodeObject:path forKey:@"path"];
	[encoder encodeInt:port forKey:@"port"];
	[encoder encodeInt:status forKey:@"status"];
	[encoder encodeBool:connected forKey:@"connected"];
	[encoder encodeBool:cancelled forKey:@"cancelled"];
	[encoder encodeObject:name forKey:@"name"];
	[encoder encodeObject:statusMessage forKey:@"statusMessage"];
	[encoder encodeObject:currentFile forKey:@"currentFile"];
	[encoder encodeObject:localFiles forKey:@"localFiles"];
	[encoder encodeInt:progress forKey:@"progress"];
	[encoder encodeInt:totalFiles forKey:@"totalFiles"];
	[encoder encodeInt:totalFilesUploaded forKey:@"totalFilesUploaded"];
}


@end
