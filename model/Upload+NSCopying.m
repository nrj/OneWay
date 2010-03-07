//
//  Upload+NSCopying.m
//  OneWay
//
//  Created by nrj on 2/14/10.
//  Copyright 2010 cocoaism.com. All rights reserved.
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
	[copy setPath:path];
	[copy setPort:port];
	[copy setStatus:status];
	[copy setConnected:connected];
	[copy setCancelled:cancelled];
	[copy setName:name];
	[copy setStatusMessage:statusMessage];
	[copy setCurrentFile:currentFile];
	[copy setLocalFiles:localFiles];
	[copy setProgress:progress];
	[copy setTotalFiles:totalFiles];
	[copy setTotalFilesUploaded:totalFilesUploaded];

    return copy;
}

@end
