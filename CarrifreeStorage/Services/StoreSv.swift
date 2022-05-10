//
//  StoreSv.swift
//  CarrifreeStorage
//
//  Created by plattics-kwon on 2021/11/02.
//
//
//  💬 ## StoreSv ##
//  💬 매장 정보 등록/수정 관련 API 모음
//

import Foundation

import Alamofire
import SwiftyJSON 

class StoreSv: Service {
    let apiManager: ApiManager
    
    init(apiManager: ApiManager) {
        self.apiManager = apiManager
    }
    
    // MARK: - 매장 정보 조회
    /// 매장 정보 조회
    func getStoreInfo(completion: ResponseJson = nil) {
        guard let headers = getHeader() else { return }
        
        let param: Parameters = [
            "USER_TYPE": CarrifreeAppType.appStorage.user,
            "USER_SEQ": _user.seq
        ]
        
        let url = getRequestUrl(body: "/sys/saver/app/getWayInfo.do")
        apiManager.request(api: .getStoreInfo, url: url, headers: headers, parameters: param, completion: completion)
    }
    
    // MARK: - 영업시간 조회
    /// 영업시간 조회
    func getWorkTime(completion: ResponseJson = nil) {
        //-------------------------- Request -------------------------- //
        //
        //      USER_SEQ                유저 시퀀스
        //
        //------------------------------------------------------------- //
        //
        //
        //
        //-------------------------- Response ------------------------- //
        //
        //      (playBaseInfo)
        //      WORK_BASE_HOLIDAY       공휴일 휴무 여부 (Y/N)
        //      WORK_STA_TIME           영업 시작 시간
        //      WORK_OUT_TIME           영업 종료 시간
        //      redCd                   결과 코드
        //
        //------------------------------------------------------------- //
        
        guard let headers = getHeader() else { return }
        
        let param: Parameters = [
            "USER_SEQ": _user.seq
        ]
        
        let url = getRequestUrl(body: "/sys/saver/app/getPlayInfo.do")
        apiManager.request(api: .getWorktime, url: url, headers: headers, parameters: param, completion: completion)
    }
    
    // MARK: - 매장 사진 등록
    /// 매장 사진 등록
    func registerStorePicture(attachGrpSeq: String, completion: ResponseJson = nil) {
        //-------------------------- Request -------------------------- //
        //
        //      USER_SEQ                유저 시퀀스
        //      MASTER_SEQ              마스터 시퀀스
        //      VECHILE_TYPE            004
        //      ATTACH_TYPE             이미지의 첫장은 014로 전달, 두번째 장부터 013으로 전달
        //      module                  3
        //      ATTACH_GRP_SEQ          처음 등록시 값이 없을 경우 전달 하지 않는다 (값이 있을 경우에만 전달)
        //      DEL_SEQ                 삭제할 파일의 시퀀스
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
            "module": "3",
            "ATTACH_GRP_SEQ": attachGrpSeq,
            "ATTACH_TYPE": AttachType.storageMain.rawValue
//            "VECHILE_TYPE": "004",
//            "DEL_SEQ": delSeq
        ]
        
        let url = getRequestUrl(body: "/sys/saverV3/app/setPictureManage.do")
//        let attach: AttachForm = [("014", [main]), ("013", normal)]
//        apiManager.requestAttach(api: .registerStorePicture, url: url, headers: headers, parameters: param, attaches: attach, completion: completion)
        
