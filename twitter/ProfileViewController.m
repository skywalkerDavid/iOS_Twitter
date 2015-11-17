//
//  ProfileViewController.m
//  twitter
//
//  Created by David Wang on 11/16/15.
//  Copyright © 2015 David Wang. All rights reserved.
//

#import "ProfileViewController.h"
#import "UIImageView+AFNetworking.h"

@interface ProfileViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *barImageView;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *handleLabel;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (weak, nonatomic) IBOutlet UILabel *followingCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *followerCountLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *barImageViewTopConstraint;

@end

@implementation ProfileViewController {
    UINavigationBar *_navigationBar;
    CGFloat _kMinHeaderImageHeight;
    CGFloat _kMaxHeaderImageHeight;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void) viewWillAppear:(BOOL)animated {
    UINavigationBar *navbar = self.navigationController.navigationBar;
    UIApplication* application = [UIApplication sharedApplication];
    CGFloat statusBarHeight = application.statusBarFrame.size.height;
    
    if (navbar == nil) {
        _navigationBar = [[UINavigationBar alloc]initWithFrame:CGRectMake(0, statusBarHeight, self.view.frame.size.width, 44)];
        navbar = _navigationBar;
        UIImage *menuImage = [UIImage imageNamed:@"menu"];
        UIBarButtonItem *menuButton = [[UIBarButtonItem alloc] initWithImage:menuImage style:0 target:self action:@selector(menuButtonTapped:)];
        UINavigationItem *navItem = [[UINavigationItem alloc] initWithTitle:@""];
        navItem.leftBarButtonItem = menuButton;
        navbar.items = @[navItem];
        [self.view addSubview:navbar];
    }
    [navbar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    navbar.translucent = YES;
    navbar.tintColor = [UIColor whiteColor];
    
    self.avatarImageView.layer.cornerRadius = 4;
    self.avatarImageView.layer.masksToBounds = YES;
    
    self.barImageView.clipsToBounds = YES;
    
    [self setNeedsStatusBarAppearanceUpdate];
    [self.viewControllerPresenter.currentController setNeedsStatusBarAppearanceUpdate];
}

- (void)menuButtonTapped:(id)sender {
    [self.viewControllerPresenter showMenu];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void) setUser:(User *)user {
    if ([self view]) {
        [self.barImageView setImageWithURL:user.bannerUrl];
        [self.avatarImageView setImageWithURL:user.profileImageUrl];
        self.nameLabel.text = user.name;
        self.handleLabel.text = [NSString stringWithFormat:@"@%@", user.screenName];
        self.descriptionTextView.text = user.tagline;
        self.followerCountLabel.text = [NSString stringWithFormat:@"%ld", user.followersCount];
        self.followingCountLabel.text = [NSString stringWithFormat:@"%ld", user.friendsCount];
    }
}

@end
