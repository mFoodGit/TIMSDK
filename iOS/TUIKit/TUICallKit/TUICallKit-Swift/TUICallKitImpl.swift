//
//  TUICallKitImpl.swift
//  TUICallKitSwift
//
//  Created by vincepzhang on 2023/1/4.
//

import Foundation
import TUICore
import TXLiteAVSDK_TRTC
import UIKit

class TUICallKitImpl: TUICallKit {
    
    static let instance = TUICallKitImpl()
    let selfUserCallStatusObserver = Observer()
    
    override init() {
        super.init()
        initEngine()
        registerNotifications()
        registerObserveState()
    }
    
    deinit {
        CallEngineManager.instance.removeObserver(TUICallState.instance)
        NotificationCenter.default.removeObserver(self)
        TUICallState.instance.selfUser.value.callStatus.removeObserver(selfUserCallStatusObserver)
    }
        
    // MARK: TUICallKit对外接口实现
    override func setSelfInfo(nickname: String, avatar: String, succ: @escaping TUICallSucc, fail: @escaping TUICallFail) {
        CallEngineManager.instance.setSelfInfo(nickname: nickname, avatar: avatar) {
            succ()
        } fail: { code, message in
            fail(code,message)
        }
    }
    
    override func call(userId: String, callMediaType: TUICallMediaType) {
        call(userId: userId, callMediaType: callMediaType, params:TUICallParams()) {
            
        } fail: { errCode, errMessage in
            
        }
    }

    override func call(userId: String, callMediaType: TUICallMediaType, params: TUICallParams,
                       succ: @escaping TUICallSucc, fail: @escaping TUICallFail) {
       
        if  userId.count <= 0 {
             fail(ERROR_PARAM_INVALID, "call failed, invalid params 'userId'")
             return
         }
        
        if TUILogin.getUserID() == nil {
            fail(ERROR_INIT_FAIL, "call failed, please login")
            return
         }
        
         if WindowManager.instance.isFloating {
             fail(ERROR_PARAM_INVALID, "call failed, Unable to restart the call")
             TUITool.makeToast(TUICallKitLocalize(key: "Demo.TRTC.Calling.UnableToRestartTheCall"))
             return
         }
        
        if callMediaType == .unknown {
             fail(ERROR_PARAM_INVALID, "call failed, callMediaType is Unknown")
             return
         }

        CallEngineManager.instance.call(userId: userId, callMediaType: callMediaType, params: params) {
            succ()
        } fail: { code, message in
            fail(code, message)
        }
    }

    override func groupCall(groupId: String, userIdList: [String], callMediaType: TUICallMediaType) {
        groupCall(groupId: groupId, userIdList: userIdList, callMediaType: callMediaType, params: TUICallParams()) {
    
        } fail: { code, message in
            
        }
    }
    
    override func groupCall(groupId: String, userIdList: [String], callMediaType: TUICallMediaType, params: TUICallParams,
                            succ: @escaping TUICallSucc, fail: @escaping TUICallFail) {
        CallEngineManager.instance.groupCall(groupId: groupId, userIdList: userIdList, callMediaType: callMediaType, params: params) {
            succ()
        } fail: { code, message in
            fail(code,message)
        }
    }
    
    override func joinInGroupCall(roomId: TUIRoomId, groupId: String, callMediaType: TUICallMediaType) {
        CallEngineManager.instance.joinInGroupCall(roomId: roomId, groupId: groupId, callMediaType: callMediaType)
    }
    
