//
//  AppDelegate.swift
//  CarrifreeStorage
//
//  Created by plattics-kwon on 2020/12/28.
//

import UIKit
import Firebase
import FirebaseMessaging
import SwiftyIamport

//import KakaoSDKCommon
//import NaverThirdPartyLogin
//import FBSDKLoginKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        HTTPCookieStorage.shared.cookieAcceptPolicy = .always
        
        // firebase init
        FirebaseApp.configure()
        
        // fcm init
        CarryPush.shared.configure(application: application)
        
        /*
        // kakao init
        KakaoSDKCommon.initSDK(appKey: _identifiers[.keyKakaoAapp])
        
        // naver init
        let instance = NaverThirdPartyLoginConnection.getSharedInstance()
        instance?.isNaverAppOauthEnable = true              // 네이버 앱으로 인증하는 방식을 활성화
        instance?.isInAppOauthEnable = true                 // SafariViewController에서 인증하는 방식을 활성화
        instance?.isOnlyPortraitSupportedInIphone()         // 인증 화면을 iPhone의 세로 모드에서만 사용하기
        instance?.serviceUrlScheme = kServiceAppUrlScheme   // 애플리케이션을 등록할 때 입력한 URL Scheme
        instance?.consumerKey = kConsumerKey                // 애플리케이션 등록 후 발급받은 클라이언트 아이디
        instance?.consumerSecret = kConsumerSecret          // 애플리케이션 등록 후 발급받은 클라이언트 시크릿
        instance?.appName = kServiceAppName                 // 애플리케이션 이름
        */
        
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
          Messaging.messaging().apnsToken = deviceToken
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        if let scheme = url.scheme {
            if scheme.hasPrefix(IAMPortPay.sharedInstance.appScheme ?? "") {
                return IAMPortPay.sharedInstance.application(app, open: url, options: options)
            }
        }
        return true
    }

    // MARK:- UISceneSession Lifecycle
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

