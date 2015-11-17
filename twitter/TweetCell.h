//
//  TweetCell.h
//  twitter
//
//  Created by David Wang on 11/9/15.
//  Copyright © 2015 David Wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tweet.h"

@class TweetCell;

@protocol TweetCellDelegate <NSObject>

- (void)tweetCell:(TweetCell *)cell replyTweet:(Tweet *)tweet;
- (void)tweetCell:(TweetCell *)cell tapUserProfile:(User *)user;

@end

@interface TweetCell : UITableViewCell

@property (strong, nonatomic) Tweet *tweet;
@property (strong, nonatomic) id<TweetCellDelegate> delegate;

@end
