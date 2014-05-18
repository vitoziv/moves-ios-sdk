//
//  ViewController.m
//  MovesSDKDemo
//
//  Created by Vito on 13-7-15.
//  Copyright (c) 2013年 vito. All rights reserved.
//

#import "ViewController.h"
#import "MovesAPI.h"
#import "NSObject+LogProperties.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UITextView *resultTextView;
@property (weak, nonatomic) IBOutlet UIButton *authBtn;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicatorView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self.scrollView setContentSize:CGSizeMake(self.scrollView.bounds.size.width, 1080)];
    CGRect frame = self.scrollView.frame;
    [self.scrollView setFrame:frame];
    
    if ([[MovesAPI sharedInstance] isAuthenticated]) {
        self.authBtn.selected = YES;
        [self.authBtn setBackgroundColor:[UIColor colorWithRed:237/255.0 green:103/255.0 blue:214/255.0 alpha:1]];
    }
}

- (IBAction)authPress:(UIButton *)sender {
    [self.indicatorView startAnimating];
    if (sender.selected) {
        [[MovesAPI sharedInstance] logout];
        sender.selected = NO;
        [sender setBackgroundColor:[UIColor colorWithRed:0/255.0 green:212/255.0 blue:90/255.0 alpha:1]];
        [self.indicatorView stopAnimating];
    } else {
        [[MovesAPI sharedInstance] authorizationWithViewController:self
                                                           success:^{
                                                               sender.selected = YES;
                                                               [sender setBackgroundColor:[UIColor colorWithRed:237/255.0 green:103/255.0 blue:214/255.0 alpha:1]];
                                                               self.resultTextView.text = @"Auth successed!";
                                                               [self.indicatorView stopAnimating];
                                                           } failure:^(NSError *error) {
                                                               sender.selected = NO;
                                                               [sender setBackgroundColor:[UIColor colorWithRed:0/255.0 green:212/255.0 blue:90/255.0 alpha:1]];
                                                               self.resultTextView.text = @"Auth failed!";
                                                               [self.indicatorView stopAnimating];
                                                           }];
    }
    
}

#pragma mark - General

- (IBAction)requestProfile:(id)sender {
    [self.indicatorView startAnimating];
    [[MovesAPI sharedInstance] getUserSuccess:^(MVUser *user) {
        self.resultTextView.text = [user logProperties];
        [self.indicatorView stopAnimating];
    } failure:^(NSError *error) {
        [self printErrorWithDescription:[NSString stringWithFormat:@"Get profile error: %@", error]];
    }];
}

- (IBAction)requestActivityList:(id)sender {
    [self.indicatorView startAnimating];
    [[MovesAPI sharedInstance] getActivityListSuccess:^(NSArray *activityList) {
        NSMutableString *logString = [NSMutableString string];
        for (id obj in activityList) {
            [logString appendFormat:@"%@", [obj logProperties]];
        }
        self.resultTextView.text = logString;
        [self.indicatorView stopAnimating];
    } failure:^(NSError *error) {
        [self printErrorWithDescription:[NSString stringWithFormat:@"Get activity list error: %@", error]];
    }];
}

#pragma mark - Summary

- (IBAction)requestDaySummaryAction:(UIButton *)sender {
    [self.indicatorView startAnimating];
    [[MovesAPI sharedInstance] getDayDailySummariesByDate:[NSDate date]
                                                  success:^(NSArray *dailySummaries) {
                                                      [self printDailySummaries:dailySummaries];
                                                  }
                                                  failure:^(NSError *error) {
                                                      [self printErrorWithDescription:[NSString stringWithFormat:@"Get day dailySummaries error: %@", error]];
                                                  }];
}

- (IBAction)requestWeekSummaryAction:(UIButton *)sender {
    [self.indicatorView startAnimating];
    [[MovesAPI sharedInstance] getWeekDailySummariesByDate:[NSDate date]
                                                   success:^(NSArray *dailySummaries) {
                                                       [self printDailySummaries:dailySummaries];
                                                   } failure:^(NSError *error) {
                                                       [self printErrorWithDescription:[NSString stringWithFormat:@"Get weak dailySummaries error: %@", error]];
                                                   }];
}

