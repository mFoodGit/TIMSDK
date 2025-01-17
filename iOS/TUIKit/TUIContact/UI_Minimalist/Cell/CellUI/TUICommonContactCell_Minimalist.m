//
//  TCommonContactCell.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/5.
//

#import "TUICommonContactCell_Minimalist.h"
#import <TIMCommon/TIMCommonModel.h>
#import "TUICommonContactCellData_Minimalist.h"
#import <TIMCommon/TIMDefine.h>
#import <TUICore/TUIThemeManager.h>
#import <TIMCommon/TUIGroupAvatar+Helper.h>

#define kScale UIScreen.mainScreen.bounds.size.width / 375.0

@interface TUICommonContactCell_Minimalist()
@property TUICommonContactCellData_Minimalist *contactData;
@end

@implementation TUICommonContactCell_Minimalist


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.backgroundColor = TIMCommonDynamicColor(@"", @"#FFFFFF");
        self.avatarView = [[UIImageView alloc] initWithImage:DefaultAvatarImage];
        [self.contentView addSubview:self.avatarView];

        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:self.titleLabel];
        self.titleLabel.font = [UIFont systemFontOfSize:14];
        self.titleLabel.textColor = TIMCommonDynamicColor(@"", @"#000000");
        
        self.onlineStatusIcon = [[UIImageView alloc] init];
        [self.contentView addSubview:self.onlineStatusIcon];

        _separtorView = [[UIView alloc] init];
        _separtorView.backgroundColor = TIMCommonDynamicColor(@"separator_color", @"#DBDBDB");
        [self.contentView addSubview:_separtorView];
        _separtorView.hidden = YES;
        
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];

        self.changeColorWhenTouched = YES;
    }
    return self;
}

- (void)fillWithData:(TUICommonContactCellData_Minimalist *)contactData
{
    [super fillWithData:contactData];
    self.contactData = contactData;

    self.titleLabel.text = contactData.title;
    [self configHeadImageView:contactData];
    @weakify(self)
    [[RACObserve(TUIConfig.defaultConfig, displayOnlineStatusIcon) takeUntil:self.rac_prepareForReuseSignal] subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        if (contactData.onlineStatus == TUIContactOnlineStatusOnline_Minimalist &&
            TUIConfig.defaultConfig.displayOnlineStatusIcon) {
            self.onlineStatusIcon.hidden = NO;
            self.onlineStatusIcon.image = TIMCommonDynamicImage(@"icon_online_status", [UIImage imageNamed:TIMCommonImagePath(@"icon_online_status")]);
        } else if (contactData.onlineStatus == TUIContactOnlineStatusOffline_Minimalist &&
                   TUIConfig.defaultConfig.displayOnlineStatusIcon) {
            self.onlineStatusIcon.hidden = NO;
            self.onlineStatusIcon.image = TIMCommonDynamicImage(@"icon_offline_status", [UIImage imageNamed:TIMCommonImagePath(@"icon_offline_status")]);
        } else {
            self.onlineStatusIcon.hidden = YES;
            self.onlineStatusIcon.image = nil;
        }
    }];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.avatarView.frame = CGRectMake(kScale390(16), (self.bounds.size.height - kScale390(40) )*0.5, kScale390(40), kScale390(40));
    if ([TUIConfig defaultConfig].avatarType == TAvatarTypeRounded) {
        self.avatarView.layer.masksToBounds = YES;
        self.avatarView.layer.cornerRadius = self.avatarView.frame.size.height / 2;
    } else if ([TUIConfig defaultConfig].avatarType == TAvatarTypeRadiusCorner) {
        self.avatarView.layer.masksToBounds = YES;
        self.avatarView.layer.cornerRadius = [TUIConfig defaultConfig].avatarCornerRadius;
    }
    
    self.titleLabel.mm_left(self.avatarView.mm_maxX+12).mm_height(20).mm__centerY(self.avatarView.mm_centerY).mm_flexToRight(0);
    
    self.onlineStatusIcon.mm_width(kScale * 15).mm_height(kScale * 15);
    self.onlineStatusIcon.mm_x = CGRectGetMaxX(self.avatarView.frame) - 0.5 * self.onlineStatusIcon.mm_w - 3 * kScale;
    self.onlineStatusIcon.mm_y = CGRectGetMaxY(self.avatarView.frame) - self.onlineStatusIcon.mm_w;
    self.onlineStatusIcon.layer.cornerRadius = 0.5 * self.onlineStatusIcon.mm_w;

    self.separtorView.frame = CGRectMake(self.avatarView.mm_maxX, self.contentView.mm_h - 1, self.contentView.mm_w, 1);
}
- (void)configHeadImageView:(TUICommonContactCellData_Minimalist *)convData {
    
    /**
     * 修改默认头像
     * Setup default avatar
     */
    if (convData.groupID.length > 0) {
        /**
         * 群组, 则将群组默认头像修改成上次使用的头像
         * If it is a group, change the group default avatar to the last used avatar
         */
        convData.avatarImage = [TUIGroupAvatar getNormalGroupCacheAvatar:convData.groupID groupType:convData.groupType];
    }
    
    @weakify(self);

    [[RACObserve(convData,faceUrl) takeUntil:self.rac_prepareForReuseSignal] subscribeNext:^(NSString *faceUrl) {
        @strongify(self)
        NSString * groupID = convData.groupID?:@"";
        NSString * pFaceUrl = convData.faceUrl?:@"";
        NSString * groupType = convData.groupType?:@"";
        UIImage * originAvatarImage = nil;
        if (convData.groupID.length > 0) {
            originAvatarImage = convData.avatarImage?:DefaultGroupAvatarImageByGroupType(groupType);
        }
        else {
            originAvatarImage = convData.avatarImage?:DefaultAvatarImage;
        }        
        NSDictionary *param =  @{
            @"groupID":groupID,
            @"faceUrl":pFaceUrl,
            @"groupType":groupType,
            @"originAvatarImage":originAvatarImage,
        };
        [TUIGroupAvatar configAvatarByParam:param targetView:self.avatarView];
    }];
}

@end

