//
//  PlaylistCell.h
//  WJRS
//
//  Created by admin_user on 6/3/16.
//  Copyright © 2016 RadioServersLLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlaylistCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *lblTitle;
@property (nonatomic, strong) IBOutlet UILabel *lblDetail;
@property (nonatomic, strong) IBOutlet UIImageView *ivCoverImage;

- (void)configureWithSong:(NSDictionary *)song;

@end
