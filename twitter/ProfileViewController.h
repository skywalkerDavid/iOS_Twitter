//
//  ProfileViewController.h
//  twitter
//
//  Created by David Wang on 11/16/15.
//  Copyright © 2015 David Wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"
#import "ViewControllerPresenter.h"

@interface ProfileViewController : UIViewController
@property (strong, nonatomic) User *user;
@property (strong, nonatomic) ViewControllerPresenter *viewControllerPresenter;
@end
