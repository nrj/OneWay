//
//  StatusMessage.h
//  OneWay
//
//  Created by nrj on 2/21/10.
//  Copyright 2010 cocoaism.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface LocationMessage : NSObject

+ (NSString *)newLocationMessage;

+ (NSString *)editLocationMessage;

+ (NSString *)uploadFilesToNewLocationMessage:(NSArray *)fileList;

@end
