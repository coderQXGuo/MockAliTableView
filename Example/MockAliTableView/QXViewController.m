//
//  QXViewController.m
//  MockAliTableView
//
//  Created by coderQXGuo on 08/20/2020.
//  Copyright (c) 2020 coderQXGuo. All rights reserved.
//

#import "QXViewController.h"
#import <Masonry/Masonry.h>
#import "QXMockAliTableView.h"
#import "CustomExpandHeader.h"

#define kNavBarHeight (CGRectGetHeight([UIApplication sharedApplication].statusBarFrame) + 44.0)

static NSString * const CellID = @"TableViewCell";
@interface QXViewController ()<UITableViewDataSource, QXMockAliTableViewDelegate>

@property(nonatomic, strong) QXMockAliTableView *tableView;

@property(nonatomic, strong) CustomExpandHeader *header;

@property(nonatomic, strong) NSMutableArray *dataArr;

/** 记录当前是否展开 */
@property(nonatomic, assign) BOOL isExpand;

@end

@implementation QXViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.dataArr = @[@{}, @{}, @{}, @{}, @{}, @{}, @{}, @{}, @{}, @{}, @{}, @{}, @{}, @{}, @{}, @{}].mutableCopy;
    
    self.tableView.headerEXPANDHEIGHT = 0;
    self.tableView.headerMAXHEIGHT = 200;
    self.isExpand = NO;
    self.header.expandHeight = self.tableView.headerEXPANDHEIGHT;
    self.header.expandY = self.tableView.headerMAXHEIGHT - self.tableView.headerEXPANDHEIGHT;
    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.tableView.headerEXPANDHEIGHT = 150;
        self.tableView.headerMAXHEIGHT = 350;
        self.isExpand = YES;
        self.header.expandHeight = self.tableView.headerEXPANDHEIGHT;
        self.header.expandY = self.tableView.headerMAXHEIGHT - self.tableView.headerEXPANDHEIGHT;
        [self.tableView reLayoutHeader];
        self.dataArr = @[@{}, @{}].mutableCopy;
        [self.tableView reloadData];
    });
}

- (void)setIsExpand:(BOOL)isExpand {
    _isExpand = isExpand;
    [self.header makeIconTransForm:isExpand ? 180.0 : 0.0];
}

- (void)refreshData {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.tableView endRefresh];
    });
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellID];
    
    cell.textLabel.text = [NSString stringWithFormat:@"第%ld行", (long)indexPath.row];
    return cell;
}

#pragma mark - QXMockAliTableViewDelegate
- (void)tableView:(QXMockAliTableView *)tableView didExpanding:(CGFloat)expandHeight {
//    NSLog(@"====%f", expandHeight);
    [self.header makeIconTransForm:MAX(0, (expandHeight / self.tableView.headerEXPANDHEIGHT) * 180.0)];
}

- (void)tableView:(QXMockAliTableView *)tableView expandStateDidChange:(BOOL)isExpand {
    _isExpand = isExpand;
}

#pragma mark - lazyload
- (QXMockAliTableView *)tableView {
    if (!_tableView) {
        _tableView = [QXMockAliTableView qxzc_tableView:self.header style:UITableViewStylePlain headerMaxH:200];
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:CellID];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        __weak typeof(self) weakSelf = self;
        _tableView.refreshHandler = ^{
            [weakSelf refreshData];
        };
        [self.view addSubview:_tableView];
        [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.offset(kNavBarHeight);
            make.left.bottom.right.offset(0);
        }];
    }
    return _tableView;
}

- (UIView *)header {
    if (!_header) {
        _header = [CustomExpandHeader finaceHeader];
        __weak typeof(self) weakSelf = self;
        _header.actionHandler = ^{
            [weakSelf.tableView setExpand:!weakSelf.isExpand animated:YES];
            weakSelf.isExpand = !weakSelf.isExpand;
        };
        _header.backgroundColor = [UIColor purpleColor];
    }
    return _header;
}

@end
