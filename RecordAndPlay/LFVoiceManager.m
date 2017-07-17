//
//  LFVoiceManager.m
//  RecordAndPlay
//
//  Created by Yuanhai on 17/7/17.
//  Copyright © 2017年 Yuanhai. All rights reserved.
//

#import "LFVoiceManager.h"

@interface LFVoiceManager () <AVAudioPlayerDelegate>

@property (nonatomic, strong) NSDictionary *recordSettings;
@property (nonatomic, strong) NSTimer *customTimer;

@end

@implementation LFVoiceManager

+ (LFVoiceManager *)instance
{
    static LFVoiceManager *instance;
    @synchronized(self)
    {
        if(!instance)
        {
            instance = [[LFVoiceManager alloc] init];
        }
    }
    return instance;
}

/** 开始录音 */
- (void)startRecording:(NSString *)filePath
{
    [self stopPlaying];
    [self deleteFile:filePath];
    
    if (![self.recorder.url isEqual:[NSURL fileURLWithPath:filePath]])
    {
        _recorder = [[AVAudioRecorder alloc] initWithURL:[NSURL fileURLWithPath:filePath] settings:self.recordSettings error:nil];
        _recorder.meteringEnabled = YES;
        [_recorder prepareToRecord];
    }
    
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [session setActive:YES error:nil];
    [self.recorder record];
    
    // Volume
    if ([self.customTimer isValid]) [self.customTimer invalidate];
    self.customTimer = nil;
    self.customTimer = [NSTimer scheduledTimerWithTimeInterval:0.3f target:self selector:@selector(updateImage) userInfo:nil repeats:YES];
}

/** 停止录音 */
- (void)stopRecording
{
    if ([self.recorder isRecording]) [self.recorder stop];
    if ([self.customTimer isValid]) [self.customTimer invalidate];
    self.customTimer = nil;
}

/** 播放录音 */
- (void)playAudio:(NSString *)filePath
{
    [self stopRecording];
    if ([self.player isPlaying]) return;
    
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:filePath] error:nil];
    self.player.delegate = self;
    
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [session overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:nil];
    [session setActive:YES error:nil];
    [self.player play];
}

/** 停止播放录音 */
- (void)stopPlaying
{
    [self.player stop];
}

/** 删除文件 */
- (void)deleteFile:(NSString *)filePath
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (filePath.length > 0) [fileManager removeItemAtURL:[NSURL fileURLWithPath:filePath] error:NULL];
}

#pragma mark - GET

- (NSDictionary *)recordSettings
{
    if (!_recordSettings)
    {
        self.recordSettings =
        [[NSDictionary alloc] initWithObjectsAndKeys:
         [NSNumber numberWithInt:AVAudioQualityMin], AVEncoderAudioQualityKey,
         [NSNumber numberWithInt:kAudioFormatAppleIMA4], AVFormatIDKey,
         [NSNumber numberWithFloat:8000.0], AVSampleRateKey,
         [NSNumber numberWithInt:16],  AVLinearPCMBitDepthKey,
         [NSNumber numberWithInt:1],   AVNumberOfChannelsKey,
         [NSNumber numberWithBool:NO], AVLinearPCMIsBigEndianKey,
         [NSNumber numberWithBool:NO], AVLinearPCMIsFloatKey, nil];
    }
    return _recordSettings;
}

#pragma mark - Timer

- (void)updateImage
{
    [self.recorder updateMeters];
    double lowPassResults = pow(10, (0.05 * [self.recorder peakPowerForChannel:0]));
    float result  = 10 * (float)lowPassResults;
    NSLog(@"result:%f", result);
    int no = 0;
    if (result <= 1.25f) no = 0;
    else if (result <= 2.5f) no = 1;
    else if (result <= 3.75f) no = 2;
    else if (result <= 5.0f) no = 3;
    else if (result <= 6.25) no = 4;
    else if (result <= 7.5f) no = 5;
    else if (result <= 8.75f) no = 6;
    else no = 7;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(recordManager:volume:)])
    {
        [self.delegate recordManager:self volume:no];
    }
}

#pragma mark - AVAudioRecorderDelegate & AVAudioPlayerDelegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(playFinished:)])
    {
        [self.delegate playFinished:self];
    }
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError * __nullable)error
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(playFinished:)])
    {
        [self.delegate playFinished:self];
    }
}

@end
