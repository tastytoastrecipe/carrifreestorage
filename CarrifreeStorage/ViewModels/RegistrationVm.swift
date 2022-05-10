//
//  RegistrationVm.swift
//  CarrifreeStorage
//
//  Created by plattics-kwon on 2021/10/25.
//

import Foundation
import SwiftyJSON

@objc protocol RegistrationVmDelegate {
    @objc optional func ready()
}

class RegistrationVm: UploadVm {
    var name: String {
        get { return user?.name ?? "" }
        set { user?.name = newValue }
    }
    
    var licenseNo: String {
        get { return user?.licenseNo ?? "" }
        set { user?.licenseNo = newValue }
    }
    
    var bankName: String {
        get { return user?.bankName ?? "" }
        set { user?.bankName = newValue }
    }
    
    var bankCode: String {
        get { return user?.bankCode ?? "" }
        set { user?.bankCode = newValue }
    }
    
    var bankAccount: String {
        get { return user?.bankAccount ?? "" }
        set { user?.bankAccount = newValue }
    }
    
    var addr: String {
        get { return user?.addr ?? "" }
        set { user?.addr = newValue }
    }
    
    var addrDetail: String {
        get { return user?.addrDetail ?? "" }
        set { user?.addrDetail = newValue }
    }
    
    var addrCode: String {
        get { return user?.addrCode ?? "" }
        set { user?.addrCode = newValue }
    }
    
    var contact: String {                           // 폰번호
        get { return user?.contact ?? "" }
        set { user?.contact = newValue }
    }
    
    var licensePicUrl: String {                     // 사업자등록증 사진 url
        get { return user?.licensePicUrl ?? "" }
        set { user?.licensePicUrl = newValue }
    }
    
    var licensePicSeq: String {                     // 사업자등록증 사진 seq
        get { return user?.licensePicSeq ?? "" }
        set { user?.licensePicSeq = newValue }
    }
    
    var bankbookPicUrl: String {                    // 통장사본 사진 url
        get { return user?.bankbookPicUrl ?? "" }
        set { user?.bankbookPicUrl = newValue }
    }
    
    var bankbookPicSeq: String {                    // 통장사본 사진 seq
        get { return user?.bankbookPicSeq ?? "" }
        set { user?.bankbookPicSeq = newValue }
    }
    
    var lat: Double {
        get { return user?.lat ?? 0.0 }
        set { user?.lat = newValue }
    }
    
    var lng: Double {
        get { return user?.lng ?? 0.0 }
        set { user?.lng = newValue }
    }
    
    var user: BizData!
    var validContact: String = ""           // 인증 완료한 폰번호
    var validLicenseNo: String = ""         // 유효한 사업자 등록번호
    var delSeq: String = ""                 // 삭제한 파일의 시퀀스
    var bankDataSource: [BankData] = []     // 은행 dataSource
    var delegate: RegistrationVmDelegate?
    
    var presignedUrl: String = ""
    var attachGrpSeq: String = _user.attachGrpSeq
    var attachSeq: String = ""
    
    init(delegate: RegistrationVmDelegate) {
        self.delegate = delegate
        
        // 서버에서 데이터 받아온 후 각 변수 초기화
        getUserInfo()
    }
    
    func getUserInfo(completion: (() -> Void)? = nil) {
        _cas.registration.getUserInfo() { (success, json) in
            guard let json = json else { return }
            
            self.user = BizData(json: json)
            self.validLicenseNo = self.user.licenseNo
            self.validContact = self.user.contact
            self.attachGrpSeq = json["ATTACH_GRP_NO"].stringValue
            _user.masterSeq = json["MASTER_SEQ"].stringValue
            _user.bizName = self.user.name
            
            var server: String = ""
            if releaseMode {
                server = _identifiers[.liveServer]
            } else {
                server = _identifiers[.devServer]
            }
            
            if self.user.licensePicUrl.count > 0 {
                self.user.licensePicUrl = "\(server)\(self.user.licensePicUrl)"
            }
            
            if self.user.bankbookPicUrl.count > 0 {
                self.user.bankbookPicUrl = "\(server)\(self.user.bankbookPicUrl)"
            }
            
            _cas.registration.getBanks() { (success, bankJson) in
                guard let bankJson = bankJson else { return }
                self.bankDataSource.removeAll()
                
                let arr = bankJson["bankList"].arrayValue
                for value in arr {
                    let code = value["COM_CD"].stringValue
                    let name = value["COM_NM"].stringValue
                    if code.isEmpty || name.isEmpty { continue }
                    self.bankDataSource.append(BankData(code: code, name: name))
                }
                self.delegate?.ready?()
            }
            
            completion?()
        }
        
    }
    
    func bankSelected(index: Int) {
        user.bankCode = bankDataSource[index].code
    }
    
    func getSelectedBankIndex(bankName: String) -> Int {
        for (i, data) in bankDataSource.enumerated() {
            if user.name == data.name { return i }
        }
        
        return 0
    }
    
