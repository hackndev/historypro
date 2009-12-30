//
//  GTMIPhoneUnitTestDelegate.m
//
//  Copyright 2008 Google Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License"); you may not
//  use this file except in compliance with the License.  You may obtain a copy
//  of the License at
// 
//  http://www.apache.org/licenses/LICENSE-2.0
// 
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
//  WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  See the
//  License for the specific language governing permissions and limitations under
//  the License.
//

#import "GTMIPhoneUnitTestDelegate.h"

#import "GTMDefines.h"
#if !GTM_IPHONE_SDK
#error GTMIPhoneUnitTestDelegate for iPhone only
#endif
#import <objc/runtime.h>
#import <stdio.h>
#import <UIKit/UIKit.h>
#import "GTMSenTestCase.h"
#import <stdio.h>

typedef int File_Writer_t(void *, const char *, int);

static NSMutableString *StdOut = nil;
static NSMutableString *StdErr = nil;
File_Writer_t *WriterOut = nil;
File_Writer_t *WriterErr = nil;

static int WriterOutHook(void *inFD, const char *buffer, int size)
{
	NSString *tmp = [[NSString alloc] initWithBytes:buffer length:size encoding:NSUTF8StringEncoding];
	
	[StdOut appendString:tmp];
	
	[tmp release];
	return size;
}

static int WriterErrHook(void *inFD, const char *buffer, int size)
{
	NSString *tmp = [[NSString alloc] initWithBytes:buffer length:size encoding:NSUTF8StringEncoding];
	
	[StdErr appendString:tmp];
	
	[tmp release];
	return size;
}


static void HookIOStart()
{
	StdOut = [[NSMutableString alloc] init];
	StdErr = [[NSMutableString alloc] init];

	WriterOut = stdout->_write;
	WriterErr = stderr->_write;
	
	stdout->_write = &WriterOutHook;
	stderr->_write = &WriterErrHook;
}

static void HookIOEnd()
{
	stdout->_write = WriterOut;
	stderr->_write = WriterErr;
	
	[StdOut release];
	[StdErr release];
	StdOut = StdErr = nil;
}

@implementation GTMIPhoneUnitTestDelegate

// Run through all the registered classes and run test methods on any
// that are subclasses of SenTestCase. Terminate the application upon
// test completion.
- (void)applicationDidFinishLaunching:(UIApplication *)application {
  [self runTests];
  
  if (!getenv("GTM_DISABLE_TERMINATION")) {
    // To help using xcodebuild, make the exit status 0/1 to signal the tests
    // success/failure.
    int exitStatus = (([self totalFailures] == 0U) ? 0 : 1);
    // Alternative to exit(status); so it cleanly terminates the UIApplication
    // and classes that depend on this signal to exit cleanly.
    if ([application respondsToSelector:@selector(_terminateWithStatus:)]) {
      [application performSelector:@selector(_terminateWithStatus:)
                        withObject:(id)exitStatus];
    } else {
      exit(exitStatus);
    }
  }
}

