//
//  ProgressMeter.h
//  OneWay
//
//  Copyright 2010 Nick Jensen <http://goto11.net>
//

#import <Cocoa/Cocoa.h>
#import <objective-curl/objective-curl.h>


@class Upload;


NSString * const BytePrefix;

NSString * const KiloBytePrefix;

NSString * const MegaBytePrefix;

NSString * const GigaBytePrefix;


@interface ProgressMeter : NSObject


+ (NSString *)uploadedAmount:(Upload *)upload;

+ (NSString *)uploadSpeed:(Upload *)upload;

+ (NSString *)uploadTimeRemaining:(Upload *)upload;

+ (NSString *)stringRepresentationOfBytes:(double)bytes;

@end
