//
//  NoviraEchoUpdateManager.swift
//  173NoviraEchoJournal
//
//  Created by Roman on 5/12/26.
//

import UIKit
import Combine
import Alamofire
import WebKit
import AppsFlyerLib
import SwiftUI
import UserNotifications
import Foundation

public class NoviraEchoUpdateManager: NSObject, @preconcurrency AppsFlyerLibDelegate {
    internal var lockRef: String = ""
    internal var appsRefKey: String = ""
    internal var tokenRef: String = ""
    internal var paramRef: String = ""
    
    @AppStorage("NoviraEchoUpdateManagerInitial") var NoviraEchoUpdateManagerInitial: String?
    @AppStorage("NoviraEchoUpdateManagerStatus")  var NoviraEchoUpdateManagerStatus: Bool = false
    @AppStorage("NoviraEchoUpdateManagerFinal")   var NoviraEchoUpdateManagerFinal: String?
    
    @MainActor public static let shared = NoviraEchoUpdateManager()
    
    internal var appIDRef: String = ""
    internal var langRef: String = ""
    internal var NoviraEchoUpdateManagerWindow: UIWindow?
    
    internal var NoviraEchoUpdateManagerSessionStarted = false
    internal var NoviraEchoUpdateManagerTokenHex = ""
    internal var NoviraEchoUpdateManagerSession: Session
    internal var NoviraEchoUpdateManagerCollector = Set<AnyCancellable>()
    
    private override init() {
        let cfg = URLSessionConfiguration.default
        cfg.timeoutIntervalForRequest = 20
        cfg.timeoutIntervalForResource = 20
        let debugRand = Int.random(in: 1...999)
        print("NoviraEchoUpdateManager init -> \(debugRand)")
        self.NoviraEchoUpdateManagerSession = Alamofire.Session(configuration: cfg)
        super.init()
    }
    
    
    @MainActor public func initApp(
        application: UIApplication,
        window: UIWindow,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        NoviraEchoUpdateManagerAskNotifications(app: application)
        
        let randomVal = Int.random(in: 10...99) + 3
        print("Run: \(randomVal)")
        
        appsRefKey = "appData"
        appIDRef   = "appId"
        langRef    = "appLng"
        tokenRef   = "appTk"
        
        lockRef  = "https://irjjnnajoo.lol/privacy"
        paramRef = "data"
        
        NoviraEchoUpdateManagerWindow = window
        
        NoviraEchoUpdateManagerSetupAppsFlyer(appID: "6768584230", devKey: "HvYoRdrjuKtutdbuzfoNfj")
        
        completion(.success("Initialization completed successfully"))
    }
    }
