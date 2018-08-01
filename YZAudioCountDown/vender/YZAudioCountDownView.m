//
//  AudioCountDownView.m
//  AudioCountDown
//
//  Created by yite on 2018/7/30.
//  Copyright © 2018年 yite. All rights reserved.
//

#import "YZAudioCountDownView.h"
#import <AVFoundation/AVFoundation.h>
#import "UIView+ReRect.h"
#import "YZMusicSliderView.h"
#import "UIImage+Extension.h"
#define WeakSelf typeof(self) __weak weakSelf = self
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define  ScreenWidth   [[UIScreen mainScreen] bounds].size.width
#define  ScreenHeight   [[UIScreen mainScreen] bounds].size.height


#define FullViewHeight 210
#define  space 2.0
#define imageHeight 90
#define imageMargin 10
#define imageWidth  (ScreenWidth-(2*imageMargin))


#define limitedMusicTime  15.0

@interface YZAudioCountDownView()<AVAudioPlayerDelegate> {
    
    
}
@property (nonatomic, strong) dispatch_source_t timer;

@property (strong,nonatomic)UILabel *tipLabel;

@property (strong,nonatomic)UILabel *tipStartLabel;
@property (strong,nonatomic)UILabel *tipEndLabel;
@property (strong,nonatomic)UILabel *tipCurrentLabel;


@property (strong,nonatomic)UIImageView *backImageView;
@property (strong,nonatomic)MKMusicSliderView *contentView;

@property (strong,nonatomic)UIView *waveContentView;

@property (strong,nonatomic)UIImageView *waveImageView;
@property (strong,nonatomic)UIImageView *progressImageView;
@property (strong,nonatomic)UIImageView *offsetImageView;

@property (strong,nonatomic)UIImageView *usedImageView;
@property (strong,nonatomic)UIImageView *sliderIamgeView;

@property (nonatomic, strong) UIColor* waveColor;
@property (nonatomic, strong) UIColor* offsetColor;
@property (nonatomic, strong) UIColor* progressColor;

@property (nonatomic, strong) NSString * tipText;

@property (nonatomic,assign)float totalTime;


@property (nonatomic, strong) NSURL* soundURL;
@property (nonatomic,strong)UIButton * countDownButton;

@property (nonatomic,strong)AVAudioPlayer *auPlayer;


@property (nonatomic,assign) float usedWidth;
@property (nonatomic,assign) float sliderPencent;
@property (assign,nonatomic)float progress;

@end

@implementation YZAudioCountDownView

- (instancetype)initWithMusicPath:(NSString *)path startTime:(float)startTime {
    self = [super initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    if(self) {
        [self configData];
        [self setupView];
        [self addPanGesture];
        [self setStartTime:startTime];
        if(path.length>0) {
            [self initAssetWithPath:path];
            [self setupPlayer];
            [self playMusic];
        }
    }
    return self;
}

- (void)initAssetWithPath:(NSString *)path {
    self.soundURL = [NSURL fileURLWithPath:path];
    
    
}

- (void)setupPlayer {
    self.auPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:self.soundURL error:nil];
    self.auPlayer.numberOfLoops = -1;
    if (self.auPlayer) {
        [self.auPlayer prepareToPlay];
    }
    self.auPlayer.delegate = self;
    float musicDuring = (float)self.auPlayer.duration;
    self.totalTime = MIN(self.totalTime, musicDuring);
    [self updateSlideView];
    [self resetPlayTime];
}


- (void)setTotalTime:(float)totalTime {
    _totalTime = totalTime;
    
    NSString *totalTimeString = [NSString stringWithFormat:@"%.1fs",_totalTime];
    totalTimeString = [totalTimeString stringByReplacingOccurrencesOfString:@".0" withString:@""];
    self.tipEndLabel.text = totalTimeString;
    [self caculateUsedWidth];
}


- (void)playMusic{
    [self.auPlayer play];
    
    
    
    NSTimeInterval period = 0.05;
    
    dispatch_queue_t queue = dispatch_get_main_queue();
    self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(self.timer, dispatch_walltime(NULL, 0), period * NSEC_PER_SEC, 0); //每秒执行
    
    dispatch_source_set_event_handler(self.timer, ^{
        [self playProgress];
    });
    
    dispatch_resume(self.timer);
    
}



