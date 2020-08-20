//
//  QXMockAliTableView.h
//  MockAliTableView
//
//  Created by coder QXGuo on 2020/6/24.
//  Copyright © 2020 coder QXGuo. All rights reserved.
//  关于tableView的属性和数据源方法有需要的可以自行扩展到.h文件中

#import <UIKit/UIKit.h>

@class QXMockAliTableView;

NS_ASSUME_NONNULL_BEGIN

@protocol QXMockAliTableViewDelegate <UITableViewDelegate>

/// 扩展区域高度变更追踪
/// @param tableView QXMockAliTableView
/// @param expandHeight 扩展区域高度
- (void)tableView:(QXMockAliTableView *)tableView didExpanding:(CGFloat)expandHeight;

/// 展开与收起状态变更
/// @param tableView QXMockAliTableView
/// @param isExpand 是否为展开状态
- (void)tableView:(QXMockAliTableView *)tableView expandStateDidChange:(BOOL)isExpand;

@optional
/// tableView滚动追踪
/// @param tableView QXMockAliTableView
/// @param offsetY 滚动偏移
- (void)tableView:(QXMockAliTableView *)tableView tableViewDidScroll:(CGFloat)offsetY;

@end

@interface QXMockAliTableView : UIView
#pragma mark - properties
/** 数据源 */
@property(nonatomic, weak) id<UITableViewDataSource> dataSource;
/** 代理 */
@property(nonatomic, weak) id<QXMockAliTableViewDelegate> delegate;
/** 下拉刷新事件 */
@property(nonatomic, strong) void(^refreshHandler)(void);

// 注意：修改以下两个属性时，需在修改完后立即调用reLayoutHeader方法
@property(nonatomic, assign) CGFloat headerMAXHEIGHT;
@property(nonatomic, assign) CGFloat headerEXPANDHEIGHT;

#pragma mark - methods

/// 快速创建QXMockAliTableView实例
/// @param header 传入自定义的头部
+ (instancetype)qxzc_tableView:(UIView *)header style:(UITableViewStyle)style headerMaxH:(CGFloat)headerMaxH;

/// 注册cell
/// @param cellClass cell类型
/// @param identifier cell标识
- (void)registerClass:(nullable Class)cellClass forCellReuseIdentifier:(NSString *)identifier API_AVAILABLE(ios(6.0));

/// 刷新数据
- (void)reloadData;

/// 刷新布局
- (void)reLayoutHeader;

/// 结束下拉刷新
- (void)endRefresh;

/// 设置展开和收起状态
/// @param expand 是否展开
/// @param animated 是否需要动画
- (void)setExpand:(BOOL)expand animated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
