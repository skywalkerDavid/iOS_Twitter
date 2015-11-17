//
//  ViewControllerPresenter.h
//  twitter
//
//  Created by David Wang on 11/16/15.
//  Copyright © 2015 David Wang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "User.h"

@interface ViewControllerPresenter : NSObject

@property (strong, readonly, nonatomic) UIViewController *currentController;

- (void)presentInWindow:(UIWindow *)window;
- (void)showTimeline;
- (void)showProfile;
- (void)showProfileWithUser:(User*)user;
- (void)showMenu;
@end
