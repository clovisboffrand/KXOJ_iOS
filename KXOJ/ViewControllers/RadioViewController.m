//
//  RadioViewController.m
//  iRadio
//
//  Created by ben on 10/05/11.
//  Copyright 2011 Ingravitymedia.com. All rights reserved.
//

#import "RadioViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <MediaPlayer/MediaPlayer.h>
#import "Header.h"
#import "RecentSongViewController.h"
#import "NSString+HTML.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
#import "Reachability.h"

@interface RadioViewController() <UIWebViewDelegate, AVAudioSessionDelegate, NSXMLParserDelegate>
{
    IBOutlet UIWebView *_adWebView;
    IBOutlet UIView *volumeSlider;
    IBOutlet UIButton *playpausebutton;
    
    IBOutlet UIImageView *ivCoverImage;
    IBOutlet UILabel *lblTitle;
    IBOutlet UILabel *lblArtist;
}

@property (nonatomic, strong) AVPlayer *radiosound;

@end


@implementation RadioViewController
{
    NSMutableArray *feeds;
    NSMutableDictionary *feeditem;
    NSMutableString *title;
    NSMutableString *link;
    NSMutableString *songguid;
    NSMutableString *songdescription;
    NSMutableString *songmedia;
    NSMutableString *pubDate;
    
    NSString *element;
    BOOL shouldPlay; //variable indicates that playback should be enabled
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    shouldPlay = YES;
    
    [self reloadRadioStreaming];
    
    // Register self for remote notifications of play/pause toggle
    // (i.e. when user backgrounds app, double-taps home,
    // then swipes right to reveal multimedia control buttons).
    // See MyWindow.h for more info.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbutton) name:@"TogglePlayPause" object:nil];
    
    // Add notification methods
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSetAlarm) name:@"setAlarm" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didWakeup) name:@"didWakeup" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateStream) name:@"updateStream" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playRadio) name:@"playRadio" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pauseRadio) name:@"pauseRadio" object:nil];
    
    [self updatebuttonstatus];
    
    [self addBanner];
    
    // Setup timer to get feed content periodicallly.
    NSTimer *feedTimer = [NSTimer scheduledTimerWithTimeInterval:45 target:self selector:@selector(getFeedContent) userInfo:nil repeats:YES];
    [feedTimer fire];
    
    // Initialize Reachability
    Reachability *reachability = [Reachability reachabilityWithHostName:@"www.google.com"];
    
    // Start Monitoring
    NSLog(@"Start Reachability Monitoring");
    [reachability startNotifier];
    
    // Add observer for reachability change.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityDidChange:) name:kReachabilityChangedNotification object:nil];
    
    // share instance for audio remote control
    // Registers this class as the delegate of the audio session.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(interruption:) name:AVAudioSessionInterruptionNotification object:nil];
}

- (void)addBanner {
    [_adWebView loadHTMLString:[CommonHelpers HTMLBodyOfBannerView] baseURL:nil];
}

#pragma mark - WebView Delegate Methods

- (BOOL)webView:(UIWebView *)inWeb shouldStartLoadWithRequest:(NSURLRequest *)inRequest navigationType:(UIWebViewNavigationType)inType {
    if (inType == UIWebViewNavigationTypeLinkClicked) {
        [[UIApplication sharedApplication] openURL:[inRequest URL]];
        return NO;
    }
    
    return YES;
}

#pragma mark - Reachability Observer

- (void)reachabilityDidChange:(NSNotification *)notification {
    Reachability *reachability = (Reachability *)[notification object];
    
    if ([reachability isReachable]) {
        NSLog(@"Reachable");
        // First, we check that radio was played before and should play again
        if (shouldPlay) {
            [self reloadRadioStreaming];
        }
    } else {
        NSLog(@"Unreachable");
        [self pauseRadio];
    }
}

#pragma mark - Play/Pause Radio Streaming

- (void)playRadio {
    [self playCurrentTrack];
}

- (void)pauseRadio {
    [self pauseCurrentTrack];
}

