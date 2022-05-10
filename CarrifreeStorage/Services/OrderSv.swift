//
//  OrderSv.swift
//  CarrifreeStorage
//
//  Created by plattics-kwon on 2021/11/11.
//
//
//  💬 ## OrderSv ##
//  💬 주문(의뢰) 관련 API 모음
//

import Foundation
import Alamofire
import SwiftyJSON

class OrderSv: Service {
    let apiManager: ApiManager
    
    init(apiManager: ApiManager) {
        self.apiManager = apiManager
    }
    
    // MARK: 의뢰 목록 요청
    /// 의뢰 목록 요청
    func getOrders(orderCategory: String, orderStatus: String, page: Int, orderNo: String = "", orderName: String = "", completion: ResponseJson = nil) {
        //-------------------------- Request -------------------------- //
        //
        //      ENTRUST_BASE_SEQ        유저 시퀀스
        //      ORDER_STATUS            의뢰 진행 상황 (예약: 002, 보관: 006, 찾음: 008)
        //      ORDER_SEQ               주문 시퀀스
        //      DELIVERY_NO             주문 번호
        //      BUYER_NAME              고객 이름
        //
        //------------------------------------------------------------- //
        //
        //
        //
        //-------------------------- Response ------------------------- //
        //
        //      [payFinishSaveList]
        //      REAL_STORE_TIME         <Number>        실제 보관 시간(분)
        //      ORDER_DATE              <String>        요청 일자(월-일 시:분)
        //      PAY_STATUS              <String>        결제 상태
        //      ATTACH_GRP_SEQ          <Number>        첨부 파일 그룹 시퀀스
        //      ENTRUST_BASE_SEQ        <Number>        보관사업자 시퀀스
        //      MAJOR_ATTACH_INFO       <String>        첨부 파일 정보
        //      EXPECT_STORE_TIME       <Number>        예약 보관 시간(분)
        //      ENTRUST_ADDR            <String>        보관소 주소
        //      PROCESS_DATE            <String>        PROCESS_DATE
        //      DELIVERY_NO             <String>        주문 번호
        //      ORDER_SEQ               <Number>        주문 번호 시퀀스
        //      ORDER_STATUS            <String>        주문 상태
        //      ORDER_KIND              <String>        주문 종류
        //      BOX_CNT                 <Number>        박스 수량(주문 건수)
        //      BUYER_NAME              <String>        고객 이름
        //
        //      (payFinishSaveItemCnt)
        //      BEFORE_CNT              <Number>        보관 예정
        //      ING_CNT                 <Number>        보관 중
        //      FINISH_CNT              <Number>        보관 완료
        //      resCd                   <String>        결과 코드
        //
        //------------------------------------------------------------- //
        
        
        guard let headers = getHeader() else { completion?(false, nil); return }
        
        var param: Parameters = [
            "ENTRUST_BASE_SEQ": _user.seq,
            "ORDER_STATUS": orderStatus
        ]
        
        if false == orderNo.isEmpty { param["DELIVERY_NO"] = orderNo }
        if false == orderName.isEmpty { param["BUYER_NAME"] = orderName }
        
//        let url = getRequestUrl(body: "/sys/payment/app/getSaverOrderInfo.do")
        let url = getRequestUrl(body: "/sys/wareHouseReq/app/getPaymentFinishSaveList.do")
        apiManager.request(api: .getOrders, url: url, headers: headers, parameters: param, completion: completion)
    }
    
