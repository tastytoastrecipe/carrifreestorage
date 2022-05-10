//
//  RegistrationVc.swift
//  TestProject
//
//  Created by plattics-kwon on 2021/10/25.
//

import UIKit
import DropDown

protocol RegistrationVcDelegate {
    func registeredBiz()
    func registrationVcDeleted()
}

class RegistrationVc: UIViewController {
    
    @IBOutlet weak var vcTitle: UILabel!
    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var titleViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollview: UIScrollView!
    
    // name
    @IBOutlet weak var nameTitle: UILabel!
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var nameDesc: UILabel!
    @IBOutlet weak var nameMark: UIImageView!
    
    // contact
    @IBOutlet weak var contactStack: UIStackView!
    @IBOutlet weak var contactTitle: UILabel!
    @IBOutlet weak var contact: UITextField!
    @IBOutlet weak var contactRequest: UIButton!
    @IBOutlet weak var authView: UIView!
    @IBOutlet weak var authTimeLabel: UILabel!
    @IBOutlet weak var authBtn: UIButton!
    @IBOutlet weak var authField: UITextField!
    
    // address
    @IBOutlet weak var addressTitle: UILabel!
    @IBOutlet weak var addressCode: UITextField!
    @IBOutlet weak var addressSearch: UIButton!
    @IBOutlet weak var addressCodeLine: UIView!
    @IBOutlet weak var address: UITextField!
    @IBOutlet weak var addressDetail: UITextField!
    @IBOutlet weak var addressDetailLine: UIView!
    
    // license
    @IBOutlet weak var licenseTitle: UILabel!
    @IBOutlet weak var licenseNo: UITextField!
    @IBOutlet weak var licenseStatus: UILabel!
    @IBOutlet weak var licenseMark: UIImageView!
    
    // bank
    @IBOutlet weak var bankTitle: UILabel!
    @IBOutlet weak var bankName: UITextField!
    @IBOutlet weak var bankAccount: UITextField!
    @IBOutlet weak var bankMark: UIImageView!
    
    // pictures
    @IBOutlet weak var pictureTitle: UILabel!
    @IBOutlet weak var cert: RegPicture!
    @IBOutlet weak var bankbook: RegPicture!
    
    // notice
    @IBOutlet weak var noticeBoard: UIView!
    @IBOutlet weak var noticeTitle: UILabel!
    @IBOutlet weak var notice: UILabel!
    @IBOutlet weak var noticeDesc: UILabel!
    
    // request
    @IBOutlet weak var request: UIButton!
    
    let validColor: UIColor = UIColor(red: 152/255, green: 196/255, blue: 85/255, alpha: 1)
    
    var vm: RegistrationVm!
    var bankMenu: DropDown!
    
    let authMaxTime: Double = 180.0     // sec (인증 번호 입력 유효 시간)
    var authDelay: Double = 1.1         // sec (딜레이)
    var authTime: Double = 0.0          // sec (현재 까지 진행된 시간)
    var authTimer: Timer? = nil
    
