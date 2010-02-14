/*
 * OWConstants
 */

#import "OWConstants.h"

// App Name
NSString * const OWApplicationName = @"OneWay";

// Log File
NSString * const OWLogFile = @"~/Library/OneWay/OneWay.log";

// Notifications
NSString * const OWQueueTransferNotification	= @"oneWayQueueTransferNotification";
NSString * const OWQueueNewTransferNotification = @"oneWayQueueNewTransferNotification";

// Files & Directories
NSString * const OWSettingsDirectory	= @"~/Library/OneWay";
NSString * const OWPluginDirectory		= @"~/Library/Contextual Menu Items";
NSString * const OWSavedLocationsFile	= @"~/Library/OneWay/locations.data";
NSString * const OWSavedTransfersFile	= @"~/Library/OneWay/transfers.data";
NSString * const OWMenuItemsFile		= @"~/Library/OneWay/.menuItems";

// Script Locations
NSString * const OWRestartFinderScript = @"Contents/Resources/restart_finder.sh";

// Plugin Source/Destination
NSString * const OWPluginSourceFile			= @"Contents/Resources/OneWayPlugin.plugin";
NSString * const OWPluginDestinationFile	= @"~/Library/Contextual Menu Items/OneWay.plugin";

// Toolbar Identifiers
NSString * const OWTransferToolbarIdentifier	= @"transferToolbarIdentifier";
NSString * const OWTransferToolbarStopItem		= @"transferToolbarStopItem";
NSString * const OWTransferToolbarClearItem		= @"transferToolbarClearItem";
NSString * const OWTransferToolbarDrawerItem	= @"transferToolbarDrawerItem";
NSString * const OWTransferToolbarTransfersItem = @"transferToolbarTransfersItem";
NSString * const OWTransferToolbarLogItem		= @"transferToolbarLogItem";

// Status Strings
NSString * const OWStatusQueued				= @"Queued";
NSString * const OWStatusConnecting			= @"Connecting";
NSString * const OWStatusAuthenticating		= @"Authenticating";
NSString * const OWStatusUploading			= @"Uploading";
NSString * const OWStatusCancelled			= @"Cancelled";
NSString * const OWStatusFinished			= @"Finished";
NSString * const OWStatusConnectionTimeout	= @"Connection Timed Out";
NSString * const OWStatusConnectionRefused	= @"Connection Refused";
NSString * const OWStatusInvalidPassword	= @"Invalid Password";
NSString * const OWStatusPermissionDenied	= @"Invalid File Permissions";
