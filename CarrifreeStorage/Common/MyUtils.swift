//
//  File.swift
//  Carrifree
//
//  Created by orca on 2020/10/11.
//  Copyright © 2020 plattics. All rights reserved.
//

//import Foundation
import UIKit
import MapKit
import SafariServices
import CoreLocation
//import CryptoSwift
import CryptoKit
import EventKit

var _utils: MyUtils = {
    return MyUtils.shared
}()

class MyUtils: NSObject {
    
    class AlertHandler {
        typealias ParamAlertController = ((UIAlertController) -> Void)?
        var title: String = ""
        var titleColor: UIColor = .systemBlue
        var handler: ParamAlertController = nil
        
        init(title: String, titleColor: UIColor = UIColor.systemBlue, handler: ParamAlertController = nil) {
            self.title = title
            self.titleColor = titleColor
            self.handler = handler
        }
    }
    
    static let shared: MyUtils = MyUtils()
    
    let symbolColor = UIColor(red: 233/255, green: 122/255, blue: 73/255, alpha: 1)
    let symbolColorSemi = UIColor(red: 255/255, green: 132/255, blue: 43/255, alpha: 1)
    let symbolColorSoft = UIColor(red: 255/255, green: 172/255, blue: 112/255, alpha: 1)
    
    var locationManager: CLLocationManager! = nil
    var currentAddress = ""
    
    var animatedObject: UIView! = nil
    var animatedObjectOriginalPos: CGPoint = CGPoint.zero
    var animatedConstraint: NSLayoutConstraint! = nil
    var animatedContraintOriginalConstant: CGFloat = 0
    
    var indicator: UIActivityIndicatorView! = nil
    
    var toast: ToastMessage
    var eventStore: EKEventStore
    
    private override init() {
        eventStore = EKEventStore()
        toast = ToastMessage(side: .top, message: "")
    }
    
