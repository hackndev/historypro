//
//  Tag.h
//  TodayInHistory
//
//  Created by Serg Bayda on 10/31/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Tag : NSObject {
	NSString *tagname;
	NSString *url;

}

- (id)initWithTagname:(NSString *)aTagname
				  url:(NSString *)aUrl;

@property (readonly) NSString *tagname;
@property (readonly) NSString *url;

@end
