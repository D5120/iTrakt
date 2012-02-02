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
#import "EMKeychain.h"
#import <CommonCrypto/CommonDigest.h>
#import <LRResty/LRResty.h>

NSString * const apiKey = @"c98bf503329d778ed1196ea6f16c80b8c50c3bb9";


@implementation TCMTrakt

+ (TCMTrakt *)sharedInstance
{
    static TCMTrakt *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[TCMTrakt alloc] init];
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


- (void)callURL:(NSString *)requestUrl withParameters:(NSDictionary *)params completionHandler:(void (^)(NSDictionary *, NSError *))completionBlock
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:requestUrl]];
    [request setHTTPMethod: @"POST"];
    [request setHTTPBody: [NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:nil]];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue setName:@"de.codingmonkeys.map.iTrakt"];
    
    // Send an asyncronous request on the queue
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        // If there was an error getting the data
        if (error) {
            
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                completionBlock(nil, error);
            });
            return;
        }
        
        // Decode the data
        NSError *jsonError;
        NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
        
        // If there was an error decoding the JSON
        if (jsonError) {
            
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                
            });
            return;
        }
        
        // All looks fine, lets call the completion block with the response data
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            completionBlock(responseDict, nil);
        });
    }];
}


-(void)callAPI:(NSString*)apiCall WithParameters:(NSDictionary *)params {
    [self callURL:[NSString stringWithFormat:@"http://api.trakt.tv/show/%@/%@", apiCall, apiKey] withParameters:params completionHandler:^(NSDictionary *dict, NSError *err) {
        if ([[dict objectForKey:@"status"] isEqualToString:@"success"]){
            NSLog(@"%@",[dict objectForKey:@"message"]);
        }
        if (err) NSLog(@"Error: %@",[dict description]);
     }];
    
}

-(void)watching:(TCMTVShow *)aShow {
    //NSLog(@"Watching %@", aShow);
    [self callAPI:@"watching" WithParameters:[self dictionaryWithShow:aShow]];
    
}

-(void)cancelWatching {
    //NSLog(@"Canceled Watching");
    [self callAPI:@"cancelwatching" WithParameters:[self dictionaryWithShow:nil]];
}

-(void)scrobble:(TCMTVShow *)aShow {
    //NSLog(@"Scrobble %@", aShow);
    [self callAPI:@"scrobble" WithParameters:[self dictionaryWithShow:aShow]];
}

@end
