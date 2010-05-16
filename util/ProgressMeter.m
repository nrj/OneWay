//
//  ProgressMeter.m
//  OneWay
//
//  Copyright 2010 Nick Jensen <http://goto11.net>
//

#import "ProgressMeter.h"



const int BYTES_IN_A_KILOBYTE = 1024;
const int BYTES_IN_A_MEGABYTE = 1048576;
const int BYTES_IN_A_GIGABYTE = 1073741824;

const int SECONDS_IN_A_MINUTE = 60;
const int SECONDS_IN_A_HOUR   = 3600;
const int SECONDS_IN_A_DAY    = 86400;

NSString * const BytePrefix		= @"B";
NSString * const KiloBytePrefix = @"KB";
NSString * const MegaBytePrefix	= @"MB";
NSString * const GigaBytePrefix	= @"GB";

NSString * const DayString		= @"day";
NSString * const HourString		= @"hour";
NSString * const MinuteString	= @"minute";
NSString * const SecondString	= @"second";


@implementation ProgressMeter


/*
 * Returns a nice string representation of the amount uploaded thus far.
 *
 *     e.g, "140KB of 2MB"
 */
+ (NSString *)uploadedAmount:(Upload *)upload
{
	NSString *totalBytes = [ProgressMeter stringRepresentationOfBytes:[upload totalBytes]];
	
	NSString *totalBytesUploaded = [ProgressMeter stringRepresentationOfBytes:[upload totalBytesUploaded]];
	
	return [NSString stringWithFormat:@"%@ of %@", totalBytesUploaded, totalBytes];
}


/*
 * Returns a nice string representation of the current upload speed.
 *
 *     e.g, "4.2 MB/s"
 */
+ (NSString *)uploadSpeed:(Upload *)upload
{
	NSString *amount = [ProgressMeter stringRepresentationOfBytes:[upload bytesPerSecond]];
		
	return [NSString stringWithFormat:@"%@/s", amount];
}


/*
 * Returns a nice string representation of the upload time remaining.
 *
 *     e.g, "6 minutes, 45 seconds"
 */