    // 홈버튼 존재 여부
    var existHomeButton: Bool {
        if #available(iOS 11.0, *), let keyWindow = appKeyWindow, keyWindow.safeAreaInsets.bottom > 0 {
            return false
        }
        return true
    }
    
    // keywindow
    var appKeyWindow: UIWindow? {
        UIApplication.shared.windows.filter {$0.isKeyWindow}.first
    }
    
    var currentLocail: Locale {
        let locale = Locale(identifier: NSLocale.preferredLanguages[0])
        return locale
    }
    
    // MARK: Remove Delimiter From String
    func removeDelimiter(str: String?) -> String {
        guard var string = str else { return str ?? "" }
        string.removeAll(where: { $0 == "," })
        return string
    }
    
    // MARK: Get Delimiter String
    func getDelimiter(str: String?) -> String {
        guard var string = str else { return str ?? "" }
        
        string.removeAll(where: { $0 == "," })
        let int = Int(string) ?? 0
        return int.delimiter
    }
    
    // MARK: Get Number From Delimiter
    func getIntFromDelimiter(str: String?) -> Int {
        guard var string = str else { return 0 }
        
        string.removeAll(where: { $0 == "," })
        let value = Int(string) ?? 0
        return value
    }
    
    func getFloatFromDelimiter(str: String?) -> Float {
        guard var string = str else { return 0 }
        
        string.removeAll(where: { $0 == "," })
        let value = Float(string) ?? 0
        return value
    }
    
    func getStringFromDelemiter(str: String?) -> String {
        guard var string = str else { return "" }
        
        string.removeAll(where: { $0 == "," })
        return string
    }
    
    // MARK: Draw dotted line
    func drawDottedLine(start p0: CGPoint, end p1: CGPoint, view: UIView) {
        let shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = UIColor.systemGray4.cgColor
        shapeLayer.lineWidth = 1
        shapeLayer.lineDashPattern = [4, 2] // 4 is the length of dash, 2 is length of the gap.
        
        let path = CGMutablePath()
        path.addLines(between: [p0, p1])
        shapeLayer.path = path
        view.layer.addSublayer(shapeLayer)
    }
    
    // MARK: - Alert
    // Alert 생성
    func createAlert(title: String = "", message: String = "", handlers: [AlertHandler], style: UIAlertController.Style, addCancel: Bool = true) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: style)
        alert.title = title.isEmpty ? nil : title
        alert.message = message.isEmpty ? nil : message
        
        for item in handlers {
            let action = UIAlertAction(title: item.title, style: .default, handler: { _ in item.handler?(alert) })
            action.setValue(item.titleColor, forKey: "titleTextColor")
            alert.addAction(action)
        }
        
        if addCancel {
            let cancel = UIAlertAction(title: _strings[.cancel], style: .cancel, handler: nil)
            alert.addAction(cancel)
        }

        return alert
    }
    
    // AlertAction 생성
    func createAlertAction(title: String, titleColor: UIColor = UIColor.systemBlue, handler: ((UIAlertController) -> Void)? = nil) -> AlertHandler {
        let action = AlertHandler(title: title, titleColor: titleColor, handler: handler)
        return action
    }
    
    // 간단한 Alert 생성 (버튼 1개만 있는)
    func createSimpleAlert(title: String, message: String, buttonTitle: String, handler: ((UIAlertController) -> Void)? = nil)  -> UIAlertController {
        let action = createAlertAction(title: buttonTitle, handler: handler)
        let alert = createAlert(title: title, message: message, handlers: [action], style: .alert, addCancel: false)
        return alert
    }
    
    
    // 토스트 메시지 생성
    func createToast(message: String, parent: UIView) {
        if nil == parent.viewWithTag(ToastMessage.toastTag) {
            toast.removeFromSuperview()
            parent.addSubview(toast)
        }
        toast.appear(message: message)
    }
    
    // MARK: - 설정 화면으로 이동
    func goToSettingsCarrifree() {
        // 캐리프리앱 설정 화면으로 이동
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        if UIApplication.shared.canOpenURL(url) { UIApplication.shared.open(url) }
    }
    
    // MARK: - Top ViewController
    func topViewController() -> UIViewController? {
        return UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.rootViewController?.topMostViewController()
    }
    
    func getCurrentAddress() {
        if locationManager == nil {
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestWhenInUseAuthorization()
        }
        
        locationManager.startUpdatingLocation()
    }
    
    // MARK: - 주소 parsing
    func parseAddress(pin: MKPlacemark, nameInclude: Bool = false) -> String {
        var name = ""
        if nameInclude {
            name = pin.name ?? ""
            if false == name.isEmpty {
                name = "  (\(name))"
            }
        }
        
        let admin = pin.administrativeArea ?? ""
        let locality = pin.locality ?? ""
        let thoroughfare = pin.thoroughfare ?? ""
        let subThoroughfare = pin.subThoroughfare ?? ""
        let countryCode = pin.countryCode ?? ""
        
        var address = ""
        if countryCode == "KR" {
            address = "\(admin) \(locality) \(thoroughfare) \(subThoroughfare)\(name)"
        } else {
            // US
            let firstSpace = (pin.subThoroughfare != nil &&  pin.thoroughfare != nil) ? " " : ""
            let comma = (pin.subThoroughfare != nil && pin.thoroughfare != nil) &&
                (pin.subAdministrativeArea != nil && pin.administrativeArea != nil) ? ", " : ""
            let secondSpace = (pin.subAdministrativeArea != nil && pin.administrativeArea != nil) ? ", " : ""
            address = String(format: "%@%@%@%@%@%@%@%@",
                                     subThoroughfare,
                                     firstSpace,
                                     thoroughfare,
                                     comma,
                                     locality,
                                     secondSpace,
                                     admin,
                                     name)
            
            // US 외의 다른 나라들은 그 나라의 주소 표기법에 따라 새로 구현해야함 ..
        }
        
        return address
    }
    
    /*
    func generateDeptFirstAddr(addr: String) -> String {
        switch(addr) {
        case "서울": return "서울특별시"
        case "대전", "인천", "부산", "광주", "울산", "대구":
            return "\(addr)광역시"
        case "경기", "제주", "강원": return "\(addr)도"
        case "충남": return "충청남도"
        case "충북": return "충청북도"
        case "경남": return "경상남도"
        case "전남": return "전라남도"
        case "전북": return "전라북도"
        case "경북": return "경상북도"
        default: return "Unknown"
        }
    }
    */
                             
    func presentSafari(presneingViewController vc: UIViewController, url urlString: String, animated: Bool, completion: (() -> Void)? = nil) {
        guard let url = URL(string: urlString) else { return }
        let safariViewController = SFSafariViewController(url: url)
        vc.present(safariViewController, animated: true, completion: completion)
    }
    
    
    // 터치한 위치에 있는 건물/가게의 이름을 가져오려고했는데 코드가 복잡하고
    // 결과가 해당주소의 모든 가게의 이름을 가져오기 때문에 그 가게들 중에서 선택하게 하는 UI작업을 해야함
    // 그래서 일단 보류..
    /*
    func getStoreNameByPlaceMark(pin: MKPlacemark) -> String {
        
        var storeName = ""
        let request = MKLocalSearch.Request()
        let pinStreetName = "\(pin.thoroughfare ?? "")\(pin.subThoroughfare ?? "")"
        request.naturalLanguageQuery = pin.locality
        request.region = map.region
        request.resultTypes = .pointOfInterest
        let search = MKLocalSearch(request: request)
        search.start { (response, error) in
            if error != nil {
                _log.log("local search error: \(error?.localizedDescription ?? "")")
                return
            } else if response?.mapItems.count == 0 {
                _log.log("no match result..")
                return
            } else {
//                self.dispatchSemaphore.signal()
                
                guard let mapItems = response?.mapItems else { return }
                for item in mapItems {
                    let itemStreetName = "\(item.placemark.thoroughfare ?? "")\(item.placemark.subThoroughfare ?? "")"
                    
                    if itemStreetName == pinStreetName {
                        _log.log("local search name: \(item.name ?? "")")
                        storeName = item.name ?? ""
                    }
                    
//                    _log.log("local search name: \(item.name ?? "")")
                }
            }
        }
        
//        dispatchSemaphore.wait()
        return storeName
    }
    */
    
    
    
    // 애니메이션 옵저버 등록
    func registerForKeyboardNotifications(animatedObject: UIView? = nil) {
        if animatedObject == nil {
            self.animatedObject = topViewController()?.view
        } else {
            self.animatedObject = animatedObject
        }
        
        animatedObjectOriginalPos = self.animatedObject.frame.origin
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(note:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(note:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    // 애니메이션 옵저버 등록 해제
    func unregisterForKeyboardNotifications() {
        animatedConstraint = nil
        animatedObject = nil
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    // 키보드 높이만큼 특정 view 위치 이동
    @objc func keyboardWillShow(note: NSNotification) {
        guard animatedObject != nil else { return }
        
        if let keyboardRect = (note.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let targetY = keyboardRect.minY - self.animatedObject.frame.height
            if self.animatedObject.frame.origin.y == targetY { return }
            
            UIView.animate(withDuration: 0.33, animations: { () -> Void in
                if (self.setConstraint(show: true, height: keyboardRect.height) == true) { return }
                self.animatedObject.frame.origin.y = targetY
            })
        }
    }

    // 키보드 사라질때 특정 view를 원래 위치로 이동
    @objc func keyboardWillHide(note: NSNotification) {
        guard animatedObject != nil else { return }
        
        UIView.animate(withDuration: 0.33, animations: { () -> Void in
            if (self.setConstraint(show: false) == true) { return }
            self.animatedObject.frame.origin = self.animatedObjectOriginalPos
        })
    }
    
    // constraint bottom이 있으면 그것의 간격을 늘림
    // (auto layout이 적용되어있으면 text 입력시 textField가 원위치로 돌아가기 때문에 view의 프레임을 바꾸지않고 constraint를 수정해야함)
    func setConstraint(show: Bool, height: CGFloat = 0) -> Bool {

        func setConstant() {
            if show {
                if animatedConstraint.constant == animatedContraintOriginalConstant { animatedConstraint.constant += height }
            } else {
                if animatedConstraint.constant != animatedContraintOriginalConstant { animatedConstraint.constant = self.animatedContraintOriginalConstant }
            }
        }
        
        if animatedConstraint != nil {
            setConstant()
            return true
        }
        
        for constraint in self.animatedObject.constraints {
            guard constraint.firstAttribute == .bottom else { continue }
            animatedConstraint = constraint
            animatedContraintOriginalConstant = constraint.constant
            setConstant()
            return true
        }

        return false
    }

    // return value 'Bool' = anable to create
    func createIndicator(alpha: CGFloat = 0.1) -> Bool {
        
        if indicator != nil && indicator.isAnimating { return false }
        
        guard let vc = topViewController() else { return false }
        
        indicator = UIActivityIndicatorView(frame: vc.view.bounds)
        indicator.style = .large
        indicator.color = .white
        indicator.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: alpha)
        indicator.hidesWhenStopped = true
        vc.view.addSubview(indicator)
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(50)) { vc.view.bringSubviewToFront(self.indicator) }
        indicator.startAnimating()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(60)) {
            self.indicator.stopAnimating()
        }
        
        return true
    }
    
    func removeIndicator() {
        if indicator == nil { return }
        indicator.stopAnimating()
    }
    
    
    func verticalImageCrop(img: UIImage) -> UIImage? {
        var newImg: UIImage? = nil
        
        let ratio = img.size.height / img.size.width
        if ratio > 1.8 {
            let minusValue = img.size.height * 0.1
            let cropRect = CGRect(x: 0, y: minusValue, width: img.size.width, height: img.size.height - (minusValue * 2))
            guard let cropImg = img.cgImage?.cropping(to: cropRect) else { return nil }
            newImg = UIImage(cgImage: cropImg)
        } else { newImg = img }
        
        return newImg
    }
    
    func getPrevMidnight() -> Date {
        let prevMidNight = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: Date())!
        return prevMidNight
    }
    
    func getNextMidnight() -> Date {
        let nextMidnight = Calendar.current.date(byAdding: .day, value: 1, to: getPrevMidnight())!
        return nextMidnight
    }
}

