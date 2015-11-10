//
//  TweetsViewController.m
//  twitter
//
//  Created by David Wang on 11/9/15.
//  Copyright © 2015 David Wang. All rights reserved.
//

#import "TweetsViewController.h"
#import "User.h"
#import "TwitterClient.h"
#import "Tweet.h"
#import "TweetCell.h"

@interface TweetsViewController () <UITableViewDataSource, UITableViewDelegate, TweetCellDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) TwitterClient *client;
@property (strong, nonatomic) NSArray *tweets;
@property (assign, nonatomic) unsigned long long minTweetId;
@end

@implementation TweetsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationController.navigationBar.translucent = NO;
    
    self.navigationItem.title = @"Home";
    
    UIImage *newTweetImage = [UIImage imageNamed:@"new"];
    newTweetImage = [newTweetImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIBarButtonItem *newTweet = [[UIBarButtonItem alloc]initWithImage:newTweetImage
                                                                style:UIBarButtonItemStylePlain
                                                               target:self
                                                               action:@selector(composeTweet)];
    self.navigationItem.rightBarButtonItem = newTweet;
    
    UIBarButtonItem *logout = [[UIBarButtonItem alloc]initWithTitle:@"logout" style:UIBarButtonItemStylePlain target:self action:@selector(onLogout)];
    self.navigationItem.leftBarButtonItem = logout;
    

    self.client = [TwitterClient sharedInstance];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.estimatedRowHeight = 100;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    [self.tableView registerNib:[UINib nibWithNibName:@"TweetCell" bundle:nil] forCellReuseIdentifier:@"tweetCell"];

    [self refreshTimelines];
}

- (void)composeTweet {
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onLogout {
    [User logout];
}

- (void)refreshTimelines {
    self.minTweetId = ULLONG_MAX;
    [self loadTweets];
}

- (void) loadTweets {
    NSDictionary *parameters = nil;
    
    if (self.minTweetId < ULLONG_MAX) {
        parameters = @{@"max_id": @(self.minTweetId)};
    }
    
    [self.client homeTimelineWithParams:nil completion:^(NSArray *tweets, NSError *error) {
        if (tweets) {
            if (parameters) {
                self.tweets = [self.tweets arrayByAddingObjectsFromArray:tweets];
            } else {
                self.tweets = tweets;
            }
            
            for (Tweet *tweet in tweets) {
                unsigned long long tid = [tweet.tweetId longLongValue];
                if (tid < self.minTweetId) {
                    self.minTweetId = tid;
                }
            }
            self.minTweetId--;
            
            [self.tableView reloadData];
        }
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tweets.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TweetCell *cell = [tableView dequeueReusableCellWithIdentifier:@"tweetCell"];
    cell.tweet = self.tweets[indexPath.row];
    cell.delegate = self;
    
    if (indexPath.row == (self.tweets.count - 1)) {
        UIView *tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, cell.frame.size.width, 50)];
        UIActivityIndicatorView *loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [loadingView startAnimating];
        loadingView.center = tableFooterView.center;
        [tableFooterView addSubview:loadingView];
        tableView.tableFooterView = tableFooterView;
        
        [self loadTweets];
    }
    
    return cell;
}

- (void) tweetCell:(TweetCell *)cell replyTweet:(Tweet *)tweet {

}

@end
