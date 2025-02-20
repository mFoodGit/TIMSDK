//
//  ContactsController_Minimalist.m
//  TUIKitDemo
//
//  Created by annidyfeng on 2019/3/25.
//  Copyright © 2019年 kennethmiao. All rights reserved.
//
/** 腾讯云IM Demo好友列表视图
 *  本文件实现了好友列表的视图控制器，使用户可以浏览自己的好友、群组并对其进行管理
 *  本文件所实现的视图控制器，对应了下方barItemView中的 "通讯录" 视图
 *
 *  本类依赖于腾讯云 TUIKit和IMSDK 实现
 */

#import "ContactsController_Minimalist.h"
#import "TUIContactController_Minimalist.h"
#import <TIMCommon/TIMCommonModel.h>
#import <TIMCommon/TIMDefine.h>

@interface ContactsController_Minimalist () <TUIPopViewDelegate>
@property (nonatomic, strong) TUINaviBarIndicatorView *titleView;
@end

@implementation ContactsController_Minimalist

- (UIColor *)navBackColor {
    return  [UIColor whiteColor];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (@available(iOS 15.0, *)) {
        UINavigationBarAppearance *appearance = [UINavigationBarAppearance new];
        [appearance configureWithDefaultBackground];
        appearance.shadowColor = nil;
        appearance.backgroundEffect = nil;
        appearance.backgroundColor =  [self navBackColor];
        UINavigationBar *navigationBar = self.navigationController.navigationBar;
        navigationBar.backgroundColor = [self navBackColor];
        navigationBar.barTintColor = [self navBackColor];
        navigationBar.shadowImage = [UIImage new];
        navigationBar.standardAppearance = appearance;
        navigationBar.scrollEdgeAppearance= appearance;
    }
    else {
        UINavigationBar *navigationBar = self.navigationController.navigationBar;
        navigationBar.backgroundColor = [self navBackColor];
        navigationBar.barTintColor = [self navBackColor];
        navigationBar.shadowImage = [UIImage new];
    }
    if (self.viewWillAppear) {
        self.viewWillAppear(YES);
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (self.viewWillAppear) {
        self.viewWillAppear(NO);
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupNavigation];
    
    self.contact = [[TUIContactController_Minimalist alloc] init];
    [self addChildViewController:self.contact];
    [self.view addSubview:self.contact.view];
}

- (void)setupNavigation
{
    _titleView = [[TUINaviBarIndicatorView alloc] init];
    _titleView.label.font = [UIFont boldSystemFontOfSize:34];
    [_titleView setTitle:TIMCommonLocalizableString(TIMAppTabBarItemContactText_mini)];
    _titleView.label.textColor = TUIDynamicColor(@"nav_title_text_color", TUIThemeModuleDemo_Minimalist, @"#000000");
    
    UIBarButtonItem *leftTitleItem = [[UIBarButtonItem alloc] initWithCustomView:_titleView];
    UIBarButtonItem *leftSpaceItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    leftSpaceItem.width = kScale390(13);
    self.showLeftBarButtonItems = [NSMutableArray arrayWithArray:@[leftSpaceItem, leftTitleItem]];
    
    self.navigationItem.title = @"";
    self.navigationItem.leftBarButtonItems = self.showLeftBarButtonItems;
    
    UIButton *moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [moreButton setImage:[UIImage imageNamed:TUIConversationImagePath_Minimalist(@"nav_add")] forState:UIControlStateNormal];
    [moreButton addTarget:self action:@selector(onRightItem:) forControlEvents:UIControlEventTouchUpInside];
    moreButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [moreButton setFrame:CGRectMake(0, 0, 26, 26)];

    UIBarButtonItem *moreItem = [[UIBarButtonItem alloc] initWithCustomView:moreButton];
    self.showRightBarButtonItems = [NSMutableArray arrayWithArray:@[moreItem]];
    self.navigationItem.rightBarButtonItems = self.showRightBarButtonItems;
}

- (void)onRightItem:(UIButton *)rightBarButton;
{
    NSMutableArray *menus = [NSMutableArray array];
    TUIPopCellData *friend = [[TUIPopCellData alloc] init];
    friend.image =
    TUIContactDynamicImage(@"pop_icon_add_friend_img", [UIImage imageNamed:TUIContactImagePath(@"add_friend")]);
    friend.title = TIMCommonLocalizableString(ContactsAddFriends); //@"添加好友";
    [menus addObject:friend];

    TUIPopCellData *group = [[TUIPopCellData alloc] init];
    group.image =
    TUIContactDynamicImage(@"pop_icon_add_group_img", [UIImage imageNamed:TUIContactImagePath(@"add_group")]);

    group.title = TIMCommonLocalizableString(ContactsJoinGroup);//@"添加群组";
    [menus addObject:group];

    CGFloat height = [TUIPopCell getHeight] * menus.count + TUIPopView_Arrow_Size.height;
    CGFloat orginY = StatusBar_Height + NavBar_Height;
    TUIPopView *popView = [[TUIPopView alloc] initWithFrame:CGRectMake(Screen_Width - 140, orginY, 130, height)];
    CGRect frameInNaviView = [self.navigationController.view convertRect:rightBarButton.frame fromView:rightBarButton.superview];
    popView.arrowPoint = CGPointMake(frameInNaviView.origin.x + frameInNaviView.size.width * 0.5, orginY);
    popView.delegate = self;
    [popView setData:menus];
    [popView showInWindow:self.view.window];
}

- (void)popView:(TUIPopView *)popView didSelectRowAtIndex:(NSInteger)index
{
    if (0 == index) {
        [self.contact addToContacts];
    } else {
        [self.contact addGroups];
    }
}




@end