- (IBAction)requestMonthSummaryAction:(UIButton *)sender {
    [self.indicatorView startAnimating];
    
    [[MovesAPI sharedInstance] getMonthDailySummariesByDate:[NSDate date]
                                                    success:^(NSArray *dailySummaries) {
                                                        [self printDailySummaries:dailySummaries];
                                                    }
                                                    failure:^(NSError *error) {
                                                        [self printErrorWithDescription:[NSString stringWithFormat:@"Get month dailySummaries error: %@", error]];
                                                    }];
}

- (IBAction)requestPastDaysSummaryAction:(UIButton *)sender {
    [self.indicatorView startAnimating];
    [[MovesAPI sharedInstance] getDailySummariesByPastDays:10
                                                   success:^(NSArray *dailySummaries) {
                                                       [self printDailySummaries:dailySummaries];
                                                   }
                                                   failure:^(NSError *error) {
                                                       [self printErrorWithDescription:[NSString stringWithFormat:@"Get PastDays dailySummaries error: %@", error]];
                                                   }];
}

- (IBAction)requestFromToSummaryAction:(UIButton *)sender {
    [self.indicatorView startAnimating];
    [[MovesAPI sharedInstance] getDailySummariesFromDate:[[NSDate date] dateByAddingTimeInterval:-10*24*60*60] // Notice: Max range is 31
                                                  toDate:[NSDate date]
                                                 success:^(NSArray *dailySummaries) {
                                                     [self printDailySummaries:dailySummaries];
                                                 }
                                                 failure:^(NSError *error) {
                                                     [self printErrorWithDescription:[NSString stringWithFormat:@"Get fromTo dailySummaries error: %@", error]];

                                                 }];
}

#pragma mark - Activity

- (IBAction)requestDayActivityAction:(UIButton *)sender {
    [self.indicatorView startAnimating];
    [[MovesAPI sharedInstance] getDayDailyActivitiesByDate:[NSDate date]
                                                   success:^(NSArray *dailyActivities) {
                                                       [self printDailyActivities:dailyActivities];
                                                   }
                                                   failure:^(NSError *error) {
                                                       [self printErrorWithDescription:[NSString stringWithFormat:@"Get day dailyActivities error: %@", error]];
                                                   }];
}

- (IBAction)requestWeekActivityAction:(UIButton *)sender {
    [self.indicatorView startAnimating];
    [[MovesAPI sharedInstance] getWeekDailyActivitiesByDate:[NSDate date]
                                                    success:^(NSArray *dailyActivities) {
                                                        [self printDailyActivities:dailyActivities];
                                                    }
                                                    failure:^(NSError *error) {
                                                        [self printErrorWithDescription:[NSString stringWithFormat:@"Get weak dailyActivities error: %@", error]];
                                                    }];
}

- (IBAction)requestMonthActivityAction:(UIButton *)sender {
    [self.indicatorView startAnimating];
    [[MovesAPI sharedInstance] getMonthDailyActivitiesByDate:[NSDate date]
                                                     success:^(NSArray *dailyActivities) {
                                                         [self printDailyActivities:dailyActivities];
                                                     } failure:^(NSError *error) {
                                                         [self printErrorWithDescription:[NSString stringWithFormat:@"Get weak dailyActivities error: %@", error]];
                                                     }];
}

- (IBAction)requestPastDaysActivityAction:(UIButton *)sender {
    [self.indicatorView startAnimating];
    [[MovesAPI sharedInstance] getDailyActivitiesByPastDays:7
                                                    success:^(NSArray *dailyActivities) {
                                                        [self printDailyActivities:dailyActivities];
                                                    }
                                                    failure:^(NSError *error) {
                                                        [self printErrorWithDescription:[NSString stringWithFormat:@"Get PastDays dailyActivities error: %@", error]];
                                                    }];
}