// Run through all the registered classes and run test methods on any
// that are subclasses of SenTestCase. Print results and run time to
// the default output.
- (void)runTests
{
	int count = objc_getClassList(NULL, 0);
	NSMutableData *classData = [NSMutableData dataWithLength:sizeof(Class) * count];
	Class *classes = (Class*)[classData mutableBytes];
	_GTMDevAssert(classes, @"Couldn't allocate class list");
	objc_getClassList(classes, count);
	totalFailures_ = 0;
	totalSuccesses_ = 0;
	NSString *suiteName = [[NSBundle mainBundle] bundlePath];
	NSDate *suiteStartDate = [NSDate date];
	NSString *suiteStartString
    = [NSString stringWithFormat:@"Test Suite '%@' started at %@\n",
	   suiteName, suiteStartDate];
	fputs([suiteStartString UTF8String], stderr);
	fflush(stderr);
	for (int i = 0; i < count; ++i) {
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		Class currClass = classes[i];
		if (class_respondsToSelector(currClass, @selector(conformsToProtocol:)) &&
			[currClass conformsToProtocol:@protocol(SenTestCase)]) {
			NSDate *fixtureStartDate = [NSDate date];
			NSString *fixtureName = NSStringFromClass(currClass);
			NSString *fixtureStartString
#ifdef TEAMCITY
			= [NSString stringWithFormat:@"##teamcity[testSuiteStarted name='%@' timestamp='%@']\n",
			   [self _tcEscape:fixtureName], [self _tcDate:fixtureStartDate]];
#else
			= [NSString stringWithFormat:@"Test Suite '%@' started at %@\n",
			   fixtureName, fixtureStartDate];
#endif
			int fixtureSuccesses = 0;
			int fixtureFailures = 0;
			fputs([fixtureStartString UTF8String], stderr);
			fflush(stderr);
			NSArray *invocations = [currClass testInvocations];
			if ([invocations count]) {
				NSInvocation *invocation;
				GTM_FOREACH_OBJECT(invocation, invocations) {
					GTMTestCase *testCase 
					= [[currClass alloc] initWithInvocation:invocation];
					BOOL failed = NO;
					NSDate *caseStartDate = [NSDate date];
					NSString *selectorName = NSStringFromSelector([invocation selector]);
#ifdef TEAMCITY
					NSString *caseStartString
					= [NSString stringWithFormat:@"##teamcity[testStarted name='[%@ %@|]' timestamp='%@']\n",
					   [self _tcEscape:fixtureName], [self _tcEscape:selectorName], [self _tcDate:caseStartDate]];
					fputs([caseStartString UTF8String], stderr);
					fflush(stderr);
					HookIOStart();
#endif			
					@try {
						[testCase performTest];
					} @catch (NSException *exception) {
						failed = YES;
					}
#ifdef TEAMCITY
					NSString *so = [StdOut copy];
					NSString *se = [StdErr copy];
					HookIOEnd();
					NSString *caseIOString = [NSString stringWithFormat:@"##teamcity[testStdOut name='[%@ %@|]' out='%@']\n"
											  @"##teamcity[testStdErr name='[%@ %@|]' out='%@']\n",
											  [self _tcEscape:fixtureName], [self _tcEscape:selectorName], [self _tcEscape:so],
											  [self _tcEscape:fixtureName], [self _tcEscape:selectorName], [self _tcEscape:se]];
					fputs([caseIOString UTF8String], stderr);
					fflush(stderr);
					NSDate *caseEndDate = [NSDate date];
#endif
					if (failed) {
						fixtureFailures += 1;
					} else {
						fixtureSuccesses += 1;
					}
					NSTimeInterval caseEndTime
					= [[NSDate date] timeIntervalSinceDate:caseStartDate];
					NSString *caseEndString
#ifdef TEAMCITY
					= [NSString stringWithFormat:@"##teamcity[testFinished name='[%@ %@|]' timestamp='%@' duration='%.0f']\n",
					   [self _tcEscape:fixtureName], [self _tcEscape:selectorName], [self _tcDate:caseEndDate], caseEndTime];
					if(failed) {
						NSString *failString = [NSString stringWithFormat:@"##teamcity[testFailed name='[%@ %@|]' timestamp='%@' message='test failed' details='message and stack trace']\n",
												[self _tcEscape:fixtureName], [self _tcEscape:selectorName], [self _tcDate:caseEndDate]];
						fputs([failString UTF8String], stderr);
						fflush(stderr);
					}
#else			
					= [NSString stringWithFormat:@"Test Case '-[%@ %@]' %@ (%0.3f "
					   @"seconds).\n",
					   fixtureName, selectorName,
					   failed ? @"failed" : @"passed",
					   caseEndTime];
#endif
					fputs([caseEndString UTF8String], stderr);
					fflush(stderr);
					[testCase release];
				}
			}
			NSDate *fixtureEndDate = [NSDate date];
			NSTimeInterval fixtureEndTime
			= [fixtureEndDate timeIntervalSinceDate:fixtureStartDate];
			NSString *fixtureEndString
#ifdef TEAMCITY
			= [NSString stringWithFormat:@"##teamcity[testSuiteFinished name='%@' timestamp='%@']\n",
			   [self _tcEscape:fixtureName], [self _tcDate:fixtureEndDate]];
#else
			= [NSString stringWithFormat:@"Test Suite '%@' finished at %@.\n"
			   @"Executed %d tests, with %d failures (%d "
			   @"unexpected) in %0.3f (%0.3f) seconds\n\n",
			   fixtureName, fixtureEndDate,
			   fixtureSuccesses + fixtureFailures, 
			   fixtureFailures, fixtureFailures,
			   fixtureEndTime, fixtureEndTime];
#endif			
			fputs([fixtureEndString UTF8String], stderr);
			fflush(stderr);
			totalSuccesses_ += fixtureSuccesses;
			totalFailures_ += fixtureFailures;      
		}
		[pool release];
	}
	NSDate *suiteEndDate = [NSDate date];
	NSTimeInterval suiteEndTime
    = [suiteEndDate timeIntervalSinceDate:suiteStartDate];
	NSString *suiteEndString
    = [NSString stringWithFormat:@"Test Suite '%@' finished at %@.\n"
	   @"Executed %d tests, with %d failures (%d "
	   @"unexpected) in %0.3f (%0.3f) seconds\n\n",
	   suiteName, suiteEndDate,
	   totalSuccesses_ + totalFailures_, 
	   totalFailures_, totalFailures_,
	   suiteEndTime, suiteEndTime];
	fputs([suiteEndString UTF8String], stderr);
	fflush(stderr);
}

- (NSUInteger)totalSuccesses {
  return totalSuccesses_;
}

- (NSUInteger)totalFailures {
  return totalFailures_;
}

#ifdef TEAMCITY
- (NSString *)_tcEscape:(NSString *)s {
	NSMutableString *m = [NSMutableString stringWithString:s];
	[m
	 replaceOccurrencesOfString:@"|"
	 withString:@"||"
	 options:0
	 range:NSMakeRange(0, [m length])];
	[m
	 replaceOccurrencesOfString:@"'"
	 withString:@"|'"
	 options:0
	 range:NSMakeRange(0, [m length])];
	[m
	 replaceOccurrencesOfString:@"\n"
	 withString:@"|n"
	 options:0
	 range:NSMakeRange(0, [m length])];
	[m
	 replaceOccurrencesOfString:@"\r"
	 withString:@"|r"
	 options:0
	 range:NSMakeRange(0, [m length])];
	[m
	 replaceOccurrencesOfString:@"]"
	 withString:@"|]"
	 options:0
	 range:NSMakeRange(0, [m length])];
	return [NSString stringWithString:m];
}

- (NSString *)_tcDate:(NSDate *)d
{
	NSDateFormatter *f = [[[NSDateFormatter alloc] init] autorelease];
	[f setDateFormat:@"YYYY-MM-dd'T'HH:mm:ss.SSSZZZ"];
	// 2008-09-03T14:02:34.487+0400
	return [f stringFromDate:d];
}
#endif

@end
