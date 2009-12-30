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
	NSString *path = [[NSBundle mainBundle] pathForResource:@"December_13" ofType:@"html"];
	NSData *html = [NSData dataWithContentsOfFile:path];
	
	Server *s = [Server sharedInstance];
	STAssertNotNil(s, @"Server hasn't inited itself!");
	BOOL parseOk = [s _parseData:html];
	STAssertTrue(parseOk, @"Parser failed somehow");
	STAssertTrue([s.events count] == 254, @"Supposed to parse 254 events, but got %d", [s.events count]);
	STAssertTrue([s.list count] == 3, @"Supposed to parse 3 categories, but got %d", [s.list count]);
	NSDictionary *routed = [NSDictionary dictionaryWithObjectsAndKeys:
							[NSNumber numberWithInt:34], @"Events",
							[NSNumber numberWithInt:145], @"Birth",
							[NSNumber numberWithInt:75], @"Death",
							nil];
	for(NSDictionary *d in s.list) {
		NSNumber *n = [routed objectForKey:[d objectForKey:@"Title"]];
		STAssertNotNil(n, @"Unexpected category %@", [d objectForKey:@"Title"]);
		NSArray *e = [d objectForKey:@"Objects"];
		STAssertTrue([e count] == [n intValue], @"Expected %d objects in %@, but got %d",
					 [n intValue], [d objectForKey:@"Title"], [e count]);
	}
}

@end