    var delegate: RegistrationVcDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        
        vm = RegistrationVm(delegate: self)
    }
    
    func configure() {
        if let _ =  self.navigationController {
            titleView.isHidden = true
            titleViewHeightConstraint.constant = 10
            self.navigationItem.title = _strings[.writeBizInfo]
            self.navigationController?.navigationBar.tintColor = UIColor(red: 242/255, green: 123/255, blue: 87/255, alpha: 1)
        } else {
            vcTitle.text = _strings[.writeBizInfo]
            vcTitle.font = UIFont(name: "NanumSquareB", size: 17)
        }
        
        _events.appendDelegate(delegate: self)
        
        initName()
        initContact()
        initAddress()
        initLicense()
        initBank()
        initPictures()
        initNotice()
        initRequest()
    }
    
    // initialize name
    func initName() {
        nameTitle.text = _strings[.alertEnterBizName]
        nameTitle.font = titleFont
        
        name.placeholder = _strings[.writeName]
        name.font = fieldFont
        name.displayAccessory = true
        
        nameDesc.text = _strings[.nameWarning]
        nameDesc.font = descFont01
        
        nameMark.isHidden = true
    }
    
    // initialize contact
    func initContact() {
        contactTitle.text = _strings[.alertEnterPhone]
        contactTitle.font = titleFont
        
        contact.placeholder = _strings[.contactOption]
        contact.font = fieldFont
        contact.displayAccessory = true
//        contact.delegate = self
        contact.addTarget(self, action: #selector(self.contactEditingChanged), for: .editingChanged)
        
        contactRequest.setTitle(_strings[.requestAuth], for: .normal)
        contactRequest.titleLabel?.font = fieldFont
        contactRequest.layer.cornerRadius = contactRequest.frame.height / 2
        contactRequest.layer.borderWidth = 1
        contactRequest.layer.borderColor = UIColor.systemGray.cgColor
        contactRequest.addTarget(self, action: #selector(self.onRequestAuthCode(_:)), for: .touchUpInside)
        
        authField.placeholder = _strings[.authNo]
        authField.font = fieldFont
        authField.displayAccessory = true
        
        authBtn.setTitle(_strings[.checkAuth], for: .normal)
        authBtn.layer.cornerRadius = contactRequest.frame.height / 2
        authBtn.layer.borderWidth = 1
        authBtn.layer.borderColor = UIColor.systemGray.cgColor
        authBtn.addTarget(self, action: #selector(self.onAuth(_:)), for: .touchUpInside)
        
        authTimeLabel.text = "\(authTime)"
        authTimeLabel.font = fieldFont
        
//        authView.removeFromSuperview()
        authView.isHidden = true
    }
    
    // initialize address
    func initAddress() {
        addressTitle.text = _strings[.alertEnterBizAddress]
        addressTitle.font = titleFont
        
        addressCode.placeholder = _strings[.postalCode]
        addressCode.font = fieldFont
        addressCode.displayAccessory = true
        addressCode.delegate = self
        
        addressSearch.setTitle(_strings[.findPostalCode], for: .normal)
        addressSearch.titleLabel?.font = fieldFont
        addressSearch.layer.cornerRadius = contactRequest.frame.height / 2
        addressSearch.layer.borderWidth = 1
        addressSearch.layer.borderColor = UIColor.systemGray.cgColor
        addressSearch.addTarget(self, action: #selector(self.onAddr(_:)), for: .touchUpInside)
        
        addressCodeLine.backgroundColor = .clear
        drawDottedLine(start: CGPoint(x: 0, y: 0), end: CGPoint(x: addressCodeLine.frame.maxX, y: 0), view: addressCodeLine)
        
        address.placeholder = _strings[.bizAddress]
        address.font = fieldFont
        address.displayAccessory = true
//        address.delegate = self
        
        addressDetail.placeholder = _strings[.alertEnterAddressDetail]
        addressDetail.font = fieldFont
        addressDetail.displayAccessory = true
        
        addressDetailLine.backgroundColor = .clear
        drawDottedLine(start: CGPoint(x: 0, y: 0), end: CGPoint(x: addressCodeLine.frame.maxX, y: 0), view: addressDetailLine)
    }
    
    // initialize license
    func initLicense() {
        
        licenseTitle.text = _strings[.alertEnterBizNo]
        licenseTitle.font = titleFont
        
        licenseNo.placeholder = _strings[.contactOption]
        licenseNo.font = fieldFont
        licenseNo.displayAccessory = true
        licenseNo.addTarget(self, action: #selector(self.licenseEditingChanged), for: .editingChanged)
        
        licenseStatus.text = ""
        licenseStatus.font = descFont01
        licenseStatus.textColor = .systemRed
    }
    
    // initialize bank
    func initBank() {
        bankTitle.text = _strings[.alertEnterBankAccount]
        bankTitle.font = titleFont
        
        bankName.placeholder = _strings[.bank]
        bankName.delegate = self
        bankName.font = fieldFont
        
//        var dataSource: [String] = []
//        for data in vm.bankDataSource {
//            dataSource.append(data.name)
//        }
        bankMenu = DropDown()
//        bankMenu.dataSource = dataSource
        bankMenu.anchorView = bankName
        bankMenu.bottomOffset = CGPoint(x: 0, y: bankName.frame.height)
        bankMenu.selectionAction = self.onBankSelect(index:item:)
        
        bankAccount.placeholder = _strings[.bankAccountDesc]
        bankAccount.font = fieldFont
        bankAccount.displayAccessory = true
        
        bankMark.isHidden = true
    }
    
    // initialize pictures
    func initPictures() {
        pictureTitle.text = _strings[.needFile]
        
        // https://img.khan.co.kr/news/2008/06/17/0617_99.webp
        cert.configure(title: _strings[.addBizLicense], desc: _strings[.addBizLicenseDesc], emptyImgName: "doc.text", imgUrl: "", seq: "")
        cert.delegate = self
        bankbook.configure(title: _strings[.addBankbook], desc: _strings[.addBankbookDesc], emptyImgName: "note.text", imgUrl: "", seq: "")
        bankbook.delegate = self
    }
    
    // initialize notice
    func initNotice() {
        noticeTitle.text = _strings[.beforeRegistration]
        notice.text = _strings[.beforeRegistrationDesc]
        notice.numberOfLines = 0
        noticeDesc.text = _strings[.registrationWating]
    }
    
    // initialize request
    func initRequest() {
        request.setTitle(_strings[.requestRegistration], for: .normal)
        request.titleLabel?.font = UIFont(name: "NanumSquareB", size: 18)
        request.addTarget(self, action: #selector(self.onRequest(_:)), for: .touchUpInside)
    }
    
    // draw dotted line
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
    
    func refresh() {
        name.text = vm.name
        contact.text = vm.contact
        updateAuthStatus(authDone: !vm.contact.isEmpty)
        address.text = vm.addr
        addressDetail.text = vm.addrDetail
        addressCode.text = vm.addrCode
        licenseNo.text = vm.licenseNo
        bankName.text = vm.bankName
        bankAccount.text = vm.bankAccount
        
        var dataSource: [String] = []
        for data in vm.bankDataSource {
            dataSource.append(data.name)
        }
        
        bankMenu.dataSource = dataSource
        
        let selectedIndex = vm.getSelectedBankIndex(bankName: vm.bankName)
        bankMenu.selectRow(selectedIndex)
        
        let certRegistered = !vm.licensePicUrl.isEmpty
        let bankbookRegistered = !vm.bankbookPicUrl.isEmpty
        cert.setImage(url: vm.licensePicUrl, registered: certRegistered, seq: vm.licensePicSeq)
        bankbook.setImage(url: vm.bankbookPicUrl, registered: bankbookRegistered, seq: vm.bankbookPicSeq)
        
        if _user.approval == .approved {
            noticeBoard?.removeFromSuperview()
            request.setTitle(_strings[.changeBizInfo], for: .normal)
        }
    }
    
    // MARK: 유효성 검사 후 보관파트너 신청
    func validateAndRequest() {
        
        let name = getText(name)
        if name.isEmpty {                                   // 이름이 비어있음
            createSimpleAlert(title: _strings[.requestFailed], msg: _strings[.alertNeedName])
            _log.log("이름 비어있음")
            return
        }
        
        let licenseNo = getText(licenseNo)
        if licenseNo.isEmpty {                              // 사업자 등록번호 비어있음
            createSimpleAlert(title: _strings[.requestFailed], msg: _strings[.alertEnterBizNo])
            _log.log("사업자 번호 비어있음")
            return
        }
        
        if licenseNo != vm.validLicenseNo {                 // 유효하지 않은 사업자 번호
            createSimpleAlert(title: _strings[.requestFailed], msg: _strings[.alertInvalidLicenseNo])
            _log.log("유효하지않은 사업자 번호!")
            return
        }
        
        let contact = getText(contact)
        if contact.isEmpty {                                // 연락처 비어있음
            createSimpleAlert(title: _strings[.requestFailed], msg: _strings[.alertEnterPhone])
            _log.log("연락처 비어있음")
            return
        }
        
        if contact != vm.validContact {                     // 연락처 인증 안됨
            createSimpleAlert(title: _strings[.requestFailed], msg: _strings[.alertNeedContactAuth])
            _log.log("연락처 인증 안됨")
            return
        }
        
        let address = getText(address)
        let addressDetail = getText(addressDetail)
        let addressCode = getText(addressCode)
        if address.isEmpty ||
           addressCode.isEmpty ||
           addressDetail.isEmpty {                          // 주소 비어있음
            createSimpleAlert(title: _strings[.requestFailed], msg: _strings[.alertEnterBizAddress])
            _log.log("주소 비어있음")
            return
        }
            
        let bankAccount = getText(bankAccount)
        if getText(bankName).isEmpty ||
           bankAccount.isEmpty ||
           vm.bankCode.isEmpty {                            // 계좌 정보 비어있음
            createSimpleAlert(title: _strings[.requestFailed], msg: _strings[.alertEnterBankAccount])
            _log.log("계좌 정보 비어있음")
            return  
        }
        
        if false == cert.registered || (cert.registered && nil == cert.img.image) {
            createSimpleAlert(title: _strings[.requestFailed], msg: "사업자등록증 사진을 등록해주세요.")
            _log.log("사업자 등록증이 비어있음")
            return
        }
        
        if false == bankbook.registered || (bankbook.registered && nil == bankbook.img.image) {
            createSimpleAlert(title: _strings[.requestFailed], msg: "통장사본 사진을 등록해주세요.")
            _log.log("통장 사본 비어있음")
            return
        }
        
        // 보관사업자 승인 요청
        self.requestApprove(name: name, licenseNo: licenseNo, bankCode: self.vm.bankCode, bankAccount: bankAccount, addr: address, addrDetail: addressDetail, addrCode: addressCode, contact: contact)
    }
    
    // MARK: 보관사업자 승인 요청
    func requestApprove(name: String, licenseNo: String, bankCode: String, bankAccount: String, addr: String, addrDetail: String, addrCode: String, contact: String) {
        
        if false == _utils.createIndicator() { return }
        
        // 사업자 정보 등록
        vm.registerBiz(name: name, licenseNo: licenseNo, bankCode: vm.bankCode, bankAccount: bankAccount, addr: addr, addrDetail: addrDetail, addrCode: addrCode, contact: contact) { (success, msg) in
            
            guard success else {
                _utils.removeIndicator()
                self.createSimpleAlert(title: _strings[.requestFailed], msg: msg)
                return
            }
            
            // 사진 등록 요청
            self.registerLicense() { (success) in
                guard success else {
                    _utils.removeIndicator()
                    self.createSimpleAlert(title: _strings[.requestFailed], msg: msg)
                    return
                }
                
                // 보관 보관사업자 승인 요청
                self.vm.requestApprove() { (success, msg) in
                    _utils.removeIndicator()
                    
                    var alertTitle: String = ""
                    if success {
                        alertTitle = _strings[.requestSuccess]
                        self.vm.getUserInfo() { self.delegate?.registeredBiz() }
                    }
                    else { alertTitle = _strings[.requestFailed] }
                    
                    self.createSimpleAlert(title: alertTitle, msg: msg)
                }
            }
        }
    }
    
    // 사진 등록 요청
    func registerLicense(completion: ((Bool) -> Void)? = nil) {
        // 사진이 새로 등록되었을 경우에만 사진 등록 API 호출
        guard self.cert.registered || self.bankbook.registered else {
            completion?(true)
            return
        }
        
        // 사진 등록
        let licenseImg = self.cert.img.image?.jpegData(compressionQuality: 0.7)
        let bankbookImg = self.bankbook.img.image?.jpegData(compressionQuality: 0.7)
        self.vm.registerLicense(licensePicture: licenseImg, bankbookPicture: bankbookImg) { (success, msg) in
            if success {
                // 사진 등록 상태 해제
                self.cert.registered = false
                self.bankbook.registered = false
            } else {
                self.createSimpleAlert(title: msg, msg: "")
            }
            
            completion?(success)
        }
    }
    
    func getText(_ field: UITextField) -> String {
        let text = field.text ?? ""
        return text
    }
    
    func createSimpleAlert(title: String, msg: String) {
        let alert = _utils.createSimpleAlert(title: title, message: msg, buttonTitle: _strings[.ok])
        self.present(alert, animated: true)
    }
    
    // 인증 유효 시간 text 갱신
    func refreshAuthTimeText() {
        let diveding: Double = 60
        let minute = Int(authTime / diveding)
        let second = Int(authTime.truncatingRemainder(dividingBy: diveding))
        
        var minuteStr = "\(minute)"
        if minute < 10 { minuteStr = "0\(minute)" }
        
        var secondStr = "\(second)"
        if second < 10 { secondStr = "0\(secondStr)" }
        
        let time = "\(minuteStr) : \(secondStr)"
        _log.log("auth time: \(time)")
        authTimeLabel.text = time
    }
    
    // 인증 유효 시간 계산
    @objc func calculateAuthTime() {
        refreshAuthTimeText()
        authTime -= 1.0
        
        if authTime < 0.0 {
            authTime = 0.0
            authTimer?.invalidate()
            refreshAuthTimeText()
        } else {
            callTimer()
        }
        
    }
    
    // 인증 시간 타이머 호출
    func callTimer() {
        authTimer?.invalidate()
        authTimer = Timer.scheduledTimer(timeInterval: authDelay, target: self, selector: #selector(self.calculateAuthTime), userInfo: nil, repeats: false)
    }
    
    // 인증 번호 요청
    func getAuthCode() {
        let contactStr = contact.text ?? ""
        if contactStr == vm.validContact { return }     // 인증받은 상태면 return
        
        if contactStr.isEmpty {
            let alert = _utils.createSimpleAlert(title: _strings[.alertNeedName], message: "", buttonTitle: _strings[.ok])
            self.present(alert, animated: true)
            return
        }
        
        vm.getAuthCode(contact: contactStr) { (success, msg) in
            if success {
                // 타이머 시작
                self.authTime = self.authMaxTime
                self.calculateAuthTime()
                self.authView.isHidden = false
            } else {
                self.createSimpleAlert(title: _strings[.requestFailed], msg: msg)
            }
        }
    }
    
    // 인증 진행
    func doAuth() {
        let codeStr = authField.text ?? ""
        if codeStr.isEmpty {
            let alert = _utils.createSimpleAlert(title: _strings[.alertNeedVerificationCode], message: "", buttonTitle: _strings[.ok])
            self.present(alert, animated: true)
            return
        }
        
        let contactStr = contact.text ?? ""
        if contactStr.isEmpty {
            let alert = _utils.createSimpleAlert(title: _strings[.alertEnterPhone], message: "", buttonTitle: _strings[.ok])
            self.present(alert, animated: true)
            return
        }
        vm.auth(phone: contactStr, authNo: codeStr) { (success, msg) in
            
            // 인증 성공
            if success {
                self.vm.validContact = self.contact.text ?? ""
                self.authTimer?.invalidate()
                self.updateAuthStatus(authDone: true)
            }
            // 인증 실패
            else {
                let alert = _utils.createSimpleAlert(title: msg, message: "", buttonTitle: _strings[.ok])
                self.present(alert, animated: true)
            }
            
        }
    }
    
    // 인증 상태에 따른 UI 갱신
    func updateAuthStatus(authDone: Bool) {
        if authDone {
            contactRequest.layer.borderColor = validColor.cgColor
            contactRequest.backgroundColor = validColor
            contactRequest.setTitleColor(.white, for: .normal)
            contactRequest.setTitle(_strings[.authComplete], for: .normal)
            authField.text = ""
            authView.isHidden = true
        } else {
            contactRequest.layer.borderColor = UIColor.systemGray.cgColor
            contactRequest.backgroundColor = .white
            contactRequest.setTitleColor(.darkGray, for: .normal)
            contactRequest.setTitle(_strings[.requestAuth], for: .normal)
        }
    }
    
    // 주소 검색 화면으로 이동
    func moveToSearch() {
        self.present(SearchAddressController(), animated: true)
    }
}

// MARK: - Actions
extension RegistrationVc {
    func onBankSelect(index: Int, item: String) {
        bankMenu.hide()
        bankName.text = item
        vm.bankSelected(index: index)
    }
    
    @IBAction func onExit(_ sender: UIButton) {
        if nil != vm { vm.initDelSeq() }
        self.view.removeFromSuperview()
        self.removeFromParent()
        delegate?.registrationVcDeleted()
    }
    
    @objc func onRequestAuthCode(_ sender: UIButton) {
        getAuthCode()
    }
    
    @objc func onAuth(_ sender: UIButton) {
        doAuth()
    }
    
    @objc func onAddr(_ sender: UIButton) {
        moveToSearch()
    }
    
    @objc func onRequest(_ sender: UIButton) {
        validateAndRequest()
    }
}

// MARK: - RegistrationVm
extension RegistrationVc: RegistrationVmDelegate {
    func ready() {
        //configure()
        refresh()
    }
}

// MARK: - UITextFieldDelegate
extension RegistrationVc: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == bankName {
            textField.resignFirstResponder()
            bankMenu.show()
        } else if textField == address || textField == addressCode {
            textField.resignFirstResponder()
            moveToSearch()
        }
    }
    
    @objc func contactEditingChanged() {
        let text = contact.text ?? ""
        if vm.validContact == text {
            if vm.validContact.isEmpty { return }
            updateAuthStatus(authDone: true)
        } else {
            updateAuthStatus(authDone: false)
        }
    }
    
    @objc func licenseEditingChanged() {
        let text = licenseNo.text ?? ""
        guard text.count == 10 else {
            licenseStatus.text = ""
            return
        }
        
        let isValid = vm.isValidLicenseNo(num: text)
        
        // 유효한 사업자 번호
        if isValid {
            licenseStatus.textColor = validColor
            licenseStatus.text = _strings[.validLicneseNo]
            vm.validLicenseNo = text
        }
        // 잘못된 사업자 번호
        else {
            licenseStatus.textColor = .systemRed
            licenseStatus.text = _strings[.alertInvalidLicenseNo]
        }
        
        licenseMark.isHidden = !isValid
    }
}

// MARK: - CarryDelegate
extension RegistrationVc: CarryDelegate {
    func selectAddress(address: String, postalCode: String, lat: Double, lng: Double) {
        self.address.text = address
        self.addressCode.text = postalCode
        vm.lat = lat
        vm.lng = lng
    }
    
}

// MARK: - RegPictureDelegate
extension RegistrationVc: RegPictureDelegate {
    func registered(seq: String) {
        vm.deletePicture(seq: seq)
    }
}

