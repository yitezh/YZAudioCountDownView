//
//  AudioCountDownView.h
//  AudioCountDown
//
//  Created by yite on 2018/7/30.
//  Copyright © 2018年 yite. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^ConfirmBlock) (float startTime,float endTime);

@interface YZAudioCountDownView : UIView


- (instancetype)initWithMusicPath:(NSString *)path startTime:(float )startTime ;

- (void)showInView:(UIView *)view;
- (void)hide;

@property (strong,nonatomic)NSString  *musicPath;
@property (assign,nonatomic)float startTime;
@property (assign,nonatomic)float endTime;


@property (strong,nonatomic)dispatch_block_t dismissBlock;
@property (strong,nonatomic)ConfirmBlock confirmBlock;
@end
