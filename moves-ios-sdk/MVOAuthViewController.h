//
//  MVOAuthViewController.h
//  MovesSDKDemo
//
//  Created by Vito on 11/19/13.
//  Copyright (c) 2013 vito. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MVOAuthViewController;

@protocol MVOAuthViewControllerDelegate <NSObject>

- (void)oauthViewControllerDidCancel:(MVOAuthViewController *)sender;
- (void)oauthViewController:(MVOAuthViewController *)sender didFailWithError:(NSError *)error;
- (void)oauthViewController:(MVOAuthViewController *)sender receivedOAuthCallbackURL:(NSURL *)url;

@end

@interface MVOAuthViewController : UIViewController

@property (nonatomic, weak) id<MVOAuthViewControllerDelegate> delegate;

- (id)initWithAuthorizationURL:(NSURL *)authorizationURL
                      delegate:(id<MVOAuthViewControllerDelegate>)delegate;

@end
