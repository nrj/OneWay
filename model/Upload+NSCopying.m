//
//  Upload+NSCopying.m
//  OneWay
//
//  Copyright 2010 Nick Jensen <http://goto11.net>
//

#import "Upload+NSCopying.h"


@implementation Upload (NSCopying)

- (id)copyWithZone:(NSZone *)zone 
{
    Upload *copy = [[self class] allocWithZone: zone];
	
	[copy setProtocol:protocol];
	[copy setProtocolPrefix:protocolPrefix];
	[copy setHostname:hostname];
	[copy setUsername:username];
	[copy setPassword:password];
	[copy setPrivateKeyFile:privateKeyFile];
	[copy setUsePublicKeyAuth:usePublicKeyAuth];
	[copy setCanUsePublicKeyAuth:canUsePublicKeyAuth];
	[copy setPath:path];
	[copy setUrl:url];
	[copy setPort:port];
	[copy setStatus:status];
	[copy setConnected:connected];
	[copy setCancelled:cancelled];
	[copy setName:name];
	[copy setStatusMessage:statusMessage];
	[copy setLocalFiles:localFiles];
	[copy setTransfers:transfers];
	[copy setProgress:progress];
	[copy setTotalFiles:totalFiles];
	[copy setTotalFilesUploaded:totalFilesUploaded];
	[copy setTotalBytes:totalBytes];
	[copy setTotalBytesUploaded:totalBytesUploaded];
	[copy setBytesPerSecond:bytesPerSecond];
	[copy setSecondsRemaining:secondsRemaining];
	
    return copy;
}

@end
