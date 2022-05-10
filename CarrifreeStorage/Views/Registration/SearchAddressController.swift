//
//  SearchAddressController.swift
//  CarrifreeStorage
//
//  Created by plattics-kwon on 2021/01/06.
//

import UIKit
import WebKit
import CoreLocation

class SearchAddressController: UIViewController {

    var web: WKWebView?
    var indicator = UIActivityIndicatorView(style: .large)
    var address = ""
    var postalCode = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let contentController = WKUserContentController()
        contentController.add(self, name: "callBackHandler")
        
        let configuration = WKWebViewConfiguration()
        configuration.userContentController = contentController
        
        web = WKWebView(frame: .zero, configuration: configuration)
        web?.navigationDelegate = self
        
        if let url = URL(string: "https://kasroid.github.io/Kakao-Postcode/"), let web = web {
            let request = URLRequest(url: url)
            web.load(request)
            indicator.startAnimating()
            self.view.addSubview(web)
            web.translatesAutoresizingMaskIntoConstraints = false

            web.addSubview(indicator)
            indicator.translatesAutoresizingMaskIntoConstraints = false

            NSLayoutConstraint.activate([
                web.topAnchor.constraint(equalTo: view.topAnchor),
                web.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                web.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                web.bottomAnchor.constraint(equalTo: view.bottomAnchor),

                indicator.centerXAnchor.constraint(equalTo: web.centerXAnchor),
                indicator.centerYAnchor.constraint(equalTo: web.centerYAnchor),
            ])
        }
    }
}

// MARK:- WKScriptMessageHandler
extension SearchAddressController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
        if let data = message.body as? [String: Any] {
            address = data["roadAddress"] as? String ?? ""
            postalCode = data["zonecode"] as? String ?? ""
        }
        
        if address.isEmpty {
            let alert = _utils.createSimpleAlert(title: _strings[.alertRetryAddress], message: "", buttonTitle: _strings[.ok])
            self.present(alert, animated: true) {
                self.dismiss(animated: true)
            }
        } else {
//            CarryTemp.address = address
            
            let geoCoder = CLGeocoder()
            geoCoder.geocodeAddressString(address) { (placemarks, error) in
                guard let placemarks = placemarks, let location = placemarks.first?.location else {
                    let alert = _utils.createSimpleAlert(title: _strings[.alertNotFountLatLng], message: "", buttonTitle: _strings[.ok])
                    self.present(alert, animated: true)
                    return
                }
                
//                _user.lat = location.coordinate.latitude
//                _user.lng = location.coordinate.longitude
//                _log.logWithArrow("위도/경도", "\(CarryTemp.lat) / \(CarryTemp.lng)")
                
                // 김포공항 (37.55968585733824, 126.80322285941398)
                _events.callSelectAddress(address: self.address, postalCode: self.postalCode, lat: location.coordinate.latitude, lng: location.coordinate.longitude)
            }
            
            self.dismiss(animated: true)
        }
    }
}

// MARK:- WKNavigationDelegate
extension SearchAddressController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        indicator.startAnimating()
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        indicator.stopAnimating()
    }
}
