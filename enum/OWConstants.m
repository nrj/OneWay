/*
 * OWConstants
 */

#import "OWConstants.h"

// App Name
NSString * const OWApplicationName = @"OneWay";

// Log File
NSString * const OWLogFile = @"~/Library/OneWay/OneWay.log";

// Notifications
NSString * const OWQueueTransferNotification	= @"OneWayQueueTransferNotification";
NSString * const OWQueueNewTransferNotification = @"OneWayQueueNewTransferNotification";

// Files & Directories
NSString * const OWSettingsDirectory	= @"~/Library/OneWay";
NSString * const OWPluginDirectory		= @"~/Library/Contextual Menu Items";
NSString * const OWSavedLocationsFile	= @"~/Library/OneWay/locations.data";
NSString * const OWSavedTransfersFile	= @"~/Library/OneWay/transfers.data";
NSString * const OWMenuItemsFile		= @"~/Library/OneWay/.menuItems";

// Script Locations
NSString * const OWRestartFinderScript = @"Contents/Resources/restart_finder.sh";
NSString * const OWRemoveServicesScript = @"Contents/Resources/remove_services.sh";

// Plugin Source/Destination - for 10.5
NSString * const OWPluginSourceFile			= @"Contents/Resources/OneWayPlugin.plugin";
NSString * const OWPluginDestinationFile	= @"~/Library/Contextual Menu Items/OneWay.plugin";

// Toolbar Identifier
NSString * const OWTransferToolbarIdentifier = @"OneWayTransferToolBarIdentifier";
NSString * const OWLocationToolbarIdentifier = @"OneWayLocationToolBarIdentifier";

NSString * const OWViewToggleMenuItem		= @"OneWayViewToggleMenuItem";

NSString * const OWRetryTransfersMenuItem	= @"OneWayRetryTransfersMenuItem";
NSString * const OWStopTransfersMenuItem	= @"OneWayStopTransfersMenuItem";
NSString * const OWClearTransfersMenuItem	= @"OneWayClearTransfersMenuItem";

NSString * const OWCreateLocationMenuItem	= @"OneWayCreateLocationMenuItem";
NSString * const OWDeleteLocationMenuItem	= @"OneWayDeleteLocationMenuItem";

// Service Constants

NSString * const OWServiceDirectory			= @"~/Library/Services";
NSString * const OWServiceWorkflowTemplate	= @"Contents/Resources/template.wflow";
NSString * const OWServicePListTemplate		= @"Contents/Resources/template.plist";
NSString * const OWServiceThumbnail			= @"Contents/Resources/Thumbnail.png";

// Labels

NSString * const USERNAME_LABEL = @"Username";
NSString * const PASSWORD_LABEL = @"Password";
NSString * const PASSPHRASE_LABEL = @"Passphrase";
NSString * const DIRECTORY_LABEL = @"Directory";
NSString * const S3DIRECTORY_LABEL = @"Bucket Name";
NSString * const S3USERNAME_LABEL = @"Access Key ID";
NSString * const S3PASSWORD_LABEL = @"Secret Acc. Key";
