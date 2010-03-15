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
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
	NSString *destinationPath = [[paths objectAtIndex:0] stringByAppendingString:@"/tmp.db"];
	db = [[FMDatabase databaseWithPath:destinationPath] retain];
	
	if (! [[NSFileManager defaultManager] fileExistsAtPath: destinationPath]) {
		// didn't find db, need to copy
		NSString *backupDbPath = [[NSBundle mainBundle]
								  pathForResource:@"tmp"
								  ofType:@"db"];
		if (backupDbPath == nil) {
			// couldn't find backup db to copy, bail
			return NO;
		} else {
			BOOL copiedBackupDb = [[NSFileManager defaultManager]
								   copyItemAtPath:backupDbPath
								   toPath:destinationPath
								   error:nil];
			if (! copiedBackupDb) {
				// copying backup db failed, bail
				return NO;
			}
		}
	}
	
	if(![db open]) {
		[self release];
		return nil;
	}
	return self;
}

-(void)addEvent:(Event *)aEvent evDate:(NSDate *)aEvDate
{
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setTimeStyle:NSDateFormatterNoStyle];
	[formatter setDateFormat:@"MMM d"];
	NSString *stringFromDate = [formatter stringFromDate:aEvDate];
	[db beginTransaction];
	[db executeUpdate:@"insert into event (eventDate, eventName) values (?, ?)", stringFromDate, aEvent.name];
	[formatter release];
	
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

-(NSArray *)favoriteEvents
{
	FMResultSet *rs = [db executeQuery:@"select eventID, eventName, eventDate from event"];
	NSMutableArray *e = [NSMutableArray array];
	NSString *tagQuery;
	FMResultSet *rsTag;
	while([rs next]) {
		NSMutableArray *t = [NSMutableArray array];
		tagQuery = [NSString stringWithFormat:@"select dbTagName, dbTagUrl from tag where evID = %d", [rs intForColumnIndex:0]];
		rsTag = [db executeQuery:tagQuery];
		while ([rsTag next]) {
			[t addObject:[[[Tag alloc] initWithTagname:[rsTag stringForColumnIndex:0]
											url:[rsTag stringForColumnIndex:1]] autorelease]];
		}
		[e addObject:[[[Event alloc] initWithName:[rs stringForColumnIndex:1]
											 tags:t
											 pkID:[NSNumber numberWithInt:[rs intForColumnIndex:0]]
										   evDate:[rs stringForColumnIndex:2]] autorelease]];
	}
	return [NSArray arrayWithArray:e];
}

-(void)dealloc
{
	[super dealloc];
	[db close];
}

@end