- (void)didSetAlarm {
    [self pauseCurrentTrack];
}

- (void)updateStream {
    if (self.radiosound.rate == 1.0) {
        [self pauseCurrentTrack];
    } else {
        [self playCurrentTrack];
    }
}

- (void)didWakeup {
    [self playCurrentTrack];
}

- (void)updatebuttonstatus {
    if (self.radiosound.rate == 1.0) {
        [playpausebutton setImage:[UIImage imageNamed:@"btn_pause.png"] forState:UIControlStateNormal];
    } else {
        [playpausebutton setImage:[UIImage imageNamed:@"btn_play.png"] forState:UIControlStateNormal];
    }
}

#pragma mark - Button Action Methods

- (IBAction)playbutton {
    if (self.radiosound.rate == 1.0) {
        [self pauseCurrentTrack];
        shouldPlay = NO;
    } else {
        [self playCurrentTrack];
        shouldPlay = YES;
    }
}

- (IBAction)stopTapped:(id)sender {
    shouldPlay = NO;
    [self pauseCurrentTrack];
}

- (IBAction)didTapGoRecent:(id)sender {
    RecentSongViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"RecentSongViewController"];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];
    [navController.navigationBar custom];
    [self presentViewController:navController animated:YES completion:nil];
}

- (void)playCurrentTrack {
    if (self.radiosound.rate == 0.0) {
        [self reloadRadioStreaming];
    } else {
        [self.radiosound play];
    }
    
    // Update image states to reflect "Pause" option
    [playpausebutton setImage:[UIImage imageNamed:@"btn_pause"] forState:UIControlStateNormal];
}

- (void)pauseCurrentTrack {
    [self.radiosound pause];
    
    // Update image states to reflect "Play" option
    [playpausebutton setImage:[UIImage imageNamed:@"btn_play"] forState:UIControlStateNormal];
}

#pragma mark - Notification Stream Radio

- (void)reloadRadioStreaming {
    AVAudioSession *session = [AVAudioSession sharedInstance];
    
    NSError *setCategoryError = nil;
    
    BOOL success = [session overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:&setCategoryError];
    if (!success) {
    }
    
    NSURL *url = [NSURL URLWithString:STREAM_URL];
    self.radiosound = [[AVPlayer alloc] initWithURL:url];
    [self.radiosound play];
    [self updatebuttonstatus];
    
    // Allow the app sound to continue to play when the screen is locked.
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
}

/**
 *  NSNotification observer for AVAudioSession
 *  Stops playback on phonecall, resumes if needed
 *
 *  @param notification received notofocation
 */
- (void)interruption:(NSNotification *)notification {
    //Check the type of notification
    NSLog(@"Interruption notification name %@", notification.name);
    if ([notification.name isEqualToString:AVAudioSessionInterruptionNotification]) {
        NSLog(@"Interruption notification received %@!", notification);
        //Check to see if it was a Begin interruption
        if ([[notification.userInfo valueForKey:AVAudioSessionInterruptionTypeKey] isEqualToNumber:[NSNumber numberWithInt:AVAudioSessionInterruptionTypeBegan]]) {
            [self pauseRadio];
        } else if ([[notification.userInfo valueForKey:AVAudioSessionInterruptionTypeKey] isEqualToNumber:[NSNumber numberWithInt:AVAudioSessionInterruptionTypeEnded]]){
            // Resume playing if needed
            if (shouldPlay) {
                [self playRadio];
            }
        }
    }
}

#pragma mark - Get Feed Content

- (void)getFeedContent {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager GET:FEED_URL parameters:nil progress:nil success:^(NSURLSessionDataTask * task, id responseObject) {
        feeds = [NSMutableArray array];
        
        NSXMLParser *parser = [[NSXMLParser alloc] initWithData:responseObject];
        [parser setDelegate:self];
        [parser setShouldResolveExternalEntities:NO];
        [parser parse];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"%@", error);
    }];
}

