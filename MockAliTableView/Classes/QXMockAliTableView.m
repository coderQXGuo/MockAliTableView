//
//  QXMockAliTableView.m
//  MockAliTableView
//
//  Created by coder QXGuo on 2020/6/24.
//  Copyright © 2020 coder QXGuo. All rights reserved.
//

#import "QXMockAliTableView.h"
#import <Masonry/Masonry.h>
#import <MJRefresh/MJRefresh.h>

#define kQXScreenWidth ([UIScreen mainScreen].bounds.size.width)
#define kQXScreenHeight ([UIScreen mainScreen].bounds.size.height)
#define kNavBarHeight (CGRectGetHeight([UIApplication sharedApplication].statusBarFrame) + 44.0)

@interface QXZCRefreshNormalHeader : MJRefreshNormalHeader

/** 自定义状态监听回调 */
@property(nonatomic, strong) void(^stateChangeHandler)(MJRefreshState state);

@end

@implementation QXZCRefreshNormalHeader

- (void)setState:(MJRefreshState)state {
    [super setState:state];
    if (self.stateChangeHandler) {
        self.stateChangeHandler(state);
    }
}

@end


@interface QXMockAliTableView ()<UITableViewDelegate>

@property(nonatomic, assign) UITableViewStyle tableStyle;

@property(nonatomic, strong) UIView *header;
/** 占位头部 */
@property(nonatomic, strong) UIView *headPlaceHolder;

@property(nonatomic, strong) UIView *expandView;

/** 展开或收起状态 */
@property(nonatomic, assign, getter=isExpand) BOOL expand;

/** tableView */
@property(nonatomic, strong) UITableView *tableView;

@property(nonatomic, strong) NSMutableArray *dataArr;

@property(nonatomic, assign) CGFloat lastOffsetY;

@property(nonatomic, assign) CGFloat beginDragOffsetY;

@property(nonatomic, assign) CGFloat endDragOffsetY;

/** 记录是否允许feedback */
@property(nonatomic, assign) BOOL shouldFeedback;

@end

@implementation QXMockAliTableView

#pragma mark - interface
+ (instancetype)qxzc_tableView:(UIView *)header style:(UITableViewStyle)style headerMaxH:(CGFloat)headerMaxH {
    QXMockAliTableView *view = [[QXMockAliTableView alloc] init];
    view.headerMAXHEIGHT = headerMaxH;
    view.header = header;
    header.clipsToBounds = YES;
    
    view.tableStyle = style;
    [view.tableView addSubview:header];
    [header mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.offset(0);
        make.width.offset(kQXScreenWidth);
        make.height.offset(headerMaxH);
    }];
    
    [view addRefresh];
    
    return view;
}

- (void)setDataSource:(id<UITableViewDataSource>)dataSource {
    _dataSource = dataSource;
    self.tableView.dataSource = dataSource;
}

- (void)registerClass:(Class)cellClass forCellReuseIdentifier:(NSString *)identifier {
    [self.tableView registerClass:cellClass forCellReuseIdentifier:identifier];
}

- (void)reloadData {
    [self.tableView reloadData];
}

- (void)reLayoutHeader {
//    [self.tableView beginUpdates];
    [self.header setNeedsLayout];
    [self.tableView bringSubviewToFront:self.header];
    [self.tableView layoutIfNeeded];
    [self.header mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.left.offset(0);
        make.width.offset(kQXScreenWidth);
        make.height.offset(self.headerMAXHEIGHT);
    }];
    [UIView animateWithDuration:0.2 animations:^{
        [self.tableView layoutIfNeeded];
        self.headPlaceHolder.frame = CGRectMake(0, 0, kQXScreenWidth, self.headerMAXHEIGHT);
        [self.tableView setContentOffset:CGPointZero];
        [self resetScrollIndicatorInsets];
    }];
//    [self.tableView endUpdates];
}

- (void)endRefresh {
    [self.tableView.mj_header endRefreshing];
}

