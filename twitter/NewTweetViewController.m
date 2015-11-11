//
//  NewTweetViewController.m
//  twitter
//
//  Created by David Wang on 11/10/15.
//  Copyright © 2015 David Wang. All rights reserved.
//

#import "NewTweetViewController.h"
#import "UIImageView+AFNetworking.h"

@interface NewTweetViewController () <UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *replyToView;
@property (weak, nonatomic) IBOutlet UILabel *replyToLabel;
@property (weak, nonatomic) IBOutlet UIButton *tweetButton;
@property (weak, nonatomic) IBOutlet UITextView *tweetText;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tweetTextHeightConstraint;
@property (strong, nonatomic) User *author;
@property (strong, nonatomic) Tweet *inReplyTo;
@end

@implementation NewTweetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.navigationController.navigationBar.translucent = NO;
    self.tweetText.delegate = self;
    
    [self.tweetButton removeFromSuperview];
    [self.tweetText setInputAccessoryView:self.tweetButton];
    
    self.tweetButton.layer.cornerRadius = 4;
    self.tweetButton.layer.masksToBounds = YES;
    
    if (self.inReplyTo) {
        self.replyToLabel.text = [NSString stringWithFormat:@"In Reply To %@", self.inReplyTo.user.name];
        self.tweetText.text = [NSString stringWithFormat:@"@%@ ", self.inReplyTo.user.screenName];
        self.replyToView.hidden = NO;
    } else {
        self.tweetText.text = @"";
        self.replyToView.hidden = YES;
    }
    
    UIImage *closeImage = [UIImage imageNamed:@"close"];
    closeImage = [closeImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIBarButtonItem *closeCompose = [[UIBarButtonItem alloc]initWithImage:closeImage
                                                                    style:UIBarButtonItemStylePlain
                                                                   target:self
                                                                   action:@selector(dismissController)];
    self.navigationItem.rightBarButtonItem = closeCompose;
    
    UIImageView *avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
    [avatarImageView setImageWithURL:self.author.profileImageUrl];
    avatarImageView.layer.cornerRadius = 4;
    avatarImageView.layer.masksToBounds = YES;
    UIBarButtonItem *authorImage = [[UIBarButtonItem alloc] initWithCustomView:avatarImageView];
    self.navigationItem.leftBarButtonItem = authorImage;
    
    [self textViewDidChange:self.tweetText];
    [self.tweetText becomeFirstResponder];
    [self.tweetText setSelectedTextRange:[self.tweetText textRangeFromPosition:[self.tweetText endOfDocument] toPosition:[self.tweetText endOfDocument]]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (id)initWithUser:(User *)user andTweet:(Tweet *)tweet {
    if (self == [super initWithNibName:@"NewTweetViewController" bundle:nil]) {
        self.author = user;
        self.inReplyTo = tweet;
    }
    
    return self;
}

- (id)initWithUser:(User *)user {
    return [self initWithUser:user andTweet:nil];
}

- (IBAction)onTweet:(id)sender {
    Tweet *tweet = [[Tweet alloc] initFromText:self.tweetText.text author:self.author inReplyTo:self.inReplyTo];
    [self.delegate newTweetViewController:self newTweet:tweet];
    [self dismissController];

}

- (void)dismissController {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)textViewDidChange:(UITextView *)textView {
    CGSize newSize = [textView sizeThatFits:CGSizeMake(textView.frame.size.width, CGFLOAT_MAX)];
    self.tweetTextHeightConstraint.constant = newSize.height;
}

@end
