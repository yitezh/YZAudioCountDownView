//
//  MKMusicSliderView.h
//  MoKaVideo
//
//  Created by yite on 2018/7/27.
//  Copyright © 2018年 hzdykj. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void (^TouchBlock) (CGPoint point);
@interface MKMusicSliderView : UIView

@property(strong,nonatomic)TouchBlock touchBlock;

@property (strong,nonatomic)dispatch_block_t touchBeginBlock;
@property (strong,nonatomic)dispatch_block_t touchEndBlock;


@end
