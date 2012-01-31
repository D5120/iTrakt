//
//  TCMTrakt.h
//  iTrakt
//
//  Created by Martin Pittenauer on 31.01.12.
//  Copyright (c) 2012 TheCodingMonkeys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>

@class TCMTVShow;

@interface TCMTrakt : NSObject <RKRequestDelegate> {


}

+ (TCMTrakt *)sharedInstance;
-(void)watching:(TCMTVShow *)aShow;
-(void)cancelWatching;
-(void)scrobble:(TCMTVShow *)aShow;
-(NSString*)username;
@end