#pragma mark - NSXMLParserDelegate Methods

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary<NSString *,NSString *> *)attributeDict {
    element = elementName;
    if ([element isEqualToString:@"item"]) {
        feeditem = [[NSMutableDictionary alloc] init];
        title = [[NSMutableString alloc] init];
        link = [[NSMutableString alloc] init];
        songguid = [[NSMutableString alloc] init];
        songdescription = [[NSMutableString alloc] init];
        pubDate = [[NSMutableString alloc] init];
        songmedia = [[NSMutableString alloc] init];
    } else if([elementName isEqualToString:@"media:thumbnail"]) {
        songmedia = [[NSMutableString alloc] init];
        NSString *string = [attributeDict objectForKey:@"url"];
        [songmedia appendString:string];
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    if ([elementName isEqualToString:@"item"]) {
        [feeditem setObject:title forKey:@"title"];
        [feeditem setObject:link forKey:@"link"];
        [feeditem setObject:songguid forKey:@"songguid"];
        [feeditem setObject:songdescription forKey:@"songdescription"];
        [feeditem setObject:songmedia forKey:@"songmedia"];
        [feeditem setObject:pubDate forKey:@"pubDate"];
        
        [feeds addObject:[feeditem copy]];
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    if ([element isEqualToString:@"title"]) {
        [title appendString:[string kv_decodeHTMLCharacterEntities]];
    } else if ([element isEqualToString:@"link"]) {
        [link appendString:[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
    } else if ([element isEqualToString:@"guid"]) {
        [songguid appendString:string];
    } else if ([element isEqualToString:@"description"]) {
        [songdescription appendString:[string kv_decodeHTMLCharacterEntities]];
    } else if ([element isEqualToString:@"media:thumbnail"]) {
        [songmedia appendString:string];
    } else if ([element isEqualToString:@"pubDate"]) {
        [pubDate appendString:string];
    }
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
    NSDictionary *currentSong = [feeds firstObject];
    lblTitle.text = currentSong[@"title"];
    lblArtist.text = [currentSong[@"songdescription"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    // Update with title immediatly
    [self updateNowPlayingInfoWithTitle:lblTitle.text artist:lblArtist.text image:nil];
    
    NSString *imageURL = [currentSong[@"songmedia"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    UIImage *placeholder = [UIImage imageNamed:@"img_logo_full"];
    
    __weak __typeof(self) weakSelf = self;
    [ivCoverImage setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:imageURL]] placeholderImage:placeholder success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull image) {
        __typeof__(self) strongSelf = weakSelf;
        if (strongSelf) {
            if (image) {
                strongSelf->ivCoverImage.image = image;
            } else {
                strongSelf->ivCoverImage.image = placeholder;
            }
            [strongSelf updateNowPlayingInfoWithTitle:strongSelf->lblTitle.text artist:strongSelf->lblArtist.text image:image];
        }
    } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSError * _Nonnull error) {
        __typeof__(self) strongSelf = weakSelf;
        if (strongSelf) {
            strongSelf->ivCoverImage.image = placeholder;
        }
    }];
}

#pragma mark - MPNowPlayingInfoCenter

/// Updates track info on lockscreen, control center and any compatible BLE device
- (void)updateNowPlayingInfoWithTitle:(NSString *)titleStr artist:(NSString *)artistStr image:(UIImage *)artwork {
    NSLog(@"udate");
    // don't pass nil, it will cause crash
    NSMutableDictionary *playInfo = [NSMutableDictionary new];
    if (titleStr) {
        [playInfo setObject:titleStr forKey:MPMediaItemPropertyTitle];
    }
    if (artistStr) {
        [playInfo setObject:artistStr forKey:MPMediaItemPropertyArtist];
    }
    if (artwork) {
        MPMediaItemArtwork *cover = [[MPMediaItemArtwork alloc] initWithImage:artwork];
        [playInfo setObject:cover forKey:MPMediaItemPropertyArtwork];
    }
    //
    [MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo = playInfo;
}

@end