// MARK: - Custom Picker
extension MyUtils {
    func timePicker(show: Bool, dataSource: [String] = [], vc: UIViewController? = nil, delegate: ActionPickerViewDelegate? = nil) {
        var viewController = vc
        if viewController == nil { viewController = topViewController() }
        
        guard let screenRect = viewController?.view.frame else { return }
        var picker: ActionPickerView!
        
        // 이전에 생성된 ActionPickerView 사용
        if let existPicker = viewController?.view.viewWithTag(CarryTags.timePicker.rawValue) as? ActionPickerView {
            picker = existPicker
            if false == dataSource.isEmpty { picker.setData(dataSource: dataSource) }
        }
        // 이전에 생성된 ActionPickerView가 없으면 새로 생성함
        else {
            picker = ActionPickerView(frame: CGRect(x: 0, y: screenRect.height, width: screenRect.width, height: ActionPickerView.pickerHeight))
            
            // dataSource가 있으면 전달
            if dataSource.isEmpty { picker.configure() }
            else { picker.configure(dataSource: dataSource) }
            
            picker.tag = CarryTags.timePicker.rawValue
            viewController?.view.addSubview(picker)
        }
        picker.delegate = delegate
        
        var moveHeight = ActionPickerView.pickerHeight
        if false == existHomeButton { moveHeight += 20 }
        
        UIView.animate(withDuration: 0.33, animations: { () -> Void in
            if show {
                picker.frame.origin.y = screenRect.height - moveHeight
            } else {
                picker.frame.origin.y = screenRect.height
            }

        })
        
        if show { picker.show() }
        else { picker.hide() }
    }
    
