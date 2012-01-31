//
//  TCMTrakt.m
//  iTrakt
//
//  Created by Martin Pittenauer on 31.01.12.
//  Copyright (c) 2012 TheCodingMonkeys. All rights reserved.
//

#import "TCMTrakt.h"
#import "TCMTVShow.h"
#import "TCMAppDelegate.h"
#import "EMKeychainItem.h"
#include <CommonCrypto/CommonDigest.h>


NSString * const apiKey = @"c98bf503329d778ed1196ea6f16c80b8c50c3bb9";


@implementation TCMTrakt

+ (TCMTrakt *)sharedInstance
{
    static TCMTrakt *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[TCMTrakt alloc] init];
        [RKClient clientWithBaseURL:@"http://api.trakt.tv"];
    });
    return sharedInstance;
}

-(NSString *)username {
    
    NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:@"username"];
    if (!username) {
        [[NSApp delegate] showPrefWindow];
    }

    return username;
}

-(NSString*)sha1hashWithString:(NSString*)aString{
    unsigned char digest[CC_SHA1_DIGEST_LENGTH];
    NSData *stringBytes = [aString dataUsingEncoding: NSUTF8StringEncoding];
    if (CC_SHA1([stringBytes bytes], (CC_LONG)[stringBytes length], digest)) {
        NSString *hexBytes = nil;
        const unsigned char* bytes = digest;
        char *strbuf = (char *)malloc([stringBytes length] * 2 + 1);
        static const char hexdigits[] = "0123456789abcdef";
        char *hex = strbuf;

        for (int i = 0; i<([stringBytes length]+1)*2; ++i) {
            const unsigned char c = *bytes++;
            *hex++ = hexdigits[(c >> 4) & 0xF];
            *hex++ = hexdigits[(c ) & 0xF];
        }
        *hex = 0;
        hexBytes = [NSString stringWithUTF8String:strbuf];
        free(strbuf);
        return hexBytes;
    } 
    return nil;
}

-(NSString *)password {
    
    EMGenericKeychainItem *keychainItem = [EMGenericKeychainItem genericKeychainItemForService:@"iTrakt" withUsername:self.username];
    
    if (!keychainItem) {
        [[NSApp delegate] showPrefWindow];
        return nil;
    }
    
    return [self sha1hashWithString:keychainItem.password];
}

-(NSDictionary *)dictionaryWithShow:(TCMTVShow *)aShow {
    NSDictionary *params;
    if (aShow) {
        params = [NSDictionary dictionaryWithObjectsAndKeys:
                  self.username, @"username", 
                  self.password, @"password", 
                  [NSNumber numberWithInt:[aShow.tvdbID intValue]], @"tvdb_id", 
                  aShow.show, @"title", 
                  [NSNumber numberWithInteger:aShow.showYear], @"year", 
                  [NSNumber numberWithInteger:aShow.seasonNumber], @"season", 
                  [NSNumber numberWithInteger:aShow.episodeNumber], @"episode", 
                  [NSNumber numberWithInteger:aShow.duration], @"duration", 
                  [NSNumber numberWithInteger:50], @"progress", 
                  @"1.0", @"plugin_version", 
                  @"1.0", @"media_center_version", 
                  @"31.1.2012", @"media_center_date", 
                  nil];
    } else {    
        params = [NSDictionary dictionaryWithObjectsAndKeys:
                  self.username, @"username", 
                  self.password, @"password", 
                  nil];
    }
        
    return params;
}


-(void)watching:(TCMTVShow *)aShow {
    NSLog(@"Watching %@", aShow);
    [[RKClient sharedClient] post:[NSString stringWithFormat:@"/show/watching/%@", apiKey] params:[self dictionaryWithShow:aShow] delegate:self];
}

-(void)cancelWatching {
    NSLog(@"Canceled Watching");
    [[RKClient sharedClient] post:[NSString stringWithFormat:@"/show/cancelwatching/%@", apiKey] params:[self dictionaryWithShow:nil] delegate:self];
}

-(void)scrobble:(TCMTVShow *)aShow {
    NSLog(@"Scrobble %@", aShow);
    [[RKClient sharedClient] post:[NSString stringWithFormat:@"/show/scrobble/%@", apiKey] params:[self dictionaryWithShow:aShow] delegate:self];
}

- (void)request:(RKRequest*)request didLoadResponse:(RKResponse*)response {  
    if ([response isJSON]) {
        NSDictionary *responseDict = [response parsedBody:nil];
        if ([[responseDict objectForKey:@"status"] isEqualToString:@"success"]) {
            //NSLog(@"trakt.tv: %@ (%@)", [responseDict objectForKey:@"message"],[responseDict objectForKey:@"year"]);
        } else {
            NSLog(@"Got a JSON response: %@", [response bodyAsString]);
            if ([[responseDict objectForKey:@"error"] isEqualToString:@"failed authentication"]) {
                [[NSApp delegate] showPrefWindow];
            }

        }
    }
}

@end
