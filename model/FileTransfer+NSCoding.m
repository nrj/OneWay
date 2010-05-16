//
//  FileTransfer+NSCoding.m
//  OneWay
//
//  Copyright 2010 Nick Jensen <http://goto11.net>
//

#import "FileTransfer+NSCoding.h"


@implementation FileTransfer (NSCoding)

- (id)initWithCoder:(NSCoder *)decoder
{
	localPath	= [[decoder decodeObjectForKey:@"localPath"] retain];
	remotePath	= [[decoder decodeObjectForKey:@"remotePath"] retain];
	
	isEmptyDirectory = [decoder decodeBoolForKey:@"isEmptyDirectory"];
	fileNotFound = [decoder decodeBoolForKey:@"fileNotFound"];
	
	percentComplete = [decoder decodeIntForKey:@"percentComplete"];
	
	totalBytes = [decoder decodeDoubleForKey:@"totalBytes"];
	totalBytesUploaded = [decoder decodeDoubleForKey:@"totalBytesUploaded"];
	
	return self;
}


- (void)encodeWithCoder:(NSCoder *)encoder
{
	[encoder encodeObject:localPath forKey:@"localPath"];
	[encoder encodeObject:remotePath forKey:@"remotePath"];
	
	[encoder encodeBool:isEmptyDirectory forKey:@"isEmptyDirectory"];
	[encoder encodeBool:fileNotFound forKey:@"fileNotFound"];
	
	[encoder encodeInt:percentComplete forKey:@"percentComplete"];
	
	[encoder encodeDouble:totalBytes forKey:@"totalBytes"];
	[encoder encodeDouble:totalBytesUploaded forKey:@"totalBytesUploaded"];
}


@end
