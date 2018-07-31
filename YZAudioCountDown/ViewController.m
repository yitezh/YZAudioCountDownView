//
//  ViewController.m
//  YZAudioCountDown
//
//  Created by yite on 2018/7/31.
//  Copyright © 2018年 yite. All rights reserved.
//

#import "ViewController.h"
#import "YZAudioCountDownView.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)musicButtonClicked:(id)sender {
    NSString* filename = @"I Need A Dollar.mp3";
    
    NSString *musicPath = [[NSBundle mainBundle] pathForResource:filename ofType:nil];
    
    float startTIme = 3;
    YZAudioCountDownView *musicView = [[YZAudioCountDownView alloc]initWithMusicPath:musicPath startTime:startTIme];
    musicView.dismissBlock = ^{
        NSLog(@"dismiss");
    };
    musicView.confirmBlock = ^(float startTime, float endTime) {
        NSLog(@"confirm startTime%.1f  endTime %.1f",startTime,endTime);
    };
    
    [musicView showInView:self.view];
    
}


- (IBAction)noMusicButtonClicked:(id)sender {
    
    
    YZAudioCountDownView *musicView = [[YZAudioCountDownView alloc]initWithMusicPath:@"" startTime:0];
    musicView.dismissBlock = ^{
        NSLog(@"dismiss");
    };
    musicView.confirmBlock = ^(float startTime, float endTime) {
        NSLog(@"confirm startTime%.1f  endTime %.1f",startTime,endTime);
    };
    
    [musicView showInView:self.view];
    
    
}


@end
