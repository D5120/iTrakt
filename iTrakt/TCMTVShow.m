//
//  TCMTVShow.m
//  iTrakt
//
//  Created by Martin Pittenauer on 31.01.12.
//  Copyright (c) 2012 TheCodingMonkeys. All rights reserved.
//

#import "TCMTVShow.h"

@implementation TCMTVShow

@synthesize show, episodeName, seasonNumber, episodeNumber, tvdbID, playCount, showYear, duration, persistentID;

static id iTunesBridge;

+(BOOL)TVShowPlaying {
    if (!iTunesBridge) iTunesBridge = NSClassFromString(@"iTunesBridge");
    return [[iTunesBridge videoKind] isEqualToString:@"«constant ****kVdT»"];
}

+(NSInteger)playCountForID:(NSString*)anID{
    if (!iTunesBridge) iTunesBridge = NSClassFromString(@"iTunesBridge");
    return [[iTunesBridge playCountOfTrack:anID] intValue];
}

+(TCMTVShow *)showWithCurrentTunesTrack {
    
    if (!iTunesBridge) iTunesBridge = NSClassFromString(@"iTunesBridge");
    
    TCMTVShow *show = [TCMTVShow new];
    show.show           = [iTunesBridge show];
    if (!show.show) return nil;
    show.episodeName    = [iTunesBridge episodeName];
    show.seasonNumber   = [[iTunesBridge seasonNumberString] intValue];
    show.episodeNumber  = [[iTunesBridge episodeNumberString]intValue];
    show.tvdbID         = [iTunesBridge tvdbID];
    show.playCount      = [[iTunesBridge playCountString]intValue];
    show.showYear       = [[iTunesBridge showYearString]intValue];
    show.duration       = (NSInteger)([[iTunesBridge durationString] intValue]/60); // we want minutes, itunes gives us seconds
    show.persistentID   = [iTunesBridge databaseID];
    
    return show;
}


-(NSString *)description{
    return [NSString stringWithFormat:@"%@ - %@ (S%02dE%02d)",self.show, self.episodeName, self.seasonNumber, self.episodeNumber];
}

@end