- (void)setExpand:(BOOL)expand animated:(BOOL)animated {
    _expand = expand;
    CGFloat height = self.headerMAXHEIGHT;
    CGFloat change = -self.lastOffsetY;
    if (!expand) {
        change = self.headerEXPANDHEIGHT - (self.headerMAXHEIGHT - self.header.bounds.size.height);
        height = (self.headerMAXHEIGHT - self.headerEXPANDHEIGHT);// 收起的高度
    }
    
    [self.header mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.offset(height);
        make.top.offset(self.lastOffsetY + change);
    }];
    if (animated) {
        [UIView animateWithDuration:0.2 animations:^{
            [self layoutIfNeeded];
            [self.tableView setContentOffset:CGPointMake(0, self.lastOffsetY + change)];
        } completion:^(BOOL finished) {
            if ([self.delegate respondsToSelector:@selector(tableView:expandStateDidChange:)]) {
                [self.delegate tableView:self expandStateDidChange:expand];
            }
        }];
    } else {
        [self layoutIfNeeded];
        [self.tableView setContentOffset:CGPointMake(0, self.lastOffsetY + change)];
        if ([self.delegate respondsToSelector:@selector(tableView:expandStateDidChange:)]) {
            [self.delegate tableView:self expandStateDidChange:expand];
        }
    }
}

#pragma mark - privateMethod
- (void)layoutSubviews {
    [super layoutSubviews];
    [self resetScrollIndicatorInsets];
}

- (void)addRefresh {
    __weak typeof(self) weakSelf = self;
    QXZCRefreshNormalHeader *refreshHeader = [QXZCRefreshNormalHeader headerWithRefreshingBlock:^{
        if (weakSelf.refreshHandler) {
            weakSelf.refreshHandler();
        }
    }];
    refreshHeader.stateChangeHandler = ^(MJRefreshState state) {
        if (state == MJRefreshStatePulling) {
            [weakSelf feedbackGenerator];
        }
    };
    self.tableView.mj_header = refreshHeader;
}

- (void)resetScrollIndicatorInsets {
    UIEdgeInsets safeAreaInsets = UIEdgeInsetsZero;
    if (@available(iOS 11.0, *)) {
        safeAreaInsets = [UIApplication sharedApplication].keyWindow.safeAreaInsets;
        CGFloat minY = CGRectGetMinY(self.frame);
        if (safeAreaInsets.bottom == 0 || minY > 0) {
            safeAreaInsets = UIEdgeInsetsZero;
        }
    }
    
    self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(CGRectGetMaxY(self.headPlaceHolder.frame) - safeAreaInsets.top, 0, 0, 0);
}

- (void)responseFeedback:(CGFloat)expandHeight {
    if (self.shouldFeedback) {
        CGFloat offsetY = self.lastOffsetY - self.beginDragOffsetY;
        if (offsetY <= 0 && expandHeight <= 10 && self.lastOffsetY <= self.headerEXPANDHEIGHT + 10) { // 往下拖
            [self feedbackGenerator];
            self.shouldFeedback = NO;
        }
    }
}

