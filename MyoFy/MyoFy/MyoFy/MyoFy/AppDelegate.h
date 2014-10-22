//
//  AppDelegate.h
//  MyoFy
//
//  Created by Keyur Patel on 10/22/14.
//  Copyright (c) 2014 Keyur Patel. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CocoaLibSpotify/CocoaLibSpotify.h>

@interface AppDelegate : NSObject <NSApplicationDelegate, SPSessionDelegate>

@property (nonatomic, strong) IBOutlet NSMenu *statusMenu;
@property (nonatomic, strong) IBOutlet NSStatusItem *statusItem;

@end
