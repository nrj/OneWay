//
//  ConnectionDelegate.h
//  objective-curl
//
//  Copyright 2010 Nick Jensen <http://goto11.net>
//


@class RemoteObject;


@protocol ConnectionDelegate

/*
 * Called when curl starts the connection process.
 */
- (void)curlIsConnecting:(RemoteObject *)record;


/*
 * Called when curl successfully connects.
 */
- (void)curlDidConnect:(RemoteObject *)record;


@end