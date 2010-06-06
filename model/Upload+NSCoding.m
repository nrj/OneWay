//
//  Upload+NSCoding.m
//  OneWay
//
//  Copyright 2010 Nick Jensen <http://goto11.net>
//

#import "Upload+NSCoding.h"


@implementation Upload (NSCoding)


- (id)initWithCoder:(NSCoder *)decoder
{
	protocol			= [decoder decodeInt32ForKey:@"protocol"];
	protocolPrefix		= [[decoder decodeObjectForKey:@"protocolPrefix"] retain];
	hostname			= [[decoder decodeObjectForKey:@"hostname"] retain];
	username			= [[decoder decodeObjectForKey:@"username"] retain];
	privateKeyFile		= [[decoder decodeObjectForKey:@"privateKeyFile"] retain];
	usePublicKeyAuth	= [decoder decodeBoolForKey:@"usePublicKeyAuth"];
	usePublicKeyAuth	= [decoder decodeBoolForKey:@"canUsePublicKeyAuth"];
	path				= [[decoder decodeObjectForKey:@"path"] retain];
	url					= [[decoder decodeObjectForKey:@"url"] retain];
	clientType			= [decoder decodeIntForKey:@"clientType"];
	port				= [decoder decodeIntForKey:@"port"];
	status				= [decoder decodeIntForKey:@"status"];
	connected			= [decoder decodeBoolForKey:@"connected"];
	cancelled			= [decoder decodeBoolForKey:@"cancelled"];
	name				= [[decoder decodeObjectForKey:@"name"] retain];
	statusMessage		= [[decoder decodeObjectForKey:@"statusMessage"] retain];
	localFiles			= [[decoder decodeObjectForKey:@"localFiles"] retain];
	transfers			= [[decoder decodeObjectForKey:@"transfers"] retain];
	progress			= [decoder decodeIntForKey:@"progress"];
	totalFiles			= [decoder decodeIntForKey:@"totalFiles"];
	totalFilesUploaded	= [decoder decodeIntForKey:@"totalFilesUploaded"];
	totalBytes			= [decoder decodeDoubleForKey:@"totalBytes"];
	totalBytesUploaded	= [decoder decodeDoubleForKey:@"totalBytesUploaded"];
	bytesPerSecond		= [decoder decodeDoubleForKey:@"bytesPerSecond"];
	secondsRemaining	= [decoder decodeDoubleForKey:@"secondsRemaining"];
	
		
	return self;
}


- (void)encodeWithCoder:(NSCoder *)encoder
{
	if ([self isActive])
	{
		[self setBytesPerSecond:0];
		[self setSecondsRemaining:0];
		[self setStatus:TRANSFER_STATUS_CANCELLED];
		[self setStatusMessage:@"Cancelled"];
	}
	
	[encoder encodeInt32:protocol forKey:@"protocol"];
	[encoder encodeObject:protocolPrefix forKey:@"protocolPrefix"];
	[encoder encodeObject:hostname forKey:@"hostname"];
	[encoder encodeObject:username forKey:@"username"];
	[encoder encodeObject:privateKeyFile forKey:@"privateKeyFile"];
	[encoder encodeBool:usePublicKeyAuth forKey:@"usePublicKeyAuth"];
	[encoder encodeBool:canUsePublicKeyAuth forKey:@"canUsePublicKeyAuth"];
	[encoder encodeObject:path forKey:@"path"];
	[encoder encodeObject:url forKey:@"url"];
	[encoder encodeInt:clientType forKey:@"clientType"];
	[encoder encodeInt:port forKey:@"port"];
	[encoder encodeInt:status forKey:@"status"];
	[encoder encodeBool:connected forKey:@"connected"];
	[encoder encodeBool:cancelled forKey:@"cancelled"];
	[encoder encodeObject:name forKey:@"name"];
	[encoder encodeObject:statusMessage forKey:@"statusMessage"];
	[encoder encodeObject:localFiles forKey:@"localFiles"];
	[encoder encodeObject:transfers forKey:@"transfers"];
	[encoder encodeInt:progress forKey:@"progress"];
	[encoder encodeInt:totalFiles forKey:@"totalFiles"];
	[encoder encodeInt:totalFilesUploaded forKey:@"totalFilesUploaded"];
	[encoder encodeDouble:totalBytes forKey:@"totalBytes"];
	[encoder encodeDouble:totalBytesUploaded forKey:@"totalBytesUploaded"];	
	[encoder encodeDouble:bytesPerSecond forKey:@"bytesPerSecond"];	
	[encoder encodeDouble:secondsRemaining forKey:@"secondsRemaining"];

}


@end
