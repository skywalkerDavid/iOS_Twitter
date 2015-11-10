//
//  Tweet.h
//  twitter
//
//  Created by David Wang on 11/8/15.
//  Copyright © 2015 David Wang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

@interface Tweet : NSObject

@property (strong, nonatomic) NSString *tweetId;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSDate *createdAt;
@property (nonatomic, strong) User *user;
@property (strong, nonatomic) Tweet *retweetedFrom;
@property (strong, nonatomic) Tweet *inReplyTo;
@property (assign, nonatomic) long long retweetCount;
@property (assign, nonatomic) long long likeCount;
@property (assign, nonatomic) BOOL retweeted;
@property (assign, nonatomic) BOOL liked;

- (id)initWithDictionary:(NSDictionary *)dictionary;

+ (NSArray *)tweetsWithArray:(NSArray *)array;

- (NSString *) originalTweetId;

@end
