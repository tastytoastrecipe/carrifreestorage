//
//  RegistrationSv.swift
//  TestProject
//
//  Created by plattics-kwon on 2021/10/31.
//
//
//  💬 ## RegistrationSv ##
//  💬 보관 파트너 신청 관련 API 모음
//


import Foundation
import Alamofire
import SwiftyJSON

class RegistrationSv: Service {
    let apiManager: ApiManager
    
    init(apiManager: ApiManager) {
        self.apiManager = apiManager
    }
    
    // MARK: SMS 인증 코드 요청
    /// SMS 인증 코드 요청
    /*
    func getAuthCode(contact: String, completion: ResponseJson = nil) {
        //-------------------------- Request -------------------------- //
        //
        //      USER_SEQ                    유저 seq
        //      USER_HP_NO                  폰 번호
        //
        //------------------------------------------------------------- //
        //
        //
        //
        //-------------------------- Response ------------------------- //
        //
        //------------------------------------------------------------- //
        
        guard let headers = getHeader() else { return }
        
        let param: Parameters = [
            "USER_TYPE": CarrifreeAppType.appStorage.user,
            "USER_SEQ": _user.seq,
            "USER_HP_NO": contact,
        ]
        
        let url = getRequestUrl(body: "/sys/memberV3/app/hpAuthNSendSms.do")
        apiManager.request(api: .getAuthCode, url: url, headers: headers, parameters: param, completion: completion)
    }
    */
    
    // MARK: SMS 인증
    /// SMS 인증
    func auth(code: String, completion: ResponseJson = nil) {
        //-------------------------- Request -------------------------- //
        //
        //      USER_SEQ                    유저 seq
        //      AUTH_CHECK_NO               인증 코드
        //
        //------------------------------------------------------------- //
        //
        //
        //
        //-------------------------- Response ------------------------- //
        //
        //------------------------------------------------------------- //
        
        guard let headers = getHeader() else { return }
        
        let param: Parameters = [
            "USER_SEQ": _user.seq,
            "AUTH_CHECK_NO": code,
        ]
        
        let url = getRequestUrl(body: "/sys/memberV3/app/hpConfirmCheck.do")
        apiManager.request(api: .auth, url: url, headers: headers, parameters: param, completion: completion)
    }
    
    //MARK: 사업자 정보 등록/수정
    /// 사업자 정보 등록/수정
    func registerBiz(name: String, licenseNo: String, bankCode: String, bankAccount: String, addr: String, addrDetail: String, addrCode: String, contact: String, coordinates: (lat: Double, lng: Double), completion: ResponseJson = nil) {
        //-------------------------- Request -------------------------- //
        //
        //      USER_SEQ                    유저 seq
        //      MASTER_SEQ                  유저 마스터 seq
        //      BIZ_NAME                    사업자 이름
        //      BIZ_CORP_NO                 사업자 등록번호
        //      BANK_CD                     은행 코드
        //      BANK_PRIVATE_NO             은행 계좌번호
        //      BIZ_SIMPLE_ADDR             사업자 간편 주소
        //      ZIP_CD                      사업자 우편번호
        //      BIZ_DETAIL_ADDR             사업자 상세 주소
        //      USER_HP_NO                  핸드폰 번호
        //      BIZ_LAT                     위도
        //      BIZ_LNG                     경도
        //
        //------------------------------------------------------------- //
        //
        //
        //
        //-------------------------- Response ------------------------- //
        //
        //------------------------------------------------------------- //
        
        
        guard let headers = getHeader() else { return }
        
        let param: Parameters = [
            "USER_SEQ": _user.seq,
            "MASTER_SEQ": _user.masterSeq,
            "BIZ_NAME": name,
            "BIZ_CORP_NO": licenseNo,
            "BANK_CD": bankCode,
            "BANK_PRIVATE_NO": bankAccount,
            "BIZ_SIMPLE_ADDR": addr,
            "ZIP_CD": addrCode,
            "BIZ_DETAIL_ADDR": addrDetail,
            "USER_HP_NO": contact,
            "BIZ_LAT": coordinates.lat,
            "BIZ_LNG": coordinates.lng
        ]
        
        let url = getRequestUrl(body: "/sys/memberV3/app/setBizMasterInfo.do")
        apiManager.request(api: .registerBiz, url: url, headers: headers, parameters: param, completion: completion)
    }
    
