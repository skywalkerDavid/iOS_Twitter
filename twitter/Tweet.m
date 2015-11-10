//
//  Tweet.m
//  twitter
//
//  Created by David Wang on 11/8/15.
//  Copyright © 2015 David Wang. All rights reserved.
//

#import "Tweet.h"

@implementation Tweet

- (id)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        self.tweetId = dictionary[@"id_str"];
        self.user = [[User alloc] initWithDictionary:dictionary[@"user"]];
        self.text = dictionary[@"text"];
        NSString *createdAtString = dictionary[@"created_at"];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"EEE MMM d HH:mm:ss Z y";
        self.createdAt = [formatter dateFromString:createdAtString];
        if (dictionary[@"retweeted_status"]) {
            self.retweetedFrom = [[Tweet alloc]initWithDictionary:dictionary[@"retweeted_status"]];
        }
        self.retweetCount = [dictionary[@"retweet_count"] longLongValue];
        self.likeCount = [dictionary[@"favorite_count"] longLongValue];
        self.retweeted = [dictionary[@"retweeted"] boolValue];
        self.liked = [dictionary[@"favorited"] boolValue];
    }
    
    return self;
}

+ (NSArray *)tweetsWithArray:(NSArray *)array {
    NSMutableArray *tweets = [NSMutableArray array];
    
    for (NSDictionary *dictionary in array) {
        [tweets addObject:[[Tweet alloc] initWithDictionary:dictionary]];
    }
    
    return tweets;
}

- (NSString *) originalTweetId {
    if (!self.retweeted) {
        return nil;
    }
    
    if (self.retweetedFrom) {
        return self.retweetedFrom.tweetId;
    } else {
        return self.tweetId;
    }
}

@end