+ (NSString *)uploadTimeRemaining:(Upload *)upload
{	
	NSString *timeRemaining = nil;
	
	int daysRemaining = (int)[upload secondsRemaining] / SECONDS_IN_A_DAY;
	int hoursRemaining = (int)[upload secondsRemaining] / SECONDS_IN_A_HOUR;
	int minutesRemaining = (int)[upload secondsRemaining] / SECONDS_IN_A_MINUTE;
	
	if (daysRemaining > 1)
	{
		// > 1 Day remaining
		
		int remainder = (int)[upload secondsRemaining] % SECONDS_IN_A_DAY;
		
		if ((remainder / SECONDS_IN_A_HOUR) > 1)
		{
			timeRemaining = [NSString stringWithFormat:@"%d days, %d hours", daysRemaining, (remainder / SECONDS_IN_A_HOUR)];
		}
		else if ((remainder / SECONDS_IN_A_HOUR) == 1)
		{
			timeRemaining = [NSString stringWithFormat:@"%d days, 1 hour", daysRemaining];			
		}
		else if ((remainder / SECONDS_IN_A_MINUTE) > 1)
		{
			timeRemaining = [NSString stringWithFormat:@"%d days, %d minutes", daysRemaining, (remainder / SECONDS_IN_A_MINUTE)];
		}
		else if ((remainder / SECONDS_IN_A_MINUTE) == 1)
		{
			timeRemaining = [NSString stringWithFormat:@"%d days, 1 minute", daysRemaining];
		}
		else
		{
			timeRemaining = [NSString stringWithFormat:@"%d days, %d seconds", daysRemaining, remainder];
		}
	}
	else if (daysRemaining == 1)
	{
		//  == 1 day remaining
		
		int remainder = (int)[upload secondsRemaining] % SECONDS_IN_A_DAY;
		
		if ((remainder / SECONDS_IN_A_HOUR) > 1)
		{
			timeRemaining = [NSString stringWithFormat:@"1 day, %d hours", (remainder / SECONDS_IN_A_HOUR)];
		}
		else if ((remainder / SECONDS_IN_A_HOUR) == 1)
		{
			timeRemaining = [NSString stringWithFormat:@"1 day, 1 hour"];			
		}
		else if ((remainder / SECONDS_IN_A_MINUTE) > 1)
		{
			timeRemaining = [NSString stringWithFormat:@"1 day, %d minutes", (remainder / SECONDS_IN_A_MINUTE)];
		}
		else if ((remainder / SECONDS_IN_A_MINUTE) == 1)
		{
			timeRemaining = [NSString stringWithFormat:@"1 day, 1 minute"];
		}
		else
		{
			timeRemaining = [NSString stringWithFormat:@"1 day, %d seconds", remainder];
		}
		
	}
	else if (hoursRemaining > 1)
	{
		//  > 1 hour remaining
		
		int remainder = (int)[upload secondsRemaining] % SECONDS_IN_A_HOUR;
		
		if ((remainder / SECONDS_IN_A_MINUTE) > 1)
		{
			timeRemaining = [NSString stringWithFormat:@"%d hours, %d minutes", hoursRemaining, (remainder / SECONDS_IN_A_MINUTE)];
		}
		else if ((remainder / SECONDS_IN_A_MINUTE) == 1)
		{
			timeRemaining = [NSString stringWithFormat:@"%d hours, 1 minute", hoursRemaining];
		}
		else
		{
			timeRemaining = [NSString stringWithFormat:@"%d hours, %d seconds", hoursRemaining, remainder];
		}		
		
	}
	else if (hoursRemaining == 1)
	{
		//  == 1 hour remaining
		
		int remainder = (int)[upload secondsRemaining] % SECONDS_IN_A_HOUR;
		
		if ((remainder / SECONDS_IN_A_MINUTE) > 1)
		{
			timeRemaining = [NSString stringWithFormat:@"1 hour, %d minutes", (remainder / SECONDS_IN_A_MINUTE)];
		}
		else if ((remainder / SECONDS_IN_A_MINUTE) == 1)
		{
			timeRemaining = [NSString stringWithFormat:@"1 hour, 1 minute"];
		}
		else
		{
			timeRemaining = [NSString stringWithFormat:@"1 hour, %d seconds", remainder];
		}
	}
	else if (minutesRemaining > 1)
	{
		//  > 1 minute remaining
		
		int remainder = (int)[upload secondsRemaining] % SECONDS_IN_A_MINUTE;
		
		timeRemaining = [NSString stringWithFormat:@"%d minutes, %d seconds", minutesRemaining, remainder];
	}
	else if (minutesRemaining == 1)
	{
		//  == 1 minute remaining
		
		int remainder = (int)[upload secondsRemaining] % SECONDS_IN_A_MINUTE;
		
		timeRemaining = [NSString stringWithFormat:@"1 minute, %d seconds", remainder];
	}
	else
	{
		//  < 1 minute remaining
		
		timeRemaining = [NSString stringWithFormat:@"%d seconds", (int)[upload secondsRemaining]];		
	}	
	
	return timeRemaining;
}


/*
 * Returns a string representation for a given number of bytes.
 *
 *     e.g, "4 MB", "512 KB", "2.4 GB"
 */
+ (NSString *)stringRepresentationOfBytes:(double)bytes
{
	NSString *str;
	
	if ((int)(bytes / BYTES_IN_A_GIGABYTE) > 0)
	{
		//  > 1 GB
		str = [NSString stringWithFormat:@"%.1f %@", (bytes / BYTES_IN_A_GIGABYTE), GigaBytePrefix];
	}
	else if ((int)(bytes / BYTES_IN_A_MEGABYTE) > 0)
	{
		//  > 1 MB
		str = [NSString stringWithFormat:@"%.1f %@", (bytes / BYTES_IN_A_MEGABYTE), MegaBytePrefix];		
	}
	else if ((int)(bytes / BYTES_IN_A_KILOBYTE) > 0)
	{
		//  > 1 KB
		str = [NSString stringWithFormat:@"%.1f %@", (bytes / BYTES_IN_A_KILOBYTE), KiloBytePrefix];
	}
	else
	{
		//  < 1 KB
		str = [NSString stringWithFormat:@"%.0f %@", bytes, BytePrefix];
	}
	
	return str;
}


@end
