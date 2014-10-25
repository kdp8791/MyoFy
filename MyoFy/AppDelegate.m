//
//  AppDelegate.m
//  MyoFy
//
//  Created by Keyur Patel on 10/22/14.
//  Copyright (c) 2014 Keyur Patel. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate()
@property (nonatomic, strong) Myo *myo;
@property (nonatomic, strong) NSAppleScript *appleScript;
@property (atomic, assign) BOOL isLocked;
@property (atomic, strong) NSTimer *timer;
@end

@implementation AppDelegate

-(void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];

    [self.statusItem setMenu:self.statusMenu];
    [self.statusItem setTitle:@"MyoFy!"];
    [self.statusItem setHighlightMode:YES];
    self.isLocked = true;
    self.timer = nil;
    
    self.myo = [[Myo alloc] initWithApplicationIdentifier:@"co.keyurpatel.myofy"];
    self.myo.delegate = self;
    
    // Set AppleScript
    NSDictionary *errs;
    NSString *path = [[NSBundle mainBundle] pathForResource:@"SpotifyScript" ofType:@"scpt"];
    self.appleScript = [[NSAppleScript alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path] error:&errs];
    
    // Create Block To Run Commands In Background Thread
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, (unsigned long)NULL), ^(void) {
        
        // Create Loop To Keep Trying To Find & Connect To Myo
        BOOL found = false;
        while (!found)
        {
            found = [self.myo connectMyoWaiting:0];
        }
        
        // Create Block To Run Commands on Main Thread
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            
            self.myo.updateTime = 1000; // Set the Update Time
            [self.myo startUpdate]; // Start Getting Updates From Myo (This Command Runs on Background Thread In Implemenation)
        });
    });
}

-(NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {
    // When quitting, you should logout and wait for logout completion before terminating.
    return NSTerminateLater;
}

# pragma mark - Myo

-(void)myo:(Myo *)myo onPose:(MyoPose *)pose timestamp:(uint64_t)timestamp
{
    if(self.isLocked && [pose poseType] == MyoPoseTypePinkyToThumb)
    {
        [self.timer invalidate];
        [myo vibrateWithType:MyoVibrationTypeShort];
        self.timer = nil;
        self.isLocked = false;
    }
    else if(!self.isLocked)
    {
        if([pose poseType] == MyoPoseTypeFingersSpread)
        {
            [self runCommand:@"tell application \"Spotify\" to playpause" withMyo:myo];
        }
        else if([pose poseType] == MyoPoseTypeWaveOut)
        {
            [self runCommand:@"tell application \"Spotify\" to next track" withMyo:myo];
        }
        else if([pose poseType] == MyoPoseTypeWaveIn)
        {
            [self runCommand:@"tell application \"Spotify\" to previous track" withMyo:myo];
        }
    }
}


-(void)myoOnConnect:(Myo *)myo firmwareVersion:(NSString *)firmware timestamp:(uint64_t)timestamp
{
    NSLog(@"Myo Connected!");
}

-(void)runCommand:(NSString *)command withMyo:(Myo *)myo
{
    NSDictionary *errs;
    NSAppleScript *script = [[NSAppleScript alloc] initWithSource:command];
    [script executeAndReturnError:&errs];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(lock:) userInfo:myo repeats:NO];
}

-(void)lock:(NSTimer *)t
{
    Myo *myo = (Myo *)[t userInfo];
    self.isLocked = true;
    [myo vibrateWithType:MyoVibrationTypeShort];
    [myo vibrateWithType:MyoVibrationTypeShort];
}

@end
