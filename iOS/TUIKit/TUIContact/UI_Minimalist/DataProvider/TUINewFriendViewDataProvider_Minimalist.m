//
//  TUINewFriendViewModel.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/7.
//

#import "TUINewFriendViewDataProvider_Minimalist.h"
#import <TIMCommon/TIMDefine.h>

@interface TUINewFriendViewDataProvider_Minimalist()

@property NSArray *dataList;

@property (nonatomic,assign) uint64_t origSeq;

@property (nonatomic,assign) uint64_t seq;

@property (nonatomic,assign) uint64_t timestamp;

@property (nonatomic,assign) uint64_t numPerPage;

@end

@implementation TUINewFriendViewDataProvider_Minimalist

- (instancetype)init
{
    self = [super init];

    _numPerPage = 5;
    _dataList = @[];

    return self;
}

- (void)loadData
{
    if (self.isLoading)
        return;
    self.isLoading = YES;
    @weakify(self)
    [[V2TIMManager sharedInstance] getFriendApplicationList:^(V2TIMFriendApplicationResult *result) {
        @strongify(self)
        NSMutableArray *list = @[].mutableCopy;
        for (V2TIMFriendApplication *item in result.applicationList) {
            if (item.type == V2TIM_FRIEND_APPLICATION_COME_IN) {
                TUICommonPendencyCellData_Minimalist *data = [[TUICommonPendencyCellData_Minimalist alloc] initWithPendency:item];
                data.hideSource = YES;
                [list addObject:data];
            }
        }
        self.dataList = list;
        self.isLoading = NO;
        self.hasNextData = YES;
    } fail:nil];
}

- (void)removeData:(TUICommonPendencyCellData_Minimalist *)data
{
    NSMutableArray *dataList = [NSMutableArray arrayWithArray:self.dataList];
    [dataList removeObject:data];
    self.dataList = dataList;
    [[V2TIMManager sharedInstance] deleteFriendApplication:data.application succ:nil fail:nil];
}

- (void)agreeData:(TUICommonPendencyCellData_Minimalist *)data
{
    [[V2TIMManager sharedInstance] acceptFriendApplication:data.application type:V2TIM_FRIEND_ACCEPT_AGREE_AND_ADD succ:nil fail:nil];
    data.isAccepted = YES;
}

- (void)rejectData:(TUICommonPendencyCellData_Minimalist *)data
{
    [V2TIMManager.sharedInstance refuseFriendApplication:data.application succ:^(V2TIMFriendOperationResult *result) {
        
    } fail:^(int code, NSString *desc) {
        
    }];
    
    data.isRejected = YES;
}

@end
