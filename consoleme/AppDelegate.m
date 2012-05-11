//
//  AppDelegate.m
//  consoleme
//
//  Created by Neil Loknath on 12-03-28.
//  Copyright (c) 2012 Neil Loknath <neil.loknath@gmail.com>. All rights reserved.
//

#import "AppDelegate.h"
#import "ConsoleMeViewController.h"

@implementation AppDelegate

@synthesize window = _window;

- (void)dealloc {
    [_window release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    UIWindow* window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window = window;
    [window release];
    
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor blackColor];
    
    UIViewController* controller = [[ConsoleMeViewController alloc] init];
    self.window.rootViewController = controller;
    [controller release];
    
    [self.window makeKeyAndVisible];
    
    return YES;
}

@end
