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
//    [[MovesAPI sharedInstance] setShareMovesOauthClientId:@"[YOUR CLIENT ID]"
//                                        oauthClientSecret:@"[YOUR CLIENT SECRET]"
//                                        callbackUrlScheme:@"[URL SCHEME / REDRECT URI]"];
    
    [[MovesAPI sharedInstance] setShareMovesOauthClientId:@"avm3AYjrb5xe1dLfOtZnXEhWMvERxS3a"
                                        oauthClientSecret:@"JwTTP04R3d6Up0vrDNtUZJdlnyI6aLKR7WaioebZ1W9uMnkCy0JO23o0pZnv2NrJ"
                                        callbackUrlScheme:@"MovesSDKDemo"];    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    if ([[MovesAPI sharedInstance] canHandleOpenUrl:url]) {
        return YES;
    }
    // Other 3rdParty Apps Handle Url Method...
    
    
    return NO;
}

@end