    // MARK: - get gurrency string
    func getCurrencyString() -> String {
        var currencyString = Locale.current.currencySymbol!
        if Locale.current.languageCode == "ko" { currencyString = "원" }
        return currencyString
    }
    
    // MARK: - Request Url
    /// 서버 주소를 적용한 url 반환
    func getRequestUrl(body: String) -> String {
        var server: String = ""
        if releaseMode {
            server = _identifiers[.liveServer]
        } else {
            server = _identifiers[.devServer]
        }
        
        return "\(server)\(body)"
    }
    
    // MARK: - 나눔 폰트 적용
    func setText(bold: BoldCase, size: CGFloat, text: String, color: UIColor = _tungsten, lineSpacing: CGFloat = -1, label: UILabel) {
//        label.font = UIFont(name: bold.name, size: size)
//        label.text = text
//        label.textColor = color
        
        let paragraphStyle = NSMutableParagraphStyle()
        if lineSpacing >= 0 {
            paragraphStyle.lineSpacing = lineSpacing
        } else {
            paragraphStyle.lineSpacing = size * 0.5
        }
        let attributes: [NSAttributedString.Key : Any] = [
//            .font: UIFont(name: bold.name, size: size) ?? UIFont.systemFont(ofSize: size),
            .foregroundColor: color,
            .paragraphStyle: paragraphStyle
            ]
        
        label.attributedText = NSAttributedString(string: text, attributes: attributes)
        label.font = UIFont(name: bold.name, size: size)
        label.textColor = color
    }
    
