//
//  LFVoicePlayer.m
//  RecordAndPlay
//
//  Created by Yuanhai on 18/7/17.
//  Copyright © 2017年 Yuanhai. All rights reserved.
//

#import "LFVoicePlayer.h"

@interface LFVoicePlayer () <AVAudioPlayerDelegate>
@end

@implementation LFVoicePlayer

+ (LFVoicePlayer *)instance
{
    static LFVoicePlayer *instance;
    @synchronized(self)
    {
        if(!instance)
        {
            instance = [[LFVoicePlayer alloc] init];
        }
    }
    return instance;
}

/** 播放录音 */
- (void)playAudio:(NSString *)filePath
{
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
