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

@interface TweetCell()
@property (weak, nonatomic) IBOutlet UIImageView *authorImage;
@property (weak, nonatomic) IBOutlet UILabel *authorNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *authorHandleLabel;
@property (weak, nonatomic) IBOutlet UILabel *tweetCreatedAt;
@property (weak, nonatomic) IBOutlet UITextView *tweetTextView;
@property (weak, nonatomic) IBOutlet UIButton *replyButton;
@property (weak, nonatomic) IBOutlet UIButton *retweetButton;
@property (weak, nonatomic) IBOutlet UILabel *retweetCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *likeCountLabel;
@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property (weak, nonatomic) IBOutlet UILabel *retweetedAuthorLabel;
@property (weak, nonatomic) IBOutlet UIView *retweetedView;

@end

@implementation TweetCell

- (void)awakeFromNib {
    self.authorImage.layer.cornerRadius = 4;
    self.authorImage.layer.masksToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:NO animated:YES];
}

- (void) setTweet:(Tweet *)tweet {
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
    
    [self updateRetweetedState:tweet.retweeted withCount:tweet.retweetCount animated:NO];
    [self updateLikedState:tweet.liked withCount:tweet.likeCount animated:NO];
}

- (void) updateRetweetedState:(BOOL)retweeted withCount:(long long)count animated:(BOOL)animated {
    if (retweeted) {
        [self.retweetButton setImage:[UIImage imageNamed:@"retweet_active"] forState:UIControlStateNormal];
    } else {
        [self.retweetButton setImage:[UIImage imageNamed:@"retweet"] forState:UIControlStateNormal];
    }
    
    if (count == 0) {
        self.retweetCountLabel.text = @"";
    } else {
        self.retweetCountLabel.text = [NSString stringWithFormat:@"%lld", count];
    }
}

- (void) updateLikedState:(BOOL)liked withCount:(long long)count animated:(BOOL)animated {
    if (liked) {
        [self.likeButton setImage:[UIImage imageNamed:@"like_active"] forState:UIControlStateNormal];
    } else {
        [self.likeButton setImage:[UIImage imageNamed:@"like"] forState:UIControlStateNormal];
    }
    
    if (count == 0) {
        self.likeCountLabel.text = @"";
    } else {
        self.likeCountLabel.text = [NSString stringWithFormat:@"%lld", count];
    }
}

- (IBAction)onReply:(id)sender {
    if (self.delegate) {
        [self.delegate tweetCell:self replyTweet:self.tweet];
    }
}

- (IBAction)onRetweet:(id)sender {
}

- (IBAction)onLike:(id)sender {
}

@end
