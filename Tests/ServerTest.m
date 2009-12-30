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

@end
