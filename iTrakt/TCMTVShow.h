//
//  TCMTVShow.h
//  iTrakt
//
//  Created by Martin Pittenauer on 31.01.12.
//  Copyright (c) 2012 TheCodingMonkeys. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TCMTVShow : NSObject
@property (nonatomic, strong) NSString *show;
@property (nonatomic, strong) NSString *episodeName;
@property (nonatomic, strong) NSString *tvdbID;
@property (nonatomic, strong) NSString *persistentID;
@property (nonatomic) NSInteger seasonNumber;
@property (nonatomic) NSInteger episodeNumber;
@property (nonatomic) NSInteger playCount;
@property (nonatomic) NSInteger showYear;
@property (nonatomic) NSInteger duration;

+(TCMTVShow *)showWithCurrentTunesTrack;
+(BOOL)TVShowPlaying;
+(NSInteger)playCountForID:(NSString*)anID;

@end
