//
//  TCMTrakt.h
//  iTrakt
//
//  Created by Martin Pittenauer on 31.01.12.
//  Copyright (c) 2012 TheCodingMonkeys. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TCMTVShow;

@interface TCMTrakt : NSObject {


}

-(void)watching:(TCMTVShow *)aShow;
-(void)cancelWatching;
-(void)scrobble:(TCMTVShow *)aShow;
-(NSString*)username;
@end
