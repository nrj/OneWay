/*
 * OWConstants
 */

enum OWTableViewType {
	OWTableViewTransfers,
	OWTableViewMenuItems
};

enum OWProtocolType {
	OWLocationTypeSFTP,
	OWLocationTypeFTP,
	OWLocationTypeS3
};

enum OWContextInfo {
	OWContextCreateLocation,
	OWContextCreateLocationAndTransferFiles,
	OWContextUpdateLocation,
	OWContextUpdateLocationAndTransferFiles,
	OWContextDeleteLocation
};

// App Name
NSString * const OWApplicationName;

// Log File
NSString * const OWLogFile;

// Notifications
NSString * const OWQueueTransferNotification;
NSString * const OWQueueNewTransferNotification;

// Files & Directories
NSString * const OWSettingsDirectory;
NSString * const OWPluginDirectory;
NSString * const OWSavedLocationsFile;
NSString * const OWSavedTransfersFile;
NSString * const OWMenuItemsFile;

// Script Locations
NSString * const OWRestartFinderScript;
NSString * const OWRemoveServicesScript;

// Plugin Source/Destination
NSString * const OWPluginSourceFile;
NSString * const OWPluginDestinationFile;

// Toolbar Identifiers
NSString * const OWTransferToolbarIdentifier;
NSString * const OWLocationToolbarIdentifier;

NSString * const OWViewToggleMenuItem;

NSString * const OWRetryTransfersMenuItem;
NSString * const OWStopTransfersMenuItem;
NSString * const OWClearTransfersMenuItem;

NSString * const OWCreateLocationMenuItem;
NSString * const OWDeleteLocationMenuItem;

// Service Constants

NSString * const OWServiceDirectory;
NSString * const OWServiceWorkflowTemplate;
NSString * const OWServicePListTemplate;
NSString * const OWServiceThumbnail;

// Labels

NSString * const USERNAME_LABEL;
NSString * const PASSWORD_LABEL;
NSString * const PASSPHRASE_LABEL;
NSString * const DIRECTORY_LABEL;
NSString * const S3DIRECTORY_LABEL;
NSString * const S3USERNAME_LABEL;
NSString * const S3PASSWORD_LABEL;
