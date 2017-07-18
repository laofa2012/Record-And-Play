//
//  ViewController.m
//  RecordAndPlay
//
//  Created by Yuanhai on 17/7/17.
//  Copyright © 2017年 Yuanhai. All rights reserved.
//

#define RecordFilePath [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"lvRecord.caf"]
#define RecordMP3FilePath [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"lvRecord.mp3"]

#import "ViewController.h"
#import "LFVoiceRecorder.h"
#import "LFVoicePlayer.h"
#import "LFVoiceUtils.h"

@interface ViewController () <LFVoiceRecorderDelegate, LFVoicePlayerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *recordButton;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UIImageView *volumeImageView;

@end

@implementation ViewController

- (void)dealloc
{
    if ([[LFVoiceRecorder instance].recorder isRecording]) [self stopPlay];
    if ([[LFVoicePlayer instance].player isPlaying]) [self stopRecord];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.recordButton setTitle:@"按住 说话" forState:UIControlStateNormal];
    [self.recordButton setTitle:@"松开 结束" forState:UIControlStateHighlighted];
    
    [LFVoiceRecorder instance].delegate = self;
    [LFVoicePlayer instance].delegate = self;
    
    // 录音按钮
    [self.recordButton addTarget:self action:@selector(recordBtnDidTouchDown:) forControlEvents:UIControlEventTouchDown];
    [self.recordButton addTarget:self action:@selector(recordBtnDidTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [self.recordButton addTarget:self action:@selector(recordBtnDidTouchDragExit:) forControlEvents:UIControlEventTouchDragExit];
}

#pragma mark - 录音、播放、界面更新

- (void)startRecord
{
    [[LFVoiceRecorder instance] startRecording:RecordFilePath];
}

- (void)stopRecord
{
    [[LFVoiceRecorder instance] stopRecording];
}

- (void)startPlay
{
    [[LFVoicePlayer instance] playAudio:RecordMP3FilePath];
    [self.playButton setTitle:@"停止" forState:UIControlStateNormal];
}

- (void)stopPlay
{
    [[LFVoicePlayer instance] stopPlaying];
    [self.playButton setTitle:@"播放" forState:UIControlStateNormal];
}

#pragma mark - 按钮点击

- (void)recordBtnDidTouchDown:(UIButton *)recordBtn
{
    [self stopPlay];
    [self startRecord];
}

// 点击
- (void)recordBtnDidTouchUpInside:(UIButton *)recordBtn
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self stopRecord];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.volumeImageView.image = [UIImage imageNamed:@"mic_0"];
        });
    });
    
    // 内容太少
    double currentTime = [LFVoiceRecorder instance].recorder.currentTime;
    NSData *audioData = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:RecordFilePath]];
    if (currentTime < 2 || audioData.length < 200)
    {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [LFVoiceUtils deleteFile:RecordFilePath];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self alertWithMessage:@"说话时间太短"];
            });
        });
        return;
    }
    
    // 转换成MP3格式
    [LFVoiceUtils cafToMp3:RecordFilePath toMp3Path:RecordMP3FilePath];
    NSData *mp3AudioData = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:RecordMP3FilePath]];
    
    self.messageLabel.text = [NSString stringWithFormat:@"录音时间:%.lf秒\nCaf文件大小:%.1fK\nMp3文件大小:%.1fK\n文件总时间:%d秒", currentTime, audioData.length / 1024.0f, mp3AudioData.length / 1024.0f, (int)[LFVoiceUtils durationWithVideo:[NSURL fileURLWithPath:RecordMP3FilePath]]];
}

// 手指从按钮上移除
- (void)recordBtnDidTouchDragExit:(UIButton *)recordBtn
{
    self.volumeImageView.image = [UIImage imageNamed:@"mic_0"];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self stopRecord];
        [LFVoiceUtils deleteFile:RecordFilePath];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self alertWithMessage:@"已取消录音"];
        });
    });
    
}

- (IBAction)playButtonPress
{
    if ([[self.playButton titleForState:UIControlStateNormal] isEqualToString:@"播放"])
    {
        [self stopRecord];
        [self startPlay];
    }
    else
    {
        [self stopPlay];
    }
}

#pragma mark - Alert

- (void)alertWithMessage:(NSString *)message
{
    UIAlertController *confirmAlert = [UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];
    [confirmAlert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:confirmAlert animated:YES completion:nil];
}

#pragma mark - LFVoiceRecorderDelegate

- (void)recordManager:(LFVoiceRecorder *)manager volume:(int)volume
{
    NSString *imageName = [NSString stringWithFormat:@"mic_%d", volume];
    self.volumeImageView.image = [UIImage imageNamed:imageName];
}

#pragma mark - LFVoicePlayerDelegate

- (void)playFinished:(LFVoiceRecorder *)manager
{
    [self.playButton setTitle:@"播放" forState:UIControlStateNormal];
}

@end
