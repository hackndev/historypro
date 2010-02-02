//
//  SQL.m
//  TodayInHistory
//
//  Created by Serg Bayda on 1/23/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SQL.h"
#import "Tag.h"
#import "Server.h"
#import "Event.h"

NSString *kID = @"id";
NSString *kName = @"name";

@implementation SQL

+ (SQL *)sharedInstance
{
	static SQL *sqlbe = nil;
	if(!sqlbe) {
		sqlbe = [[SQL alloc] init];
	}
	return sqlbe;
}

- (id)init
{
	self = [super init];
	if(!self) return self;
	
	db = [[FMDatabase databaseWithPath:@"/Users/serg/Documents/tmp.db"] retain];
	
	if(![db open]) {
		[self release];
		return nil;
	}
	return self;
}

-(void)addEvent:(Event *)aEvent
{
	[db beginTransaction];
	[db executeUpdate:@"insert into event (eventName) values (?)", aEvent.name];
	
	FMResultSet *rs = [db executeQuery:@"select eventID from event where eventName=? LIMIT 1", aEvent.name];
	[rs next];
	for(Tag *enumerator in aEvent.tags)
	{
		[db executeUpdate:@"insert into tag (dbTagName, dbTagUrl, evID) values (?, ?, ?)", enumerator.tagname, enumerator.url, [NSNumber numberWithInt:[rs intForColumn:@"eventID"]]];
	}
	[db commit]; 
	[rs close];
}

-(void)removeFavoriteEvent:(NSNumber *)pk
{
	[db beginTransaction];
	[db executeUpdate:@"delete from tag where evID = ?", pk];
	[db executeUpdate:@"delete from event where eventID = ?", pk];
	[db commit];
}

-(Event *)favoriteEvents
{
	FMResultSet *rs = [db executeQuery:@"select eventID, eventName from event"];
	FMResultSet *rsTag = [db executeQuery:@"select dbTagName, dbTagUrl from tag where evID = ?", [rs stringForColumnIndex:1]];
	NSMutableArray *t = [NSMutableArray array];
	while ([rsTag next]) {
		[t addObject:[[[Tag alloc] initWithTagname:[rsTag stringForColumnIndex:0]
											  url:[rsTag stringForColumnIndex:1]] autorelease]];
	}
	NSMutableArray *e = [NSMutableArray array];
	while([rs next]) {
		[e addObject:[[[Event alloc] initWithName:[rs stringForColumnIndex:1]
											tags:t
											pkID:[NSNumber numberWithInt:[rs intForColumnIndex:0]]] autorelease]];
	}
	return [NSArray arrayWithArray:e];
}

-(void)dealloc
{
	[super dealloc];
	[db close];
}

@end
