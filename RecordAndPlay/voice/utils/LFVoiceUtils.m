//
//  LFVoiceUtils.m
//  RecordAndPlay
//
//  Created by Yuanhai on 18/7/17.
//  Copyright © 2017年 Yuanhai. All rights reserved.
//

#import "LFVoiceUtils.h"
#import <AVFoundation/AVFoundation.h>
#import "lame.h"

@implementation LFVoiceUtils

/** 获取播放总时间 */
+ (NSUInteger)durationWithVideo:(NSURL *)videoUrl
{
    NSDictionary *opts = [NSDictionary dictionaryWithObject:@(NO) forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
    AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:videoUrl options:opts];
    NSUInteger second = 0;
    second = urlAsset.duration.value / urlAsset.duration.timescale;
    return second;
}

/**
 *  caf转mp3
 *  @param cafPath caf文件地址
 *  @param mp3Path mp3文件存放地址
 */
+ (BOOL)cafToMp3:(NSString *)cafPath toMp3Path:(NSString *)mp3Path
{
    @try {
        int write,read;
        const int PCM_SIZE = 8192;
        const int MP3_SIZE = 8192;
        short int pcm_buffer[PCM_SIZE*2];
        unsigned char mp3_buffer[MP3_SIZE];
        
        //source 被转换的音频文件位置
        FILE *pcm = fopen([cafPath cStringUsingEncoding:1], "rb");
        //output 输出生成的Mp3文件位置
        FILE *mp3 = fopen([mp3Path cStringUsingEncoding:1], "wb");
        
        lame_t lame = lame_init ();
        lame_set_num_channels (lame, 1 ); // 设置 1 为单通道，默认为 2 双通道
        lame_set_in_samplerate (lame, 8000.0 ); //11025.0
        //lame_set_VBR(lame, vbr_default);
        lame_set_brate (lame, 8 );
        lame_set_mode (lame, 3 );
        lame_set_quality (lame, 2 ); /* 2=high 5 = medium 7=low 音 质 */
        lame_init_params (lame);
        do {
            
            read = fread (pcm_buffer, 2 * sizeof ( short int ), PCM_SIZE, pcm);
            if (read == 0 )
                write = lame_encode_flush (lame, mp3_buffer, MP3_SIZE);
            else
                write = lame_encode_buffer_interleaved (lame, pcm_buffer, read, mp3_buffer, MP3_SIZE);
            fwrite (mp3_buffer, write, 1 , mp3);
        } while (read != 0 );
        lame_close (lame);
        fclose (mp3);
        fclose (pcm);
    }
    @catch (NSException *exception) {
        NSLog(@"%@",[exception description]);
        return NO;
    }
    @finally
    {
        NSLog(@"MP3生成成功: %@",mp3Path);
        return YES;
        
    }
}

/** 删除文件 */
+ (void)deleteFile:(NSString *)filePath
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (filePath.length > 0) [fileManager removeItemAtURL:[NSURL fileURLWithPath:filePath] error:NULL];
}

@end