- (IBAction)requestFromToActivityAction:(UIButton *)sender {
    [self.indicatorView startAnimating];
    [[MovesAPI sharedInstance] getDailyActivitiesFromDate:[[NSDate date] dateByAddingTimeInterval:-11*24*60*60] // Notice: Max range is 31
                                                   toDate:[NSDate date]
                                                  success:^(NSArray *dailyActivities) {
                                                      [self printDailyActivities:dailyActivities];
                                                  }
                                                  failure:^(NSError *error) {
                                                      [self printErrorWithDescription:[NSString stringWithFormat:@"Get fromTo dailyActivities error: %@", error]];
                                                  }];
}

#pragma mark - Places

- (IBAction)requestDayPlacesAction:(id)sender {
    [self.indicatorView startAnimating];
    [[MovesAPI sharedInstance] getDayDailyPlacesByDate:[NSDate date]
                                               success:^(NSArray *dailyPlaces) {
                                                   [self printDailyPlaces:dailyPlaces];
                                               }
                                               failure:^(NSError *error) {
                                                   [self printErrorWithDescription:[NSString stringWithFormat:@"Get day DailyPlaces error: %@", error]];
                                               }];
}

- (IBAction)requestWeekPlacesAction:(id)sender {
    [self.indicatorView startAnimating];
    [[MovesAPI sharedInstance] getWeekDailyPlacesByDate:[NSDate date]
                                                success:^(NSArray *dailyPlaces) {
                                                    [self printDailyPlaces:dailyPlaces];
                                                }
                                                failure:^(NSError *error) {
                                                    [self printErrorWithDescription:[NSString stringWithFormat:@"Get weak DailyPlaces error: %@", error]];
                                                }];
}

- (IBAction)requestMonthPlacesAction:(id)sender {
    [self.indicatorView startAnimating];
    [[MovesAPI sharedInstance] getMonthDailyPlacesByDate:[NSDate date]
                                                 success:^(NSArray *dailyPlaces) {
                                                     [self printDailyPlaces:dailyPlaces];
                                                 }
                                                 failure:^(NSError *error) {
                                                     [self printErrorWithDescription:[NSString stringWithFormat:@"Get month DailyPlaces error: %@", error]];
                                                 }];
}

- (IBAction)requestPastDaysPlacesAction:(id)sender {
    [self.indicatorView startAnimating];
    [[MovesAPI sharedInstance] getDailyPlacesByPastDays:7
                                                success:^(NSArray *dailyPlaces) {
                                                    [self printDailyPlaces:dailyPlaces];
                                                }
                                                failure:^(NSError *error) {
                                                    [self printErrorWithDescription:[NSString stringWithFormat:@"Get PastDays DailyPlaces error: %@", error]];
                                                }];
}

- (IBAction)requestFromToPlacesAction:(id)sender {
    [self.indicatorView startAnimating];
    [[MovesAPI sharedInstance] getDailyPlacesFromDate:[[NSDate date] dateByAddingTimeInterval:-6*24*60*60] // Notice: Max range is 7
                                               toDate:[NSDate date]
                                              success:^(NSArray *dailyPlaces) {
                                                  [self printDailyPlaces:dailyPlaces];
                                              }
                                              failure:^(NSError *error) {
                                                  [self printErrorWithDescription:[NSString stringWithFormat:@"Get fromTo DailyPlaces error: %@", error]];
                                              }];
}

#pragma mark - Storyline

- (IBAction)requestDayStorylineAction:(id)sender {
    [self.indicatorView startAnimating];
    [[MovesAPI sharedInstance] getDayStoryLineByDate:[NSDate date]
                                         trackPoints:YES
                                             success:^(NSArray *storyLines) {
                                                 [self printStoryLine:storyLines];
                                             }
                                             failure:^(NSError *error) {
                                                 [self printErrorWithDescription:[NSString stringWithFormat:@"Get day storyLine error: %@", error]];
                                             }];
}

- (IBAction)requestWeekStorylineAction:(id)sender {
    [self.indicatorView startAnimating];
    [[MovesAPI sharedInstance] getWeekStoryLineByDate:[NSDate date]
                                          trackPoints:YES
                                              success:^(NSArray *storyLines) {
                                                  [self printStoryLine:storyLines];
                                              }
                                              failure:^(NSError *error) {
                                                  [self printErrorWithDescription:[NSString stringWithFormat:@"Get weak StoryLine error: %@", error]];
                                              }];
}

