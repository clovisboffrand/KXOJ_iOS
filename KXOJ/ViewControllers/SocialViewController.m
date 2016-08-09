//
//  SocialViewController.m
//  WJRS
//
//  Created by admin_user on 3/7/16.
//
//

#import "SocialViewController.h"
#import "SocialPageViewController.h"
#import <MessageUI/MFMailComposeViewController.h>
#import <MessageUI/MessageUI.h>
#import "header.h"

@interface SocialViewController () <UIWebViewDelegate, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate>
{
    IBOutlet UIWebView *adWebView;
}

@end

#define FACEBOOK_URL1   @"http://www.facebook.com/kxojtulsa"
#define FACEBOOK_URL2   @"http://facebook.com/kxoj2"

#define TWITTER_URL1    @"http://twitter.com/kxoj"
#define TWITTER_URL2    @"http://twitter.com/kxojhd2"

#define INSTAGRAM_URL   @"http://instagram.com/kxoj2"
#define VINE_URL        @"https://vine.co/u/1230442394806587392"
#define YOUTUBE_URL     @"http://www.youtube.com/kxoj"

#define WEBSITE_URL1    @"http://www.kxoj.com"
#define WEBSITE_URL2    @"http://kxoj2.com"

#define PHONE_NUMBER    @"918-460-5965"
#define SMS_NUMBER1     @"918-512-1009"
#define SMS_NUMBER2     @"539-302-4945"

#define EMAIL_ADDRESS1  @"onair@kxoj.com"
#define EMAIL_ADDRESS2  @"studio@kxoj2.com"

@implementation SocialViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupBanner];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Setup Ad Banner View

- (void)setupBanner {
    [adWebView loadHTMLString:[CommonHelpers HTMLBodyOfBannerView] baseURL:nil];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        [[UIApplication sharedApplication] openURL:[request URL]];
        return NO;
    }
    
    return YES;
}

#pragma mark - Button Action Methods

- (IBAction)didTapSocialButton:(UIButton *)button {
    SocialPageViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SocialPageViewController"];
    switch (button.tag) {
        case 100:
            viewController.title = @"Facebook";
            if ([[AppSettings shared].channelId integerValue] == 1) {
                viewController.pageURL = FACEBOOK_URL1;
            } else {
                viewController.pageURL = FACEBOOK_URL2;
            }
            break;
        case 101:
            viewController.title = @"Twitter";
            if ([[AppSettings shared].channelId integerValue] == 1) {
                viewController.pageURL = TWITTER_URL1;
            } else {
                viewController.pageURL = TWITTER_URL2;
            }
            break;
        case 102:
            viewController.title = @"Instagram";
            viewController.pageURL = INSTAGRAM_URL;
            break;
        case 103:
            viewController.title = @"Vine";
            viewController.pageURL = VINE_URL;
            break;
        case 104:
            viewController.title = @"Youtube";
            viewController.pageURL = YOUTUBE_URL;
            break;
        case 105:
            viewController.title = @"Website";
            if ([[AppSettings shared].channelId integerValue] == 1) {
                viewController.pageURL = WEBSITE_URL1;
            } else {
                viewController.pageURL = WEBSITE_URL2;
            }
            break;
    }
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style: UIBarButtonItemStyleBordered target:nil action:nil];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (IBAction)didTapOtherButton:(UIButton *)button {
    switch (button.tag) {
        case 106: {
            NSString *url = [NSString stringWithFormat:@"telprompt:%@", PHONE_NUMBER];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
            break;
        }
        case 107:
            [self sendEmail];
            break;
        case 108:
            [self sendSMS];
            break;
    }
}

#pragma mark - Send SMS

- (void)sendSMS {
    MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init] ;
    if ([MFMessageComposeViewController canSendText]) {
        controller.body = @"";
        NSString *number;
        if ([AppSettings shared].channelId.integerValue == 1) {
            number = SMS_NUMBER1;
        } else {
            number = SMS_NUMBER2;
        }
        controller.recipients = [NSArray arrayWithObjects:number, nil];
        controller.messageComposeDelegate = self;
        [self presentViewController:controller animated:YES completion:nil];
    }
}

#pragma mark - Send Email

- (void)sendEmail {
    Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
    if (mailClass != nil) {
        if ([MFMailComposeViewController canSendMail]) {
            [self displayComposerSheet];
        } else {
            [self launchMailAppOnDevice];
        }
    } else {
        [self launchMailAppOnDevice];
    }
}

- (void)displayComposerSheet {
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    [[picker navigationBar] setTintColor:[UIColor blackColor]];
    picker.mailComposeDelegate = self;
    
    NSString *address;
    if ([AppSettings shared].channelId.integerValue == 1) {
        address = EMAIL_ADDRESS1;
    } else {
        address = EMAIL_ADDRESS2;
    }
    [picker setToRecipients:[NSArray arrayWithObjects:address, nil]];
    [picker setCcRecipients:nil];
    [picker setBccRecipients:nil];
    [picker setSubject:@"Mobile App Email"];
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)launchMailAppOnDevice {
    NSString *address;
    if ([AppSettings shared].channelId.integerValue == 1) {
        address = EMAIL_ADDRESS1;
    } else {
        address = EMAIL_ADDRESS2;
    }
    NSString *recipients = [NSString stringWithFormat:@"mailto:%@?cc=&subject=iRadio Email", address];
    NSString *body = [NSString stringWithFormat:@"&body="];
    NSString *email = [NSString stringWithFormat:@"%@%@", recipients, body];
    email = [email stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:email]];
}

#pragma mark - MFMailComposeViewControllerDelegate Method

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - MFMessageComposeViewControllerDelegate Method

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    switch(result) {
        case MessageComposeResultCancelled:
            // user canceled sms
            break;
        case MessageComposeResultSent: {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"iRadio" message:@"Send SMS successfully!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            break;
        }
        case MessageComposeResultFailed: {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"iRadio" message:@"Send SMS fail!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            break;
        }
        default:
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
