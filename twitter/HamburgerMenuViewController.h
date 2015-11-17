//
//  HamburgerMenuViewController.h
//  twitter
//
//  Created by David Wang on 11/16/15.
//  Copyright © 2015 David Wang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HamburgerMenuViewController : UIViewController
@property (weak, nonatomic) UIViewController *menuViewController;
@property (weak, nonatomic) UIViewController *contentViewController;
@property (assign, readonly, nonatomic) BOOL menuOpened;

- (void) openMenu;
- (void) closeMenu;
@end
