//
//  ViewControllerPresenter.m
//  twitter
//
//  Created by David Wang on 11/16/15.
//  Copyright © 2015 David Wang. All rights reserved.
//

#import "ViewControllerPresenter.h"
#import "HamburgerMenuViewController.h"
#import "TweetsViewController.h"
#import "MenuViewController.h"
#import "ProfileViewController.h"
#import "CustomNavigationController.h"
#import "User.h"

@interface ViewControllerPresenter() <UINavigationControllerDelegate>

@end

@implementation ViewControllerPresenter {
    HamburgerMenuViewController *_hamburgerViewController;
    MenuViewController *_menuViewController;
    TweetsViewController *_tweetsViewController;
    CustomNavigationController *_tweetsNavigationController;
    ProfileViewController *_profileViewController;
}

- (void) presentInWindow:(UIWindow *)window {
    window.rootViewController = [self rootViewController];
    [self showTimeline];
}

#pragma mark private methods
- (UIViewController *)rootViewController {
    if (_hamburgerViewController == nil) {
        _hamburgerViewController = [[HamburgerMenuViewController alloc] init];
        
        _menuViewController = [[MenuViewController alloc] init];
        _menuViewController.viewControllerPresenter = self;
        
        _hamburgerViewController.menuViewController = _menuViewController;
        _currentController = _hamburgerViewController;
    }
    
    return _hamburgerViewController;
}

- (void)showTimeline {
    if (_tweetsNavigationController == nil) {
        _tweetsViewController = [[TweetsViewController alloc] init];
        _tweetsViewController.viewControllerPresenter = self;
        
        _tweetsNavigationController = [[CustomNavigationController alloc] initWithRootViewController:_tweetsViewController];
        _tweetsNavigationController.delegate = self;
    }
    
    _hamburgerViewController.contentViewController = _tweetsNavigationController;
}

- (void)showMenu {
    if (_hamburgerViewController.menuOpened) {
        [_hamburgerViewController closeMenu];
    } else {
        [_hamburgerViewController openMenu];
    }
}

- (void)showProfile {
    [self showProfileWithUser:User.currentUser];
}

- (void)showProfileWithUser:(User *)user {
    if (_profileViewController == nil) {
        _profileViewController = [[ProfileViewController alloc] init];
        _profileViewController.viewControllerPresenter = self;
    }
    
    _profileViewController.user = user;
    _hamburgerViewController.contentViewController = _profileViewController;
}


- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [viewController setNeedsStatusBarAppearanceUpdate];
    [navigationController setNeedsStatusBarAppearanceUpdate];
}

@end
