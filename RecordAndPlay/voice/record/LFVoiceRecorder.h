//
//  LFVoiceRecorder.h
//  RecordAndPlay
//
//  Created by Yuanhai on 18/7/17.
//  Copyright © 2017年 Yuanhai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
@protocol LFVoiceRecorderDelegate;

@interface LFVoiceRecorder : NSObject

@property (nonatomic, strong) AVAudioRecorder *recorder;
@property (nonatomic,   weak) id<LFVoiceRecorderDelegate> delegate;

+ (LFVoiceRecorder *)instance;

/** 开始录音 */
- (void)startRecording:(NSString *)filePath;

/** 停止录音 */
- (void)stopRecording;

@end


@protocol LFVoiceRecorderDelegate <NSObject>

@optional
- (void)recordManager:(LFVoiceRecorder *)manager volume:(int)volume;

@end
