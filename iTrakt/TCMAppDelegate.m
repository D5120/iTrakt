//
//  TCMAppDelegate.m
//  iTrakt
//
//  Created by Martin Pittenauer on 31.01.12.
//  Copyright (c) 2012 TheCodingMonkeys. All rights reserved.
//

#import "TCMAppDelegate.h"
#import "TCMTrakt.h"
#import "TCMTVShow.h"
#import "EMKeychain.h"
#import <AppleScriptObjC/AppleScriptObjC.h>

@implementation TCMAppDelegate
@synthesize statusMenu;
@synthesize passwordTextField;
@synthesize preferenceWindow;

@synthesize currentlyPlaying, statusItem, trakt;


- (void)registerForiTunesNotifcations {
    [[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(iTunesPlaybackStateChanged:) name:@"com.apple.iTunes.playerInfo" object:@"com.apple.iTunes.player" suspensionBehavior:NSNotificationSuspensionBehaviorCoalesce];
}

-(void)addStatusItem {
    statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength];
    
    NSImage *statusImage = [NSImage imageNamed:@"favicon.png"];
    [statusItem setImage:statusImage];
    [statusItem setHighlightMode:YES];
    [statusItem setMenu:statusMenu];
}

-(void)scrobbleOrCancel {
    NSLog(@"%d %d",currentlyPlaying.playCount ,[TCMTVShow playCountForID:currentlyPlaying.persistentID]);
    if (currentlyPlaying.playCount<[TCMTVShow playCountForID:currentlyPlaying.persistentID]) {
        [self.trakt scrobble:currentlyPlaying];
    } else {
        [self.trakt cancelWatching];
    }
    currentlyPlaying = nil;
}


- (void)iTunesPlaybackStateChanged:(NSNotification*)notification {
    NSDictionary *newPlayerInfo = [notification userInfo];
    NSString *playerState = [newPlayerInfo objectForKey:@"Player State"];
    
    if ([playerState isEqualToString:@"Playing"]) {
        
        if (currentlyPlaying) {
            [self scrobbleOrCancel]; 
        }
        
        if (![TCMTVShow TVShowPlaying]) return;
        
        currentlyPlaying = [TCMTVShow showWithCurrentTunesTrack];
        
        [self.trakt watching:currentlyPlaying];
        
        //Spawn timer that calls /watching every 15 min?
        
    } else if ([playerState isEqualToString:@"Paused"]) {
      // Clear current playing show
        if (currentlyPlaying) [self scrobbleOrCancel]; 
    } else if ([playerState isEqualToString:@"Stopped"]) {
       // If there was a TV Show playing, check for playcount and scrobble or suspend watching status
        if (currentlyPlaying) [self scrobbleOrCancel]; 
    }    
}

-(void)updatePassword {
    EMGenericKeychainItem *keychainItem = [EMGenericKeychainItem genericKeychainItemForService:@"iTrakt" withUsername:[self.trakt username]];
    if (keychainItem) {
        [passwordTextField setStringValue:keychainItem.password];
    } else {
        [self showPrefWindow];
    }
    
}

- (IBAction)savePassword:(id)sender {
    EMGenericKeychainItem *keychainItem = [EMGenericKeychainItem genericKeychainItemForService:@"iTrakt" withUsername:[self.trakt username]];
    if (!keychainItem) {
        keychainItem = [EMGenericKeychainItem addGenericKeychainItemForService:@"iTrakt" withUsername:[self.trakt username] password:[passwordTextField stringValue]];
    }
    keychainItem.password = [passwordTextField stringValue];
}

-(void)showPrefWindow{
    [preferenceWindow makeKeyAndOrderFront:self];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    self.trakt = [TCMTrakt new];
    [self registerForiTunesNotifcations];
    [self addStatusItem];
    [self updatePassword];

    [[NSBundle mainBundle] loadAppleScriptObjectiveCScripts];    
    
}
- (IBAction)quitApplication:(id)sender {
    [NSApp terminate:self];
}


@end

