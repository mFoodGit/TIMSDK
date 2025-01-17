//
//  TUIChatObjectFactory_Minimalist.m
//  TUIChat
//
//  Created by wyl on 2023/3/20.
//

#import "TUIChatObjectFactory_Minimalist.h"
#import "TUIC2CChatViewController_Minimalist.h"
#import "TUIGroupChatViewController_Minimalist.h"
#import "TUIChatConfig.h"
#import <TUICore/NSDictionary+TUISafe.h>
#import "TUIChatDefine.h"

@interface TUIChatObjectFactory_Minimalist()<TUIObjectProtocol>

@end

@implementation TUIChatObjectFactory_Minimalist
+ (void)load {
    [TUICore registerObjectFactoryName:TUICore_TUIChatObjectFactory_Minimalist objectFactory:[TUIChatObjectFactory_Minimalist shareInstance]];
}
+ (TUIChatObjectFactory_Minimalist *)shareInstance {
    static dispatch_once_t onceToken;
    static TUIChatObjectFactory_Minimalist * g_sharedInstance = nil;
    dispatch_once(&onceToken, ^{
        g_sharedInstance = [[TUIChatObjectFactory_Minimalist alloc] init];
    });
    return g_sharedInstance;
}

#pragma mark - TUIObjectProtocol
- (id)onCreateObject:(NSString *)method param:(nullable NSDictionary *)param {
    if ([method isEqualToString:TUICore_TUIChatObjectFactory_GetChatViewControllerMethod]) {
        return [self createChatViewController:[param tui_objectForKey:TUICore_TUIChatObjectFactory_GetChatViewControllerMethod_TitleKey asClass:NSString.class]
                                       userID:[param tui_objectForKey:TUICore_TUIChatObjectFactory_GetChatViewControllerMethod_UserIDKey asClass:NSString.class]
                                      groupID:[param tui_objectForKey:TUICore_TUIChatObjectFactory_GetChatViewControllerMethod_GroupIDKey asClass:NSString.class]
                               conversationID:[param tui_objectForKey:TUICore_TUIChatObjectFactory_GetChatViewControllerMethod_ConversationIDKey asClass:NSString.class]
                                  avatarImage:[param tui_objectForKey:TUICore_TUIChatObjectFactory_GetChatViewControllerMethod_AvatarImageKey asClass:UIImage.class]
                                    avatarUrl:[param tui_objectForKey:TUICore_TUIChatObjectFactory_GetChatViewControllerMethod_AvatarUrlKey asClass:NSString.class]
                             highlightKeyword:[param tui_objectForKey:TUICore_TUIChatObjectFactory_GetChatViewControllerMethod_HighlightKeywordKey asClass:NSString.class]
                                locateMessage:[param tui_objectForKey:TUICore_TUIChatObjectFactory_GetChatViewControllerMethod_LocateMessageKey asClass:V2TIMMessage.class]
                                    atMsgSeqs:[param tui_objectForKey:TUICore_TUIChatObjectFactory_GetChatViewControllerMethod_AtMsgSeqsKey asClass:NSArray.class]
                                        draft:[param tui_objectForKey:TUICore_TUIChatObjectFactory_GetChatViewControllerMethod_DraftKey asClass:NSString.class]];
    }
    return nil;
}


#pragma mark - Private


- (UIViewController *)createChatViewController:(NSString *)title
                                        userID:(NSString *)userID
                                       groupID:(NSString *)groupID
                                conversationID:(NSString *)conversationID
                                   avatarImage:(UIImage *)avatarImage
                                     avatarUrl:(NSString *)avatarUrl
                              highlightKeyword:(NSString *)highlightKeyword
                                 locateMessage:(V2TIMMessage *)locateMessage
                                    atMsgSeqs:(NSArray<NSNumber *> *)atMsgSeqs
                                        draft:(NSString *)draft {
    TUIChatConversationModel *conversationModel = [TUIChatConversationModel new];
    conversationModel.title = title;
    conversationModel.userID = userID;
    conversationModel.groupID = groupID;
    conversationModel.conversationID = conversationID;
    conversationModel.avatarImage = avatarImage;
    conversationModel.faceUrl = avatarUrl;
    conversationModel.atMsgSeqs = [NSMutableArray arrayWithArray:atMsgSeqs];
    conversationModel.draftText = draft;
    
    TUIBaseChatViewController_Minimalist *chatVC = nil;
    if (conversationModel.groupID.length > 0) {
        chatVC = [[TUIGroupChatViewController_Minimalist alloc] init];
    } else if (conversationModel.userID.length > 0) {
        chatVC = [[TUIC2CChatViewController_Minimalist alloc] init];
    }
    chatVC.conversationData = conversationModel;
    chatVC.title = conversationModel.title;
    chatVC.highlightKeyword = highlightKeyword;
    chatVC.locateMessage = locateMessage;
    return chatVC;
}

@end
