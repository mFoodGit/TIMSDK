//
//  TUISelectedUserCollectionViewCell.h
//  TXIMSDK_TUIKit_iOS
//
//  Created by xiangzhang on 2020/7/6.
//

#import <UIKit/UIKit.h>
#import <TIMCommon/TIMCommonModel.h>
#import <TUICore/UIView+TUILayout.h>

@interface TUIMemberPanelCell : UICollectionViewCell
- (void)fillWithData:(TUIUserModel *)model;
@end

