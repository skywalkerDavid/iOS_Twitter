//
//  User.m
//  twitter
//
//  Created by David Wang on 11/8/15.
//  Copyright © 2015 David Wang. All rights reserved.
//

#import "User.h"
#import "TwitterClient.h"

NSString *const UserDidLoginNotification = @"UserDidLoginNotification";
NSString *const UserDidLogoutNotification = @"UserDidLogoutNotification";

@interface User()

@property (nonatomic, strong) NSDictionary *dictionary;

@end

@implementation User

- (id)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        self.dictionary = dictionary;
        self.name = dictionary[@"name"];
        self.screenName = dictionary[@"screen_name"];
        self.profileImageUrl = [NSURL URLWithString:dictionary[@"profile_image_url_https"]];
        self.tagline = dictionary[@"description"];
        self.backgroundUrl = [NSURL URLWithString:dictionary[@"profile_background_image_url"]];
        self.bannerUrl = [NSURL URLWithString:dictionary[@"profile_banner_url"]];
        self.followersCount = [dictionary[@"followers_count"] longValue];
        self.friendsCount = [dictionary[@"friends_count"] longValue];
    }
    
    return self;
}

static User *_currentUser = nil;
NSString *const kCurrentUserKey = @"CurrentUserKey";


+ (User *)currentUser {
    if (_currentUser == nil) {
        NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:kCurrentUserKey];
        
        if (data != nil) {
            NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
            _currentUser = [[User alloc] initWithDictionary:dictionary];
        }
    }
    
    return _currentUser;
}

+ (void)setCurrentUser:(User *)user {
    _currentUser = user;
    
    if(_currentUser != nil) {
        NSData *data = [NSJSONSerialization dataWithJSONObject:_currentUser.dictionary options:0 error:NULL];
        [[NSUserDefaults standardUserDefaults] setObject:data forKey:kCurrentUserKey];
    } else {
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:kCurrentUserKey];
    }
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)logout {
    [User setCurrentUser:nil];
    [[TwitterClient sharedInstance].requestSerializer removeAccessToken];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:UserDidLogoutNotification object:nil];
}

+ (void)login:(User *)user {
    [User setCurrentUser:user];
    
    if (user != nil) {
        [[NSNotificationCenter defaultCenter] postNotificationName:UserDidLoginNotification object:nil];
    }
}

@end
