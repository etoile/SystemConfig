/*
 * SCMachineInfo_OpenBSD.m - OpenBSD specific backend for SCMachineInfo
 *
 * Copyright 2006, David Chisnall
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without 
 * modification, are permitted provided that the following conditions are met:
 *
 * Redistributions of source code must retain the above copyright notice, 
 * this list of conditions and the following disclaimer.
 * 
 * Redistributions in binary form must reproduce the above copyright notice, 
 * this list of conditions and the following disclaimer in the documentation 
 * and/or other materials provided with the distribution.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE 
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
 * POSSIBILITY OF SUCH DAMAGE.
 */

#ifdef OPENBSD

#import "SCMachineInfo.h"
#import "TRSysctl.h"

@implementation SCMachineInfo (OpenBSD)

+ (unsigned long long) realMemory
{
  int sysctlName[] = {CTL_HW, HW_PHYSMEM};

  return (unsigned long long) performIntegerSysctl (sysctlName, 2);
}

+ (unsigned int) cpuMHzSpeed
{
  int sysctlName[] = {CTL_HW, HW_CPUSPEED};

  return performIntegerSysctl (sysctlName, 2);
}

+ (NSString *) cpuName
{
  int sysctlName[] = {CTL_HW, HW_MODEL};

  return performSysctl (sysctlName, 2);
}

+ (BOOL) platformSupported
{
  return YES;
}

@end

#endif // OPENBSD