    func setText(bold: BoldCase, size: CGFloat, text: String, placeHolder: String = "", color: UIColor = _tungsten, field: UITextField) {
        field.font = UIFont(name: bold.name, size: size)
        field.text = text
        field.textColor = color
        field.placeholder = placeHolder
    }
    
    func setText(bold: BoldCase, size: CGFloat, text: String, color: UIColor = _tungsten, textview: UITextView) {
//        textview.font = UIFont(name: bold.name, size: size)
//        textview.text = text
//        textview.textColor = color
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = size * 0.5
        let attributes: [NSAttributedString.Key : Any] = [
            .font: UIFont(name: bold.name, size: size) ?? UIFont.systemFont(ofSize: size),
            .foregroundColor: color,
            .paragraphStyle: paragraphStyle
            ]
        
        textview.attributedText = NSAttributedString(string: text, attributes: attributes)
        textview.textColor = color
    }
    
    func setText(bold: BoldCase, size: CGFloat, text: String, color: UIColor = _tungsten, button: UIButton) {
        button.titleLabel?.font = UIFont(name: bold.name, size: size)
        button.setTitle(text, for: .normal)
        button.setTitleColor(color, for: .normal)
    }
}

// MARK: - Version
extension MyUtils {
    
    // 업데이트 가능 여부 확인
    // iTunes Connect에 업로드 후 구현할 예정..
    // 내번들ID에 앱의 번들ID 입력 (iTunes Connect > 나의 앱 > 확인하고 싶은 앱 클릭 > 앱정보 > 일반정보 > 번들ID)
    // (출처: https://zeddios.tistory.com/372)
    func isUpdateAvailable() -> Bool {
        let version = getAppVersion()
        guard let url = URL(string: "http://itunes.apple.com/lookup?bundleId=내번들ID"),
              let data = try? Data(contentsOf: url),
              let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any],
              let results = json["results"] as? [[String: Any]],
              results.count > 0,
              let appStoreVersion = results[0]["version"] as? String
        else { return false }
        
        if !(version == appStoreVersion) { return true }
        
        return false
    }
    
    func getAppVersion() -> String {
        guard let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else { return "?" }
        return version
    }
    
    func getAppVersionInt() -> Int {
        guard let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else { return 0 }
        let versionStr = version.components(separatedBy: ["."]).joined()
        let versionInt = Int(versionStr) ?? 0
        return versionInt
    }
    
    func getAppVersionInt(version: String) -> Int {
        let versionStr = version.components(separatedBy: ["."]).joined()
        let versionInt = Int(versionStr) ?? 0
        return versionInt
    }
    
    func openAppStore(urlStr: String) {
        guard let url = URL(string: urlStr) else {
            _log.log("invalid app store url")
            return
        }
        
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            _log.log("can't open app store url")
        }
    }
    
    func getServerInfo() -> String {
        var server: String = ""
        if releaseMode {
            server = "live"
        } else {
            server = "dev"
        }
        
        return server
    }
    
    func getAppType() -> String {
        let type = "storage(\(CarrifreeAppType.appStorage.rawValue))"
        return type
    }
    
    func getAppInfo() -> String {
        let appInfo = "\(getServerInfo()) \(getAppType()) v\(getAppVersion())"
        return appInfo
    }
}

// MARK: - crypt

extension MyUtils {
    // encode to MD5
    func encodeToMD5(pw: String) -> String {
        let digest = Insecure.MD5.hash(data: pw.data(using: .utf8) ?? Data())
        return digest.map {
            String(format: "%02hhx", $0)
        }.joined()
    }
    
