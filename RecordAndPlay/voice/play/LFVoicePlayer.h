//
//  LFVoicePlayer.h
//  RecordAndPlay
//
//  Created by Yuanhai on 18/7/17.
//  Copyright © 2017年 Yuanhai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
@protocol LFVoicePlayerDelegate;

@interface LFVoicePlayer : NSObject

@property (nonatomic, strong) AVAudioPlayer *player;
@property (nonatomic,   weak) id<LFVoicePlayerDelegate> delegate;

+ (LFVoicePlayer *)instance;

/** 播放录音 */
- (void)playAudio:(NSString *)filePath;

/** 停止播放录音 */
- (void)stopPlaying;

@end


@protocol LFVoicePlayerDelegate <NSObject>

@optional
- (void)playFinished:(LFVoicePlayer *)manager;

@end
