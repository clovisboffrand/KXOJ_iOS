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

#define FACEBOOK_URL    @"http://www.facebook.com/bristolbeat"
#define TWITTER_URL     @"http://www.twitter.com/bristolsrockmix"
#define WEBSITE_URL     @"http://bristolbeat.com/"
#define INSTAGRAM_URL   @"https://instagram.com/bristolbeatradio"
#define PHONE_NUMBER    @"860-261-7456"
#define EMAIL_ADDRESS   @"studio@bristolbeat.com"
#define CALENDAR_URL    @"http://bristolbeat.com/event-directory/"
#define ADVERTISERS_URL @"http://www.bristolbeat.com/directory"
#define CONTESTS_URL    @"http://bristolbeat.com/category/contests/"

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
        case 1:
            viewController.title = @"Facebook";
            viewController.pageURL = FACEBOOK_URL;
            break;
        case 2:
            viewController.title = @"Twitter";
            viewController.pageURL = TWITTER_URL;
            break;
        case 4:
            viewController.title = @"Website";
            viewController.pageURL = WEBSITE_URL;
            break;
        case 5:
            viewController.title = @"Calendar";
            viewController.pageURL = CALENDAR_URL;
            break;
        case 6:
            viewController.title = @"Advertisers";
            viewController.pageURL = ADVERTISERS_URL;
            break;
        case 7:
            viewController.title = @"Contests";
            viewController.pageURL = CONTESTS_URL;
            break;
        case 8:
            viewController.title = @"Instagram";
            viewController.pageURL = INSTAGRAM_URL;
            break;
    }
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style: UIBarButtonItemStyleBordered target:nil action:nil];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (IBAction)didTapOtherButton:(UIButton *)button {
    switch (button.tag) {
        case 5: {
            NSString *url = [NSString stringWithFormat:@"telprompt:%@", PHONE_NUMBER];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
            break;
        }
        case 6:
            [self sendSMS];
            break;
        case 7:
            [self sendEmail];
            break;
    }
}

#pragma mark - Send SMS

- (void)sendSMS {
    MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init] ;
    if ([MFMessageComposeViewController canSendText]) {
        controller.body = @"";
        controller.recipients = [NSArray arrayWithObjects:PHONE_NUMBER, nil];
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
    [picker setToRecipients:[NSArray arrayWithObjects:EMAIL_ADDRESS, nil]];
    [picker setCcRecipients:nil];
    [picker setBccRecipients:nil];
    [picker setSubject:@"Mobile App Email"];
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)launchMailAppOnDevice {
    NSString *recipients = [NSString stringWithFormat:@"mailto:%@?cc=&subject=iRadio Email", EMAIL_ADDRESS];
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