    /*
    func encrypt(string: String) -> String {
        guard !string.isEmpty else { return "" }
//        return try! getAESObject().encrypt(string.bytes).toBase64()
        
        var encode: [UInt8] = []
        do {
            try encode = getAESObject().encrypt(string.bytes)
        } catch {
            encode = Array(string.utf8)
        }
        
        return encode.toBase64()
    }
    
    func decrypt(encoded: String) -> String {
        let datas = Data(base64Encoded: encoded)
        
        guard datas != nil else {
            return ""
        }
        
        let bytes = datas!.bytes
        var decode: [UInt8] = []
        do {
            try decode = getAESObject().decrypt(bytes)
        } catch {
            decode = Array(encoded.utf8)
        }
        
        let decoded = String(bytes: decode, encoding: .utf8) ?? ""
        return decoded
    }
    
    func getAESObject() -> AES {
        let key: Array<UInt8> = Array("01234567890123450123456789012345".utf8)
        let iv = Array("0123456789012345".utf8)
        let aesObject = try! AES(key: key, blockMode: CBC(iv: iv), padding: .pkcs5)
        return aesObject
    }
     */
}

// MARK: - Get Date from String {
extension MyUtils {
    func getDateFromString(dateString: String, dateFormat: String) -> Date {
        let dateFormatter = DateFormatter()

        dateFormatter.dateFormat = dateFormat
        dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone?

        let date = dateFormatter.date(from: dateString)!
        return date
    }
}


// MARK: - Input Display View
/// UITextField 터치시 입력 UI를 강조해서 보여주는 view
extension MyUtils {
    func registerInputDisplayView(parent: UIView?, textField: UITextField, title: String) {
        let parentView = getParent(parent: parent)
        if let inputDisplayView = parentView.viewWithTag(CarryTags.inputDisplay.rawValue) as? InputDisplayView {
            inputDisplayView.addTextField(textField: textField, title: title)
        } else {
            createInputDisplayView(parent: parent, textField: textField, title: title)
            controlInputDisplayView(parent: parent, hidden: true)
        }
        
    }
    
    func getParent(parent: UIView?) -> UIView {
        var parentView: UIView!
        
        if parent == nil {
            parentView = topViewController()?.view!
        } else {
            parentView = parent
        }
        
        return parentView
    }
    
    func controlInputDisplayView(parent: UIView?, hidden: Bool) {
        let parentView = getParent(parent: parent)
        parentView.viewWithTag(CarryTags.inputDisplay.rawValue)?.isHidden = hidden
    }
    
    func createInputDisplayView(parent: UIView?, textField: UITextField, title: String) {
        let parentView = getParent(parent: parent)
        
        var y: CGFloat = 0
        if let bar = topViewController()?.navigationController?.navigationBar, parent == nil {
            y = bar.frame.maxY
        }
        
        let inputDisplayView = InputDisplayView(frame: CGRect(x: 0, y: y, width: parentView.frame.width, height: parentView.frame.height))
        inputDisplayView.configure(textField: textField, title: title)
        parentView.addSubview(inputDisplayView)
        inputDisplayView.tag = CarryTags.inputDisplay.rawValue
    }
    
    func removeInputDisPlayView(parent: UIView?) {
        let parentView = getParent(parent: parent)
        parentView.viewWithTag(CarryTags.inputDisplay.rawValue)?.removeFromSuperview()
    }
}

// MARK:- Get Holidays
extension MyUtils {
    func getHolidays(completion: (([(String, String)]) -> Void)? = nil) {
        
        eventStore.requestAccess(to: EKEntityType.event, completion: {
            (accessGranted: Bool, error: Error?) in

            if accessGranted == true {
                DispatchQueue.main.async(execute: {
                    let events = self.getAllEvents()
                    let holidays = self.getHolidays(events: events)
                    completion?(holidays)
                    
                })
            } else {

            }
        })
    }
    
    private func getAllEvents() -> [EKEvent] {
        let caledar = NSCalendar.current
        let oneDayAgoComponents = NSDateComponents.init()
        oneDayAgoComponents.day = -1
        let oneDayAgo = caledar.date(byAdding: oneDayAgoComponents as DateComponents, to: Date(), wrappingComponents: true)

        let oneYearFromNowComponents = NSDateComponents.init()
        oneYearFromNowComponents.year = 1
        let oneYearFromNow = caledar.date(byAdding: oneYearFromNowComponents as DateComponents, to: Date(), wrappingComponents: true)

        let store = EKEventStore.init()
        let predicate = store.predicateForEvents(withStart: oneDayAgo!, end: oneYearFromNow!, calendars: nil)
        let events = store.events(matching: predicate)
        
        return events
    }
    