    override func setCallingBell(filePath: String) {
        if filePath.hasPrefix("http") {
            let session = URLSession.shared
            guard let url = URL(string: filePath) else { return }
            let downloadTask = session.downloadTask(with: url) { location, response, error in
                if error != nil {
                    return
                }
                
                if location != nil {
                    if let oldBellFilePath = UserDefaults.standard.object(forKey: TUI_CALLING_BELL_KEY) as? String {
                        do {
                            try FileManager.default.removeItem(atPath: oldBellFilePath)
                        } catch let error {
                            debugPrint("FileManager Error: \(error)")
                        }
                    }
                    guard let location = location else { return }
                    guard let dstDocPath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).last else { return }
                    let dstPath = dstDocPath + "/" + location.lastPathComponent
                    do {
                        try FileManager.default.moveItem(at: location, to: URL(fileURLWithPath: dstPath))
                    } catch let error {
                        debugPrint("FileManager Error: \(error)")
                    }
                    UserDefaults.standard.set(dstPath, forKey: TUI_CALLING_BELL_KEY)
                    UserDefaults.standard.synchronize()
                }
            }
            downloadTask.resume()
        } else {
            UserDefaults.standard.set(filePath, forKey: TUI_CALLING_BELL_KEY)
            UserDefaults.standard.synchronize()
        }
    }
    
    override func enableMuteMode(enable: Bool) {
        UserDefaults.standard.set(enable, forKey: ENABLE_MUTEMODE_USERDEFAULT)
        TUICallState.instance.enableMuteMode = enable
    }
    
    override func enableFloatWindow(enable: Bool) {
        TUICallState.instance.enableFloatWindow = enable
    }
    
    override func enableCustomViewRoute(enable: Bool) {
        
    }
    
    override func getCallViewController() -> UIViewController {
        
        if let callWindowVC = WindowManager.instance.callWindow.rootViewController {
            return callWindowVC
        }
        
        if let floatingWindowVC = WindowManager.instance.floatWindow.rootViewController {
            return floatingWindowVC
        }
        
        return UIViewController()
    }
    
}


// MARK: TUICallKit内部接口
private extension TUICallKitImpl {
        
    func registerNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(loginSuccessNotification),
                                               name: NSNotification.Name.TUILoginSuccess,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(logoutSuccessNotification),
                                               name: NSNotification.Name.TUILogoutSuccess,
                                               object: nil)
    }
    
    @objc func loginSuccessNotification(noti: Notification) {
        initEngine()
        initState()
        CallEngineManager.instance.addObserver(TUICallState.instance)
        CallEngineManager.instance.setFramework()
    }
    
    @objc func logoutSuccessNotification(noti: Notification) {
        CallEngineManager.instance.removeObserver(TUICallState.instance)
    }
    
    func initEngine() {
        CallEngineManager.instance.initEigine(sdkAppId:TUILogin.getSdkAppID(),
                                                userId: TUILogin.getUserID() ?? "",
                                               userSig: TUILogin.getUserSig() ?? "") {} fail: { Int32errCode, errMessage in }
        
        let videoEncoderParams = TUIVideoEncoderParams()
        videoEncoderParams.resolution = ._640_360
        videoEncoderParams.resolutionMode = .portrait
        CallEngineManager.instance.setVideoEncoderParams(params: videoEncoderParams)  {} fail: { Int32errCode, errMessage in }
        
        let videoRenderParams = TUIVideoRenderParams()
        videoRenderParams.fillMode = .fill
        videoRenderParams.rotation = ._0
        CallEngineManager.instance.setVideoRenderParams(userId: TUILogin.getUserID() ?? "",
                                                            params: videoRenderParams) {} fail: { Int32errCode, errMessage in }

        let beauty = CallEngineManager.instance.getTRTCCloudInstance().getBeautyManager()
        beauty.setBeautyStyle(.nature)
        beauty.setBeautyLevel(6.0)
    }
    
    func initState() {
        
        CallEngineManager.instance.addObserver(TUICallState.instance)
        User.getSelfUserInfo(response: { selfUser in
            TUICallState.instance.selfUser.value.id.value = selfUser.id.value
            TUICallState.instance.selfUser.value.nickname.value = selfUser.nickname.value
            TUICallState.instance.selfUser.value.avatar.value = selfUser.avatar.value
        })
    }
    
    func registerObserveState() {
        TUICallState.instance.selfUser.value.callStatus.addObserver(selfUserCallStatusObserver, closure: { newValue, _ in
            if TUICallState.instance.selfUser.value.callRole.value != .none &&
                TUICallState.instance.selfUser.value.callStatus.value == .waiting {
                TUICallState.instance.audioDevice.value = .earpiece
                CallEngineManager.instance.setAudioPlaybackDevice(device: .earpiece)
                WindowManager.instance.showCallWindow()
            }

            if TUICallState.instance.selfUser.value.callRole.value == .none &&
                TUICallState.instance.selfUser.value.callStatus.value == .none {
                WindowManager.instance.closeCallWindow()
                WindowManager.instance.closeFloatWindow()
            }
        })
    }
}
