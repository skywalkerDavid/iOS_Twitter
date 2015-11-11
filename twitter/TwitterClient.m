//
//  TwitterClient.m
//  twitter
//
//  Created by David Wang on 11/8/15.
//  Copyright © 2015 David Wang. All rights reserved.
//

#import "TwitterClient.h"
#import "Tweet.h"

NSString *const kTwitterConsumerKey = @"euoUpx1ixT3Z8Oeoh2BZdSHU5";
NSString *const kTwitterConsumerSecret = @"fmmesJe8HXfRHPNSv99hbeDasQykPgkVgfXD8P1GRWdUSaagfC";
NSString *const kTwitterBaseUrl = @"https://api.twitter.com";

@interface TwitterClient()

@property (nonatomic, strong) void (^loginCompletion)(User *user, NSError *error);

@end

@implementation TwitterClient

+ (TwitterClient *)sharedInstance {
    static TwitterClient *instance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (instance == nil) {
            instance = [[TwitterClient alloc] initWithBaseURL:[NSURL URLWithString:kTwitterBaseUrl] consumerKey:kTwitterConsumerKey consumerSecret:kTwitterConsumerSecret];
        }
    });
    
    return instance;
}

- (void)loginWithCompletion:(void (^)(User *user, NSError *error))completion {
    self.loginCompletion = completion;
    
    [self.requestSerializer removeAccessToken];
    [self fetchRequestTokenWithPath:@"oauth/request_token" method:@"GET" callbackURL:[NSURL URLWithString:@"cptwitterdemo://oauth"] scope:nil success:^(BDBOAuth1Credential *requestToken) {
        NSLog(@"Got request token");
        
        NSURL *authURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.twitter.com/oauth/authorize?oauth_token=%@", requestToken.token]];
        [[UIApplication sharedApplication] openURL:authURL];
        
    } failure:^(NSError *error) {
        NSLog(@"Failed to get the request token");
    }];
}

- (void)processAuthUrl:(NSURL *)url {
    [self fetchAccessTokenWithPath:@"oauth/access_token" method:@"POST" requestToken:[BDBOAuth1Credential credentialWithQueryString:url.query] success:^(BDBOAuth1Credential *accessToken) {
        NSLog(@"Got the access token");
        
        [self.requestSerializer saveAccessToken:accessToken];
        [self GET:@"1.1/account/verify_credentials.json" parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
            User * user = [[User alloc] initWithDictionary:responseObject];
            self.loginCompletion(user, nil);
        } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
            NSLog(@"Failed to get current user");
            self.loginCompletion(nil, error);
        }];
    } failure:^(NSError *error) {
        NSLog(@"Failed to get the access token");
    }];
}

-(void)homeTimelineWithParams:(NSDictionary *)params completion:(void (^)(NSArray *tweets, NSError *error))completion {
    [self GET:@"1.1/statuses/home_timeline.json" parameters:params success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        NSArray *tweetsArray = [Tweet tweetsWithArray:responseObject];
        completion(tweetsArray, nil);
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        completion(nil, error);
    }];
}

- (void)likeTweet:(Tweet *)tweet completion:(void (^)(NSDictionary *newTweetInfo, NSError * error))completion {
    NSDictionary *parameters = @{@"id": tweet.tweetId};
    
    [self POST:@"/1.1/favorites/create.json" parameters:parameters success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        completion(responseObject, nil);
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        completion(nil, error);
    }];
}

- (void)unlikeTweet:(Tweet *)tweet completion:(void (^)(NSDictionary *newTweetInfo, NSError * error))completion {
    NSDictionary *parameters = @{@"id": tweet.tweetId};
    
    [self POST:@"/1.1/favorites/destroy.json" parameters:parameters success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        completion(responseObject, nil);
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        completion(nil, error);
    }];
}

- (void)retweet:(Tweet *)tweet completion:(void (^)(NSDictionary *newTweetInfo, NSError *error))completion {
    NSDictionary *parameters = @{@"id": tweet.tweetId};
    
    NSString *endpoint = [NSString stringWithFormat:@"/1.1/statuses/retweet/%@.json", tweet.tweetId];
    [self POST:endpoint parameters:parameters success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        completion(responseObject, nil);
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        completion(nil, error);
    }];
}

- (void)unRetweet:(Tweet *)tweet completion:(void (^)(NSDictionary *newTweetInfo, NSError * error))completion {
    NSString *endpoint = [NSString stringWithFormat:@"/1.1/statuses/show/%@.json", [tweet originalTweetId]];
    NSDictionary *parameters = @{@"include_my_retweet": @(YES)};
    
    [self GET:endpoint parameters:parameters success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        NSString *tweetId = responseObject[@"current_user_retweet"][@"id_str"];
        NSString *endpoint = [NSString stringWithFormat:@"/1.1/statuses/destroy/%@.json", tweetId];
        [self POST:endpoint parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
            completion(nil, nil);
        } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
            completion(nil, error);
        }];
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        completion(nil, error);
    }];
}

- (void)tweet:(Tweet *)tweet completion:(void (^)(NSDictionary *newTweetInfo, NSError * error))completion {
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    parameters[@"status"] = tweet.text;
    if (tweet.inReplyTo) {
        parameters[@"in_reply_to_status_id"] = tweet.inReplyTo.tweetId;
    };
    
    [self POST:@"/1.1/statuses/update.json" parameters:parameters success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        if (completion) {
            completion(responseObject, nil);
        }
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        if (completion) {
            completion(nil, error);
        }
    }];
}
@end