    private func getHolidays(events: [EKEvent]) -> [(String, String)] {
        var holidays: [(String, String)] = []
        for event in events {
            if event.calendar.allowsContentModifications { continue }
            let dateStr = event.endDate.toString().split(separator: " ").map { (value) -> String in
                return String(value)
            }
            
            holidays.append((event.title ?? "", dateStr[0]))
//            _log.log("\(event.title ?? ""): \(dateStr[0])")
        }
        
        return holidays
    }
}


// MARK:- CLLocationManagerDelegate
extension MyUtils: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let resultLocation = manager.location else { return }
        
        CLGeocoder().reverseGeocodeLocation(resultLocation, completionHandler: { (placemarks, error)->Void in
                if error != nil {
                    _log.logWithArrow("Reverse geocoder failed", error?.localizedDescription ?? "")
                    return
                }
                guard let placemarks = placemarks else { return }
                if placemarks.count > 0 {
                    let clPlaceMark = placemarks[0] as CLPlacemark
                    let mkPlaceMark = MKPlacemark(placemark: clPlaceMark)
                    let address = self.parseAddress(pin: mkPlaceMark)
//                    _log.logWithArrow("location", address)
                    self.currentAddress = address
                    _events.callCurrentLocation(address: address)
                } else {
                    _log.log("Problem with the data received from geocoder")
                }
            })
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        _log.logWithArrow("get location failed", error.localizedDescription)
    }
    
    func regularExp(form: String, content: String) -> [String] {
        let nsContent = content as NSString
        let regex = try? NSRegularExpression(pattern: form, options: .caseInsensitive)
        let opResult = regex?.matches(in: content, options: [], range: NSRange(location: 0, length: nsContent.length)).map { nsContent.substring(with: $0.range) }
        
        guard let result = opResult else { return [] }
        return result
    }
}

// MARK:- Get 'Image Data' From URL
extension MyUtils {
    func getImageFromUrl(url: String) -> Data? {
        var data: Data? = nil
        
        if url.isEmpty == false {
            let url = URL(string: url)!
            
            do { data = try Data(contentsOf: url) }
            catch { _log.log("Delivery oper img download failed..") }
        }
        return data
    }
    
}

// MARK:- Move Scene From TopViewController
extension MyUtils {
    func moveScene(storyboardId: String, push: Bool, fullScreen: Bool = true) {
        guard let topVc = topViewController() else { _log.log("not found top view controller"); return }
        guard let destination = topVc.storyboard?.instantiateViewController(withIdentifier: storyboardId) else { _log.log("not found [\(storyboardId)] controller"); return }
        
        if push {
            guard let topNavi = topVc.navigationController else { _log.log("not found top navigation controller"); return }
            topNavi.pushViewController(destination, animated: true)
        } else {
            if fullScreen { destination.modalPresentationStyle = .fullScreen }
            else { destination.modalPresentationStyle = .pageSheet }
            
            topVc.present(destination, animated: true, completion: nil)
        }
    }
}