    // MARK: 보관 의뢰 상세 정보 요청
    /// 보관 의뢰 상세 정보 요청
    func getOrderDetail(orderSeq: String, completion: ResponseJson = nil) {
        //-------------------------- Request -------------------------- //
        //
        //      USER_SEQ                보관사업자 시퀀스
        //      ORDER_SEQ               주문(예약) 시퀀스
        //
        //------------------------------------------------------------- //
        //
        //
        //
        //-------------------------- Response ------------------------- //
        //
        //      (payFinishSaveItem)
        //      REAL_STORE_TIME         <Number>        실제 보관 시간(분)
        //      ORDER_ATTACH_GRP_SEQ    <Number>        짐 사진 그룹 시퀀스
        //      ENTRUST_BASE_SEQ        <Number>        보관사업자 시퀀스
        //      USER_EMAIL              <String>        이메일
        //      TAKE_DATE               <String>        찾은 날짜(예약)
        //      ENTRUST_DATE            <String>        맡긴 날짜(예약)
        //      XL_TYPE                 <Number>        대형짐
        //      OVER_AMOUNT             <Number>        추가 요금
        //      ING_DATE                <String>        맡긴 날짜(실제)
        //      FINISH_DATE             <String>        찾은 날짜(실제)
        //      ORDER_STATUS            <String>        주문 상태
        //      L_TYPE                  <Number>        큰짐
        //      USER_HP_NO              <String>        연락처
        //      S_TYPE                  <Number>        미니짐
        //      ORDER_KIND_TEXT         <String>        주문 종류
        //      ORDER_DATE              <String>        주문 날짜
        //      EXPECT_STORE_TIME       <Number>        예약 시간(분)
        //      M_TYPE                  <Number>        중간짐
        //      BUYER_MEMO              <String>        요청 사항
        //      PAY_AMOUNT              <Number>        결제 금액
        //      DELIVERY_NO             <String>        주문 번호
        //      ORDER_SEQ               <Number>        주문 번호 시퀀스
        //      ORDER_KIND              <String>        주문 종류
        //      BUYER_NAME              <String>        이름
        //      USER_SEQ_BUYER          <Number>        주문의뢰자 시퀀스
        //      TOTAL_AMOUNT            <Number>        총 금액
        //
        //                                                          [boxList]
        //                                                          ITEM_QUANTITY   <Number>    짐 갯수
        //                                                          ITEM_KIND       <String>    짐 종류 코드
        //                                                          ITEM_KIND_TXT   <String>    짐 종류
        //
        //      resCd    String        결과 코드
        //
        //------------------------------------------------------------- //
        
        guard let headers = getHeader() else { completion?(false, nil); return }
        
        let param: Parameters = [
            "USER_SEQ": _user.seq,
            "ORDER_SEQ": orderSeq
        ]
        
//        let url = getRequestUrl(body: "/sys/payment/app/getSaverOrderDetail.do")
        let url = getRequestUrl(body: "/sys/wareHouseReq/app/getPaymentFinishSaveItem.do")
        apiManager.request(api: .getOrderDetail, url: url, headers: headers, parameters: param, completion: completion)
    }
    
    // MARK: 짐 사진 조회
    /// 짐 사진 조회
    func getLuggagePictures(userSeq: String, attachType: String, attachGrpSeq: String, orderSeq: String, completion: ResponseJson = nil) {
        // -------------------------- Request -------------------------- //
        //
        //      ORDER_SEQ               결제 시퀀스
        //      ATTACH_TYPE             파일 타입
        //      ORDER_ATTACH_GRP_SEQ    첨부파일 그룹 시퀀스
        //
        // ------------------------------------------------------------- //
        //
        //
        //
        // -------------------------- Response ------------------------- //
        //
        //      [orderPicList]
        //      ORDER_ATTACH_SEQ        첨부 파일 시퀀스
        //      ORDER_ATTACH_GRP_SEQ    첨부 파일 그룹 시퀀스
        //      ORDER_ATTACH_INFO       짐사진 url
        //      resCd                   결과 코드
        //
        // ------------------------------------------------------------- //
        
        guard let headers = getHeader() else { completion?(false, nil); return }
        
        let param: Parameters = [
            "USER_SEQ_BUYER": userSeq,
            "ATTACH_TYPE": attachType,
            "ORDER_ATTACH_GRP_SEQ": attachGrpSeq,
            "ORDER_SEQ": orderSeq
        ]
        
        let url = getRequestUrl(body: "/sys/payment/app/getOrderPicList.do")
        apiManager.request(api: .getOrderPictures, url: url, headers: headers, parameters: param, completion: completion)
    }
    
    
    // MARK: 의뢰 상태 변경
    /// 의뢰 상태 변경
    func updateOrderStatus(orderSeq: String, orderStatus: String, storageSeq: String, completion: ResponseJson = nil) {
        //-------------------------- Request -------------------------- //
        //
        //       USER_SEQ_BUYER      사용자 시퀀스
        //       ORDER_SEQ           결제 시퀀스
        //       ORDER_STATUS        운송사업자 명     (맡길때 006, 찾을때 008 보내면됨)
        //                                          002 : 결제 완료(최초상태)
        //                                          006 : 사용자가 짐을 맡기고 난후 처리 상태
        //                                          004 : 운송사업자가 짐을 받아 배송중인 상태
        //                                          005 : 운송사업자가 짐을 배송 완료한 상태
        //                                          008 : 사용자가 짐을 찾아 업무가 종료된 상태
        //                                          003 : 주문이 취소된 상태
        //
        //------------------------------------------------------------- //
        //
        //
        //
        //-------------------------- Response ------------------------- //
        //
        //------------------------------------------------------------- //
        
        guard let headers = getHeader() else { completion?(false, nil); return }
        
        let param: Parameters = [
            "USER_TYPE": CarrifreeAppType.appStorage.user,
            "USER_SEQ_BUYER": _user.seq,
            "ORDER_SEQ": orderSeq,
            "ORDER_STATUS": orderStatus,
            "ENTRUST_BASE_SEQ": storageSeq
        ]
        
        let url = getRequestUrl(body: "/sys/payment/app/setChangePaymentProcess.do")
        apiManager.request(api: .updateOrderStatus, url: url, headers: headers, parameters: param, completion: completion)
    }
}