- (IBAction)requestMonthStorylineAction:(id)sender {
    [self.indicatorView startAnimating];
    [[MovesAPI sharedInstance] getMonthStoryLineByDate:[NSDate date]
                                               success:^(NSArray *storyLines) {
                                                   [self printStoryLine:storyLines];
                                               }
                                               failure:^(NSError *error) {
                                                   [self printErrorWithDescription:[NSString stringWithFormat:@"Get month StoryLine error: %@", error]];
                                               }];
}

- (IBAction)requestPastDaysStorylineAction:(id)sender {
    [self.indicatorView startAnimating];
    [[MovesAPI sharedInstance] getDailyStoryLineByPastDays:6
                                               trackPoints:YES
                                                   success:^(NSArray *storyLines) {
                                                       [self printStoryLine:storyLines];
                                                   } failure:^(NSError *error) {
                                                       [self printErrorWithDescription:[NSString stringWithFormat:@"Get fromTo DailyStoryLines error: %@", error]];
                                                   }];
}

- (IBAction)requestFromToStorylineAction:(id)sender {
    [self.indicatorView startAnimating];
    [[MovesAPI sharedInstance] getDailyStoryLineFromDate:[[NSDate date] dateByAddingTimeInterval:-1*24*60*60]
                                                  toDate:[NSDate date]
                                             trackPoints:YES
                                                 success:^(NSArray *storyLines) {
                                                     [self printStoryLine:storyLines];
                                                 } failure:^(NSError *error) {
                                                     [self printErrorWithDescription:[NSString stringWithFormat:@"Get fromTo DailyStoryLines error: %@", error]];
                                                 }];
}

#pragma mark - Helper

- (void)printDailySummaries:(NSArray *)dailySummaries {
    NSMutableString *logString = [[NSMutableString alloc] init];
    [logString appendFormat:@"\n\ndailySummaries count: %lu\n", (unsigned long)dailySummaries.count];
    
    for (MVDailySummary *dailySummary in dailySummaries) {
        [logString appendFormat:@"----------\n%@\n----------\n", [dailySummary logProperties]];
    }
    self.resultTextView.text = logString;
    
    [self.indicatorView stopAnimating];
}

- (void)printDailyActivities:(NSArray *)dailyActivities {
    NSMutableString *logString = [[NSMutableString alloc] init];
    [logString appendFormat:@"dailyActivities count: %lu\n", (unsigned long)dailyActivities.count];
    
    for (MVDailyActivity *dailyActivity in dailyActivities) {
        [logString appendFormat:@"----------\n%@\n----------\n", [dailyActivity logProperties]];
    }
    self.resultTextView.text = logString;
    
    [self.indicatorView stopAnimating];
}

- (void)printDailyPlaces:(NSArray *)dailyPlaces {
    NSMutableString *logString = [[NSMutableString alloc] init];
    [logString appendFormat:@"dailyPlaces count: %lu\n", (unsigned long)dailyPlaces.count];
    
    for (MVDailyPlace *dailyPlace in dailyPlaces) {
        [logString appendFormat:@"----------\n%@\n----------\n", [dailyPlace logProperties]];
    }
    self.resultTextView.text = logString;
    
    [self.indicatorView stopAnimating];
}

- (void)printStoryLine:(NSArray *)storyLines {
    NSMutableString *logString = [[NSMutableString alloc] init];
    [logString appendFormat:@"storyLines count: %lu\n", (unsigned long)storyLines.count];
    
    for (MVStoryLine *storyLine in storyLines) {
        [logString appendFormat:@"----------\n%@\n----------\n", [storyLine logProperties]];
    }
    self.resultTextView.text = logString;
    
    [self.indicatorView stopAnimating];
}

- (void)printErrorWithDescription:(NSString *)description {
    self.resultTextView.text = description;
    
    [self.indicatorView stopAnimating];
}

@end

