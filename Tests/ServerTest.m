//
//  ServerTest.m
//  TodayInHistory
//
//  Created by Farcaller on 29.12.09.
//  Copyright 2009 Codeneedle. All rights reserved.
//

#import "GTMSenTestCase.h"
#import "Server.h"
#import <OCMock/OCMock.h>

@interface Server (PrivateAPI)

- (void)_fetchURL:(NSURL *)url invoking:(DataBlock)block;
- (NSData *)_fetchURL:(NSURL *)url;
- (BOOL)_parseData:(NSData *)htmlData;

@end

@interface ServerTest : GTMTestCase { } @end


@implementation ServerTest

- (void)setUp
{
	
}

- (void)testServerFetchCache
{
	Server *s = [Server sharedInstance];
	STAssertNotNil(s, @"Server hasn't inited itself!");
	
	NSString *path = [[NSBundle mainBundle] pathForResource:@"December_13" ofType:@"html"];
	NSURL *url = [NSURL fileURLWithPath:path];
	NSData *html = [NSData dataWithContentsOfFile:path];
	
	[[NSUserDefaults standardUserDefaults] setValue:nil forKey:@"cacheDate"];
	[[NSUserDefaults standardUserDefaults] setValue:nil forKey:@"cacheData"];
	NSData *fhtml = [s _fetchURL:url];
	STAssertEqualObjects(html, fhtml, @"Data fetched is not same as data stored");
	STAssertEqualObjects(html, [[NSUserDefaults standardUserDefaults] valueForKey:@"cacheData"], @"Data cached is not same as data stored");
	fhtml = [s _fetchURL:url];
	STAssertEqualObjects(html, fhtml, @"Data fetched from cache is not same as data stored");
}

- (void)testServerParse
{
	NSArray *testPages = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ParserTests" ofType:@"plist"]];
	Server *s = [Server sharedInstance];
	STAssertNotNil(s, @"Server hasn't inited itself!");
	
	for(NSDictionary *d in testPages) {
		NSString *testPage = [d objectForKey:@"page"];
		NSLog(@"Testing parser in page %@", testPage);
		NSString *path = [[NSBundle mainBundle] pathForResource:testPage ofType:@"html"];
		NSData *html = [NSData dataWithContentsOfFile:path];
		STAssertNotNil(html, @"HTML data for test page %@ is missing", testPage);
	
		BOOL parseOk = [s _parseData:html];
		STAssertTrue(parseOk, @"Parser failed somehow for page %@", testPage);
		/*
		int totalEvents = 0;
		for(NSNumber *n in [[d objectForKey:@"categories"] allValues]) {
			totalEvents += [n intValue];
		}
		STAssertTrue([s.events count] == totalEvents, @"Supposed to parse %d events, but got %d in page %@",
					 totalEvents, [s.events count], testPage);
		*/
		int totalCategories = [[[d objectForKey:@"categories"] allKeys] count];
		STAssertTrue([s.list count] == totalCategories, @"Supposed to parse %d categories, but got %d in page %@",
					 totalCategories, [s.list count], testPage);
		
		NSDictionary *routed = [d objectForKey:@"categories"];
		for(NSDictionary *d in s.list) {
			NSNumber *n = [routed objectForKey:[d objectForKey:@"Title"]];
			STAssertNotNil(n, @"Unexpected category %@ in page %@", [d objectForKey:@"Title"], testPage);
			NSArray *e = [d objectForKey:@"Objects"];
			STAssertTrue([e count] == [n intValue], @"Expected %d objects in %@, but got %d in page %@",
						 [n intValue], [d objectForKey:@"Title"], [e count], testPage);
		}
	}
}

@end
