//
//  NewTweetViewController.h
//  twitter
//
//  Created by David Wang on 11/10/15.
//  Copyright © 2015 David Wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tweet.h"

@class NewTweetViewController;

@protocol NewTweetViewControllerDelegate <NSObject>

- (void)newTweetViewController:(NewTweetViewController *)viewController newTweet:(Tweet *)tweet;

@end

@interface NewTweetViewController : UIViewController

- (id)initWithUser:(User *)user;
- (id)initWithUser:(User *)user andTweet:(Tweet *)tweet;

@property (weak, nonatomic) id<NewTweetViewControllerDelegate> delegate;

@end
