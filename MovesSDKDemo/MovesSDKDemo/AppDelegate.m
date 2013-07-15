//
//  AppDelegate.m
//  MovesSDKDemo
//
//  Created by Vito on 13-7-15.
//  Copyright (c) 2013年 vito. All rights reserved.
//

#import "AppDelegate.h"
#import "MovesAPI.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[MovesAPI sharedInstance] setShareMovesOauthClientId:@"[YOUR CLIENT ID]"
                                        oauthClientSecret:@"[YOUR CLIENT SECRET]"
                                        callbackUrlScheme:@"[URL SCHEME / REDRECT URI]"];
    return YES;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    [[MovesAPI sharedInstance] authorizationCompletedCallback:url];
    
    return YES;
}

@end