//
//  IMPAuthController.swift
//  CarrifreeDriver
//
//  Created by orca on 2021/01/19.
//

import UIKit
import WebKit
import SwiftyJSON

@objc protocol ImpAuthControllerDelegate {
    @objc optional func complete(phone: String)
}

class ImpAuthController: UIViewController {
    
    @IBOutlet weak var screen: UIView!
    
    var delegate: ImpAuthControllerDelegate?
    var webView: WKWebView?
    var impUid: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        presentingViewController?.view.endEditing(true)
        
//        _ = _utils.createIndicator()
        
        // 브릿지 설정
        let contentController = WKUserContentController()
        contentController.add(self, name: "authSuccess")
        contentController.add(self, name: "authFail")

        let config = WKWebViewConfiguration()
        config.userContentController = contentController

        webView = WKWebView(frame: screen.frame, configuration: config)
        webView?.uiDelegate = self
        webView?.navigationDelegate = self
        screen.addSubview(webView!)
    }
    

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let url = Bundle.main.url(forResource: "IdentityVerification", withExtension: "html") {
            let urlRequest = URLRequest(url: url)
            webView?.load(urlRequest)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        delegate?.complete?(phone: _user.contact)
    }
    
    func requestToken() {
        ImpRequest.shared.requestToken(impKey: _identifiers[.iamportKey], impSecret: _identifiers[.iamportSecret]) { (success, msg) in
            if success {
                self.requestUserInfo(impUid: self.impUid, token: msg)
            } else {
                let alert = _utils.createSimpleAlert(title: "failed to get access_token", message: "", buttonTitle: _strings[.ok])
                self.present(alert, animated: true)
            }
        }
    }
    
    func requestUserInfo(impUid: String, token: String) {
        ImpRequest.shared.requestUserInfo(impUid: impUid, token: token) { (success, msg) in
            var title = ""
            if _user.contact.isEmpty {
                title = "\(_strings[.verificationFailed01])\n\(_strings[.plzTryAgain])"
            } else {
                title = _strings[.verificationSuccess01]
            }
            
            let ok = _utils.createAlertAction(title: _strings[.ok], handler: { (alertController) in
                if let navi = self.navigationController {
                    navi.popViewController(animated: true)
                } else {
                    self.presentingViewController?.dismiss(animated: true)
//                    self.dismiss(animated: true)
                }
            })
            let alert = _utils.createAlert(title: title, message: "", handlers: [ok], style: .alert, addCancel: false)
            self.present(alert, animated: true)
        }
    }
}

// MARK:- WKScriptMessageHandler, WKUIDelegate, WKNavigationDelegate
extension ImpAuthController: WKScriptMessageHandler, WKUIDelegate, WKNavigationDelegate {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "authSuccess" {
            // 인증 성공 시 처리할 로직
            if let bodyString = message.body as? String {
                if let dataFromString = bodyString.data(using: String.Encoding.utf8, allowLossyConversion: false) {
                    
                    let json = JSON(dataFromString)
                    if let impUid = json["imp_uid"].string {
                        self.impUid = impUid
                        let phone = json["phone"].stringValue
                        _log.logWithArrow("imp_uid", self.impUid)
                        _log.logWithArrow("phone", phone)
                        requestToken()
                    } else {
                        let alert = _utils.createSimpleAlert(title: "imp_uid is empty", message: "", buttonTitle: _strings[.ok])
                        self.present(alert, animated: true)
                    }
                    
                }
            }
//            _log.logWithArrow("iamport message body", json.debugDescription)
            
        } else if message.name == "authFail" {
          // 인증 취소, 실패 시 처리할 로직
            _log.logWithArrow("iamport auth failed/canceled", (message.body as? String) ?? "")
        }
    }
    
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Swift.Void) {
        let alertController = UIAlertController(title: message, message: nil, preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: _strings[.ok], style: .cancel) { _ in
            completionHandler()
        }
        
        alertController.addAction(cancelAction)
        
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
}