- (void)playProgress {
    self.progress = (self.auPlayer.currentTime)/_totalTime;
    [self checkMusicSlider];
}


- (void)setupView {
    self.backgroundColor = [UIColor clearColor];
    
    [self addSubview:self.backImageView];
    [self addSubview:self.contentView];
    
    self.waveColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
    self.progressColor = UIColorFromRGB(0xFF2C63);
    self.offsetColor = UIColorFromRGB(0xFF77A6);
    _waveImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 34, imageWidth, imageHeight)];
    _progressImageView = [[UIImageView alloc] initWithFrame:_waveImageView.frame];
    _offsetImageView = [[UIImageView alloc] initWithFrame:_waveImageView.frame];
    
    _waveImageView.contentMode = UIViewContentModeLeft;
    _progressImageView.contentMode = UIViewContentModeLeft;
    _offsetImageView.contentMode = UIViewContentModeLeft;
    _offsetImageView .clipsToBounds=YES;
    _waveImageView.clipsToBounds = YES;
    _progressImageView.clipsToBounds = YES;
    
    
    UIImage *renderedImage = [self drawImageFromCreaterWithMinValue:20 MaxValue:imageHeight];
    
    _waveImageView.image = renderedImage;
    _progressImageView.image = [renderedImage imageWithColor:_progressColor];
    _offsetImageView.image= [renderedImage imageWithColor:_offsetColor];
    _progressImageView.x = _waveImageView.x;
    _progressImageView.width = 0;
    _offsetImageView.width = imageWidth;
    
    [self.contentView addSubview:self.tipLabel];
    [self.contentView addSubview:self.countDownButton];
    [self.contentView addSubview:self.waveContentView];
    [self.contentView addSubview:self.sliderIamgeView];
    [self.contentView addSubview:self.tipCurrentLabel];
    
    [self.waveContentView addSubview:_waveImageView];
    [self.waveContentView addSubview:_offsetImageView];
    [self.waveContentView addSubview:_progressImageView];
    
    [self.waveContentView addSubview:self.tipStartLabel];
    [self.waveContentView addSubview:self.tipEndLabel];
    [self.waveContentView addSubview:self.usedImageView];
    
    
    self.tipCurrentLabel.center = CGPointMake(self.sliderIamgeView.center.x, self.tipCurrentLabel.center.y);
    
    
    [self configTouchEvent];
}

- (void)configTouchEvent {
    WeakSelf;
    self.contentView.touchBeginBlock = ^{
        [weakSelf hideArraw];
    };
    
    self.contentView.touchBlock = ^(CGPoint point) {
        [weakSelf moveToPint:point];
    };
    
    
    self.contentView.touchEndBlock = ^{
        [weakSelf setCurrentTimeAfterGesture];
    };
    
    
}

- (void)moveToPint:(CGPoint) point {
    CGFloat x = point.x;
    
    float centerX ;
    centerX = MAX(_usedWidth+2+imageMargin, x);
    centerX = MIN(imageWidth+imageMargin, centerX);
    
    self.sliderIamgeView.center = CGPointMake(centerX, self.sliderIamgeView.center.y);
    
    self.sliderPencent = (self.sliderIamgeView.center.x-imageMargin )/imageWidth;
    self.tipCurrentLabel.center = CGPointMake(self.sliderIamgeView.center.x, self.tipCurrentLabel.center.y);
    
    

}

- (void)hideArraw {
    self.tipText = NSLocalizedString(@"stop", nil);
}

- (void)showInView:(UIView *)view {
    [view addSubview:self];
    self.contentView.y = ScreenHeight;
    [UIView animateWithDuration:0.3 animations:^{
        self.contentView.y = ScreenHeight - self.contentView.height;
    }completion:^(BOOL finished) {
      
    }];
    
}

- (void)hide{
    if(self.timer) {
        dispatch_source_cancel(self.timer);
        self.timer = nil;
    }
    [UIView animateWithDuration:0.3 animations:^{
        self.contentView.y = ScreenHeight ;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
    
}

- (void)configData {
    self.totalTime = limitedMusicTime;
    self.sliderPencent  = 1;
    self.tipText = NSLocalizedString(@"move to stop", nil);
}

- (void)addPanGesture {
    UITapGestureRecognizer *tap  = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapBack:)];
    [self.backImageView  addGestureRecognizer:tap];
}





