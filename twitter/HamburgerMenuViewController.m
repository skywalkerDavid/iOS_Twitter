//
//  HamburgerMenuViewController.m
//  twitter
//
//  Created by David Wang on 11/16/15.
//  Copyright © 2015 David Wang. All rights reserved.
//

#import "HamburgerMenuViewController.h"

@interface HamburgerMenuViewController ()
@property (weak, nonatomic) IBOutlet UIView *menuView;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentViewLeadingConstraint;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *tapGestureRecognizer;

@end

@implementation HamburgerMenuViewController {
    CGFloat _originalcontentViewLeadingConstant;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _menuOpened = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    if (self.contentViewController) {
        return [self.contentViewController preferredStatusBarStyle];
    } else {
        return [super preferredStatusBarStyle];
    }
}

- (void) setMenuViewController:(UIViewController *)menuViewController {
    if (self.view) {
        if (_menuViewController && _menuViewController != menuViewController) {
            [_menuViewController willMoveToParentViewController:nil];
            [_menuViewController.view removeFromSuperview];
            [_menuViewController didMoveToParentViewController:nil];
        }
        
        [self.view layoutIfNeeded];
        _menuViewController = menuViewController;
        
        [_menuViewController willMoveToParentViewController:self];
        [self.menuView addSubview:menuViewController.view];
        [_menuViewController didMoveToParentViewController:self];
    }
}

- (void) setContentViewController:(UIViewController *)contentViewController {
    if (self.view) {
        
        if (_contentViewController && _contentViewController != contentViewController) {
            [_contentViewController willMoveToParentViewController:nil];
            [_contentViewController.view removeFromSuperview];
            [_contentViewController didMoveToParentViewController:nil];
        }
        
        [contentViewController willMoveToParentViewController:self];
        [self.contentView addSubview:contentViewController.view];
        [contentViewController didMoveToParentViewController:self];

        [self.view layoutIfNeeded];
        _contentViewController = contentViewController;
        [self setNeedsStatusBarAppearanceUpdate];
        
        if (self.menuOpened) {
            [self closeMenu];
        }
    }
}

- (IBAction)onDragMenuView:(UIPanGestureRecognizer *)sender {
    CGPoint translation = [sender translationInView:self.view];
    CGPoint velocity = [sender velocityInView:self.view];
    
    if (sender.state == UIGestureRecognizerStateBegan) {
        _originalcontentViewLeadingConstant = self.contentViewLeadingConstraint.constant;
    } else if (sender.state == UIGestureRecognizerStateChanged) {
        CGFloat newPosition = _originalcontentViewLeadingConstant + translation.x;
        if (newPosition >= 0) {
            self.contentViewLeadingConstraint.constant = newPosition;
        }
    } else if (sender.state == UIGestureRecognizerStateEnded) {
        if (velocity.x > 0) {
            [self openMenu];
        } else {
            [self closeMenu];
        }
    }
}

- (void)openMenu {
//    self.contentViewController.view.userInteractionEnabled = NO;
//    self.tapGestureRecognizer.cancelsTouchesInView = YES;
    
    [UIView animateWithDuration:0.3 animations:^{
        self.contentViewLeadingConstraint.constant = self.view.frame.size.width - 50;
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        _menuOpened = YES && finished;
    }];
}

- (void)closeMenu {
    [UIView animateWithDuration:0.3 animations:^{
        self.contentViewLeadingConstraint.constant = 0;
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        _menuOpened = !finished;
//        self.contentViewController.view.userInteractionEnabled = YES;
//        self.tapGestureRecognizer.cancelsTouchesInView = NO;
    }];
}

@end
