//
//  HomepwnerAppDelegate.m
//  SpotterProject
//
//  Created by Earl St Sauver on 9/17/12.
//  Copyright (c) 2012 Earl St Sauver. All rights reserved.
//

#import "HomepwnerAppDelegate.h"
#import "TestFlight.h"
#import "HomepwnerViewController.h"

#import <Parse/Parse.h>
#define TESTING 0


@implementation HomepwnerAppDelegate

- (void)dealloc
{
    [_window release];
    [_viewController release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    [TestFlight takeOff:@"3c5a4fbc53184f637343ac6342d65ed0_MTM0MDc1MjAxMi0wOS0xOSAyMzoyODoxNy4zMjI0NzQ"];
    
#ifdef TESTING
    [TestFlight setDeviceIdentifier:[[UIDevice currentDevice] uniqueIdentifier]];
#endif
    
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.
    [Parse setApplicationId:@"BmK4dbnbV8tkr3Vsu3PeCyoPlxoo0e7PI2JBnKGN"
                  clientKey:@"nWa2cVgjMAapt7xPWbhjnCaWph7pWVwfTYWUXPJN"];
    [PFUser enableAutomaticUser];
    [[PFUser currentUser] saveInBackground];
    PFACL *defaultACL = [PFACL ACL];
    
    [PFACL setDefaultACL:defaultACL withAccessForCurrentUser:YES];
    self.viewController = [[[HomepwnerViewController alloc] initWithNibName:@"HomepwnerViewController" bundle:nil] autorelease];
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
   // [self.viewController switchToBackgroundMode:YES];
    
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    _viewController.executingInBackground = YES;
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    _viewController.executingInBackground=NO;
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
