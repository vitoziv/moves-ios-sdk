//
//  ViewController.m
//  MovesSDKDemo
//
//  Created by Vito on 13-7-15.
//  Copyright (c) 2013年 vito. All rights reserved.
//

#import "ViewController.h"
#import "MovesAPI.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UITextView *resultTextView;
@property (weak, nonatomic) IBOutlet UIButton *authBtn;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicatorView;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)authPress:(id)sender {
    [self.indicatorView startAnimating];
    [[MovesAPI sharedInstance] authorizationSuccess:^{
        self.resultTextView.text = @"Auth successed!";
        [self.indicatorView stopAnimating];
    } failure:^(NSError *reason) {
        self.resultTextView.text = @"Auth failed!";
        [self.indicatorView stopAnimating];
    }];
}

- (IBAction)dayUrl:(id)sender {
    [self.indicatorView startAnimating];
    [[MovesAPI sharedInstance] getDayDailySummariesByDate:[NSDate date]
                                                  success:^(NSArray *dailySummaries) {
                                                      [self printDailySummaries:dailySummaries];
                                                  }
                                                  failure:^(NSError *error) {
                                                      NSLog(@"Get day dailySummaries error: %@", error);
                                                      [self.indicatorView stopAnimating];
                                                  }];
    
    
//    [[MovesAPI sharedInstance] getDayStoryLineByDate:[NSDate date]
//                                         trackPoints:YES
//                                             success:^(NSArray *storyLines) {
//                                                 [self printStoryLine:storyLines];
//                                             }
//                                             failure:^(NSError *error) {
//                                                 NSLog(@"Get day StoryLine error: %@", error);
//                                             }];
    
    //    [[MovesAPI sharedInstance] getDayDailyPlacesByDate:[NSDate date]
    //                                               success:^(NSArray *dailyPlaces) {
    //                                                   [self printDailyPlaces:dailyPlaces];
    //                                               }
    //                                               failure:^(NSError *error) {
    //                                                   NSLog(@"Get day DailyPlaces error: %@", error);
    //                                               }];
    
    
    //    [[MovesAPI sharedInstance] getDayDailyActivitiesByDate:[NSDate date]
    //                                                   success:^(NSArray *dailyActivities) {
    //                                                       [self printDailyActivities:dailyActivities];
    //                                                   }
    //                                                   failure:^(NSError *error) {
    //                                                       NSLog(@"Get day dailyActivities error: %@", error);
    //                                                   }];
}

- (IBAction)weekUrl:(id)sender {
    [self.indicatorView startAnimating];
    
    [[MovesAPI sharedInstance] getWeekDailySummariesByDate:[NSDate date]
                                                   success:^(NSArray *dailySummaries) {
                                                       [self printDailySummaries:dailySummaries];
                                                   } failure:^(NSError *error) {
                                                       NSLog(@"Get week dailySummaries error: %@", error);
                                                       [self.indicatorView stopAnimating];
                                                   }];
    
    //    [[MovesAPI sharedInstance] getWeekStoryLineByDate:[NSDate date]
    //                                              success:^(NSArray *storyLines) {
    //                                                  [self printStoryLine:storyLines];
    //                                              }
    //                                              failure:^(NSError *error) {
    //                                                  NSLog(@"Get week StoryLine error: %@", error);
    //                                              }];
    
    //    [[MovesAPI sharedInstance] getWeekDailyPlacesByDate:[NSDate date]
    //                                                success:^(NSArray *dailyPlaces) {
    //                                                    [self printDailyPlaces:dailyPlaces];
    //                                                }
    //                                                failure:^(NSError *error) {
    //                                                    NSLog(@"Get week DailyPlaces error: %@", error);
    //                                                }];
    
    
    //    [[MovesAPI sharedInstance] getWeekDailyActivitiesByDate:[NSDate date]
    //                                                    success:^(NSArray *dailyActivities) {
    //                                                        [self printDailyActivities:dailyActivities];
    //                                                    }
    //                                                    failure:^(NSError *error) {
    //                                                        NSLog(@"Get week dailyActivities error: %@", error);
    //                                                    }];
}

- (IBAction)monthUrl:(id)sender {
    [self.indicatorView startAnimating];
    
    [[MovesAPI sharedInstance] getMonthDailySummariesByDate:[NSDate date]
                                                    success:^(NSArray *dailySummaries) {
                                                        [self printDailySummaries:dailySummaries];
                                                    }
                                                    failure:^(NSError *error) {
                                                        NSLog(@"Get month dailySummaries error: %@", error);
                                                        [self.indicatorView stopAnimating];
                                                    }];
}

- (IBAction)pastDaysUrl:(id)sender {
    [self.indicatorView startAnimating];
    
//    [[MovesAPI sharedInstance] getDailySummariesByPastDays:10
//                                                   success:^(NSArray *dailySummaries) {
//                                                       [self printDailySummaries:dailySummaries];
//                                                   }
//                                                   failure:^(NSError *error) {
//                                                       NSLog(@"Get PastDays dailySummaries error: %@", error);
//                                                   }];
    
//    [[MovesAPI sharedInstance] getDailyActivitiesByPastDays:7
//                                                    success:^(NSArray *dailyActivities) {
//                                                        [self printDailyActivities:dailyActivities];
//                                                    }
//                                                    failure:^(NSError *error) {
//                                                        NSLog(@"Get PastDays dailySummaries error: %@", error);
//                                                    }];
    
    [[MovesAPI sharedInstance] getDailyPlacesByPastDays:7
                                                success:^(NSArray *dailyPlaces) {
                                                    [self printDailyPlaces:dailyPlaces];
                                                }
                                                failure:^(NSError *error) {
                                                    NSLog(@"Get PastDays DailyPlaces error: %@", error);
                                                    [self.indicatorView stopAnimating];
                                                }];
    
}

