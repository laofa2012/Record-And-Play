//
//  LFVoiceRecorder.m
//  RecordAndPlay
//
//  Created by Yuanhai on 18/7/17.
//  Copyright © 2017年 Yuanhai. All rights reserved.
//

#import "LFVoiceRecorder.h"
#import "LFVoiceUtils.h"

@interface LFVoiceRecorder ()

@property (nonatomic, strong) NSDictionary *recordSettings;
@property (nonatomic, strong) NSTimer *customTimer;

@end

@implementation LFVoiceRecorder

+ (LFVoiceRecorder *)instance
{
    static LFVoiceRecorder *instance;
    @synchronized(self)
    {
        if(!instance)
        {
            instance = [[LFVoiceRecorder alloc] init];
        }
    }
    return instance;
}

/** 开始录音 */
- (void)startRecording:(NSString *)filePath
{
    [LFVoiceUtils deleteFile:filePath];
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

#pragma mark - Timer

- (void)updateImage
{
    [self.recorder updateMeters];
    double lowPassResults = pow(10, (0.05 * [self.recorder peakPowerForChannel:0]));
    float result  = 10 * (float)lowPassResults;
    // NSLog(@"result:%f", result);
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

#pragma mark - GET

- (NSDictionary *)recordSettings
{
    if (!_recordSettings)
    {
        self.recordSettings =
        [[NSDictionary alloc] initWithObjectsAndKeys:
         [NSNumber numberWithInt:AVAudioQualityMin], AVEncoderAudioQualityKey,
         [NSNumber numberWithInt:kAudioFormatLinearPCM],AVFormatIDKey,
         [NSNumber numberWithInt:8000.0],AVSampleRateKey,
         [NSNumber numberWithInt:2],AVNumberOfChannelsKey,
         [NSNumber numberWithInt:16],AVLinearPCMBitDepthKey,
         nil];
        
        /*
         最小CAF
         [[NSDictionary alloc] initWithObjectsAndKeys:
         [NSNumber numberWithInt:AVAudioQualityMin], AVEncoderAudioQualityKey,
         [NSNumber numberWithInt:kAudioFormatAppleIMA4], AVFormatIDKey,
         [NSNumber numberWithFloat:8000.0], AVSampleRateKey,
         [NSNumber numberWithInt:16],  AVLinearPCMBitDepthKey,
         [NSNumber numberWithInt:1],   AVNumberOfChannelsKey,
         [NSNumber numberWithBool:NO], AVLinearPCMIsBigEndianKey,
         [NSNumber numberWithBool:NO], AVLinearPCMIsFloatKey, nil];
         */
    }
    return _recordSettings;
}

@end
