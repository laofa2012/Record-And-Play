//
//  LFVoiceManager.h
//  RecordAndPlay
//
//  Created by Yuanhai on 17/7/17.
//  Copyright © 2017年 Yuanhai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
@protocol LFVoiceManagerDelegate;

@interface LFVoiceManager : NSObject

@property (nonatomic, strong) AVAudioRecorder *recorder;
@property (nonatomic, strong) AVAudioPlayer *player;
@property (nonatomic,   weak) id<LFVoiceManagerDelegate> delegate;

+ (LFVoiceManager *)instance;

/** 开始录音 */
- (void)startRecording:(NSString *)filePath;

/** 停止录音 */
- (void)stopRecording;

/** 播放录音 */
- (void)playAudio:(NSString *)filePath;

/** 停止播放录音 */
- (void)stopPlaying;

/** 删除文件 */
- (void)deleteFile:(NSString *)filePath;

@end


@protocol LFVoiceManagerDelegate <NSObject>

@optional
- (void)recordManager:(LFVoiceManager *)manager volume:(int)volume;
- (void)playFinished:(LFVoiceManager *)manager;

@end
