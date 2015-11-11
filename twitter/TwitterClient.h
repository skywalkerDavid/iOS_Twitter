//
//  TwitterClient.h
//  twitter
//
//  Created by David Wang on 11/8/15.
//  Copyright © 2015 David Wang. All rights reserved.
//

#import "BDBOAuth1RequestOperationManager.h"
#import "User.h"
#import "Tweet.h"

@interface TwitterClient : BDBOAuth1RequestOperationManager

+ (TwitterClient *)sharedInstance;

- (void)loginWithCompletion:(void (^)(User *user, NSError *error))completion;
- (void)processAuthUrl:(NSURL *)url;
- (void)homeTimelineWithParams:(NSDictionary *)params completion:(void (^)(NSArray *tweets, NSError *error))completion;
- (void)likeTweet:(Tweet *)tweet completion:(void (^)(NSDictionary *tweetInfo, NSError *error))completion;
- (void)unlikeTweet:(Tweet *)tweet completion:(void (^)(NSDictionary *tweetInfo, NSError * error))completion;
- (void)retweet:(Tweet *)tweet completion:(void (^)(NSDictionary *tweetInfo, NSError *error))completion;
- (void)unRetweet:(Tweet *)tweet completion:(void (^)(NSDictionary *tweetInfo, NSError * error))completion;
- (void)tweet:(Tweet *)tweet completion:(void (^)(NSDictionary *tweetInfo, NSError * error))completion;
@end
