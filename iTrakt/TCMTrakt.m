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

@implementation TCMTrakt

-(NSString *)username {
    
    NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:@"username"];
    if (!username) {
        [[NSApp delegate] showPrefWindow];
    }

    return username;
}

-(NSString*)sha1hashWithString:(NSString*)str {
    const char *cStr = [str UTF8String];
    unsigned char result[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1(cStr, strlen(cStr), result);
    NSString *s = [NSString  stringWithFormat:
                   @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
                   result[0], result[1], result[2], result[3], result[4],
                   result[5], result[6], result[7],
                   result[8], result[9], result[10], result[11], result[12],
                   result[13], result[14], result[15],
                   result[16], result[17], result[18], result[19]
                   ];
    
    return [s lowercaseString];
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
    [self callURL:apiCall withParameters:params completionHandler:^(NSDictionary *dict, NSError *err) {
        if ([[dict objectForKey:@"status"] isEqualToString:@"success"]){
            NSLog(@"%@",[dict objectForKey:@"message"]);
        }
        if (err) NSLog(@"Error: %@",[err description]);
     }];
    
}

-(void)watching:(TCMTVShow *)aShow {
    //NSLog(@"Watching %@", aShow);
    [self callAPI:@"http://api.trakt.tv/show/watching/c98bf503329d778ed1196ea6f16c80b8c50c3bb9" WithParameters:[self dictionaryWithShow:aShow]];
    
}

-(void)cancelWatching {
    //NSLog(@"Canceled Watching");
    [self callAPI:@"http://api.trakt.tv/show/cancelwatching/c98bf503329d778ed1196ea6f16c80b8c50c3bb9" WithParameters:[self dictionaryWithShow:nil]];
}

-(void)scrobble:(TCMTVShow *)aShow {
    //NSLog(@"Scrobble %@", aShow);
    [self callAPI:@"http://api.trakt.tv/show/scrobble/c98bf503329d778ed1196ea6f16c80b8c50c3bb9" WithParameters:[self dictionaryWithShow:aShow]];
}

@end