- (IBAction)fromToUrl:(id)sender {
    [self.indicatorView startAnimating];
    
//    [[MovesAPI sharedInstance] getDailySummariesFromDate:[[NSDate date] dateByAddingTimeInterval:-10*24*60*60] // Notice: Max range is 31
//                                                  toDate:[NSDate date]
//                                                 success:^(NSArray *dailySummaries) {
//                                                     [self printDailySummaries:dailySummaries];
//                                                 }
//                                                 failure:^(NSError *error) {
//                                                     NSLog(@"Get fromTo dailySummaries error: %@", error);
//                                                 }];
    
    
//    [[MovesAPI sharedInstance] getDailyActivitiesFromDate:[[NSDate date] dateByAddingTimeInterval:-6*24*60*60] // Notice: Max range is 7
//                                                   toDate:[NSDate date]
//                                                  success:^(NSArray *dailyActivities) {
//                                                      [self printDailyActivities:dailyActivities];
//                                                  }
//                                                  failure:^(NSError *error) {
//                                                      NSLog(@"Get fromTo dailyActivities error: %@", error);
//                                                  }];
    
    [[MovesAPI sharedInstance] getDailyPlacesFromDate:[[NSDate date] dateByAddingTimeInterval:-6*24*60*60] // Notice: Max range is 7
                                               toDate:[NSDate date]
                                              success:^(NSArray *dailyPlaces) {
                                                  [self printDailyPlaces:dailyPlaces];
                                              }
                                              failure:^(NSError *error) {
                                                  NSLog(@"Get PastDays DailyPlaces error: %@", error);
                                                  [self.indicatorView stopAnimating];
                                              }];
}

#pragma mark - Helper

- (void)printDailySummaries:(NSArray *)dailySummaries {
    NSMutableString *logString = [[NSMutableString alloc] init];
    [logString appendFormat:@"\n\ndailySummaries count: %i\n", dailySummaries.count];
    
    for (MVDailySummary *dailySummary in dailySummaries) {
        [logString appendFormat:@"dailySummary: date=%@, caloriesIdle=%i\n", dailySummary.date, dailySummary.caloriesIdle];
        
        for (MVSummary *summary in dailySummary.summaries) {
            [logString appendFormat:@"summary: activity=%i, duration=%i, steps=%i\n", summary.activity, summary.duration, summary.steps];
        }
    }
    self.resultTextView.text = logString;
    
    [self.indicatorView stopAnimating];
}

- (void)printDailyActivities:(NSArray *)dailyActivities {
    NSMutableString *logString = [[NSMutableString alloc] init];
    [logString appendFormat:@"dailyActivities count: %i\n", dailyActivities.count];
    
    for (MVDailyActivity *dailyActivity in dailyActivities) {
        [logString appendFormat:@"\n\ndailyActivity, date: %@, caloriesIdle: %i", dailyActivity.date, dailyActivity.caloriesIdle];
        
        for (MVSegment *segment in dailyActivity.segments) {
            [logString appendFormat:@"\nsegment-------\nstartTime: %@, endTime: %@\n\n", segment.startTime, segment.endTime];
            
            for (MVActivity *activity in segment.activities) {
                [logString appendFormat:@"\nActivity, distabce: %i, duration: %i, steps=%i", activity.distance, activity.duration, activity.steps];
            }
        }
    }
    self.resultTextView.text = logString;
    
    [self.indicatorView stopAnimating];
}

- (void)printDailyPlaces:(NSArray *)dailyPlaces {
    NSMutableString *logString = [[NSMutableString alloc] init];
    [logString appendFormat:@"dailyPlaces count: %i\n", dailyPlaces.count];
    
    for (MVDailyPlace *dailyPlace in dailyPlaces) {
        [logString appendFormat:@"\n\nMVDailyPlace, date: %@\n", dailyPlace.date];
        
        for (MVSegment *segment in dailyPlace.segments) {
            [logString appendFormat:@"\n-------\nsegment, startTime: %@, endTime: %@", segment.startTime, segment.endTime];
            [logString appendFormat:@"\nPlace, name: %@, type: %@, foursquareId: %@\n", segment.place.name, segment.place.type, segment.place.foursquareId];
        }
    }
    self.resultTextView.text = logString;
    
    [self.indicatorView stopAnimating];
}

- (void)printStoryLine:(NSArray *)storyLines {
    NSMutableString *logString = [[NSMutableString alloc] init];
    [logString appendFormat:@"storyLines count: %i\n", storyLines.count];
    
    for (MVStoryLine *storyLine in storyLines) {
        [logString appendFormat:@"\n\nstoryLine, date: %@, caloriesIdle: %i", storyLine.date, storyLine.caloriesIdle];
        
        for (MVSegment *segment in storyLine.segments) {
            [logString appendFormat:@"\n-------\nsegment, startTime: %@, endTime: %@", segment.startTime, segment.endTime];
            [logString appendFormat:@"\nPlace, name: %@, type: %@, foursquareId: %@", segment.place.name, segment.place.type, segment.place.foursquareId];
            for (MVActivity *activity in segment.activities) {
                [logString appendFormat:@"\nActivity, distabce: %i, duration: %i, steps=%i\n", activity.distance, activity.duration, activity.steps];
                
                for (MVTrackPoint *trackPoint in activity.trackPoints) {
                    [logString appendFormat:@"\nTrackPoint: lat=%f, lon=%f", trackPoint.lat, trackPoint.lon];
                }
            }
        }
    }
    self.resultTextView.text = logString;
    
    [self.indicatorView stopAnimating];
}

@end

