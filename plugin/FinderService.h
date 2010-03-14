//
//  FinderService.h
//  OneWay
//
//  Created by nrj on 3/14/10.
//  Copyright 2010 cocoaism.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class Location;


NSString * const OWXPathForPListTitleNode;

NSString * const OWXPathForWorkflowScriptNode;

NSString * const OWUploadToNewLocationBundleName;

NSString * const OWUploadToNewLocationTitle;

NSString * const OWUploadToNewLocationScript;

NSString * const OWUploadToExistingLocationBundleName;

NSString * const OWUploadToExistingLocationTitle;

NSString * const OWUploadToExistingLocationScript;


@interface FinderService : NSObject


+ (void)updateForLocations:(NSArray *)locations;

+ (void)createServiceForNewLocation;

+ (void)createServiceForLocation:(Location *)location atIndex:(int)index;

+ (void)removeServiceFromLocations:(NSArray *)locations atIndex:(int)index;

+ (void)createServiceDirectory;

+ (void)createServiceBundle:(NSString *)name withWorkflowData:(NSXMLDocument *)workflow plistData:(NSXMLDocument *)plist;

+ (NSXMLDocument *)workflowDocument;

+ (NSXMLDocument *)plistDocument;

+ (void)reload;


@end
