//
//  Controller+TransferMenu.h
//  OneWay
//
//  Copyright 2010 Nick Jensen <http://goto11.net>
//

#import <Cocoa/Cocoa.h>
#import "Controller.h"

@interface Controller (TransferMenu)

- (IBAction)revealUploadInFinder:(id)sender;

- (void)copyHyperlinkToClipboard:(NSMenuItem *)menuItem;

@end
