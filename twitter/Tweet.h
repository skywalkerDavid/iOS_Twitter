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
@property (assign, nonatomic) BOOL retweeted;
@property (assign, nonatomic) BOOL liked;
@property (assign, nonatomic) long long retweetCount;
@property (assign, nonatomic) long long likeCount;

+ (NSArray *)tweetsWithArray:(NSArray *)array;

- (id)initWithDictionary:(NSDictionary *)dictionary;
- (id)initFromText:(NSString *)text author:(User *)author inReplyTo:(Tweet *)inReplyTo;
- (void)updateWithDictionary:(NSDictionary *)dictionary;
- (NSString *) originalTweetId;

@end
