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
@end

@implementation AppDelegate

-(void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];

    [self.statusItem setMenu:self.statusMenu];
    [self.statusItem setTitle:@"MyoFy!"];
    [self.statusItem setHighlightMode:YES];
    
    
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
}

-(void)myo:(Myo *)myo onPose:(MyoPose *)pose timestamp:(uint64_t)timestamp
{
    NSLog(@"%i", [pose poseType]);
    if([pose poseType] == MyoPoseTypeFist)
    {
        
    }
}

-(void)myoOnConnect:(Myo *)myo firmwareVersion:(NSString *)firmware timestamp:(uint64_t)timestamp
{
    NSLog(@"Myo Connected!");
}

-(NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {
	// When quitting, you should logout and wait for logout completion before terminating.
	return NSTerminateLater;
}


@end
