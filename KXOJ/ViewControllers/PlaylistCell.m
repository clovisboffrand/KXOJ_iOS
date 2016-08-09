//
//  PlaylistCell.m
//  WJRS
//
//  Created by admin_user on 6/3/16.
//  Copyright © 2016 RadioServersLLC. All rights reserved.
//

#import "PlaylistCell.h"
#import "Header.h"
#import <AFNetworking/UIImageView+AFNetworking.h>

@implementation PlaylistCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)configureWithSong:(NSDictionary *)song {
    _lblTitle.text = [song[@"title"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    _lblDetail.text = [song[@"songdescription"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    UIImage *image = [UIImage imageNamed:[AppSettings shared].logo];
    NSString *imageURL = [song[@"songmedia"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [_ivCoverImage setImageWithURL:[NSURL URLWithString:imageURL] placeholderImage:image];
}

@end
