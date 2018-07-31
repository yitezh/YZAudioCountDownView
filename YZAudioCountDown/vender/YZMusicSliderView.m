//
//  MKMusicSliderView.m
//  MoKaVideo
//
//  Created by yite on 2018/7/27.
//  Copyright © 2018年 hzdykj. All rights reserved.
//

#import "YZMusicSliderView.h"

@implementation MKMusicSliderView

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch * touch = [touches anyObject];
    CGPoint currentTouchPoint = [touch locationInView: self];
    if(self.touchBeginBlock) {
        self.touchBeginBlock();
    }
    
    if(self.touchBlock) {
        self.touchBlock(currentTouchPoint);
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch * touch = [touches anyObject];
    CGPoint currentTouchPoint = [touch locationInView: self];
    if(self.touchBeginBlock) {
        self.touchBeginBlock();
    }
    
    if(self.touchBlock) {
        self.touchBlock(currentTouchPoint);
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if(self.touchEndBlock) {
        self.touchEndBlock();
    }

}

@end
