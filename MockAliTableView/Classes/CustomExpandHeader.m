//
//  CustomExpandHeader.m
//  MockAliTableView
//
//  Created by coder QXGuo on 2020/6/19.
//  Copyright © 2020 coder QXGuo. All rights reserved.
//

#import "CustomExpandHeader.h"
#import <Masonry/Masonry.h>

@interface CustomExpandHeader ()

@property(nonatomic, strong) UIView *expandView;

/** 点击的View */
@property(nonatomic, strong) UIView *clickView;

/** 图片icon */
@property(nonatomic, strong) UIImageView *icon;

@end

@implementation CustomExpandHeader

+ (instancetype)finaceHeader {
    CustomExpandHeader *header = [[CustomExpandHeader alloc] init];
    header.expandView.backgroundColor = [UIColor orangeColor];
    header.clickView.backgroundColor = [UIColor clearColor];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:@"我是按钮" forState:UIControlStateNormal];
    [header addSubview:btn];
    [btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.offset(20);
    }];
    
    return header;
}

- (void)reloadHeader:(NSArray *)dataArr {
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self.expandView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.offset(MAX(0, self.expandHeight));
        make.top.offset(self.expandY);
    }];
}

- (void)makeIconTransForm:(CGFloat)angle {
    self.icon.transform = CGAffineTransformMakeRotation((angle) * (M_PI/180.0));
}

- (void)buttonEvents:(UIButton *)button {
    NSLog(@"buttonEvents");
    
}

- (void)tapGestureEvent:(UITapGestureRecognizer *)tap {
    if (self.actionHandler) {
        self.actionHandler();
    }
}

- (UIView *)expandView {
    if (!_expandView) {
        _expandView = [[UIView alloc] init];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        [button setTitle:@"测试按钮" forState:UIControlStateNormal];
        [button addTarget:self action:@selector(buttonEvents:) forControlEvents:UIControlEventTouchUpInside];
        [_expandView addSubview:button];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.offset(20);
            make.top.offset(20);
            make.width.height.offset(80);
        }];
        
        [self addSubview:_expandView];
        [_expandView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.offset(0);
            make.top.offset(200);
            make.height.offset(200);
        }];
    }
    return _expandView;
}

- (UIView *)clickView {
    if (!_clickView) {
        _clickView = [[UIView alloc] init];
        _clickView.clipsToBounds = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureEvent:)];
        [_clickView addGestureRecognizer:tap];
        
        [self addSubview:_clickView];
        [_clickView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.bottom.right.offset(0);
            make.height.offset(20);
        }];
        _icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_expand_gray"]];
        [_clickView addSubview:_icon];
        [_icon mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.mas_equalTo(_clickView);
        }];
    }
    return _clickView;
}

@end
