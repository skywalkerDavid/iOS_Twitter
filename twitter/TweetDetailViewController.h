//
//  TweetDetailViewController.h
//  twitter
//
//  Created by David Wang on 11/10/15.
//  Copyright © 2015 David Wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tweet.h"

@class TweetDetailViewController;

@protocol TweetDetailViewControllerDelegate<NSObject>

@optional

- (void)tweetDetail:(TweetDetailViewController *)detail replyTweet:(Tweet *)tweet;

@end

@interface TweetDetailViewController : UIViewController

@property (strong, nonatomic) id<TweetDetailViewControllerDelegate> delegate;

- (id)initWithUser:(User *)user andTweet:(Tweet *)tweet;

@end
