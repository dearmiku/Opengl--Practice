//
//  ViewController.m
//  箱子世界的探险
//
//  Created by MBP on 2017/12/1.
//  Copyright © 2017年 leqi. All rights reserved.
//

#import "ViewController.h"
#import "BoxWordView.h"

@interface ViewController ()

@property(nonatomic,weak)BoxWordView* bov;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    BoxWordView* v = [BoxWordView new];
    _bov = v;
    v.frame = self.view.bounds;
    [self.view insertSubview:v atIndex:0];
}

- (IBAction)touchDownAdvaceBu:(UIButton *)sender {
    _bov.isAdvance = !_bov.isAdvance;
}

- (IBAction)touchUpDown:(id)sender {
    _bov.isUp = !_bov.isUp;
}

- (IBAction)touchDown:(id)sender {
    _bov.isDown = !_bov.isDown;
}

- (IBAction)touchRight:(id)sender {
    _bov.isRight = !_bov.isRight;
}

- (IBAction)touchBack:(id)sender {
    _bov.isback = !_bov.isback;
}

- (IBAction)touchLeft:(id)sender {
    _bov.isLeft = !_bov.isLeft;
}




@end
