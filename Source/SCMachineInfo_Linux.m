/*
    SCMachineInfo_Linux.m

    Linux specific backend for SCMachineInfo.

    Copyright (C) 2005, 2006  Saso Kiselkov

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
*/

#ifdef LINUX

#import "SCMachineInfo.h"
#import <sys/types.h>
#import <sys/stat.h>

#import <Foundation/NSArray.h>
#import <Foundation/NSCharacterSet.h>
#import <Foundation/NSFileManager.h>
#import <Foundation/NSString.h>

/* A dictionary mapping cpu reference identifiers to cpu commercial names. */
static NSDictionary *cpuNames = nil;

static inline int
my_round (float x)
{
  return (int) (x + 0.5);
}

@implementation SCMachineInfo (Linux)

+ (void) initialize
{
    if (self == [SCMachineInfo class])
      {
        cpuNames = [NSDictionary dictionaryWithObjectsAndKeys:
          /* PowerPC cpus
             NOTE: 750GX, 750FX, 970FX, 970MP are taken in account by trimming 
             the suffix. */
          @"G3", @"740", @"G3", @"745", @"G3", @"750", @"G3", @"755",
          @"G4", @"7400", @"G4", @"7410", @"G4", @"7450", @"G4", @"7447", 
            @"G4", @"7457", @"G4", @"7448", @"G4", @"7447/7457",
          @"G5", @"970", nil];
      }
}

/* Returns the value of the memSize from the meminfo file.
 * Slex's fixme: I will reimplement this file from scratch with a BSD license.
 */
+ (unsigned long long) realMemory
{
	NSEnumerator *e = [[[NSString stringWithContentsOfFile:@"/proc/meminfo"] 
								componentsSeparatedByString: @"\n"]
								objectEnumerator];
	NSString * line = [e nextObject];
	if ([line hasPrefix: @"MemTotal"])
	{
		NSArray * comps = [line componentsSeparatedByString: @":"];
		NSString *memSize = [comps objectAtIndex:1];
		return [memSize intValue];
	}
	  
	return 0; 
}

+ (unsigned int) cpuMHzSpeed
{
  // read /proc/cpuinfo for the processor type
  NSString *maxFreq = [NSString stringWithContentsOfFile: @"/sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq"];
  return [maxFreq intValue];
}

+ (NSString *) cpuName
{
  // read /proc/cpuinfo for the processor type
  NSArray * components = [[NSString stringWithContentsOfFile: @"/proc/cpuinfo"]
    componentsSeparatedByString: @"\n"];
  NSEnumerator * e = [components objectEnumerator];
  NSString * line = nil;

  /* For x86 and other architectures */
  while ((line = [e nextObject]) != nil)
    {
      if ([line hasPrefix: @"model name"])
        {
          NSArray * comps = [line componentsSeparatedByString: @":"];

          if ([comps count] > 1)
            {
              return [[comps objectAtIndex: 1] stringByTrimmingSpaces];
            }
        }
     }

  e = [components objectEnumerator];
  line = nil;

  /* For ppc architecture */
  while ((line = [e nextObject]) != nil)
    {
      if ([line hasPrefix: @"cpu"])
        {
          NSArray * comps = [line componentsSeparatedByString: @":"];

          /* Example /proc/cpuinfo on a Mac mini:
             cpu             : 7447A, altivec supported */

          if ([comps count] > 1)
            {
              NSString * cpuIdentifier = [comps objectAtIndex: 1];
              NSString * cpuName;
              NSCharacterSet * letterSet = [NSCharacterSet letterCharacterSet];

              cpuIdentifier = [[cpuIdentifier 
                componentsSeparatedByString: @","] objectAtIndex: 0];
              cpuName = [cpuNames objectForKey: 
                  [[cpuIdentifier stringByTrimmingCharactersInSet: letterSet]
                  stringByTrimmingSpaces]];
              cpuName = [NSString stringWithFormat: 
                  @"PowerPC %@ (%@)", cpuName, cpuIdentifier];

              return cpuName;
            }
        }
    }

  return nil;
}

+ (BOOL) platformSupported
{
  return YES;
}

@end

#endif // LINUX
