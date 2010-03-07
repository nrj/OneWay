//
//  NSString+Extras.h
//  OneWay
//
//  Created by nrj on 2/23/10.
//  Copyright 2010 cocoaism.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSString (Extras)

- (BOOL)isEmptyOrNil;

- (NSString *)stringWithTruncatingToLength:(unsigned)length;

- (NSString *)stringTruncatedToLength:(unsigned int)length direction:(unsigned)truncateFrom;

- (NSString *)stringTruncatedToLength:(unsigned int)length direction:(unsigned)truncateFrom withEllipsisString:(NSString *)ellipsis;

- (NSString *)stringTruncatedAtLastInstanceOfCharacter:(NSString *)character;

@end
