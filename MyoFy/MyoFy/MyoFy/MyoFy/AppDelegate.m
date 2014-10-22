//
//  AppDelegate.m
//  MyoFy
//
//  Created by Keyur Patel on 10/22/14.
//  Copyright (c) 2014 Keyur Patel. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

-(void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [self.statusItem setMenu:self.statusMenu];
    [self.statusItem setTitle:@"MyoFy!"];
    [self.statusItem setHighlightMode:YES];
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