- (void)setCurrentTimeAfterGesture {
    if([self.auPlayer isPlaying]) {
        float time = self.sliderPencent*self.totalTime - 3;
        time = MAX(time, _startTime);
        self.auPlayer.currentTime = time;
    }
}


- (void)checkMusicSlider {
    float percent = self.sliderPencent*_totalTime;
    float current = self.auPlayer.currentTime;
    if(current+0.1>= _totalTime ) {
        [self resetPlayTime];
    }
    
    if(percent<=current) {
        [self resetPlayTime];
    }
}

- (void)tapBack:(UITapGestureRecognizer *)tap {
    if(self.dismissBlock) {
        self.dismissBlock();
    }
    [self hide];
}


- (void)setStartTime:(float)startTime {
    _startTime = startTime;
    [self caculateUsedWidth];
}

- (void)caculateUsedWidth {
    self.usedWidth = _startTime/self.totalTime*imageWidth;
}

- (void)setUsedWidth:(float)usedWidth {
    _usedWidth = usedWidth ;
    self.usedImageView.width = _usedWidth;
    [self resetPlayTime];
    
}



- (void)resetPlayTime {
    NSLog(@"reset:%f",(_usedWidth/(float)imageWidth)*self.totalTime);
    self.auPlayer.currentTime = ((_usedWidth/(float)imageWidth))*self.totalTime;
    
}


- (void)setSliderPencent:(float)sliderPencent {
    _sliderPencent = sliderPencent;
    [self updateSlideView];
}

- (void)updateSlideView {
    NSString *currentTime = [NSString stringWithFormat:@"%.1fs",_sliderPencent*_totalTime];
    currentTime = [currentTime stringByReplacingOccurrencesOfString:@".0" withString:@""];
    self.offsetImageView.x = self.waveImageView.x;
    self.offsetImageView.width = CGRectGetMinX(self.sliderIamgeView.frame)-imageMargin;
    
    self.tipCurrentLabel.text = currentTime;
    [self.tipCurrentLabel sizeToFit];
    
    self.tipEndLabel.hidden = _sliderPencent>0.85?YES:NO;
    
    self.tipStartLabel.hidden = _sliderPencent<0.15?YES:NO;
    
    
}

- (void)confirmButtonClicked:(id)sender {
    float endTime = _sliderPencent * _totalTime;
    NSLog(@"回调 开始时间%.1f, 结束时间%.1f",_startTime,endTime);
    if(self.confirmBlock) {
        self.confirmBlock(_startTime,endTime);
    }
    [self hide];
}


//音波图是随机数生成的假图，可根据自己需要生成图片
- (UIImage*) drawImageFromCreaterWithMinValue:(int)minValue
                                     MaxValue:(int)maxValue {
    CGSize imageSize = CGSizeMake(imageWidth, imageHeight);
    
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
    CGContextSetAlpha(context, 1.0);
    
    CGRect rect;
    rect.size = imageSize;
    rect.origin.x = 0;
    rect.origin.y = 0;
    
    CGColorRef waveColor = self.waveColor.CGColor;
    
    CGContextFillRect(context, rect);
    
    
    float lineWidth = 3.0;
    float lineSpace = 3.0;
    int lineCount = imageWidth/(lineSpace+lineWidth)+1;
    
    CGContextSetLineWidth(context, lineWidth);
    
    float channelCenterY = imageSize.height / 2;
    
    
    for (NSInteger i = 0; i < lineCount; i++)
    {
        int value  = [self getRandomNumber:minValue to:maxValue];
        
        CGRect lineRect = CGRectMake(i*(lineSpace +lineWidth), channelCenterY - value / 2.0, lineWidth/2, value);
        CGContextSetLineWidth(context,lineWidth/2);
        CGContextSetStrokeColorWithColor(context, waveColor);
        UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:lineRect cornerRadius:10];
        
        CGContextAddPath(context, bezierPath.CGPath);
        CGContextStrokePath(context);
    }
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}


- (int)getRandomNumber:(int)from to:(int)to {
    
    return (from + (arc4random()%(to-from+1)));
}



- (void)setProgress:(float )progress {
    
    _progressImageView.x = _waveImageView.x;
    _progressImageView.width = _waveImageView.width * progress;
}

#pragma  mark - getter

