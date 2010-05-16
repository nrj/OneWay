//
//  NSString+Extras.h
//  OneWay
//
//  Copyright 2010 Nick Jensen <http://goto11.net>
//

#import <Cocoa/Cocoa.h>


typedef enum {
	NSTruncateStart = 0,
	NSTruncateMiddle = 1,
	NSTruncateEnd = 2
} NSTruncateTypes;


@interface NSString (Extras)

- (NSString *)stringWithTruncatingToLength:(unsigned)length;

- (NSString *)stringTruncatedToLength:(unsigned int)length direction:(unsigned)truncateFrom;

- (NSString *)stringTruncatedToLength:(unsigned int)length direction:(unsigned)truncateFrom withEllipsisString:(NSString *)ellipsis;

- (NSString *)stringTruncatedAtLastInstanceOfCharacter:(NSString *)character;

@end
