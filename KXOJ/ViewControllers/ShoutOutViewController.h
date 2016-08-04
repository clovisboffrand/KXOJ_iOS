//
//  ShoutOutViewController.h
//  WJRS
//
//  Created by admin_user on 3/7/16.
//
//

#import <QuartzCore/QuartzCore.h>
#import <AVFoundation/AVFoundation.h>

@interface ShoutOutViewController : UIViewController<AVAudioPlayerDelegate, AVAudioRecorderDelegate>
{
    AVAudioRecorder *audioRecorder;
    BOOL isRecording;
    AVAudioPlayer *theAudio;
}

@property(nonatomic, strong) NSMutableArray *arrSlide;
@property(nonatomic, strong) IBOutlet UIButton *btRecord;
@property(nonatomic, strong) IBOutlet UIButton *btnPreview;
@property(nonatomic, strong) IBOutlet UIButton *btnSample;
@property(nonatomic, strong) IBOutlet UIButton *btnSend;

@end
