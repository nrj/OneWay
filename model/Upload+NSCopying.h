//
//  Upload+NSCopying.h
//  OneWay
//
//  Created by nrj on 2/14/10.
//  Copyright 2010 cocoaism.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <objective-curl/objective-curl.h>

@interface Upload (NSCopying)

- (id)copyWithZone:(NSZone *)zone;

@end
