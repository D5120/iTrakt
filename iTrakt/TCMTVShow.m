//
//  TCMTVShow.m
//  iTrakt
//
//  Created by Martin Pittenauer on 31.01.12.
//  Copyright (c) 2012 TheCodingMonkeys. All rights reserved.
//

#import "TCMTVShow.h"
#import "iTunes.h"

@implementation TCMTVShow

@synthesize show, episodeName, seasonNumber, episodeNumber, tvdbID, playCount, showYear, duration, persistentID;

+(TCMTVShow *)showWithiTunesTrack:(iTunesTrack *)track {
    TCMTVShow *show = nil;
    if (track.videoKind == iTunesEVdKTVShow) {
        show = [TCMTVShow new];
        show.show           = track.show;
        show.episodeName    = track.name;
        show.seasonNumber   = track.seasonNumber;
        show.episodeNumber  = track.episodeNumber;
        show.tvdbID         = track.episodeID;
        show.playCount      = track.playedCount;
        show.showYear       = track.year;
        show.duration       = (NSInteger)(track.duration/60); // we want minutes, itunes gives us seconds
        show.persistentID   = track.persistentID;
    }
    
    return show;
}

-(NSString *)description{
    return [NSString stringWithFormat:@"%@ - %@ (S%02dE%02d)",self.show, self.episodeName, self.seasonNumber, self.episodeNumber];
}

@end