// MARK:- Get device name
// (출처 - https://khstar.tistory.com/entry/Swift-Device-Model-%EC%9D%B4%EB%A6%84-%EA%B0%80%EC%A0%B8%EC%98%A4%EA%B8%B0)
extension MyUtils {
    //Identifier 찾기
    func getDeviceIdentifier() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return identifier
    }

    // 디바이스 모델 (iPhone, iPad) 이름 전달 (iPhone6, iPhone7 Plus...)
    func deviceModelName() -> String {
        let model = UIDevice.current.model
        switch model {
        
        case "iPhone":
            
            return self.iPhoneModel()
            
        case "iPad":
            
            return self.iPadModel()
            
        case "iPad_mini" :
            
            return self.iPadMiniModel()
            
        default:
            
            return "Unknown_Model_\(model)"
        }
    }
    
    // iPhone 모델 이름 (iPhone6, iPhone7 Plus...)
    func iPhoneModel() -> String {
        let identifier = self.getDeviceIdentifier()
        switch identifier {
        
        case "iPhone1,1" :
            
            return "iPhone"
            
        case "iPhone1,2" :
            
            return "iPhone3G"
            
        case "iPhone2,1" :
            
            return "iPhone3GS"
            
        case "iPhone3,1", "iPhone3,2", "iPhone3,3" :
            
            return "iPhone4"
            
        case "iPhone4,1" :
            
            return "iPhone4s"
            
        case "iPhone5,1", "iPhone5,2" :
            
            return "iPhone5"
            
        case "iPhone5,3", "iPhone5,4" :
            
            return "iPhone5c"
            
        case "iPhone6,1", "iPhone6,2" :
            
            return "iPhone5s"
            
        case "iPhone7,2" :
            
            return "iPhone6"
            
        case "iPhone7,1" :
            
            return "iPhone6_Plus"
            
        case "iPhone8,1" :
            
            return "iPhone6s"
            
        case "iPhone8,2" :
            
            return "iPhone6s_Plus"
            
        case "iPhone8,4" :
            
            return "iPhone SE"
            
        case "iPhone9,1", "iPhone9,3" :
            
            return "iPhone7"
            
        case "iPhone9,2", "iPhone9,4" :
            
            return "iPhone7_Plus"
            
        case "iPhone10,1", "iPhone10,4" :
            
            return "iPhone8"
            
        case "iPhone10,2", "iPhone10,5" :
            
            return "iPhone8_Plus"
            
        case "iPhone10,3", "iPhone10,6" :
            
            return "iPhoneX"
            
        default:
            return "Unknown_iPhone_\(identifier)"
        }
    }
    
    // iPad 모델 이름
    func iPadModel() -> String {
        let identifier = self.getDeviceIdentifier()
        switch identifier {
        
        case "iPad1,1":
            
            return "iPad"
            
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4" :
            
            return "iPad2"
            
        case "iPad3,1", "iPad3,2", "iPad3,3" :
            
            return "iPad 3rd Generation"
            
        case "iPad3,4", "iPad3,5", "iPad3,6" :
            
            return "iPad_4rd_Generation"
            
        case "iPad4,1", "iPad4,2", "iPad4,3" :
            
            return "iPad_Air"
            
        case "iPad5,3", "iPad5,4" :
            
            return "iPad_Air2"
            
        case "iPad6,7", "iPad6,8" :
            
            return "iPad_Pro_12.9"
            
        case "iPad6,3", "iPad6,4" :
            
            return "iPad_Pro_9.7"
            
        case "iPad6,11", "iPad6,12" :
            
            return "iPad_5th_Generation"
            
        case "iPad7,1", "iPad7,2" :
            
            return "iPad_Pro_12.9_2nd_Generation"
            
        case "iPad7,3", "iPad7,4" :
            
            return "iPad_Pro_10.5"
            
        case "iPad7,5", "iPad7,6" :
            
            return "iPad_6th_Generation"
            
        default:
            
            return "Unknown_iPad_\(identifier)"
        }
        
    }
    
    // iPad mini 모델 이름
    func iPadMiniModel() -> String {
        let identifier = self.getDeviceIdentifier()
        
        switch identifier {
        case "iPad2,5", "iPad2,6", "iPad2,7" :
            
            return "iPad_mini"
            
        case "iPad4,4", "iPad4,5", "iPad4,6" :
            
            return "iPad_mini2"
            
        case "iPad4,7", "iPad4,8", "iPad4,9" :
            
            return "iPad_mini3"
            
        case "iPad5,1", "iPad5,2" :
            
            return "iPad_mini4"
            
        default:
            
            return "Unknown_iPad_mini_\(identifier)"
            
        }
    }
}

// MARK:- Test
extension MyUtils {
    func test01() {
        let date = Date()
        let nextDayStartTime = Calendar.current.nextDate(after: date, matching: DateComponents(hour: 10), matchingPolicy: .nextTime) ?? Date()           // 다음날 자정!!
        let nextDayEndTime = nextDayStartTime.addingTimeInterval(8 * 60 * 60)
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        
        let currentLocale = Locale(identifier: NSLocale.preferredLanguages[0])
        formatter.locale = currentLocale
        
        let startDateString = formatter.string(from: nextDayStartTime)
        _log.logWithArrow("start time", startDateString)
        
        let endDateString = formatter.string(from: nextDayEndTime)
        _log.logWithArrow("end time", endDateString)
    }
}