        apiManager.request(api: .registerStorePicture, url: url, headers: headers, parameters: param, completion: completion)
    }
    
    // MARK: - 매장 사진 조회
    /// 매장 사진 조회
    func getStorePictures(attachGrpSeq: String, completion: ResponseJson = nil) {
        //-------------------------- Request -------------------------- //
        //
        //      USER_SEQ                유저 시퀀스
        //      ATTACH_GRP_SEQ          사진 그룹 시퀀스 (값이 있을 경우에만 전달)
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
            "ATTACH_GRP_SEQ": attachGrpSeq,
        ]
        
        let url = getRequestUrl(body: "/sys/saver/app/getPictureList.do")
        apiManager.request(api: .getStorePicture, url: url, headers: headers, parameters: param, completion: completion)
    }
    
    // MARK: - 매장 사진 삭제
    /// 매장 사진 삭제
    func deleteStorePicture(attachGrpSeq: String, attachSeq: String, completion: ResponseJson = nil) {
        //-------------------------- Request -------------------------- //
        //
        //      ATTACH_SEQ              사진 시퀀스
        //      ATTACH_GRP_SEQ          사진 그룹 시퀀스 (값이 있을 경우에만 전달)
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
            "ATTACH_SEQ": attachSeq,
            "ATTACH_GRP_SEQ": attachGrpSeq,
        ]
        
        let url = getRequestUrl(body: "/sys/attach/image/deleteFile.do")
        apiManager.request(api: .getStorePicture, url: url, headers: headers, parameters: param, completion: completion)
    }
    
    // MARK: - 매장정보 등록
    /// 매장정보 등록
    func registerStoreInfo(pr: String, capacity: Int, attachGrpSeq: String, completion: ResponseJson = nil) {
        //-------------------------- Request -------------------------- //
        //
        //      USER_SEQ            사용자 시퀀스
        //      MASTER_SEQ          마스터 시퀀스
        //      MAX_BOX_CNT         보관 가능 수량
        //      WAREHOUSE_ISSUE     소개글
        //      ATTACH_GRP_SEQ      파일 그룹 시퀀스
        //      module              첨부파일 저장 공간 코드
        //
        //------------------------------------------------------------- //
        //
        //
        //
        //-------------------------- Response ------------------------- //
        //
        //
        //------------------------------------------------------------- //
        
        guard let headers = getHeader() else { completion?(false, nil); return }
        
        let param: Parameters = [
            "USER_SEQ": _user.seq,
            "MASTER_SEQ": _user.masterSeq,
            "MAX_BOX_CNT": capacity,
            "WAREHOUSE_ISSUE": pr,
            "ATTACH_GRP_SEQ": _user.attachGrpSeq,
            "module": "3"
        ]
        
        let url = getRequestUrl(body: "/sys/saver/app/setWayInsert.do")
        apiManager.request(api: .registerDayoff, url: url, headers: headers, parameters: param, completion: completion)
    }
    
    // MARK: - 영업시간 등록
    /// 영업시간 등록
    func setWorktime(open: String, close: String, holiday: Bool = false, completion: ResponseJson = nil) {
        //-------------------------- Request -------------------------- //
        //
        //      USER_SEQ            사용자 시퀀스
        //      WORK_STA_TIME       영업 시작 시간
        //      WORK_OUT_TIME       영업 종료 시간
        //      WORK_BASE_HOLIDAY   공휴일 휴무 여부 (Y/N)
        //
        //------------------------------------------------------------- //
        //
        //
        //
        //-------------------------- Response ------------------------- //
        //
        //
        //------------------------------------------------------------- //
        
        guard let headers = getHeader() else { completion?(false, nil); return }
        
        let holidayStr = holiday ? "Y" : "N"
        let param: Parameters = [
            "USER_SEQ": _user.seq,
            "WORK_STA_TIME": open,
            "WORK_OUT_TIME": close,
            "WORK_BASE_HOLIDAY": holidayStr,
        ]
        
        let url = getRequestUrl(body: "/sys/saver/app/setPlayInsert.do")
        apiManager.request(api: .registerWorktime, url: url, headers: headers, parameters: param, completion: completion)
    }
    
    // MARK: - 소개글 등록
    /// 소개글 등록
    func registerPr(pr: String, vehicleSeq: String, completion: ResponseJson = nil) {
        //-------------------------- Request -------------------------- //
        //
        //      USER_SEQ            유저 seq
        //      USER_VECHILE_SEQ    운송수단 seq (getWayInfo.do 에서 받음)
        //      CARRYING_ISSUE      소개글
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
            "USER_VECHILE_SEQ": vehicleSeq,
            "CARRYING_ISSUE": pr
        ]
        
        let urlString = "/sys/saverV2/app/setIusseUpdate.do"
        let url = getRequestUrl(body: urlString)
        apiManager.request(api: .registerPr, url: url, headers: headers, parameters: param, completion: completion)
    }
    

    // MARK: - 업종 정보
    /// 업종 정보
    func getCategories(completion: ResponseJson = nil) {
        guard let headers = getHeader() else { return }
        
        let urlString = "/sys/common/app/getCdBizTypeInfo.do"
        let url = getRequestUrl(body: urlString)
        apiManager.request(api: .getCategories, url: url, headers: headers, parameters: [:], completion: completion)
    }
    
    // MARK: - 업종 등록
    /// 업종 등록
    func registerCategory(category: String, completion: ResponseJson = nil) {
        //-------------------------- Request -------------------------- //
        //      USER_SEQ            유저 seq
        //      MASTER_SEQ          마스터 seq
        //      CD_BIZ_TYPE         업종 코드
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
            "USER_TYPE": CarrifreeAppType.appStorage.user,
            "USER_SEQ": _user.seq,
            "MASTER_SEQ": _user.masterSeq,
            "CD_BIZ_TYPE": category
        ]
        
        let urlString = "/sys/memberV2/app/setBizTypeUpdate.do"
        let url = getRequestUrl(body: urlString)
        apiManager.request(api: .registerCategories, url: url, headers: headers, parameters: param, completion: completion)
    }
    
    // MARK: - 짐 보관 개수 등록
    /// 짐 보관 개수 등록
    func registerLuggages(luggageCount: Int, vehicleSeq: String, completion: ResponseJson = nil) {
        //-------------------------- Request -------------------------- //
        //      USER_SEQ                유저 seq
        //      USER_VECHILE_SEQ        차량 seq
        //      BOX_CNT                 짐 보관 개수
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
            "USER_VECHILE_SEQ": vehicleSeq,
            "BOX_CNT": luggageCount
        ]
        
        let url = getRequestUrl(body: "/sys/saverV3/app/setBoxCnt.do")
        apiManager.request(api: .registerLuggages, url: url, headers: headers, parameters: param, completion: completion)
    }
    
    // MARK: - 매장정보 관련 코드 조회
    /// 매장정보 관련 코드 조회
    func getStorageCodes(all: Bool, codeGroup: StorageCodeGroup, completion: (([StorageCode]) -> Void)? = nil) {
        guard let headers = getHeader() else { completion?([]); return }
        
        var api: ApiType = .getCategories
        if codeGroup == .bank       { api = .getBanks }
        else if codeGroup == .weeks { api = .getWeeks }
        else if codeGroup == .merit { api = .getMerits }
        
        var param: [String: String] = [
            "USER_SEQ": _user.seq
        ]
        
        var url = ""
        if all {
            url = getRequestUrl(body: "/sys/common/app/getComCdList.do")
            param["comGrpCd"] = codeGroup.rawValue
        } else {
            url = getRequestUrl(body: "/sys/common/app/getOptionList.do")
            param["ITEM_GRP_CD"] = codeGroup.rawValue
        }
        
        apiManager.request(api: api, url: url, headers: headers, parameters: param) { (success, json) in
            guard let json = json, true == success else { completion?([]); return }
            
            var codes: [StorageCode] = []
            
            if all {
                let arr = json["comCdList"].arrayValue
                for val in arr {
                    let grp = val["COM_GRP_CD"].stringValue
                    let code = val["COM_CD"].stringValue
                    let name = val["COM_NM"].stringValue
                    let storageCode = StorageCode(grp: grp, code: code, name: name)
                    codes.append(storageCode)
                }
            } else {
                let arr = json["optionList"].arrayValue
                for val in arr {
                    let grp = val["ITEM_GRP_CD"].stringValue
                    let code = val["ITEM_COM_CD"].stringValue
                    let storageCode = StorageCode(grp: grp, code: code, name: "")
                    codes.append(storageCode)
                }
            }
                
            completion?(codes)
        }
    }
    
    // MARK: - 매장 관련 코드 등록
    func registerCodes(codes: String, grpCd: String, completion: ResponseJson = nil) {
        //-------------------------- Request -------------------------- //
        //
        //      USER_SEQ                유저 seq
        //      ITEM_CD_ARR             부가기능 코드 (','로 구분)
        //      ITEM_GRP_CD             부가기능 그룹 코드 (StorageCodeGroup)
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
            "ITEM_CD_ARR": codes,
            "ITEM_GRP_CD": grpCd
        ]
        
        let url = getRequestUrl(body: "/sys/common/app/setOptionInsert.do")
        apiManager.request(api: .registerMerits, url: url, headers: headers, parameters: param, completion: completion)
    }
    
    
    
    // MARK: - 캐리프리 기본 요금 조회
    func getDefaultCosts(completion: ResponseJson = nil) {
        
        //-------------------------- Request -------------------------- //
        //
        //      USER_SEQ                사용자 시퀀스
        //
        //------------------------------------------------------------- //
        //
        //
        //
        //-------------------------- Response ------------------------- //
        //
        //      (basicPriceList)
        //      RATE_SEQ                기본 가격 시퀀스
        //      RATE_KIND               기본 가격 종류
        //      RATE_USER_SECTION       기본 적용시간
        //      RATE_USER_PRICE         기본 가격
        //
        //      (overPriceList)
        //      RATE_SEQ                할증 가격 시퀀스
        //      RATE_KIND               할증 가격 종류
        //      RATE_USER_SECTION       할증 적용시간
        //      RATE_USER_PRICE         할증 가격
        //
        //      (oneDayPriceList)
        //      RATE_SEQ                할증 가격 시퀀스
        //      RATE_KIND               할증 가격 종류
        //      RATE_SECTION            할증 적용시간
        //      RATE_PRICE              할증 가격
        //
        //------------------------------------------------------------- //
                
        guard let headers = getHeader() else { return }
        
        let param: Parameters = [
            "USER_TYPE": CarrifreeAppType.appStorage.user,
            "USER_SEQ": _user.seq
        ]
        
        let url = getRequestUrl(body: "/sys/price/app/getSaverBasicPriceRate.do")
        apiManager.request(api: .getDefaultCosts, url: url, headers: headers, parameters: param, completion: completion)
    }
    
    // MARK: - 내가 설정한 요금 조회
    func getMyCosts(completion: ResponseJson = nil) {
        
        //-------------------------- Request -------------------------- //
        //
        //      USER_SEQ                사용자 시퀀스
        //
        //------------------------------------------------------------- //
        //
        //
        //
        //-------------------------- Response ------------------------- //
        //
        //      (basicPriceList)
        //      RATE_SEQ                기본 가격 시퀀스
        //      RATE_KIND               기본 가격 종류
        //      RATE_USER_SECTION       기본 적용시간
        //      RATE_USER_PRICE         기본 가격
        //
        //      (overPriceList)
        //      RATE_SEQ                할증 가격 시퀀스
        //      RATE_KIND               할증 가격 종류
        //      RATE_USER_SECTION       할증 적용시간
        //      RATE_USER_PRICE         할증 가격
        //
        //      (oneDayPriceList)
        //      RATE_SEQ                할증 가격 시퀀스
        //      RATE_KIND               할증 가격 종류
        //      RATE_SECTION            할증 적용시간
        //      RATE_PRICE              할증 가격
        //
        //------------------------------------------------------------- //
                
        guard let headers = getHeader() else { return }
        
        let param: Parameters = [
            "USER_TYPE": CarrifreeAppType.appStorage.user,
            "USER_SEQ": _user.seq
        ]
        
        let url = getRequestUrl(body: "/sys/price/app/getSaveUserPriceRate.do")
        apiManager.request(api: .getMyCosts, url: url, headers: headers, parameters: param, completion: completion)
    }
    
    // MARK: - 보관 가격 등록
    func registerCosts(sequences: String, sections: String, costs: String, completion: ResponseJson = nil) {
        
        //-------------------------- Example -------------------------- //
        //
        //      /sys/price/app/setSaveUserPriceRate
        //      .do?USER_SEQ=1&CARRYING_PRICE_TYPE=002&CARRYING_SUP_PRICE=0&rate_seq=1,2,3&rate_user_section=4,4,4&rate_user_price=2000,3000,7000
        //
        //------------------------------------------------------------- //
        //
        //
        //
        //-------------------------- Request -------------------------- //
        //
        //      USER_SEQ                사용자 시퀀스
        //      CARRYING_PRICE_TYPE     가격정책 구분 - 001 : 캐리프리값으로 사용, 002 : 직접 가격 책정
        //      CARRYING_SUP_PRICE      추가요금
        //      rate_seq                가격 시퀀스 - 캐리프리 기본 가격의 시퀀스를 받아와 , 로 구분하여 전달한다. 예)1,2,3
        //
        //      rate_user_section       003 : 시간단위로 한시간에 1, 두시간이면 2,2,2,2
        //                              004 : 분단위로 30분일 경우 30, 1시간일 경우 60
        //                              005 : 일 단위로 1일 일 경우 1, 2일 일 경우 2
        //
        //      rate_user_price         짐 크기별 가격 - 구간 가격을 위에 전달된 시퀀스 크기만큼 , 로 구분하여 전달한다. 예)2000,3000,7000
        //
        //
        //------------------------------------------------------------- //
        //
        //
        //
        //-------------------------- Response ------------------------- //
        //
        //
        //------------------------------------------------------------- //
        
        guard let headers = getHeader() else { return }
        
        let param: Parameters = [
            "USER_TYPE": CarrifreeAppType.appStorage.user,
            "USER_SEQ": _user.seq,
            "CARRYING_PRICE_TYPE": "N",
            "CARRYING_SUP_PRICE": "0",
            "rate_seq": sequences,
            "rate_user_section": sections,
            "rate_user_price": costs
        ]
        
        let url = getRequestUrl(body: "/sys/price/app/setSaveUserPriceRate.do")
        apiManager.request(api: .registerCosts, url: url, headers: headers, parameters: param, completion: completion)
    }
    
}


