//
//  StatusMessage.h
//  OneWay
//
//  Copyright 2010 Nick Jensen <http://goto11.net>
//

#import <Cocoa/Cocoa.h>


@interface LocationMessage : NSObject

+ (NSString *)newLocationMessage;

+ (NSString *)editLocationMessage;

+ (NSString *)uploadFilesToNewLocationMessage:(NSArray *)fileList;

@end