    //MARK: 사업자등록증, 통장사본 사진 등록
    /// 사업자등록증, 통장사본 사진 등록
    func registerLicense(attachGrpSeq: String, attachType: String, completion: ResponseJson = nil) {
        //-------------------------- Request -------------------------- //
        //
        //      USER_SEQ                    유저 seq
        //      MASTER_SEQ                  유저 마스터 seq
        //      DEL_SEQ                     삭제할 파일의 seq
        //      fileList                    등록할 사진 파일
        //      module                      3
        //
        //------------------------------------------------------------- //
        //
        //
        //
        //-------------------------- Response ------------------------- //
        //
        //------------------------------------------------------------- //
        
        
        guard let headers = getHeader() else { return }
        
        let param: [String: String] = [
            "USER_SEQ": _user.seq,
            "MASTER_SEQ": _user.masterSeq,
//            "DEL_SEQ": delSeq,
            "ATTACH_TYPE": attachType,
            "ATTACH_GRP_SEQ": attachGrpSeq,
            "module": "3"
        ]
        
        let url = getRequestUrl(body: "/sys/memberV3/app/setBizFile.do")
//        let attach: AttachForm = [("001", license), ("020", bankbook)]
//        apiManager.requestAttach(api: .registerLicense, url: url, headers: headers, parameters: param, attaches: attach, completion: completion)
        apiManager.request(api: .registerLicense, url: url, headers: headers, parameters: param, completion: completion)
    }
    
    // MARK: 회원정보/사업자정보 조회
    /// 회원정보/사업자정보 조회
    func getUserInfo(completion: ResponseJson = nil) {
        
        //-------------------------- Request -------------------------- //
        //
        //          USER_ID             id
        //
        //------------------------------------------------------------- //
        //
        //
        //
        //-------------------------- Response ------------------------- //
        //
        //          USER_SEQ            용자 seq
        //          MASTER_SEQ          마스터 seq
        //          USER_ID             사용자 ID
        //          BIZ_NAME            회사명
        //          BIZ_CORP_NO         회사 사업자 번호
        //          BANK_CD             은행 코드
        //          BANK_NM             은행 명
        //          BANK_PRIVATE_NO     은행 계좌번호
        //          MSG_AGREE           약관 동의 여부
        //          INFO_AGREE          정보 동의 여부
        //          MAR_AGREE           마케팅 동의 여부
        //          USER_HP_NO          사용자 핸드폰 번호
        //          TMP_HP_NO           사용자 추가 핸드폰 번호
        //          MASTER_YN           마스터 사용자 유무
        //          VECHILE_CNT         운송수당 등록 현황
        //          PRIVATE_CODE        유저코드
        //          BIZ_SIMPLE_ADDR     업체 주소
        //          BIZ_DETAIL_ADDR     업체 상세 주소
        //          CD_BIZ_TYPE         업종 코드
        //          USER_ATTACH_INFO    주민등록증 사진
        //          BIZ_ATTACH_INFO     사업자등록증 사진
        //          BIZ_LAT             위도
        //          BIZ_LNG             경도
        //          REG_STEP            사업자 등록 단계
        //
        //------------------------------------------------------------- //
        
        guard let headers = getHeader() else { return }
        
        let param: Parameters = [
            "USER_ID": _user.id,
            "USER_TYPE": CarrifreeAppType.appStorage.user
        ]
        
        let urlString = "/sys/member/app/getUserInfo.do"
        let url = getRequestUrl(body: urlString)
        apiManager.request(api: .getUserInfo, url: url, headers: headers, parameters: param, completion: completion)
    }
    
    // MARK: 은행 정보
    /// 은행 정보
    func getBanks(completion: ResponseJson = nil) {
        
        guard let headers = getHeader() else { return }
        
        let urlString = "/sys/common/app/getBankInfo.do"
        let url = getRequestUrl(body: urlString)
        apiManager.request(api: .getBanks, url: url, headers: headers, parameters: [:], completion: completion)
    }
    
    // MARK: 보관사업자 승인 요청 or 매장 정보 등록
    /// 보관사업자 승인 요청 or 매장 정보 등록
    func requestApprove(isStoreInfo: Bool, completion: ResponseJson = nil) {
        //-------------------------- Request -------------------------- //
        //
        //      USER_SEQ            유저 seq
        //      USER_TYPE           유저 type (보관:002, 운반:003)
        //      USER_NAME           이름
        //
        //------------------------------------------------------------- //
        //
        //
        //
        //-------------------------- Response ------------------------- //
        //
        //------------------------------------------------------------- //
        
        guard let headers = getHeader() else { return }
        
        var flag = ""
        if isStoreInfo { flag = "BIZ" }
        else { flag = "ADMIN" }
        
        let param: Parameters = [
            "USER_SEQ": _user.seq,
            "USER_TYPE": CarrifreeAppType.appStorage.user,
            "USER_NAME": _user.name,
            "CHECK_FLAG": flag
        ]
        
        let urlString = "/sys/member/app/setAuthCheck.do"
        let url = getRequestUrl(body: urlString)
        apiManager.request(api: .requestApprove, url: url, headers: headers, parameters: param, completion: completion)
    }
    
}
