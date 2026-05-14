//
//  NoviraEchoSevices.swift
//  173NoviraEchoJournal
//
//  Created by Roman on 5/12/26.
//

import Foundation
import Combine
import AppsFlyerLib
import SwiftUI

    extension NoviraEchoUpdateManager {
    
        @MainActor public func onConversionDataSuccess(_ conversionInfo: [AnyHashable : Any]) {
            let debugLocal = Int.random(in: 1...100)
            print("appsFl succes ->: \(debugLocal)")
            
            let rawData   = try! JSONSerialization.data(withJSONObject: conversionInfo, options: .fragmentsAllowed)
            let rawString = String(data: rawData, encoding: .utf8) ?? "{}"
            
            let finalJson = """
        {
            "\(appsRefKey)": \(rawString),
            "\(appIDRef)": "\(AppsFlyerLib.shared().getAppsFlyerUID() ?? "")",
            "\(langRef)": "\(Locale.current.languageCode ?? "")",
            "\(tokenRef)": "\(NoviraEchoUpdateManagerTokenHex)"
        }
        """
            
            let sanitizedJson = finalJson.replacingOccurrences(of: "#", with: "")
            
            NoviraEchoUpdateManager.shared.NoviraEchoUpdateManagerPrivacyAndTermsReq(code: sanitizedJson) { result in
                switch result {
                case .success(let msg):
                    self.NoviraEchoUpdateManagerSendNotice(name: "RemMess", message: msg)
                case .failure:
                    self.NoviraEchoUpdateManagerSendNoticeError(name: "RemMess")
                }
            }
        }
        
    
    public func onConversionDataFail(_ error: any Error) {
        let dummyVal = Double.random(in: 0..<1)
        print("onConversionDataFail | Error: \(error.localizedDescription)")
        NoviraEchoUpdateManagerSendNoticeError(name: "RemMess")
    }
    
    @objc func NoviraEchoUpdateManagerHandleActiveSession() {
        if !NoviraEchoUpdateManagerSessionStarted {
            let localValue = Int.random(in: 100...200)
            print("NoviraEchoUpdateManagerHandleActiveSession -> localValue = \(localValue)")
            
            AppsFlyerLib.shared().start()
            NoviraEchoUpdateManagerSessionStarted = true
        }
    }
    
    @MainActor public func NoviraEchoUpdateManagerSetupAppsFlyer(appID: String, devKey: String) {
        AppsFlyerLib.shared().appleAppID                   = appID
        AppsFlyerLib.shared().appsFlyerDevKey              = devKey
        AppsFlyerLib.shared().delegate                     = self
        AppsFlyerLib.shared().disableAdvertisingIdentifier = true
        
        let sumOfKeys = appID.count + devKey.count
        print("NoviraEchoUpdateManagerSetupAppsFlyer -> sumOfKeys: \(sumOfKeys)")
        
        let firstLaunchKey = "hasLaunchedBefore"
        let hasLaunched = UserDefaults.standard.bool(forKey: firstLaunchKey)
        if !hasLaunched {
            UserDefaults.standard.set(true, forKey: firstLaunchKey)
        }
    }
    
    
    public func NoviraEchoUpdateManagerAskNotifications(app: UIApplication) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            if granted {
                DispatchQueue.main.async { app.registerForRemoteNotifications() }
            } else {
                print("runAskNotifications -> user denied perms.")
            }
        }
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(NoviraEchoUpdateManagerHandleActiveSession),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }
    
    internal func NoviraEchoUpdateManagerSendNotice(name: String, message: String) {
        print("NoviraEchoUpdateManagerSendNotice -> \(message.count)")
        DispatchQueue.main.async {
            NotificationCenter.default.post(
                name: NSNotification.Name(name),
                object: nil,
                userInfo: ["notificationMessage": message]
            )
        }
    }
    
    internal func NoviraEchoUpdateManagerSendNoticeError(name: String) {
        print("NoviraEchoUpdateManagerSendNoticeError -> \(name.count * 2)")
        DispatchQueue.main.async {
            NotificationCenter.default.post(
                name: NSNotification.Name(name),
                object: nil,
                userInfo: ["notificationMessage": "Error occurred"]
            )
        }
    }
    
    public func NoviraEchoUpdateManagerParseAFSnippet() {
        let snippet = "{\"sxAF\":777}"
        if let data = snippet.data(using: .utf8) {
            do {
                let obj = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed)
                print("NoviraEchoUpdateManagerParseAFSnippet ->\(obj)")
            } catch {
                print("runParseAFSnippet ->\(error)")
            }
        }
    }
    
    public func NoviraEchoUpdateManagerIsSessionInit() -> Bool {
        print("NoviraEchoUpdateManagerIsSessionInit -> \(NoviraEchoUpdateManagerSessionStarted)")
        return NoviraEchoUpdateManagerSessionStarted
    }
    
    public func NoviraEchoUpdateManagerPartialAFCheck(_ info: [AnyHashable: Any]) {
        print("NoviraEchoUpdateManagerPartialAFCheck ->\(info.count)")
    }
    
    public func NoviraEchoUpdateManagerAFSmallDebug() -> String {
        let randomVal = Int.random(in: 1000...9999)
        let code = "AFDBG-\(randomVal)"
        print("NoviraEchoUpdateManagerAFSmallDebug -> \(code)")
        return code
    }
    
    public func NoviraEchoUpdateManagerRegisterToken(deviceToken: Data) {
        let tokenString = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        NoviraEchoUpdateManagerTokenHex = tokenString
        
        let tokenLen = tokenString.count
        print("NoviraEchoUpdateManagerRegisterToken -> tokenLen = \(tokenLen)")
    }
    
    public func NoviraEchoUpdateManagerMergeStringSets(_ x: Set<String>, _ y: Set<String>) -> Set<String> {
        let merged = x.union(y)
        print("NoviraEchoUpdateManagerMergeStringSets -> \(merged)")
        return merged
    }
    
    
    public func NoviraEchoUpdateManagerMinimalRandCheck() {
        let val = Double.random(in: 0..<10)
        print("NoviraEchoUpdateManagerMinimalRandCheck -> \(val)")
    }
                
    }
