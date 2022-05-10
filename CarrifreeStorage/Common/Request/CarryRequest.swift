//
//  CarryRequest.swift
//  Carrifree
//
//  Created by orca on 2020/10/26.
//  Copyright © 2020 plattics. All rights reserved.
//

/*
 
import Foundation
import Alamofire
import SwiftyJSON

class CarryRequest {
    
    static let shared = CarryRequest()
    
    struct Result {
        var success: Bool = false
        var msg: String = ""
    }
    
    private let timeoutInterval: Double = 20
    
    private var currentKeyword = ""
    private var reviewPage = 1
    
    var server: String = ""
    var api: CarryApis = .none
    
    private init() {
        if releaseMode {
            server = _identifiers[.liveServer]
        } else {
            server = _identifiers[.devServer]
        }
    }
    
    // 내가 요청한 스펙을 logging
    func printRequestInfo(requestTitle: String, response: AFDataResponse<Any>) {
        _log.logWithArrow("\(requestTitle) response", response.debugDescription)
        
        /*
        if let data = response.request?.httpBody {
            let body = String(data: data, encoding: .utf8)
            _log.logWithArrow("\(requestTitle) request body", body ?? "")
        }
        */
        
        if let data = response.request?.httpBody {
            let bodyStr = String(data: data, encoding: .utf8) ?? ""
            let bodyArr = bodyStr.split(separator: "&").map { (value) -> String in
                return String(value)
            }
            
            _log.logWithArrow("\(requestTitle) request body", "\n")
            for body in bodyArr {
                print("\t\(body)")
            }
            
            print("\n")
        }
    }

    // 서버 주소를 합친 주소를 반환
    func getRequestUrl(body: String) -> String {
        return "\(server)\(body)"
    }
    
    
    
    // MARK:- 리뷰 목록 요청
    func requestReviews(firstRequest: Bool, completion: ResponseString = nil) {
        
        //-------------------------- Request -------------------------- //
        //
        //          USER_BUYER_SEQ          리뷰 작성하는 사용자 시퀀스
        //          ORDER_KIND              사업자 종류 (운송사업자: 001, 보관사업자: 004)
        //          page                    페이지 번호
        //
        //------------------------------------------------------------- //
        //
        //
        //
        //-------------------------- Response ------------------------- //
        //
        //          (getBuyerUserReviewList)
        //          REVIEW_BODY             리뷰 내용
        //          REVIEW_POINT            리뷰 점수
        //          USER_NAME               작성자 이름
        //          ORDER_DATE              작성 날짜
        //          
        //          (getSelfAvgReviewPoint)
        //          AVG_POINT               캐리어베이스 평균
        //
        //------------------------------------------------------------- //
            
        
        if false == _utils.createIndicator() { return }
        
        if firstRequest {
            reviewPage = 1
        }
        
        let headers: HTTPHeaders = [
            "USER_TOKEN": CarryDatas.shared.user.token,
            "USER_ID": CarryDatas.shared.user.id,
            "USER_TYPE": CarrifreeAppType.appStorage.user
        ]
        
        let param: Parameters = [
            "USER_TYPE": CarrifreeAppType.appStorage.user,
            "USER_TRANS_SEQ": CarryUser.seq,
            "ORDER_KIND": "004",
            "page": reviewPage
        ]
        
        let urlString = "/sys/trans/app/getTransUserReviewList.do"
        let url = getRequestUrl(body: urlString)
        
        AF.request(url, method: .post, parameters: param, headers: headers) { $0.timeoutInterval = 10 }.validate().responseJSON { (response) in
            
            let requestTitle = "[리뷰 목록 조회]"
            self.printRequestInfo(requestTitle: requestTitle, response: response)
            _utils.removeIndicator()
            
            switch response.result {
            case .success(let value):
//                self.binding.bindingReviewList(json: JSON(value), completion: completion)
                let json = JSON(value)
                let requestTitle = "[리뷰 목록 조회]"
                let msg = json["resMsg"].stringValue
                
                guard json["resCd"].stringValue == "0000" else {
                    _log.logWithArrow("\(requestTitle) failed", msg)
                    completion?(false, msg)
                    return
                }
                
                CarryUser.review.reset()
                var allReviews: [Review] = []
                var totalReviewPoint: Float = 0
                let reviewArr = json["getBuyerUserReviewList"].arrayValue
                for value in reviewArr {
                    let reviewSeq = value["REVIEW_SEQ"].stringValue
                    let orderSeq = value["ORDER_SEQ"].stringValue
                    let userSeq = value["USER_SEQ"].stringValue
                    let content = value["REVIEW_BODY"].stringValue
                    let point = value["REVIEW_POINT"].floatValue
                    let name = value["USER_NAME"].stringValue
                    let date = value["ORDER_DATE"].stringValue
                    let upperReviewSeq = value["UPPER_REVIEW_SEQ"].stringValue
                    let review = Review(reviewSeq: reviewSeq, upperReviewSeq: upperReviewSeq, orderSeq: orderSeq, userSeq: userSeq, content: content, name: name, date: date, point: point)
                    allReviews.append(review)
                }
                
                // --------------------------------------- 리뷰인지 댓글인지 구분함 --------------------------------------- //
                
                // 리뷰에 댓글 내용 적용
                var replySeq: [String] = []
                for review in allReviews {
                    if let reply = allReviews.filter({ $0.upperReviewSeq == review.reviewSeq }).first {
                        review.reply = reply.content
                        replySeq.append(reply.reviewSeq)
                    }
                }
                
                // 댓글이면 리뷰 목록에서 삭제
                for seq in replySeq {
                    allReviews.removeAll(where: { $0.reviewSeq == seq })
                }
                
                // 실제 리뷰 데이터에 대입
                CarryUser.review.reviews.append(contentsOf: allReviews)
                
                // ------------------------------------------------------------------------------------------------- //
                
                
                // 평점
                CarryUser.review.reviews.forEach({ totalReviewPoint += $0.point })
                
                let carrierBaseAvgPoint = json["getSelfAvgReviewPoint"]["AVG_POINT"].floatValue
                CarryUser.review.carrierBaseAvg = carrierBaseAvgPoint
                
                let reviewAvg = totalReviewPoint / Float(reviewArr.count)
                CarryUser.review.reviewAvg = reviewAvg
                
                _log.log("\(requestTitle) success")
                completion?(true, "")
                
            case .failure(let error):
                _log.logWithArrow("\(requestTitle) failed", error.localizedDescription)
                completion?(false, error.localizedDescription)
            }
        }
        
    }
    
    
    // MARK:- 댓글 작성
    func requestWriteReply(upperReviewSeq: String, upperUserSeq: String, orderSeq: String, reply: String, completion: ((Bool, String) -> Void)? = nil) {
        
        //-------------------------- Request -------------------------- //
        //
        //         USER_BUYER_SEQ       리뷰 작성하는 사용자 시퀀스
        //         USER_SEQ             운송사업자 시퀀스
        //         ORDER_SEQ            결제 시퀀스
        //         REVIEW_POINT         리뷰 점수
        //         REVIEW_BODY          리뷰 내용
        //
        //------------------------------------------------------------- //
     
        
        if false == _utils.createIndicator() { return }
        
        let headers: HTTPHeaders = [
            "USER_TOKEN": CarryDatas.shared.user.token,
            "USER_ID": CarryDatas.shared.user.id,
            "USER_TYPE": CarrifreeAppType.appStorage.user
        ]
        
        let upperReviewPoint = CarryUser.review.reviews.filter({ $0.reviewSeq == upperReviewSeq }).first?.point ?? 0
        let param: Parameters = [
            "USER_TYPE": CarrifreeAppType.appStorage.user,
            "USER_BUYER_SEQ": CarryDatas.shared.user.seq,
            "USER_SEQ": CarryUser.seq,
            "ORDER_SEQ": orderSeq,
            "REVIEW_BODY": reply,
            "UPPER_REVIEW_SEQ": upperReviewSeq,
            "UPPER_USER_SEQ": upperUserSeq,
            "REVIEW_POINT": upperReviewPoint
        ]
        
        let urlString = "/sys/trans/app/setTransReviewMng.do"
        let url = getRequestUrl(body: urlString)
        
        AF.request(url, method: .post, parameters: param, headers: headers) { $0.timeoutInterval = 10 }.validate().responseJSON { (response) in
            
            let requestTitle = "[댓글 작성]"
            self.printRequestInfo(requestTitle: requestTitle, response: response)
            _utils.removeIndicator()
            
            switch response.result {
            case .success(let value):
                let jsonValue = JSON(value)
                let msg = jsonValue["resMsg"].stringValue
                
                if let result = jsonValue["resCd"].string {
                    if result == "0000" {
                        
                        _log.log("\(requestTitle) success")
                        completion?(true, "")
                    } else {
                        _log.logWithArrow("\(requestTitle) failed", msg)
                        completion?(false, msg)
                    }
                    
                } else {
                    _log.logWithArrow("\(requestTitle) failed", msg)
                    completion?(false, msg)
                }
            case .failure(let error):
                _log.logWithArrow("\(requestTitle) failed", error.localizedDescription)
                completion?(false, error.localizedDescription)
            }
        }
    }
    
    
    
    // MARK:- 사업자 승인 요청
    func requestBizApprove(completion: ResponseString = nil) {
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
        
        let headers: HTTPHeaders = [
            "USER_TOKEN": CarryUser.token,
            "USER_ID": CarryUser.id,
            "USER_TYPE": CarrifreeAppType.appStorage.user
        ]
        
        
        let param: [String: String] = [
            "USER_SEQ": CarryUser.seq,
            "USER_TYPE": CarrifreeAppType.appStorage.user,
            "USER_NAME": CarryUser.name
        ]
        
        
        let urlString = "/sys/member/app/setAuthCheck.do"
        let url = getRequestUrl(body: urlString)
        api = .bizApprove
        
        AF.request(url, method: .post, parameters: param, headers: headers) { $0.timeoutInterval = self.timeoutInterval }.validate().responseJSON { (response) in
            
            let requestTitle = "[사업자 승인 요청]"
            self.printRequestInfo(requestTitle: requestTitle, response: response)
            
            switch response.result {
            case .success(let value):
                let jsonValue = JSON(value)
                let msg = jsonValue["resMsg"].stringValue
                guard jsonValue["resCd"].stringValue == "0000" else {
                    _log.logWithArrow("\(requestTitle) failed", msg)
                    completion?(false, msg)
                    return
                }
                
                CarryUser.mainTap.approval = .wating
                _log.log("\(requestTitle) success")
                completion?(true, "")
                
            case .failure(let error):
                _log.logWithArrow("\(requestTitle) 실패", error.localizedDescription)
                completion?(false, error.localizedDescription)
            }
            
            self.api = .none
        }
    }
    
    // MARK:- 업종 등록
    func requestUpdateCategory(category: String, completion: ResponseString = nil) {
        //--------------------------
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
        
        let headers: HTTPHeaders = [
            "USER_TOKEN": CarryUser.token,
            "USER_ID": CarryUser.id,
            "USER_TYPE": CarrifreeAppType.appStorage.user
        ]
        
        
        let param: [String: String] = [
            "USER_TYPE": CarrifreeAppType.appStorage.user,
            "USER_SEQ": CarryUser.seq,
            "MASTER_SEQ": CarryUser.masterSeq,
            "CD_BIZ_TYPE": category
        ]
        
        
        let urlString = "/sys/memberV2/app/setBizTypeUpdate.do"
        let url = getRequestUrl(body: urlString)
        api = .updateCategory
        
        AF.request(url, method: .post, parameters: param, headers: headers) { $0.timeoutInterval = self.timeoutInterval }.validate().responseJSON { (response) in
            
            let requestTitle = "[업종 등록]"
            self.printRequestInfo(requestTitle: requestTitle, response: response)
            
            switch response.result {
            case .success(let value):
                let jsonValue = JSON(value)
                let msg = jsonValue["resMsg"].stringValue
                guard jsonValue["resCd"].stringValue == "0000" else {
                    _log.logWithArrow("\(requestTitle) failed", msg)
                    completion?(false, msg)
                    return
                }
                
                CarryUser.bizType = category
                _log.log("\(requestTitle) success")
                completion?(true, "")
                
            case .failure(let error):
                _log.logWithArrow("\(requestTitle) 실패", error.localizedDescription)
                completion?(false, error.localizedDescription)
            }
            
            self.api = .none
        }
    }
    
    // MARK:- 상호명 등록
    func requestUpdateName(name: String, regStep: Int, completion: ResponseString = nil) {
        //-------------------------- Request -------------------------- //
        //
        //      USER_SEQ            유저 seq
        //      MASTER_SEQ          마스터 seq
        //      BIZ_NAME            상호명
        //      REG_STEP            사업자 등록 단계
        //
        //------------------------------------------------------------- //
        //
        //
        //
        //-------------------------- Response ------------------------- //
        //
        //------------------------------------------------------------- //
        
        let headers: HTTPHeaders = [
            "USER_TOKEN": CarryUser.token,
            "USER_ID": CarryUser.id,
            "USER_TYPE": CarrifreeAppType.appStorage.user
        ]
        
        let param: Parameters = [
            "USER_TYPE": CarrifreeAppType.appStorage.user,
            "USER_SEQ": CarryUser.seq,
            "MASTER_SEQ": CarryUser.masterSeq,
            "BIZ_NAME": name,
            "REG_STEP": regStep
        ]
        
        
        let urlString = "/sys/memberV2/app/setBizNameUpdate.do"
        let url = getRequestUrl(body: urlString)
        api = .updateBizName
        
        AF.request(url, method: .post, parameters: param, headers: headers) { $0.timeoutInterval = self.timeoutInterval }.validate().responseJSON { (response) in
            
            let requestTitle = "[상호명 등록]"
            self.printRequestInfo(requestTitle: requestTitle, response: response)
            
            switch response.result {
            case .success(let value):
                let jsonValue = JSON(value)
                let msg = jsonValue["resMsg"].stringValue
                guard jsonValue["resCd"].stringValue == "0000" else {
                    _log.logWithArrow("\(requestTitle) failed", msg)
                    completion?(false, msg)
                    return
                }
                
                CarryUser.bizName = name
                _log.log("\(requestTitle) success")
                completion?(true, "")
                
            case .failure(let error):
                _log.logWithArrow("\(requestTitle) 실패", error.localizedDescription)
                completion?(false, error.localizedDescription)
            }
            
            self.api = .none
        }
    }
    
    // MARK:- 폰번호 등록
    func requestUpdatePhone(tel: String, phone: String, regStep: Int, completion: ResponseString = nil) {
        //-------------------------- Request -------------------------- //
        //
        //      USER_SEQ            유저 seq
        //      MASTER_SEQ          마스터 seq
        //      USER_HP_NO          폰번호
        //      BIZ_TEL             매장 전화번호
        //      REG_STEP            사업자 등록 단계
        //
        //------------------------------------------------------------- //
        //
        //
        //
        //-------------------------- Response ------------------------- //
        //
        //------------------------------------------------------------- //
        
        let headers: HTTPHeaders = [
            "USER_TOKEN": CarryUser.token,
            "USER_ID": CarryUser.id,
            "USER_TYPE": CarrifreeAppType.appStorage.user
        ]
        
        let param: Parameters = [
            "USER_TYPE": CarrifreeAppType.appStorage.user,
            "USER_SEQ": CarryUser.seq,
            "MASTER_SEQ": CarryUser.masterSeq,
            "USER_HP_NO": phone,
            "BIZ_TEL": tel,
            "REG_STEP": regStep
        ]
        
        let urlString = "/sys/memberV2/app/setUserHpNoUpdate.do"
        let url = getRequestUrl(body: urlString)
        api = .updateBizName
        
        AF.request(url, method: .post, parameters: param, headers: headers) { $0.timeoutInterval = self.timeoutInterval }.validate().responseJSON { (response) in
            
            let requestTitle = "[폰번호 등록]"
            self.printRequestInfo(requestTitle: requestTitle, response: response)
            
            switch response.result {
            case .success(let value):
                let jsonValue = JSON(value)
                let msg = jsonValue["resMsg"].stringValue
                guard jsonValue["resCd"].stringValue == "0000" else {
                    _log.logWithArrow("\(requestTitle) failed", msg)
                    completion?(false, msg)
                    return
                }
                
                CarryUser.phone = phone
                CarryUser.otherPhone = tel
                _log.log("\(requestTitle) success")
                completion?(true, "")
                
            case .failure(let error):
                _log.logWithArrow("\(requestTitle) 실패", error.localizedDescription)
                completion?(false, error.localizedDescription)
            }
            
            self.api = .none
        }
    }
    
    // MARK:- 주소 등록
    func requestUpdateAddress(address: String, addressDetail: String, lat: Double, lng: Double, regStep: Int, completion: ResponseString = nil) {
        //-------------------------- Request -------------------------- //
        //
        //      USER_SEQ            유저 seq
        //      MASTER_SEQ          마스터 seq
        //      BIZ_SIMPLE_ADDR     주소
        //      BIZ_DETAIL_ADDR     상세주소
        //      BIZ_LAT             위도
        //      BIZ_LNG             경도
        //      REG_STEP            사업자 등록 단계
        //
        //------------------------------------------------------------- //
        //
        //
        //
        //-------------------------- Response ------------------------- //
        //
        //------------------------------------------------------------- //
        
        let headers: HTTPHeaders = [
            "USER_TOKEN": CarryUser.token,
            "USER_ID": CarryUser.id,
            "USER_TYPE": CarrifreeAppType.appStorage.user
        ]
        
        let param: Parameters = [
            "USER_TYPE": CarrifreeAppType.appStorage.user,
            "USER_SEQ": CarryUser.seq,
            "MASTER_SEQ": CarryUser.masterSeq,
            "BIZ_SIMPLE_ADDR": address,
            "BIZ_DETAIL_ADDR": addressDetail,
            "BIZ_LAT": lat,
            "BIZ_LNG": lng,
            "REG_STEP": regStep
        ]
        
        let urlString = "/sys/memberV2/app/setUserAddrUpdate.do"
        let url = getRequestUrl(body: urlString)
        api = .updateBizName
        
        AF.request(url, method: .post, parameters: param, headers: headers) { $0.timeoutInterval = self.timeoutInterval }.validate().responseJSON { (response) in
            
            let requestTitle = "[주소 등록]"
            self.printRequestInfo(requestTitle: requestTitle, response: response)
            
            switch response.result {
            case .success(let value):
                let jsonValue = JSON(value)
                let msg = jsonValue["resMsg"].stringValue
                guard jsonValue["resCd"].stringValue == "0000" else {
                    _log.logWithArrow("\(requestTitle) failed", msg)
                    completion?(false, msg)
                    return
                }
                
                CarryUser.bizAddress = address
                CarryUser.bizAddressDetail = addressDetail
                CarryUser.lat = lat
                CarryUser.lng = lng
                _log.log("\(requestTitle) success")
                completion?(true, "")
                
            case .failure(let error):
                _log.logWithArrow("\(requestTitle) 실패", error.localizedDescription)
                completion?(false, error.localizedDescription)
            }
            
            self.api = .none
        }
    }
    
    // MARK:- 계좌 등록
    func requestUpdateBank(bankCode: String, bankAccount: String, bankAccountHolder: String, regStep: Int, completion: ResponseString = nil) {
        //-------------------------- Request -------------------------- //
        //
        //      USER_SEQ            유저 seq
        //      MASTER_SEQ          마스터 seq
        //      BANK_CD             은행 코드
        //      BANK_PRIVATE_NO     계좌 번호
        //      BANK_USER_NAME      예금주
        //      REG_STEP            사업자 등록 단계
        //
        //------------------------------------------------------------- //
        //
        //
        //
        //-------------------------- Response ------------------------- //
        //
        //------------------------------------------------------------- //
        
        let headers: HTTPHeaders = [
            "USER_TOKEN": CarryUser.token,
            "USER_ID": CarryUser.id,
            "USER_TYPE": CarrifreeAppType.appStorage.user
        ]
        
        let param: Parameters = [
            "USER_TYPE": CarrifreeAppType.appStorage.user,
            "USER_SEQ": CarryUser.seq,
            "MASTER_SEQ": CarryUser.masterSeq,
            "BANK_CD": bankCode,
            "BANK_PRIVATE_NO": bankAccount,
            "BANK_USER_NAME": bankAccountHolder,
            "REG_STEP": regStep
        ]
        
        let urlString = "/sys/memberV2/app/setMoneySerialUpdate.do"
        let url = getRequestUrl(body: urlString)
        api = .updateBizName
        
        AF.request(url, method: .post, parameters: param, headers: headers) { $0.timeoutInterval = self.timeoutInterval }.validate().responseJSON { (response) in
            
            let requestTitle = "[계좌 등록]"
            self.printRequestInfo(requestTitle: requestTitle, response: response)
            
            switch response.result {
            case .success(let value):
                let jsonValue = JSON(value)
                let msg = jsonValue["resMsg"].stringValue
                guard jsonValue["resCd"].stringValue == "0000" else {
                    _log.logWithArrow("\(requestTitle) failed", msg)
                    completion?(false, msg)
                    return
                }
                
                CarryUser.bankCode = bankCode
                CarryUser.bankAccount = bankAccount
                CarryUser.bankAccountHolder = bankAccountHolder
                _log.log("\(requestTitle) success")
                completion?(true, "")
                
            case .failure(let error):
                _log.logWithArrow("\(requestTitle) 실패", error.localizedDescription)
                completion?(false, error.localizedDescription)
            }
            
            self.api = .none
        }
    }
    
    // MARK:- 보관 관련 정보 등록
    func requestSetStorageInfo(pictureGrpSeq: String, horizontal: String, vertical: String, height: String, mainImageData: Data?, imageDatas: [Data?], deletedSeq: String, completion: ResponseString = nil) {
        
        //-------------------------- Request -------------------------- //
        //
        //         USER_SEQ         사용자 시퀀스
        //         MASTER_SEQ       사용자 마스터 시퀀스
        //         VECHILE_TYPE     수단 타입
        //         VECHILE_HTL      가로
        //         VECHILE_VCL      세로
        //         VECHILE_HGT      높이
        //         module           첨부파일 저장 공간 코드
        //         ATTACH_TYPE      첨부파일 구분
        //         fileList         첨부파일 객체명
        //
        //------------------------------------------------------------- //
        //
        //
        //
        //-------------------------- Response ------------------------- //
        //
        //          attachGrpSeq    첨부파일 코드(다음페이지로 넘겨서 위 코드를 전달한다)
        //
        //------------------------------------------------------------- //
        
        if false == _utils.createIndicator() { return }
        
        let headers: HTTPHeaders = [
            "USER_TOKEN": CarryDatas.shared.user.token,
            "USER_ID": CarryDatas.shared.user.id,
            "USER_TYPE": CarrifreeAppType.appStorage.user
        ]
        
        var param: [String: String] = [
            "USER_TYPE": CarrifreeAppType.appStorage.user,
            "USER_SEQ": CarryUser.seq,
            "MASTER_SEQ": CarryUser.masterSeq,
            "VECHILE_TYPE": "004",
            "VECHILE_HTL": horizontal,
            "VECHILE_VCL": vertical,
            "VECHILE_HGT": height,
            "ATTACH_GRP_SEQ": pictureGrpSeq,
            "module": "3"
        ]
        
        let attach = "ATTACH_TYPE"
//        let attachType012 = _identifiers[.pictureType012]
        let attachType013 = _identifiers[.pictureType013]
        let attachType014 = _identifiers[.pictureType014]

        
        var urlString = ""
        if pictureGrpSeq.isEmpty {
            urlString = "/sys/saverV2/app/setWayInsert.do"
        } else {
            urlString = "/sys/saverV2/app/setWayUpdate.do"
            param["DEL_SEQ"] = deletedSeq
            param["USER_VECHILE_SEQ"] = CarryUser.vehicleSeq
        }
        
        let url = getRequestUrl(body: urlString)
        api = .setBizStorageInfo
        AF.upload(multipartFormData: { multipartFormData in
            
            // multipart 데이터 생성 (parameters)
            for (key, value) in param {
                multipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: key)
            }
            
            // multipart 데이터 생성 (images)
            if let mainImageData = mainImageData {
                multipartFormData.append(mainImageData, withName: "fileList", fileName: "main.jpg", mimeType: "image/jpeg")
                multipartFormData.append(attachType014.data(using: .utf8)!, withName: attach)
            }
            
            for (index, data) in imageDatas.enumerated() {
                guard let imgData = data else { continue }
                multipartFormData.append(imgData, withName: "fileList", fileName: "\(index).jpg", mimeType: "image/jpeg")
                multipartFormData.append(attachType013.data(using: .utf8)!, withName: attach)
            }
            
            /*
            for (index, data) in imageDatas012.enumerated() {
                guard let imgData = data else { continue }
                multipartFormData.append(imgData, withName: "fileList", fileName: "\(index).jpg", mimeType: "image/jpeg")
                multipartFormData.append(attachType012.data(using: .utf8)!, withName: attach)
            }
            
            for (index, data) in imageDatas013.enumerated() {
                guard let imgData = data else { continue }
                multipartFormData.append(imgData, withName: "fileList", fileName: "\(index).jpg", mimeType: "image/jpeg")
                multipartFormData.append(attachType013.data(using: .utf8)!, withName: attach)
            }
            
            for (index, data) in imageDatas014.enumerated() {
                guard let imgData = data else { continue }
                multipartFormData.append(imgData, withName: "fileList", fileName: "\(index).jpg", mimeType: "image/jpeg")
                multipartFormData.append(attachType014.data(using: .utf8)!, withName: attach)
            }
            */
        }, to: url, method: .post, headers: headers) { $0.timeoutInterval = 10 }.validate().responseJSON { (response) in
            
            _utils.removeIndicator()
            
            let requestTitle = "[보관소 정보 등록 요청]"
            self.printRequestInfo(requestTitle: requestTitle, response: response)
            
            switch response.result {
            case .success(let value):
                let jsonValue = JSON(value)
                if let result = jsonValue["resCd"].string {
                    if result == "0000" {
                        let attachGrpSeq = jsonValue["attachGrpSeq"].stringValue
                        
                        CarryUser.configureStorage(horizontal: horizontal, vertical: vertical, height: height, vehicleType: "004", vehicleSeq: CarryUser.vehicleSeq, introduce: CarryUser.introduce, attachGrpSeq: attachGrpSeq)
                        
                        completion?(true, "")
                        _log.log("\(requestTitle) 성공")
                    } else {
                        completion?(false, jsonValue["resMsg"].stringValue)
                        _log.logWithArrow("\(requestTitle) 실패", jsonValue["resMsg"].stringValue)
                    }
                } else {
                    _log.logWithArrow("\(requestTitle) 실패", jsonValue["resMsg"].stringValue)
                    completion?(false, jsonValue["resMsg"].stringValue)
                }
            case .failure(let error):
                _log.logWithArrow("\(requestTitle) 실패", error.localizedDescription)
                completion?(false, error.localizedDescription)
            }
            
            self.api = .none
        }
    }
    
    
    // MARK:- 소개글 등록
    func requestUpdatePr(pr: String, completion: ResponseString = nil) {
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
        
        let headers: HTTPHeaders = [
            "USER_TOKEN": CarryUser.token,
            "USER_ID": CarryUser.id,
            "USER_TYPE": CarrifreeAppType.appStorage.user
        ]
        
        let param: Parameters = [
            "USER_TYPE": CarrifreeAppType.appStorage.user,
            "USER_SEQ": CarryUser.seq,
            "USER_VECHILE_SEQ": CarryUser.vehicleSeq,
            "CARRYING_ISSUE": pr
        ]
        
        let urlString = "/sys/saverV2/app/setIusseUpdate.do"
        let url = getRequestUrl(body: urlString)
        api = .updateBizName
        
        AF.request(url, method: .post, parameters: param, headers: headers) { $0.timeoutInterval = self.timeoutInterval }.validate().responseJSON { (response) in
            
            let requestTitle = "[소개글 등록]"
            self.printRequestInfo(requestTitle: requestTitle, response: response)
            
            switch response.result {
            case .success(let value):
                let jsonValue = JSON(value)
                let msg = jsonValue["resMsg"].stringValue
                guard jsonValue["resCd"].stringValue == "0000" else {
                    _log.logWithArrow("\(requestTitle) failed", msg)
                    completion?(false, msg)
                    return
                }
                
                CarryUser.introduce = pr
                _log.log("\(requestTitle) success")
                completion?(true, "")
                
            case .failure(let error):
                _log.logWithArrow("\(requestTitle) 실패", error.localizedDescription)
                completion?(false, error.localizedDescription)
            }
            
            self.api = .none
        }
    }
    
    // MARK:- 사업자 등록 단계 Update
    func requestUpdateRegistrationStep(step: Int, completion: ResponseString = nil) {
        //-------------------------- Request -------------------------- //
        //
        //      USER_SEQ            유저 seq
        //      REG_STEP            단계
        //
        //------------------------------------------------------------- //
        //
        //
        //
        //-------------------------- Response ------------------------- //
        //
        //------------------------------------------------------------- //
        
        let headers: HTTPHeaders = [
            "USER_TOKEN": CarryUser.token,
            "USER_ID": CarryUser.id,
            "USER_TYPE": CarrifreeAppType.appStorage.user
        ]
        
        let param: Parameters = [
            "USER_TYPE": CarrifreeAppType.appStorage.user,
            "USER_SEQ": CarryUser.seq,
            "REG_STEP": step
        ]
        
        let urlString = "/sys/common/app/setStepUpdate.do"
        let url = getRequestUrl(body: urlString)
        api = .updateBizName
        
        AF.request(url, method: .post, parameters: param, headers: headers) { $0.timeoutInterval = self.timeoutInterval }.validate().responseJSON { (response) in
            
            let requestTitle = "[사업자 등록 단계 Update]"
            self.printRequestInfo(requestTitle: requestTitle, response: response)
            
            switch response.result {
            case .success(let value):
                let jsonValue = JSON(value)
                let msg = jsonValue["resMsg"].stringValue
                guard jsonValue["resCd"].stringValue == "0000" else {
                    _log.logWithArrow("\(requestTitle) failed", msg)
                    completion?(false, msg)
                    return
                }
                
                _log.log("\(requestTitle) success")
                completion?(true, "")
                
            case .failure(let error):
                _log.logWithArrow("\(requestTitle) 실패", error.localizedDescription)
                completion?(false, error.localizedDescription)
            }
            
            self.api = .none
        }
    }
    
    // MARK:- 부가기능 조회 (전체)
    func requestGetFeatures(myFeature: Bool, featureGrpSeq: String = "", completion: ResponseJson = nil) {
        //-------------------------- Request -------------------------- //
        //
        //
        //------------------------------------------------------------- //
        //
        //
        //
        //-------------------------- Response ------------------------- //
        //
        //------------------------------------------------------------- //
        
        let headers: HTTPHeaders = [
            "USER_TOKEN": CarryUser.token,
            "USER_ID": CarryUser.id,
            "USER_TYPE": CarrifreeAppType.appStorage.user
        ]
        
        var param: Parameters = [
            "USER_TYPE": CarrifreeAppType.appStorage.user
        ]
        var urlString = "/sys/common/app/getCdOptionInfo.do"
        if myFeature {
            urlString = "/sys/common/app/getOptionList.do"
            param["USER_SEQ"] = CarryUser.seq
            param["ITEM_GRP_CD"] = featureGrpSeq
        }
        let url = getRequestUrl(body: urlString)
        api = .updateBizName
        
        AF.request(url, method: .post, parameters: param, headers: headers) { $0.timeoutInterval = self.timeoutInterval }.validate().responseJSON { (response) in
            
            let requestTitle = "[부가기능 조회]"
            self.printRequestInfo(requestTitle: requestTitle, response: response)
            
            switch response.result {
            case .success(let value):
                completion?(true, JSON(value))
                
            case .failure(let error):
                _log.logWithArrow("\(requestTitle) failed", error.localizedDescription)
                completion?(false, JSON(response))
            }
            
            self.api = .none
        }
    }
    
    // MARK:- 부가기능 등록
    func requestUpdateFeatures(isFirstRegistration: Bool, features: String, featureSeq: String, completion: ResponseString = nil) {
        //-------------------------- Request -------------------------- //
        //
        //      USER_SEQ            유저 seq
        //      ITEM_CD_ARR         부가기능 코드 ( , 로 구분)
        //      ITEM_GRP_CD         부가기능 그룹 코드
        //
        //------------------------------------------------------------- //
        //
        //
        //
        //-------------------------- Response ------------------------- //
        //
        //------------------------------------------------------------- //
        
        let headers: HTTPHeaders = [
            "USER_TOKEN": CarryUser.token,
            "USER_ID": CarryUser.id,
            "USER_TYPE": CarrifreeAppType.appStorage.user
        ]
        
        let param: Parameters = [
            "USER_TYPE": CarrifreeAppType.appStorage.user,
            "USER_SEQ": CarryUser.seq,
            "ITEM_CD_ARR": features,
            "ITEM_GRP_CD": featureSeq
        ]
        
        var urlString = "/sys/common/app/setOptionUpdate.do"
        if isFirstRegistration { urlString = "/sys/common/app/setOptionInsert.do" }
        
        let url = getRequestUrl(body: urlString)
        api = .updateBizName
        
        AF.request(url, method: .post, parameters: param, headers: headers) { $0.timeoutInterval = self.timeoutInterval }.validate().responseJSON { (response) in
            
            let requestTitle = "[부가기능 등록]"
            self.printRequestInfo(requestTitle: requestTitle, response: response)
            
            switch response.result {
            case .success(let value):
                let jsonValue = JSON(value)
                let msg = jsonValue["resMsg"].stringValue
                guard jsonValue["resCd"].stringValue == "0000" else {
                    _log.logWithArrow("\(requestTitle) failed", msg)
                    completion?(false, msg)
                    return
                }
                
                _log.log("\(requestTitle) success")
                completion?(true, "")
                
            case .failure(let error):
                _log.logWithArrow("\(requestTitle) 실패", error.localizedDescription)
                completion?(false, error.localizedDescription)
            }
            
            self.api = .none
        }
    }
    
    
    // MARK:- 사업자등록번호 등록
    func requestUpdateBizNumber(bizNumber: String, step: Int, completion: ResponseString = nil) {
        //-------------------------- Request -------------------------- //
        //
        //      USER_SEQ            유저 seq
        //      MASTER_SEQ          마스터 seq
        //      BIZ_GUBN            002로 전달
        //      BIZ_CORP_NO         사업자등록번호
        //      REG_STEP            등록 단계
        //
        //------------------------------------------------------------- //
        //
        //
        //
        //-------------------------- Response ------------------------- //
        //
        //------------------------------------------------------------- //
        
        let headers: HTTPHeaders = [
            "USER_TOKEN": CarryUser.token,
            "USER_ID": CarryUser.id,
            "USER_TYPE": CarrifreeAppType.appStorage.user
        ]
        
        let param: Parameters = [
            "USER_TYPE": CarrifreeAppType.appStorage.user,
            "USER_SEQ": CarryUser.seq,
            "MASTER_SEQ": CarryUser.masterSeq,
            "BIZ_GUBN": "002",
            "BIZ_CORP_NO": bizNumber,
            "REG_STEP": step
        ]
        
        let urlString = "/sys/memberV2/app/setCorpNoUpdate.do"
        
        let url = getRequestUrl(body: urlString)
        api = .updateBizNumber
        
        AF.request(url, method: .post, parameters: param, headers: headers) { $0.timeoutInterval = self.timeoutInterval }.validate().responseJSON { (response) in
            
            let requestTitle = "[사업자등록번호 등록]"
            self.printRequestInfo(requestTitle: requestTitle, response: response)
            
            switch response.result {
            case .success(let value):
                let jsonValue = JSON(value)
                let msg = jsonValue["resMsg"].stringValue
                guard jsonValue["resCd"].stringValue == "0000" else {
                    _log.logWithArrow("\(requestTitle) failed", msg)
                    completion?(false, msg)
                    return
                }
                
                CarryUser.bizCorpNo = bizNumber
                _log.log("\(requestTitle) success")
                completion?(true, "")
                
            case .failure(let error):
                _log.logWithArrow("\(requestTitle) 실패", error.localizedDescription)
                completion?(false, error.localizedDescription)
            }
            
            self.api = .none
        }
    }
    
    // MARK:- 사업자등록증 사진 등록
    func requestUpdateBizCert(imgData: Data?, step: Int, completion: ResponseString = nil) {
        //-------------------------- Request -------------------------- //
        //
        //      USER_SEQ            유저 seq
        //      MASTER_SEQ          마스터 seq
        //      BIZ_GUBN            002로 전달
        //      BIZ_CORP_NO         사업자등록번호
        //      REG_STEP            등록 단계
        //
        //------------------------------------------------------------- //
        //
        //
        //
        //-------------------------- Response ------------------------- //
        //
        //------------------------------------------------------------- //
        
        if false == _utils.createIndicator() { return }
        
        let headers: HTTPHeaders = [
            "USER_TOKEN": CarryUser.token,
            "USER_ID": CarryUser.id,
            "USER_TYPE": CarrifreeAppType.appStorage.user
        ]
        
        let attachYn = imgData == nil ? "N" : "Y"
        
        let param: [String: String] = [
            "USER_TYPE": CarrifreeAppType.appStorage.user,
            "USER_SEQ": CarryUser.seq,
            "MASTER_SEQ": CarryUser.masterSeq,
            "ATTACH_YN": attachYn,
            "REG_STEP": String(step),
            "module": "3"
        ]
        
        let attach = "ATTACH_TYPE"
        let attachType = "001"
        let urlString = "/sys/memberV2/app/setCorpPictureUpdate.do"
        
        let url = getRequestUrl(body: urlString)
        api = .updateCert
        
        // api 요청 후 응답 처리
        func registrationResponse(response : AFDataResponse<Any>) {
            _utils.removeIndicator()
            let requestTitle = "[사업자등록증 사진 등록]"
            self.printRequestInfo(requestTitle: requestTitle, response: response)
            
            switch response.result {
            case .success(let value):
                let jsonValue = JSON(value)
                let msg = jsonValue["resMsg"].stringValue
                guard jsonValue["resCd"].stringValue == "0000" else {
                    _log.logWithArrow("\(requestTitle) failed", msg)
                    completion?(false, msg)
                    return
                }
                
                
                _log.log("\(requestTitle) success")
                completion?(true, "")
                
            case .failure(let error):
                _log.logWithArrow("\(requestTitle) 실패", error.localizedDescription)
                completion?(false, error.localizedDescription)
            }
            
            self.api = .none
        }
        
        // 이미지가 있으면 multipart 형식으로 전송
        if let imgData = imgData {
            AF.upload(multipartFormData: { multipartFormData in
                
                // multipart 데이터 생성 (parameters)
                for (key, value) in param {
                    multipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: key)
                }
                
                // multipart 데이터 생성 (images)
                multipartFormData.append(imgData, withName: "fileList", fileName: "main.jpg", mimeType: "image/jpeg")
                multipartFormData.append(attachType.data(using: .utf8)!, withName: attach)
                
            }, to: url, method: .post, headers: headers) { $0.timeoutInterval = 10 }.validate().responseJSON { (response) in
                registrationResponse(response: response)
            }
        }
        // 이미지가 없으면 그냥 전송
        else {
            AF.request(url, method: .post, parameters: param, headers: headers) { $0.timeoutInterval = self.timeoutInterval }.validate().responseJSON { (response) in
                registrationResponse(response: response)
            }
        }
    }
}

*/