    /// 삭제할 파일 시퀀스 추가
    func deletePicture(seq: String) {
        if seq.isEmpty { return }
        
        if delSeq.isEmpty {
            delSeq = seq
        } else {
            
            // 중복 seq가 입력되지않게 함
            let delSeqArr = delSeq.split(separator: ",").map { (value) -> String in return String(value) }
            for value in delSeqArr { if seq == value { return } }
            
            delSeq += ",\(seq)"
        }
    }
    
    /// delSeq 초기화
    func initDelSeq() {
        delSeq = ""
    }
    
    // MARK: SMS 인증
    /// SMS 인증 번호 요청
    func getAuthCode(contact: String, completion: ResponseString = nil) {
        _cas.signup.requestAuth(phone: contact, signup: true) { (success, json) in
            if success {
                completion?(true, "")
            } else {
                var msg = _strings[.requestFailed]
                if let json = json {
                    let failedMsg = json["resMsg"].stringValue
                    if false == failedMsg.isEmpty { msg = failedMsg }
                }
                
                completion?(false, msg)
            }
        }
    }
    
    /// SMS 인증
    func auth(phone: String, authNo: String, completion: ResponseString = nil) {
        _cas.signup.doAuth(phone: phone, authNo: authNo) { (success, json) in
//        _cas.registration.auth(code: code) { (success, json) in
            if success {
                completion?(true, "")
            } else {
                var msg = _strings[.requestFailed]
                if let json = json {
                    let failedMsg = json["resMsg"].stringValue
                    if false == failedMsg.isEmpty { msg = failedMsg }
                }
                
                completion?(false, msg)
            }
        }
    }
    
    // MARK: 사업자 정보 등록/수정
    /// 사업자 정보 등록/수정
    func registerBiz(name: String, licenseNo: String, bankCode: String, bankAccount: String, addr: String, addrDetail: String, addrCode: String, contact: String, completion: ResponseString = nil) {
        _cas.registration.registerBiz(name: name, licenseNo: licenseNo, bankCode: bankCode, bankAccount: bankAccount, addr: addr, addrDetail: addrDetail, addrCode: addrCode, contact: contact, coordinates: (user.lat, user.lng)) { (success, json) in
            if success {
                self.write(name: name, licenseNo: licenseNo, bankCode: bankCode, bankAccount: bankAccount, addr: addr, addrDetail: addrDetail, addrCode: addrCode, contact: contact)
                completion?(true, "")
            } else {
                var msg = _strings[.requestFailed]
                if let json = json {
                    let failedMsg = json["resMsg"].stringValue
                    if false == failedMsg.isEmpty { msg = failedMsg }
                }
                
                completion?(false, msg)
            }
        }
    }
    
    func write(name: String, licenseNo: String, bankCode: String, bankAccount: String, addr: String, addrDetail: String, addrCode: String, contact: String) {
        self.user.name = name
        self.user.licenseNo = licenseNo
        self.user.bankCode = bankCode
        self.user.bankAccount = bankAccount
        self.user.addr = addr
        self.user.addrDetail = addrDetail
        self.user.addrCode = addrCode
        self.user.contact = contact
    }
    
    // MARK: 사업자등록증, 통장사본 등록 (Multipart 방식)
    /*
    func registerLicense(licensePicture: Data?, bankbookPicture: Data?, completion: ResponseString = nil) {
        _cas.registration.registerLicense(license: [licensePicture], bankbook: [bankbookPicture], delSeq: delSeq) { (success, json) in
            if success {
                self.initDelSeq()
                completion?(true, "")
            } else {
                var msg = "\(_strings[.alertFailedToRegisterPicture]) \(_strings[.plzTryAgain])"
                if let json = json {
                    let failedMsg = json["resMsg"].stringValue
                    if false == failedMsg.isEmpty { msg = "\(msg)\n(\(failedMsg))" }
                }
                
                completion?(false, msg)
            }
        }
    }
     */
    
    // MARK: 사업자등록증, 통장사본 등록 (Data 방식)
    func registerLicense(licensePicture: Data?, bankbookPicture: Data?, completion: ResponseString = nil) {
        guard let license = licensePicture, let bankbook = bankbookPicture else {
            completion?(false, "사업자등록증, 통장사본을 등록하지 못했습니다.\n(wrong img data)")
            return
        }
        
        // 사업자 등록증
        uploadImage(imgData: license, attachType: .bizLicense) { (success, msg) in
            var message: String = ""
            if false == success { message = msg }
            
            // 통장사본
            self.uploadImage(imgData: bankbook, attachType: .bank) { (success, msg) in
                guard success else {
                    message = msg
                    completion?(false, message)
                    return
                }
                
                _cas.registration.registerLicense(attachGrpSeq: self.attachGrpSeq, attachType: AttachType.bizLicense.rawValue) { (success, json) in
                    if success {
                        self.initDelSeq()
                        completion?(true, "")
                    } else {
                        var msg = "\(_strings[.alertFailedToRegisterPicture]) \(_strings[.plzTryAgain])"
                        if let json = json {
                            let failedMsg = json["resMsg"].stringValue
                            if false == failedMsg.isEmpty { msg = "\(msg)\n(\(failedMsg))" }
                        }
                        
                        completion?(false, msg)
                    }
                }
            }
        }
        
        
    }
    
    
    
