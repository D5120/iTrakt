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

+(NSInteger)playCountForID:(NSString*)anID {
    NSDictionary *err;
    NSAppleEventDescriptor *result = [[[NSAppleScript alloc] initWithSource:[NSString stringWithFormat:@"tell application \"iTunes\"\n set lib_ref to first library playlist\n set track_id to (database ID of some track of lib_ref)\n  tell lib_ref\nset track_ref to (last track whose database ID is %@) \n end tell\n set foo to played count of track_ref\n end tell", anID]] executeAndReturnError:&err];
    if (!err) return [[result stringValue] intValue];
    else {
        NSLog(@"err %@",err);
    }
    return -1;
}

+(NSString *)stringForProperty:(NSString*)property {
    NSDictionary *err;
    NSAppleEventDescriptor *result = [[[NSAppleScript alloc] initWithSource:[NSString stringWithFormat:@"tell application \"iTunes\"\n set foo to %@ of current track\nend tell", property]] executeAndReturnError:&err];
    if (!err) return [result stringValue];
    else {
        NSLog(@"err %@",err);
    }
    return nil;
}

+(BOOL)TVShowPlaying {
    return [[TCMTVShow stringForProperty:@"video kind"] isEqualToString:@"kVdT"];
}

+(TCMTVShow *)showWithCurrentTunesTrack {
    TCMTVShow *show = [TCMTVShow new];
    show.show           = [TCMTVShow stringForProperty:@"show"];
    if (!show.show) return nil;
    show.episodeName    = [TCMTVShow stringForProperty:@"name"];
    show.seasonNumber   = [[TCMTVShow stringForProperty:@"season number"] intValue];
    show.episodeNumber  = [[TCMTVShow stringForProperty:@"episode number"] intValue];
    show.tvdbID         = [TCMTVShow stringForProperty:@"name"];
    show.playCount      = [[TCMTVShow stringForProperty:@"played count"] intValue];
    show.showYear       = [[TCMTVShow stringForProperty:@"year"] intValue];
    show.duration       = (NSInteger)([[TCMTVShow stringForProperty:@"duration"] intValue]/60); // we want minutes, itunes gives us seconds
    show.persistentID   = [TCMTVShow stringForProperty:@"database ID"];
    return show;
}



-(NSString *)description{
    return [NSString stringWithFormat:@"%@ - %@ (S%02dE%02d)",self.show, self.episodeName, self.seasonNumber, self.episodeNumber];
}

@end
