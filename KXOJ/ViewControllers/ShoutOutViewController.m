//
//  ShoutOutViewController.m
//  WJRS
//
//  Created by admin_user on 3/7/16.
//
//

#import "ShoutOutViewController.h"
#import "Header.h"
#import <QuartzCore/QuartzCore.h>
#import <AVFoundation/AVFoundation.h>

#define SAMPLE_LINK @"https://s3.amazonaws.com/radioservers/apps/KXOJ/sample.mp3"
#define UPLOAD_LINK @"http://kxojlisteners.com/app/upload.php"


@interface ShoutOutViewController() <AVAudioPlayerDelegate, AVAudioRecorderDelegate>

@property(nonatomic, strong) NSMutableArray *arrSlide;

@property(nonatomic, strong) IBOutlet UIButton *btnRecord;
@property(nonatomic, strong) IBOutlet UIButton *btnPreview;
@property(nonatomic, strong) IBOutlet UIButton *btnSample;
@property(nonatomic, strong) IBOutlet UIButton *btnSend;

@end

@implementation ShoutOutViewController
{
    AVAudioRecorder *audioRecorder;
    BOOL isRecording;
    AVAudioPlayer *theAudio;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    INIT_INDICATOR;
    isRecording = NO;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"playRadio" object:nil];
}

#pragma mark - Button Action Methods

- (IBAction)doRecord:(id)sender {
    if (isRecording) {
        [self stopRecording];
    } else {
        [self startRecording];
    }
}

- (IBAction)doPreview:(id)sender {
    if (isRecording)
        [self stopRecording];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *recDir = [paths objectAtIndex:0];
    NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@.m4a", recDir,@"Record"]];
    NSError *error;
    theAudio = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    
    [theAudio setDelegate:self];
    [theAudio setNumberOfLoops:0];
    [theAudio play];
}

- (IBAction)doSend:(id)sender {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *recDir = [paths objectAtIndex:0];
    NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@.m4a", recDir, @"Record"]];
    NSData *data = [NSData dataWithContentsOfURL:url];
    
    if (!data) {
        return;
    }
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    SHOW_INDICATOR(self.navigationController.view);
    [manager POST:UPLOAD_LINK parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:data name:@"file" fileName:@"file.wav" mimeType:@"audio/wav"];
    } progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSLog(@"upload success: %@", responseObject);
        
        HIDE_INDICATOR(YES);
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"THANK YOU!" message:@"Thanks for sharing! Listen to KXOJ and you might hear yourself on the radio!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"Error: %@", error);
        
        HIDE_INDICATOR(YES);
    }];
}

- (IBAction)doSample:(id)sender {
    if (theAudio.isPlaying)
        return;
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"pauseRadio" object:nil];
    if (isRecording) {
        [self stopRecording];
    }
    
    NSURL *url = [NSURL URLWithString:SAMPLE_LINK];
    NSData *soundData = [NSData dataWithContentsOfURL:url];
    NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"sound.caf"];
    [soundData writeToFile:filePath atomically:YES];
    
    NSError *error;
    theAudio = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:filePath] error:&error];
    if (error) {
        NSLog(@"error %@", error.localizedDescription);
    }
    
    [theAudio setDelegate:self];
    [theAudio setNumberOfLoops:0];
    [theAudio play];
}

#pragma mark - Recording Methods

- (void)startRecording {
    [[NSNotificationCenter defaultCenter]postNotificationName:@"pauseRadio" object:nil];
    [self initRecord];
    
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setActive:YES error:nil];
    
    // Start recording
    [audioRecorder record];
    isRecording = YES;
    self.btnRecord.selected = YES;
    [self.btnRecord setTitle:@"Stop Recording" forState:UIControlStateNormal];
    [self.btnRecord setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.btnPreview.enabled = NO;
    self.btnSample.enabled = NO;
    self.btnSend.enabled = NO;
}

- (void)initRecord {
    audioRecorder = nil;
    
    // Init audio with record capability
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryRecord error:nil];
    
    NSMutableDictionary *recordSettings = [[NSMutableDictionary alloc] initWithCapacity:0];
    [recordSettings setObject:[NSNumber numberWithInt: kAudioFormatMPEG4AAC] forKey: AVFormatIDKey];
    [recordSettings setObject:[NSNumber numberWithFloat:16000.0] forKey: AVSampleRateKey];
    [recordSettings setObject:[NSNumber numberWithInt:1] forKey:AVNumberOfChannelsKey];
    [recordSettings setObject:[NSNumber numberWithInt: AVAudioQualityMedium] forKey: AVEncoderAudioQualityKey];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *recDir = [paths objectAtIndex:0];
    NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@.m4a", recDir, @"Record"]];
    
    NSLog(@"URL: %@",[url path]);
    NSError *error = nil;
    audioRecorder = [[ AVAudioRecorder alloc] initWithURL:url settings:recordSettings error:&error];
    audioRecorder.delegate = self;
    audioRecorder.meteringEnabled = YES;
    [audioRecorder prepareToRecord];
}

- (void)stopRecording {
    self.btnRecord.selected = NO;
    [self.btnRecord setTitle:@"Record Your Voice" forState:UIControlStateNormal];
    [self.btnRecord setTitleColor:UIColorWithHexCode(TINT_DEF_COLR, 1) forState:UIControlStateNormal];
    
    isRecording = NO;
    [audioRecorder stop];
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryAmbient error:nil];
    [audioSession setActive:NO error:nil];
}

#pragma mark - AVAudioRecorderDelegate Methods

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag {
    NSLog(@"audioRecorderDidFinishRecording");
    
    self.btnPreview.enabled = YES;
    self.btnSample.enabled = YES;
    self.btnSend.enabled = YES;
}

- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error {
    NSLog(@"audioRecorderEncodeErrorDidOccur");
}

#pragma mark - AVAudioPlayerDelegate Methods

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error {
    NSLog(@"ERROR %@", error.localizedDescription);
}

@end
