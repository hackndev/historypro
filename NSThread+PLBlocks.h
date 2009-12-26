//
//  NSRunLoop+PLBlocks.h
//  NSOperationBlocks
//
//  Created by Landon Fuller on 7/4/09.
//  Copyright 2009 Plausible Labs Cooperative, Inc.. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSThread (PLBlocks)
+ (void) pl_performBlockOnNewThread: (void (^)()) block;
- (void) pl_performBlock: (void (^)()) block;
- (void) pl_performBlock: (void (^)()) block waitUntilDone: (BOOL) wait;
@end
