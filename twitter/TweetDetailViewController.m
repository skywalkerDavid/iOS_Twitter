//
//  TweetDetailViewController.m
//  twitter
//
//  Created by David Wang on 11/10/15.
//  Copyright © 2015 David Wang. All rights reserved.
//

#import "TweetDetailViewController.h"
#import "UIImageView+AFNetworking.h"
#import "TweetCell.h"
#import "TwitterClient.h"

@interface TweetDetailViewController ()
@property (weak, nonatomic) IBOutlet UIView *retweetView;
@property (weak, nonatomic) IBOutlet UILabel *retweetedAuthorName;
@property (weak, nonatomic) IBOutlet UIImageView *authorImageView;
@property (weak, nonatomic) IBOutlet UILabel *authorNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *authorNameHandleLabel;
@property (weak, nonatomic) IBOutlet UITextView *tweetTextView;
@property (weak, nonatomic) IBOutlet UILabel *tweetDateTime;
@property (weak, nonatomic) IBOutlet UIButton *retweetButton;
@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property (weak, nonatomic) IBOutlet UILabel *retweetCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *likeCountLabel;

@property (strong, nonatomic) Tweet *tweet;
@property (strong, nonatomic) User *user;

@end

@implementation TweetDetailViewController

- (id)initWithUser:(User *)user andTweet:(Tweet *)tweet {
    if (self == [super initWithNibName:@"TweetDetailViewController" bundle:nil]) {
        self.user = user;
        self.tweet = tweet;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationController.navigationBar.translucent = NO;
    self.navigationItem.leftBarButtonItem.title = @"";
    self.navigationItem.title = @"Tweet";
    
    [self.authorImageView setImageWithURL:self.tweet.user.profileImageUrl];
    self.authorImageView.layer.cornerRadius = 4;
    self.authorImageView.layer.masksToBounds = YES;
    
    self.authorNameLabel.text = self.tweet.user.name;
    self.authorNameHandleLabel.text = [NSString stringWithFormat:@"@%@", self.tweet.user.screenName];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    
    self.tweetDateTime.text = [dateFormatter stringFromDate:self.tweet.createdAt];
    self.tweetTextView.text = self.tweet.text;
    
    if (self.tweet.retweetedFrom) {
        self.retweetedAuthorName.text = [NSString stringWithFormat:@"%@ Retweeted", self.tweet.retweetedFrom.user.name];
        self.retweetView.hidden = NO;
    } else {
        self.retweetView.hidden = YES;
    }
    
    [self updateRetweetedState:self.tweet.retweeted withCount:self.tweet.retweetCount];
    [self updateLikedState:self.tweet.liked withCount:self.tweet.likeCount];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onReply:(id)sender {
    if (self.delegate) {
        [self.delegate tweetDetail:self replyTweet:self.tweet];
    }
}

- (IBAction)onRetweet:(id)sender {
    if (self.tweet.retweeted) {
        [[TwitterClient sharedInstance] unRetweet:self.tweet completion:^(NSDictionary *newTweetInfo, NSError *error) {
            if (error) {
                [self updateRetweetedState:self.tweet.retweeted withCount:self.tweet.retweetCount];
            } else {
                self.tweet.retweeted = NO;
                self.tweet.retweetCount--;
            }
        }];
        [self updateRetweetedState:NO withCount:(self.tweet.retweetCount - 1)];
    } else {
        [[TwitterClient sharedInstance] retweet:self.tweet completion:^(NSDictionary *newTweetInfo, NSError *error) {
            if (error) {
                [self updateRetweetedState:self.tweet.retweeted withCount:self.tweet.retweetCount];
            } else {
                self.tweet.retweeted = YES;
                self.tweet.retweetCount++;
            }
        }];
        
        [self updateRetweetedState:YES withCount:(self.tweet.retweetCount + 1)];
    }
}

- (IBAction)onLike:(id)sender {
    BOOL newLiked = !self.tweet.liked;
    long newCount = self.tweet.likeCount;
    
    void (^completedRequest)(NSDictionary *newTweetInfo, NSError *error) = ^void(NSDictionary *newTweetInfo, NSError *error) {
        if (error) {
            NSString* errorResponse = [[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding];
            
            NSLog(@"error: %@", errorResponse);
        } else {
            [self.tweet updateWithDictionary:newTweetInfo];
        }
        
        [self updateLikedState:self.tweet.liked withCount:self.tweet.likeCount];
    };
    
    if (self.tweet.liked) {
        newCount--;
        [[TwitterClient sharedInstance] unlikeTweet:self.tweet completion:completedRequest];
    } else {
        newCount++;
        [[TwitterClient sharedInstance] likeTweet:self.tweet completion:completedRequest];
    }
    
    [self updateLikedState:newLiked withCount:newCount];
}

- (void)updateRetweetedState:(BOOL)retweeted withCount:(long long)count {
    if (retweeted) {
        [self.retweetButton setImage:[UIImage imageNamed:@"retweet_active"] forState:UIControlStateNormal];
    } else {
        [self.retweetButton setImage:[UIImage imageNamed:@"retweet"] forState:UIControlStateNormal];
    }
    
    self.retweetCountLabel.text = [NSString stringWithFormat:@"%lld", count];
}

- (void)updateLikedState:(BOOL)liked withCount:(long long)count {
    if (liked) {
        [self.likeButton setImage:[UIImage imageNamed:@"like_active"] forState:UIControlStateNormal];
    } else {
        [self.likeButton setImage:[UIImage imageNamed:@"like"] forState:UIControlStateNormal];
    }
    
    self.likeCountLabel.text = [NSString stringWithFormat:@"%lld", count];
}

@end
