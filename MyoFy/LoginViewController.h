//
//  LoginViewController.h
//  MyoFy
//
//  Created by Keyur Patel on 10/22/14.
//  Copyright (c) 2014 Your Company. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface LoginViewController : NSViewController
@property (nonatomic, strong) IBOutlet NSTextField *username;
@property (nonatomic, strong) IBOutlet NSTextField *password;
@property (nonatomic, strong) IBOutlet NSButton *loginButton;
@end
