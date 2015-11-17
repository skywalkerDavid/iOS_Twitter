//
//  TweetCell.m
//  twitter
//
//  Created by David Wang on 11/9/15.
//  Copyright © 2015 David Wang. All rights reserved.
//

#import "TweetCell.h"
#import "UIImageView+AFNetworking.h"
#import "NSDate+DateTools.h"
#import "TwitterClient.h"

@interface TweetCell()
@property (weak, nonatomic) IBOutlet UIImageView *authorImage;
@property (weak, nonatomic) IBOutlet UILabel *authorNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *authorHandleLabel;
@property (weak, nonatomic) IBOutlet UILabel *tweetCreatedAt;
@property (weak, nonatomic) IBOutlet UITextView *tweetTextView;
@property (weak, nonatomic) IBOutlet UIButton *replyButton;
@property (weak, nonatomic) IBOutlet UIButton *retweetButton;
@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property (weak, nonatomic) IBOutlet UILabel *retweetedAuthorLabel;
@property (weak, nonatomic) IBOutlet UIView *retweetedView;

@end

@implementation TweetCell

- (void)awakeFromNib {
    self.authorImage.layer.cornerRadius = 3;
    self.authorImage.layer.masksToBounds = YES;
    
    UITapGestureRecognizer *tapAuthorImage = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapAuthorImage)];
    
    [self.authorImage setUserInteractionEnabled:YES];
    
    [self.authorImage addGestureRecognizer:tapAuthorImage];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:NO animated:YES];
}

- (void)setTweet:(Tweet *)tweet {
    _tweet = tweet;
    
    [self.authorImage setImageWithURL:tweet.user.profileImageUrl];
    self.authorNameLabel.text = tweet.user.name;
    self.authorHandleLabel.text = [NSString stringWithFormat:@"@%@", tweet.user.screenName];
    self.tweetCreatedAt.text = tweet.createdAt.shortTimeAgoSinceNow;
    self.tweetTextView.text = tweet.text;
    
    if (tweet.retweetedFrom) {
        self.retweetedAuthorLabel.text = [NSString stringWithFormat:@"%@ Retweeted", tweet.retweetedFrom.user.name];
        self.retweetedView.hidden = NO;
    } else {
        self.retweetedView.hidden = YES;
    }
    
    [self updateRetweetedState:tweet.retweeted];
    [self updateLikedState:tweet.liked];
}

- (void)updateRetweetedState:(BOOL)retweeted {
    if (retweeted) {
        [self.retweetButton setImage:[UIImage imageNamed:@"retweet_active"] forState:UIControlStateNormal];
    } else {
        [self.retweetButton setImage:[UIImage imageNamed:@"retweet"] forState:UIControlStateNormal];
    }
}

- (void)updateLikedState:(BOOL)liked {
    if (liked) {
        [self.likeButton setImage:[UIImage imageNamed:@"like_active"] forState:UIControlStateNormal];
    } else {
        [self.likeButton setImage:[UIImage imageNamed:@"like"] forState:UIControlStateNormal];
    }
}

- (IBAction)onReply:(id)sender {
    if (self.delegate) {
        [self.delegate tweetCell:self replyTweet:self.tweet];
    }
}

- (IBAction)onRetweet:(id)sender {
    if (self.tweet.retweeted) {
        [[TwitterClient sharedInstance] unRetweet:self.tweet completion:^(NSDictionary *newTweetInfo, NSError *error) {
            if (error) {
                [self updateRetweetedState:self.tweet.retweeted];
            } else {
                self.tweet.retweeted = NO;
            }
        }];
        [self updateRetweetedState:NO];
    } else {
        [[TwitterClient sharedInstance] retweet:self.tweet completion:^(NSDictionary *newTweetInfo, NSError *error) {
            if (error) {
                [self updateRetweetedState:self.tweet.retweeted];
            } else {
                self.tweet.retweeted = YES;
            }
        }];
        
        [self updateRetweetedState:YES];
    }

}

- (IBAction)onLike:(id)sender {
    BOOL newLiked = !self.tweet.liked;
    
    void (^completedRequest)(NSDictionary *newTweetInfo, NSError *error) = ^void(NSDictionary *newTweetInfo, NSError *error) {
        if (error) {
            NSString* errorResponse = [[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding];
            
            NSLog(@"error: %@", errorResponse);
        } else {
            [self.tweet updateWithDictionary:newTweetInfo];
        }
        
        [self updateLikedState:self.tweet.liked];
    };
    
    if (self.tweet.liked) {
        [[TwitterClient sharedInstance] unlikeTweet:self.tweet completion:completedRequest];
    } else {
        [[TwitterClient sharedInstance] likeTweet:self.tweet completion:completedRequest];
    }
    
    [self updateLikedState:newLiked];
}

- (void)onTapAuthorImage {
    [self.delegate tweetCell:self tapUserProfile:self.tweet.user];
}

@end