    // MARK: 사업자등록번호 유효성 검사
    // ------------------------------------------------
    /*
     참조 - http://alohastudy.com/bbs/board.php?bo_table=manageman&wr_id=64
    1) 사업자등록번호 10자리를 쓰고 각 자리마다 9자리 수를 맞춰서 쓴 다음 각각의 자리수를 곱합니다.
    2) 곱해서 나온 결과값이 2자를 넘으면 십의 자리를버리고 일의 자리만 씁니다.(예 : 2×5=10일 경우에는 0을 쓰고 7×5=35일 경우에는 5를 씀)
    3) 단 9번째 자리의 수는 곱해서 나온값을 그대로 적습니다. (45일 경우는 4와 5)
    4) 그런 다음, 곱해서 나온 수 10자를 각각 더합니다.
    위의 예의 경우를 계산해 보면  1+0+7+8+9+0+0+3+4+5를 전부 더하면 결과값이 37이 나옵니다.
    마지막으로 사업자번호 10자리중 검증번호라는 끝자리를 결과값에 더합니다.

    37(결과값) + 3(검증번호) = 40

    이처럼 결과값에 검증번호를 더해서 나온 값이 10의 배수(10,20,30,40,....)가 나오면 이 사업자등록번호는 구성원칙에 맞는 번호입니다.
    */

    //=======================================================
    // 사업자번호를 입력받아서 유효한 사업자 번호인지 체크하는 기능
    //=======================================================
    let veriNum: String = "137137135"           // 검증 대응숫자
    var checkSum: Int = 0                       // 검증번호
    //=======================================================

    /// 사업자등록번호 유효성 검사
    func isValidLicenseNo(num: String) -> Bool {
        
        var bizNumArr: [Int] = []
        for char in num {
            bizNumArr.append(Int(String(char)) ?? 0)
        }

        var veriNumArr: [Int] = []
        for char in veriNum {
            veriNumArr.append(Int(String(char)) ?? 0)
        }

        // 1. 검증 대응숫자 기준으로 두 값을 곱하여 1의 자리 숫자를 추출
        var addValueArr: [Int] = []
        var sum: Int = 0
        for i in 0...veriNumArr.count-1 {
            var tmp = bizNumArr[i] * veriNumArr[i]
            
            // 1~8 자리의 곱이 10 이상일 경우는 1자리의 숫자만 사용한다.
            if i < veriNumArr.count-1 {
                if tmp > 10 {
                    tmp = tmp%10
                }
                sum += tmp
            }
            addValueArr.append(tmp)
            //print(tmp)
        }
        //print(sum)
        //print(addValueArr[addValueArr.count-1])

        // 2. 마지막 9번번째 자리의 경우 10 이상일 경우 십의 자리와 일의 자리를 따로 숫자로 떼어서 합한다.
        if addValueArr[addValueArr.count-1] >= 10 {
            let lastNumStr = String(addValueArr[addValueArr.count-1])
            var lastNumArr: [Int] = []
            for char in lastNumStr {
                lastNumArr.append(Int(String(char)) ?? 0)
            }
            sum += lastNumArr[0]
            sum += lastNumArr[1]
        }
        else {
            sum += addValueArr[addValueArr.count-1]
        }

        // 3. 검증 숫자 검출
        checkSum = 10 - (sum % 10)
        if checkSum == 10 { checkSum = 0 }

        // 4. 검증
        if checkSum == bizNumArr[bizNumArr.count-1] {
            _log.log("검증 성공!")
            return true
        }
        else {
            _log.log("검증 실패!")
            return false
        }
    }
    
    // MARK: 보관사업자 승인 요청
    /// 보관사업자 승인 요청
    func requestApprove(completion: ResponseString = nil) {
        if _user.approval == .wating || _user.approval == .approved {
            completion?(true, _strings[.bizInfoChanged])
            return
        }
        
        _cas.registration.requestApprove(isStoreInfo: false) { (success, json) in
            if success {
                _user.approval = .wating
                completion?(true, _strings[.approvalRequestDone])
            } else {
                var msg = "\(_strings[.alertRequestApproveFailed]) \(_strings[.plzTryAgain])"
                if let json = json {
                    let failedMsg = json["resMsg"].stringValue
                    if false == failedMsg.isEmpty { msg = "\(msg)\n(\(failedMsg))" }
                }
                completion?(false, msg)
            }
        }
    }
}
