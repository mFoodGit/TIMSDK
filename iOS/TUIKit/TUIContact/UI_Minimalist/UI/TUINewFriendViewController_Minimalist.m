//
//  TUINewFriendViewController.m
//  TUIKit
//
//  Created by annidyfeng on 2019/4/19.
//  Copyright © 2019年 Tencent. All rights reserved.
//

#import "TUINewFriendViewController_Minimalist.h"
#import "TUINewFriendViewDataProvider_Minimalist.h"
#import <TIMCommon/TIMDefine.h>
#import <TUICore/TUIThemeManager.h>

@interface TUINewFriendViewController_Minimalist ()<UITableViewDelegate,UITableViewDataSource>
@property UITableView *tableView;
@property UIButton  *moreBtn;
@property TUINewFriendViewDataProvider_Minimalist *viewModel;
@property (nonatomic, strong) UILabel *noDataTipsLabel;
@end

@implementation TUINewFriendViewController_Minimalist

- (void)viewDidLoad {
    [super viewDidLoad];

    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = TIMCommonLocalizableString(TUIKitContactsNewFriends);
    titleLabel.font = [UIFont boldSystemFontOfSize:17.0];
    titleLabel.textColor = TIMCommonDynamicColor(@"nav_title_text_color", @"#000000");
    [titleLabel sizeToFit];
    self.navigationItem.titleView = titleLabel;    
    self.view.backgroundColor = [UIColor whiteColor];
    
    CGRect rect = self.view.bounds;
    _tableView = [[UITableView alloc] initWithFrame:rect style:UITableViewStylePlain];
    if (@available(iOS 15.0, *)) {
        _tableView.sectionHeaderTopPadding = 0;
    }
    [self.view addSubview:_tableView];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [_tableView registerClass:[TUICommonPendencyCell_Minimalist class] forCellReuseIdentifier:@"PendencyCell"];
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.separatorInset = UIEdgeInsetsMake(0, 94, 0, 0);
    _tableView.backgroundColor = self.view.backgroundColor;

    _viewModel = TUINewFriendViewDataProvider_Minimalist.new;

    _moreBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    _moreBtn.mm_h = 20;
    _tableView.tableFooterView = _moreBtn;
    _moreBtn.hidden = YES;

    UIView *messageBackView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    messageBackView.backgroundColor = [UIColor clearColor];
    messageBackView.userInteractionEnabled = YES;
    _tableView.tableHeaderView = messageBackView;
    
    @weakify(self)
    [RACObserve(_viewModel, dataList) subscribeNext:^(id  _Nullable x) {
       @strongify(self)
        NSInteger count = self.viewModel.dataList.count;
        if(count == 0) {
            titleLabel.text = TIMCommonLocalizableString(TUIKitContactsNewFriends);
        }
        else {
            titleLabel.text = [NSString stringWithFormat:@"%ld %@",(long)count,TIMCommonLocalizableString(TUIKitContactsNewFriends)];
        }
        [titleLabel sizeToFit];
        self.navigationItem.titleView = titleLabel;  
       [self.tableView reloadData];
    }];
    
    self.noDataTipsLabel.frame = CGRectMake(10, 60, self.view.bounds.size.width - 20, 40);
    [self.tableView addSubview:self.noDataTipsLabel];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self loadData];
}

- (void)loadData
{
    [_viewModel loadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    self.noDataTipsLabel.hidden = (self.viewModel.dataList.count != 0);
    return self.viewModel.dataList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kScale390(57);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 20;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TUICommonPendencyCell_Minimalist *cell = [self.tableView dequeueReusableCellWithIdentifier:@"PendencyCell" forIndexPath:indexPath];
    TUICommonPendencyCellData_Minimalist *data = self.viewModel.dataList[indexPath.row];
    data.cselector = @selector(cellClick:);
    data.cbuttonSelector = @selector(btnClick:);
    data.cRejectButtonSelector = @selector(rejectBtnClick:);
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell fillWithData:data];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //add code here for when you hit delete
        [self.tableView beginUpdates];
        TUICommonPendencyCellData_Minimalist *data = self.viewModel.dataList[indexPath.row];
        [self.viewModel removeData:data];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
    }
}

- (void)btnClick:(TUICommonPendencyCell_Minimalist *)cell
{
    [self.viewModel agreeData:cell.pendencyData];
    [self.tableView reloadData];
}

- (void)rejectBtnClick:(TUICommonPendencyCell_Minimalist *)cell
{
    [self.viewModel rejectData:cell.pendencyData];
    [self.tableView reloadData];
}

- (void)cellClick:(TUICommonPendencyCell_Minimalist *)cell
{
    if (self.cellClickBlock) {
        self.cellClickBlock(cell);
    }
}

- (UILabel *)noDataTipsLabel
{
    if (_noDataTipsLabel == nil) {
        _noDataTipsLabel = [[UILabel alloc] init];
        _noDataTipsLabel.textColor = TUIContactDynamicColor(@"contact_add_contact_nodata_tips_text_color", @"#999999");
        _noDataTipsLabel.font = [UIFont systemFontOfSize:14.0];
        _noDataTipsLabel.textAlignment = NSTextAlignmentCenter;
        _noDataTipsLabel.text = TIMCommonLocalizableString(TUIKitContactNoNewApplicationRequest);
    }
    return _noDataTipsLabel;
}

@end