- (void)feedbackGenerator {
    if (@available(iOS 10.0,*)) {
        UIImpactFeedbackGenerator *generator = [[UIImpactFeedbackGenerator alloc] initWithStyle: UIImpactFeedbackStyleLight];
        [generator prepare];
        [generator impactOccurred];
    }
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if ([self.delegate respondsToSelector:@selector(tableView:heightForHeaderInSection:)]) {
        return [self.delegate tableView:tableView heightForHeaderInSection:section];
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if ([self.delegate respondsToSelector:@selector(tableView:heightForFooterInSection:)]) {
        return [self.delegate tableView:tableView heightForFooterInSection:section];
    }
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if ([self.delegate respondsToSelector:@selector(tableView:viewForHeaderInSection:)]) {
        return [self.delegate tableView:tableView viewForHeaderInSection:section];
    }
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if ([self.delegate respondsToSelector:@selector(tableView:viewForFooterInSection:)]) {
        return [self.delegate tableView:tableView viewForFooterInSection:section];
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)]) {
        [self.delegate tableView:tableView didSelectRowAtIndexPath:indexPath];
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (scrollView.contentOffset.y <= - (scrollView.mj_header.mj_h + 15)) {
        [scrollView setContentOffset:CGPointMake(0, - (scrollView.mj_header.mj_h + 15))];
        return;
    }
    
    CGFloat topConstrait = MIN(MAX(0, scrollView.contentOffset.y), self.headerEXPANDHEIGHT);
    [self.header mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.offset(topConstrait);
    }];

    CGFloat height = MAX(0, MIN(self.headerMAXHEIGHT - scrollView.contentOffset.y, self.headerMAXHEIGHT));
    height = MAX(height, self.headerMAXHEIGHT - self.headerEXPANDHEIGHT);
    [self.header mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.offset(height);
    }];
    self.lastOffsetY = scrollView.contentOffset.y;
    
    if ([self.delegate respondsToSelector:@selector(tableView:tableViewDidScroll:)]) {
        [self.delegate tableView:self tableViewDidScroll:scrollView.contentOffset.y];
    }
    
    CGFloat expandHeight = self.headerEXPANDHEIGHT - (self.headerMAXHEIGHT - height);
    if ([self.delegate respondsToSelector:@selector(tableView:didExpanding:)]) {
        [self.delegate tableView:self didExpanding:expandHeight];
    }
    
    if (self.headerEXPANDHEIGHT == 0) {
        return;
    }
    
    // 如果当前状态是展开状态，则偏移量不能大于HEADER_EXPAND_HEIGHT
    if (self.isExpand && self.lastOffsetY >= self.headerEXPANDHEIGHT) {
        [scrollView setContentOffset:CGPointMake(0, self.headerEXPANDHEIGHT)];
    }
    // 如果当前状态是收起状态，则偏移量不能小于0
    else if (!self.isExpand && self.lastOffsetY <= 0) {
        [scrollView setContentOffset:CGPointZero];
    }
    
    [self responseFeedback:expandHeight];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.beginDragOffsetY = scrollView.contentOffset.y;
    BOOL disExpand = (scrollView.contentOffset.y >= self.headerEXPANDHEIGHT);
    _expand = !disExpand;
    CGFloat originHeight = scrollView.contentSize.height;
    scrollView.contentSize = CGSizeMake(0, MAX(self.bounds.size.height + self.headerMAXHEIGHT, originHeight));
    self.shouldFeedback = YES;
    
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    self.endDragOffsetY = scrollView.contentOffset.y;
    self.shouldFeedback = NO;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        if (scrollView.contentOffset.y < 0) {
            return;
        }
        
        if (scrollView.contentOffset.y > 0 && scrollView.contentOffset.y <= self.headerEXPANDHEIGHT) {
            BOOL notAnimated = scrollView.contentOffset.y >= self.headerEXPANDHEIGHT;
            // (self.beginDragOffsetY - self.endDragOffsetY < 0)表示向上拖拽
            [self setExpand:!(self.beginDragOffsetY - self.endDragOffsetY < 0) animated:!notAnimated];
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.y < 0) {
        return;
    }
    
    if (scrollView.contentOffset.y > 0 && scrollView.contentOffset.y <= self.headerEXPANDHEIGHT) {
        BOOL notAnimated = scrollView.contentOffset.y >= self.headerEXPANDHEIGHT;
        // (self.beginDragOffsetY - self.endDragOffsetY < 0)表示向上拖拽
        [self setExpand:!(self.beginDragOffsetY - self.endDragOffsetY < 0) animated:!notAnimated];
    }
}

#pragma mark - lazyLoad
- (UIView *)headPlaceHolder {
    if (!_headPlaceHolder) {
        _headPlaceHolder = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kQXScreenWidth, self.headerMAXHEIGHT)];
        _headPlaceHolder.userInteractionEnabled = NO;
        _headPlaceHolder.backgroundColor = [UIColor clearColor];
    }
    return _headPlaceHolder;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:self.tableStyle];
        if (@available(iOS 11.0, *)) {
            _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.delegate = self;
        _tableView.separatorStyle = UITableViewCellSelectionStyleNone;
        _tableView.tableHeaderView = self.headPlaceHolder;
        _tableView.tableFooterView = [UIView new];
        _tableView.estimatedRowHeight = 126.0;  //  随便设个不那么离谱的值
        _tableView.rowHeight = UITableViewAutomaticDimension;
        [self addSubview:_tableView];
        [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self);
        }];
    }
    return _tableView;
}

@end
