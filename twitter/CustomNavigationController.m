//
//  CustomNavigationController.m
//  twitter
//
//  Created by David Wang on 11/16/15.
//  Copyright © 2015 David Wang. All rights reserved.
//

#import "CustomNavigationController.h"

@interface CustomNavigationController ()

@end

@implementation CustomNavigationController

- (UIStatusBarStyle)preferredStatusBarStyle {
    return [self.visibleViewController preferredStatusBarStyle];
}

@end
