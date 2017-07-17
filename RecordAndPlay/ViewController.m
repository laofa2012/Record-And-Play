//
//  ViewController.m
//  RecordAndPlay
//
//  Created by Yuanhai on 17/7/17.
//  Copyright © 2017年 Yuanhai. All rights reserved.
//

#define RecordFilePath [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"lvRecord.caf"]

#import "ViewController.h"
#import "LFVoiceManager.h"

@interface ViewController () <LFVoiceManagerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *recordButton;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UIImageView *volumeImageView;

@end

@implementation ViewController

- (void)dealloc
{
    if ([[LFVoiceManager instance].recorder isRecording]) [[LFVoiceManager instance] stopPlaying];
    if ([[LFVoiceManager instance].player isPlaying]) [[LFVoiceManager instance] stopRecording];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.recordButton setTitle:@"按住 说话" forState:UIControlStateNormal];
    [self.recordButton setTitle:@"松开 结束" forState:UIControlStateHighlighted];
    
    [LFVoiceManager instance].delegate = self;
    
    // 录音按钮
    [self.recordButton addTarget:self action:@selector(recordBtnDidTouchDown:) forControlEvents:UIControlEventTouchDown];
    [self.recordButton addTarget:self action:@selector(recordBtnDidTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [self.recordButton addTarget:self action:@selector(recordBtnDidTouchDragExit:) forControlEvents:UIControlEventTouchDragExit];
}

#pragma mark - 按钮点击

- (void)recordBtnDidTouchDown:(UIButton *)recordBtn
{
    [[LFVoiceManager instance] startRecording:RecordFilePath];
}

// 点击
- (void)recordBtnDidTouchUpInside:(UIButton *)recordBtn
{
    double currentTime = [LFVoiceManager instance].recorder.currentTime;
    NSData *audioData = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:RecordFilePath]];
    
    if (currentTime < 2 || audioData.length < 200)
    {
        self.volumeImageView.image = [UIImage imageNamed:@"mic_0"];
        [self alertWithMessage:@"说话时间太短"];
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [[LFVoiceManager instance] stopRecording];
            [[LFVoiceManager instance] deleteFile:RecordFilePath];
        });
        return;
    }
    
    self.messageLabel.text = [NSString stringWithFormat:@"录音时间:%.lf秒\n文件大小:%.1fK", currentTime, audioData.length / 1024.0f];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [[LFVoiceManager instance] stopRecording];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.volumeImageView.image = [UIImage imageNamed:@"mic_0"];
        });
    });
    
    // 已成功录音
    NSLog(@"已成功录音");
}

// 手指从按钮上移除
- (void)recordBtnDidTouchDragExit:(UIButton *)recordBtn
{
    self.volumeImageView.image = [UIImage imageNamed:@"mic_0"];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [[LFVoiceManager instance] stopRecording];
        [[LFVoiceManager instance] deleteFile:RecordFilePath];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self alertWithMessage:@"已取消录音"];
        });
    });
    
}

- (IBAction)playButtonPress
{
    if ([[self.playButton titleForState:UIControlStateNormal] isEqualToString:@"播放"])
    {
        [[LFVoiceManager instance] playAudio:RecordFilePath];
        [self.playButton setTitle:@"停止" forState:UIControlStateNormal];
    }
    else
    {
        [[LFVoiceManager instance] stopPlaying];
        [self.playButton setTitle:@"播放" forState:UIControlStateNormal];
    }
}

#pragma mark - Alert

- (void)alertWithMessage:(NSString *)message
{
    UIAlertController *confirmAlert = [UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];
    [confirmAlert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:confirmAlert animated:YES completion:nil];
}

#pragma mark - LFVoiceManagerDelegate

- (void)recordManager:(LFVoiceManager *)manager volume:(int)volume
{
    NSString *imageName = [NSString stringWithFormat:@"mic_%d", volume];
    self.volumeImageView.image = [UIImage imageNamed:imageName];
}

- (void)playFinished:(LFVoiceManager *)manager
{
    [self.playButton setTitle:@"播放" forState:UIControlStateNormal];
}

@end
