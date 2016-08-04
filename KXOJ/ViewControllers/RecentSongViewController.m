//
//  RecentSongViewController.m
//  WJRS
//
//  Created by admin_user on 6/3/16.
//  Copyright © 2016 RadioServersLLC. All rights reserved.
//

#import "RecentSongViewController.h"
#import "Header.h"
#import "NSString+HTML.h"
#import "PlaylistCell.h"

@interface RecentSongViewController () <UIWebViewDelegate, NSXMLParserDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tblRecent;
@property (strong, nonatomic) IBOutlet UIWebView *adWebView;

@property (strong, nonatomic) NSMutableArray *arraysong;
@property (strong, nonatomic) NSTimer *timer;

@end

@implementation RecentSongViewController
{
    NSXMLParser *parser;
    NSMutableArray *feeds;
    NSMutableDictionary *feeditem;
    NSMutableString *title;
    NSMutableString *link;
    NSMutableString *songguid;
    NSMutableString *songdescription;
    NSMutableString *songmedia;
    NSMutableString *pubDate;
    
    NSString *element;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.arraysong = [NSMutableArray array];
    
    self.tblRecent.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    
    [self getSongList];
    [self setupTimer];
    
    [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelView)]];
    self.navigationItem.leftBarButtonItem.tintColor=[UIColor whiteColor];
    self.navigationItem.title = @"Recent Playlist";
    
    [self addBanner];
}

- (void)addBanner {
    [_adWebView loadHTMLString:[CommonHelpers HTMLBodyOfBannerView] baseURL:nil];
}

- (BOOL)webView:(UIWebView *)inWeb shouldStartLoadWithRequest:(NSURLRequest *)inRequest navigationType:(UIWebViewNavigationType)inType {
    if (inType == UIWebViewNavigationTypeLinkClicked) {
        [[UIApplication sharedApplication] openURL:[inRequest URL]];
        return NO;
    }
    
    return YES;
}

- (void)cancelView {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)setupTimer {
    self.timer = [NSTimer scheduledTimerWithTimeInterval:45 target:self selector:@selector(getSongList) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];
}

- (void)getSongList {
    feeds = [[NSMutableArray alloc] init];
    parser = [[NSXMLParser alloc] initWithContentsOfURL:[NSURL URLWithString:FEED_URL]];
    [parser setDelegate:self];
    [parser setShouldResolveExternalEntities:NO];
    [parser parse];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
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
    NSLog(@"feed data: %@", feeds);
    [self.tblRecent reloadData];
}

#pragma mark - Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return feeds.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PlaylistCell *cell = (PlaylistCell *)[tableView dequeueReusableCellWithIdentifier:@"PlaylistCell" forIndexPath:indexPath];
    NSDictionary *song = feeds[indexPath.row];
    [cell configureWithSong:song];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

@end



