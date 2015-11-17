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
#import "NewTweetViewController.h"
#import "TweetDetailViewController.h"
#import "ProfileViewController.h"

@interface TweetsViewController () <UITableViewDataSource, UITableViewDelegate, TweetCellDelegate, NewTweetViewControllerDelegate, TweetDetailViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) TwitterClient *client;
@property (strong, nonatomic) NSArray *tweets;
@property (assign, nonatomic) unsigned long long minTweetId;
@property (strong, nonatomic) UIRefreshControl *timelineRefreshControl;
@end

@implementation TweetsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.client = [TwitterClient sharedInstance];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.estimatedRowHeight = 100;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    [self.tableView registerNib:[UINib nibWithNibName:@"TweetCell" bundle:nil] forCellReuseIdentifier:@"tweetCell"];

    self.timelineRefreshControl = [[UIRefreshControl alloc] init];
    [self.timelineRefreshControl addTarget:self action:@selector(refreshTimelines) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:self.timelineRefreshControl atIndex:0];
    
    [self refreshTimelines];
}

- (void)viewWillAppear:(BOOL)animated {
    self.navigationItem.title = @"Home";
    
    UIImage *newTweetImage = [UIImage imageNamed:@"new"];
    newTweetImage = [newTweetImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIBarButtonItem *newTweet = [[UIBarButtonItem alloc]initWithImage:newTweetImage
                                                                style:UIBarButtonItemStylePlain
                                                               target:self
                                                               action:@selector(newTweet)];
    self.navigationItem.rightBarButtonItem = newTweet;
    
    UIImage *menuImage = [UIImage imageNamed:@"menu"];
    menuImage = [menuImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIBarButtonItem *menu = [[UIBarButtonItem alloc]initWithImage:menuImage
                                                            style:UIBarButtonItemStylePlain
                                                           target:self
                                                           action:@selector(showMenu)];
    self.navigationItem.leftBarButtonItem = menu;

    self.navigationController.navigationBar.translucent = NO;

    [self setNeedsStatusBarAppearanceUpdate];
    [self.viewControllerPresenter.currentController setNeedsStatusBarAppearanceUpdate];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

- (void)newTweet {
    NewTweetViewController *vc = [[NewTweetViewController alloc] initWithUser:[User currentUser]];
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void) showMenu {
    [self.viewControllerPresenter showMenu];
}

- (void)newTweetViewController:(NewTweetViewController *)viewController newTweet:(Tweet *)tweet {
    [self.client tweet:tweet completion:nil];
    
    NSMutableArray *tweets = [[NSMutableArray alloc] init];
    [tweets addObject:tweet];
    [tweets addObjectsFromArray:self.tweets];
    self.tweets = tweets;
    [self.tableView reloadData];
}

- (void)refreshTimelines {
    self.minTweetId = ULLONG_MAX;
    [self loadTweets];
}

- (void)loadTweets {
    NSDictionary *parameters = nil;
    
    if (self.minTweetId < ULLONG_MAX) {
        parameters = @{@"max_id": @(self.minTweetId)};
    }
    
    [self.client homeTimelineWithParams:parameters completion:^(NSArray *tweets, NSError *error) {
        if (tweets) {
            if (parameters) {
                self.tweets = [self.tweets arrayByAddingObjectsFromArray:tweets];
            } else {
                [self.timelineRefreshControl endRefreshing];
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Tweet *tweet = self.tweets[indexPath.row];
    TweetDetailViewController *vc = [[TweetDetailViewController alloc] initWithUser:[User currentUser] andTweet:tweet];
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)tweetCell:(TweetCell *)cell replyTweet:(Tweet *)tweet {
    NewTweetViewController *vc = [[NewTweetViewController alloc] initWithUser:[User currentUser] andTweet:tweet];
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)tweetCell:(TweetCell *)cell tapUserProfile:(User *)user {
    ProfileViewController *vc = [[ProfileViewController alloc] init];
    vc.user = user;
    vc.viewControllerPresenter = self.viewControllerPresenter;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)tweetDetail:(TweetDetailViewController *)detail replyTweet:(Tweet *)tweet {
    [self tweetCell:nil replyTweet:tweet];
}

@end
