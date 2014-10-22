//
//  SpotifyHelper.m
//  MyoFy
//
//  Created by Keyur Patel on 10/22/14.
//  Copyright (c) 2014 Keyur Patel. All rights reserved.
//

#import "SpotifyHelper.h"
#import <CocoaLibSpotify/CocoaLibSpotify.h>

#define SP_LIBSPOTIFY_DEBUG_LOGGING 0

#include "appkey.c"

@implementation SpotifyHelper

// Initialization
-(id)init {
    self = [super init];
    if(self) {
        NSString *userAgent = [[[NSBundle mainBundle] infoDictionary] valueForKey:(__bridge NSString *)kCFBundleIdentifierKey];
        NSData *appKey = [NSData dataWithBytes:&g_appkey length:g_appkey_size];
        NSError *err = nil;
        [SPSession initializeSharedSessionWithApplicationKey:appKey
                                                   userAgent:userAgent
                                               loadingPolicy:SPAsyncLoadingManual error:&err];
        if(err != nil) {
            return nil;
        }
        [[SPSession sharedSession] setDelegate:self];
    }
    return self;
}


// Thread-safe singleton instance
-(SpotifyHelper *)instance {
    SpotifyHelper *instance = nil;
    @synchronized(self) {
        if(instance == nil) {
            instance = [[SpotifyHelper alloc] init];
        }
    }
    return instance;
}

#pragma mark -
#pragma mark SPSessionDelegate Methods

-(void)sessionDidLoginSuccessfully:(SPSession *)aSession {
    // Called after a successful login.
}

-(void)session:(SPSession *)aSession didFailToLoginWithError:(NSError *)error {
    // Called after a failed login.
}

-(void)sessionDidLogOut:(SPSession *)aSession; {
    // Called after a logout has been completed.
}

-(void)session:(SPSession *)aSession didGenerateLoginCredentials:(NSString *)credential forUserName:(NSString *)userName {
    
    // Called when login credentials are created. If you want to save user logins, uncomment the code below.
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *storedCredentials = [[defaults valueForKey:@"SpotifyUsers"] mutableCopy];
     
    if (storedCredentials == nil) {
        storedCredentials = [NSMutableDictionary dictionary];
    }
    
    [storedCredentials setValue:credential forKey:userName];
    [defaults setValue:storedCredentials forKey:@"SpotifyUsers"];
}

-(void)session:(SPSession *)aSession didEncounterNetworkError:(NSError *)error; {
    if (SP_LIBSPOTIFY_DEBUG_LOGGING != 0)
        NSLog(@"CocoaLS NETWORK ERROR: %@", error);
}

-(void)session:(SPSession *)aSession didLogMessage:(NSString *)aMessage; {
    if (SP_LIBSPOTIFY_DEBUG_LOGGING != 0)
        NSLog(@"CocoaLS DEBUG: %@", aMessage);
}

-(void)sessionDidChangeMetadata:(SPSession *)aSession; {
    // Called when metadata has been updated somewhere in the
    // CocoaLibSpotify object model. You don't normally need to do
    // anything here. KVO on the metadata you're interested in instead.
}

-(void)session:(SPSession *)aSession recievedMessageForUser:(NSString *)aMessage; {
    // Called when the Spotify service wants to relay a piece of information to the user.
    [[NSAlert alertWithMessageText:aMessage
                     defaultButton:@"OK"
                   alternateButton:@""
                       otherButton:@""
         informativeTextWithFormat:@"This message was sent to you from the Spotify service."] runModal];
}




@end