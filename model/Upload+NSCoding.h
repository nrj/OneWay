//
//  Upload+NSCoding.h
//  OneWay
//
//  Created by nrj on 2/14/10.
//  Copyright 2010 cocoaism.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <objective-curl/objective-curl.h>

@interface Upload (NSCoding) 

- (id)initWithCoder:(NSCoder *)decoder;
- (void)encodeWithCoder:(NSCoder *)encoder;

@end
