//
//  CustomExpandHeader.h
//  MockAliTableView
//
//  Created by coder QXGuo on 2020/6/19.
//  Copyright © 2020 coder QXGuo. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CustomExpandHeader : UIView

@property(nonatomic, assign) CGFloat expandHeight;

@property(nonatomic, assign) CGFloat expandY;

/** 点击事件回调 */
@property(nonatomic, strong) void(^actionHandler)(void);

+ (instancetype)finaceHeader;

- (void)reloadHeader:(NSArray *)dataArr;

- (void)makeIconTransForm:(CGFloat)angle;

@end

NS_ASSUME_NONNULL_END
