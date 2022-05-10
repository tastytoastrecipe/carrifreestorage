//
//  SceneDelegate.swift
//  CarrifreeStorage
//
//  Created by plattics-kwon on 2020/12/28.
//

import UIKit
import SwiftyIamport

//import KakaoSDKAuth
//import FBSDKCoreKit
//import NaverThirdPartyLogin

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    static var backFromImport: Bool = false
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        
        /*
        if let url = connectionOptions.urlContexts.first?.url {
            _ = checkCarrifreeDriverParameter(url: url)
        }
        */
        
        guard let _ = (scene as? UIWindowScene) else { return }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }

    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        
        /*
        guard let url = URLContexts.first?.url else { return }
        
        _log.logWithArrow("AppDelegate.application url scheme ", url.scheme ?? "")
        _log.logWithArrow("AppDelegate.application url query", url.query ?? "")
        
        if true == checkCarrifreeDriverParameter(url: url) { return }
        
        if (AuthApi.isKakaoTalkLoginUrl(url)) {
            // kakao sign-in setting
            _ = AuthController.handleOpenUrl(url: url)
        }
        else {
            // facebook sign-in setting
            let isFacebookLiginUrl = ApplicationDelegate.shared.application(UIApplication.shared, open: url, sourceApplication: nil, annotation: [UIApplication.OpenURLOptionsKey.annotation])
            
            if isFacebookLiginUrl == false {
                NaverThirdPartyLoginConnection.getSharedInstance()?.receiveAccessToken(url)
            }
        }
        */
    }
    
    /*
    func checkCarrifreeDriverParameter(url: URL) -> Bool {
        let host = url.host ?? ""
        let scheme = url.scheme ?? ""
        var pathComponent = url.pathComponents
        if pathComponent.count > 0 { _ = pathComponent.removeFirst() }
        let appScheme = _identifiers[.scheme].lowercased()
        if scheme == appScheme {
            CarryPush.shared.receiveNotification(route: host, param: pathComponent)
            CarryPush.shared.checkPush()
            return true
        }
        
        return false
    }
    */

}

