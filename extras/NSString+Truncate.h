//
//  NSString+Truncate.h
//  OneWay
//
//  Created by nrj on 8/29/09.
//  Copyright 2009. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Truncate)

- (NSString *)stringWithTruncatingToLength:(unsigned)length;

- (NSString *)stringTruncatedToLength:(unsigned int)length direction:(unsigned)truncateFrom;

- (NSString *)stringTruncatedToLength:(unsigned int)length direction:(unsigned)truncateFrom withEllipsisString:(NSString *)ellipsis;

- (NSString *)stringTruncatedAtLastInstanceOfCharacter:(NSString *)character;

@end
