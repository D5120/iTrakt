//
//  TCMAppDelegate.h
//  iTrakt
//
//  Created by Martin Pittenauer on 31.01.12.
//  Copyright (c) 2012 TheCodingMonkeys. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class TCMTVShow, TCMTrakt;

@interface TCMAppDelegate : NSObject <NSApplicationDelegate> {
}
@property (unsafe_unretained) IBOutlet NSWindow *preferenceWindow;
@property (weak) IBOutlet NSMenu *statusMenu;
@property (weak) IBOutlet NSSecureTextField *passwordTextField;

@property (nonatomic, strong) TCMTVShow *currentlyPlaying;
@property (nonatomic, strong) TCMTrakt *trakt;
@property (nonatomic, strong) NSStatusItem *statusItem;

-(void)showPrefWindow;

@end