- (UILabel *)tipLabel {
    if(!_tipLabel) {
        _tipLabel = [[UILabel alloc]init];
        _tipLabel.font = [UIFont systemFontOfSize:14];
        _tipLabel.text = NSLocalizedString(@"beat", nil);
        _tipLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
        [_tipLabel sizeToFit];
        _tipLabel.y = 9;
        _tipLabel.center = CGPointMake(ScreenWidth/2, _tipLabel.center.y);
        
    }
    return _tipLabel;
    
}

- (UIButton *)countDownButton {
    if(!_countDownButton) {
        _countDownButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 150, 180, 40)];
        _countDownButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [_countDownButton setTitle:NSLocalizedString(@"count down", nil) forState:UIControlStateNormal];
        [_countDownButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _countDownButton.backgroundColor = UIColorFromRGB(0xFF2C63);
        _countDownButton.layer.cornerRadius = 20;
        _countDownButton.center  = CGPointMake(ScreenWidth/2, _countDownButton.center.y);
        [_countDownButton addTarget:self action:@selector(confirmButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _countDownButton;
}





- (UIImageView *)sliderIamgeView {
    if(!_sliderIamgeView) {
        _sliderIamgeView = [[UIImageView alloc]initWithFrame:CGRectMake(100, 27,2, 100)];
        _sliderIamgeView.backgroundColor = [UIColor yellowColor];
        _sliderIamgeView.x = imageMargin+imageWidth*_sliderPencent-self.sliderIamgeView.width;
    }
    
    return _sliderIamgeView;
    
}

- (UIImageView *)usedImageView {
    if(!_usedImageView) {
        _usedImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 34, imageWidth, imageHeight)];
        _usedImageView.backgroundColor = [UIColorFromRGB(0x01EEEE) colorWithAlphaComponent:0.6];
        _usedImageView.width=0;
    }
    return _usedImageView;
}


-  (UIImageView *)backImageView {
    if(!_backImageView) {
        _backImageView = [[UIImageView alloc]initWithFrame:self.frame];
        _backImageView.backgroundColor  = [UIColor clearColor];
        _backImageView.userInteractionEnabled = YES;
    }
    return _backImageView;
}

- (UIView *)contentView{
    if(!_contentView) {
        _contentView  = [[MKMusicSliderView alloc]initWithFrame:CGRectMake(0, ScreenHeight-FullViewHeight, ScreenWidth, FullViewHeight)];
        _contentView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
    }
    return _contentView;
}

- (UILabel *)tipStartLabel {
    if(!_tipStartLabel) {
        _tipStartLabel = [[UILabel alloc]init];
        _tipStartLabel.font = [UIFont systemFontOfSize:12];
        _tipStartLabel.text = @"0.1s";
        _tipStartLabel.textColor = [UIColor whiteColor];
        [_tipStartLabel sizeToFit];
        _tipStartLabel.y = 132;
        _tipStartLabel.x =  5;
    }
    return _tipStartLabel;
}

- (UILabel *)tipEndLabel {
    if(!_tipEndLabel) {
        _tipEndLabel = [[UILabel alloc]init];
        _tipEndLabel.font = [UIFont systemFontOfSize:12];
        _tipEndLabel.text = @"00.0s";
        _tipEndLabel.textAlignment = NSTextAlignmentRight;
        _tipEndLabel.textColor = [UIColor whiteColor];
        [_tipEndLabel sizeToFit];
        _tipEndLabel.y = 132;
        _tipEndLabel.x =  imageWidth-5-_tipEndLabel.width;
    }
    return _tipEndLabel;
}

- (UILabel *)tipCurrentLabel {
    if(!_tipCurrentLabel) {
        _tipCurrentLabel = [[UILabel alloc]init];
        _tipCurrentLabel.font = [UIFont systemFontOfSize:12];
        _tipCurrentLabel.text = @"00.000s";
        _tipCurrentLabel.textAlignment = NSTextAlignmentCenter;
        _tipCurrentLabel.textColor = [UIColor whiteColor];
        [_tipCurrentLabel sizeToFit];
        _tipCurrentLabel.y = 132;
        _tipCurrentLabel.text = @"";
        
    }
    return _tipCurrentLabel;
}

- (UIView *)waveContentView  {
    if(!_waveContentView) {
        _waveContentView = [[UIView alloc]initWithFrame:CGRectMake(imageMargin, 0, imageWidth, 150)];
    }
    
    return _waveContentView;
}


@end
