//
//  TCMAppDelegate.m
//  iTrakt
//
//  Created by Martin Pittenauer on 31.01.12.
//  Copyright (c) 2012 TheCodingMonkeys. All rights reserved.
//

#import "TCMAppDelegate.h"
//#import <AppleScriptObjC/AppleScriptObjC.h> // Should use this instead of SB
#import <ScriptingBridge/ScriptingBridge.h>
#import "iTunes.h"
#import "TCMTrakt.h"
#import "TCMTVShow.h"
#import "EMKeychain.h"

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
    //Compare save playcount to current playcount and act accordingly 
    iTunesApplication *iTunes = [SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"];
    SBElementArray *sources = [iTunes sources];
    SBElementArray *entireLibrary = [[[[sources objectAtIndex:0] libraryPlaylists] objectAtIndex:0] fileTracks];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"persistentID == %@", currentlyPlaying.persistentID];
    [entireLibrary filterUsingPredicate:predicate];
    iTunesTrack *stoppedTrack = [entireLibrary lastObject]; // Boy this is complicated with ScriptingBrdige…
    
    if (currentlyPlaying.playCount<stoppedTrack.playedCount) {
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
        
        // Get full track via AppleScript
        iTunesApplication * iTunes = [SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"];
        iTunesTrack *current = [iTunes currentTrack];
        
        BOOL isTVShow = (current.videoKind == iTunesEVdKTVShow);
        if (!isTVShow) return;
        
        currentlyPlaying = [TCMTVShow showWithiTunesTrack:current];
        
        [self.trakt watching:currentlyPlaying];
        
        //Spawn timer that calls /watching every 15 min?
        
    } else if ([playerState isEqualToString:@"Paused"]) {
      // Clear current playing show
        [self scrobbleOrCancel]; 
    } else if ([playerState isEqualToString:@"Stopped"]) {
       // If there was a TV Show playing, check for playcount and scrobble or suspend watching status
        [self scrobbleOrCancel]; 
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
}


@end
