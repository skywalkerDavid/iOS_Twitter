//
//  MenuViewController.m
//  twitter
//
//  Created by David Wang on 11/16/15.
//  Copyright © 2015 David Wang. All rights reserved.
//

#import "MenuViewController.h"
#import "UIImageView+AFNetworking.h"
#import "TweetsViewController.h"
#import "User.h"

@interface MenuViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UITableView *menuTableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *avatarTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameTopConstraint;
@property (strong, nonatomic) NSArray *menuItems;
@end

@implementation MenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.menuItems = @[
                       @{@"text": @"Timeline", @"icon": @"timeline"},
                       @{@"text": @"Profile", @"icon": @"profile"},
                       @{@"text": @"Logout", @"icon": @"logo"}
                       ];
    
    self.menuTableView.delegate = self;
    self.menuTableView.dataSource = self;
    self.avatarImageView.layer.cornerRadius = 4;
    self.avatarImageView.layer.masksToBounds = YES;
    
    [self.avatarImageView setImageWithURL:User.currentUser.profileImageUrl];
    self.nameLabel.text = User.currentUser.name;
    self.descriptionLabel.text = User.currentUser.tagline;
}

- (void)viewWillAppear:(BOOL)animated {
    UIApplication* sharedApplication = [UIApplication sharedApplication];
    CGFloat statusBarHeight = sharedApplication.statusBarFrame.size.height;
    self.avatarTopConstraint.constant = 8 + statusBarHeight;
    self.nameTopConstraint.constant = 8 + statusBarHeight;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.menuItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self dequeueBasicCellForTableView:tableView];
    cell.textLabel.text = self.menuItems[indexPath.row][@"text"];
    cell.imageView.image = [UIImage imageNamed:self.menuItems[indexPath.row][@"icon"]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0:
            [self.viewControllerPresenter showTimeline];
            break;
            
        case 1:
            [self.viewControllerPresenter showProfile];
            break;
            
        case 2:
            [User logout];
            break;
            
        default:
            break;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


- (UITableViewCell *)dequeueBasicCellForTableView:(UITableView *)tableView {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    return cell;
}


@end
