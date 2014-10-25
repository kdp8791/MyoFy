//
//  AppDelegate.m
//  MyoFy
//
//  Created by Keyur Patel on 10/22/14.
//  Copyright (c) 2014 Keyur Patel. All rights reserved.
//

#import "AppDelegate.h"
#import "SpotifyHelper/SpotifyHelper.h"

@interface AppDelegate()
@property (nonatomic, strong) Myo *myo;
@property (nonatomic, strong) SpotifyHelper *spotify;
@end

@implementation AppDelegate

-(void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];

    [self.statusItem setMenu:self.statusMenu];
    [self.statusItem setTitle:@"MyoFy!"];
    [self.statusItem setHighlightMode:YES];
    
    self.spotify = [SpotifyHelper instance];
    
    self.myo = [[Myo alloc] initWithApplicationIdentifier:@"co.keyurpatel.myofy"];
    self.myo.delegate = self;
    
    // Create Block To Run Commands In Background Thread
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, (unsigned long)NULL), ^(void) {
        
        // Create Loop To Keep Trying To Find & Connect To Myo
        BOOL found = false;
        while (!found) {
            found = [self.myo connectMyoWaiting:10000];
        }
        
        // Create Block To Run Commands on Main Thread
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            
            self.myo.updateTime = 1000; // Set the Update Time
            [self.myo startUpdate]; // Start Getting Updates From Myo (This Command Runs on Background Thread In Implemenation)
        });
    });
    
    CGEventSourceRef src =
    CGEventSourceCreate(kCGEventSourceStateHIDSystemState);
    
    CGEventRef cmdd = CGEventCreateKeyboardEvent(src, (CGKeyCode)96, true);
    CGEventRef cmdu = CGEventCreateKeyboardEvent(src, (CGKeyCode)96, false);
    CGEventRef spcd = CGEventCreateKeyboardEvent(src, 0x31, true);
    CGEventRef spcu = CGEventCreateKeyboardEvent(src, 0x31, false);
    
    CGEventSetFlags(spcd, kCGEventFlagMaskCommand);
    CGEventSetFlags(spcu, kCGEventFlagMaskCommand);
    
    CGEventTapLocation loc = kCGHIDEventTap; // kCGSessionEventTap also works
    CGEventPost(loc, cmdd);
    CGEventPost(loc, spcd);
    CGEventPost(loc, spcu);
    CGEventPost(loc, cmdu);
    
    CFRelease(cmdd);
    CFRelease(cmdu);
    CFRelease(spcd);
    CFRelease(spcu);
    CFRelease(src);
}

-(void)keyUp:(NSEvent *)event
{
    NSLog(@"Characters: %@", [event characters]);
    NSLog(@"KeyCode: %hu", [event keyCode]);
}

-(void)myo:(Myo *)myo onPose:(MyoPose *)pose timestamp:(uint64_t)timestamp
{
    NSLog(@"%i", [pose poseType]);
    if([pose poseType] == MyoPoseTypeFist)
    {
        if([[NSWorkspace sharedWorkspace] launchApplication:@"Spotify"])
        {
            [self.spotify newSong];
        }
    }
}

-(void)myoOnConnect:(Myo *)myo firmwareVersion:(NSString *)firmware timestamp:(uint64_t)timestamp
{
    NSLog(@"Myo Connected!");
}

-(NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {
	// When quitting, you should logout and wait for logout completion before terminating.
	if ([SPSession sharedSession].connectionState == SP_CONNECTION_STATE_LOGGED_OUT ||
		[SPSession sharedSession].connectionState == SP_CONNECTION_STATE_UNDEFINED)
		return NSTerminateNow;

	[[SPSession sharedSession] logout:^{
		[[NSApplication sharedApplication] replyToApplicationShouldTerminate:YES];
	}];
	return NSTerminateLater;
}


@end