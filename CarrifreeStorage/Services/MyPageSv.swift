//
//  MyPageSv.swift
//  CarrifreeStorage
//
//  Created by plattics-kwon on 2021/12/20.
//

import Foundation
import SwiftyJSON
import Alamofire

class MyPageSv: Service {

    let apiManager: ApiManager
    
    init(apiManager: ApiManager) {
        self.apiManager = apiManager
    }
    
    // MARK: - 회원 탈퇴
    func requestWithdrawal(completion: ResponseJson = nil) {
        // -------------------------- Request -------------------------- //
        //
        //      USER_ID             유저 ID
        //      USER_SEQ            유저 시퀀스
        //
        // ------------------------------------------------------------- //
        //
        //
        // -------------------------- Response ------------------------- //
        //
        // ------------------------------------------------------------- //
        
        guard let headers = getHeader() else { completion?(false, nil); return }
        
        let param: Parameters = [
            "USER_TYPE": CarrifreeAppType.appStorage.user,
            "USER_ID": _user.id,
            "USER_SEQ": _user.seq
        ]
        
        let url = getRequestUrl(body: "/sys/member/app/dropMember.do")
        apiManager.request(api: .withdraw, url: url, headers: headers, parameters: param)
    }
    
    // MARK: - 프로필 사진 조회
    func getProfilePicture(completion: ResponseJson = nil) {
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
        //      USER_ATTACH_INFO        프로필 사진
        //      ATTACH_GRP_SEQ          프로필 사진 시퀀스
        //
        //------------------------------------------------------------- //
        
        guard let headers = getHeader() else { completion?(false, nil); return }
        
        let param: Parameters = [
            "USER_TYPE": CarrifreeAppType.appStorage.user,
            "USER_SEQ": _user.seq
        ]
        
        let url = getRequestUrl(body: "/sys/member/app/getProfileImage.do")
        apiManager.request(api: .getProfilePicture, url: url, headers: headers, parameters: param, completion: completion)
    }
    
    
    // MARK: - 프로필 사진 등록
    func registerProfilePicture(attachGrpSeq: String, imgData: Data, completion: ResponseJson = nil) {
        // -------------------------- Request -------------------------- //
        //
        //      USER_SEQ                사용자 시퀀스
        //      ATTACH_TYPE             저장 구분 (고정값: 016)
        //      ATTACH_GRP_SEQ          파일 시퀀스
        //      fileList                첨부 파일
        //      module                  모듈 번호 (고정값: 1)
        //
        // ------------------------------------------------------------- //
        //
        //
        //
        // -------------------------- Response ------------------------- //
        //
        // ------------------------------------------------------------- //
        
        guard let headers = getHeader() else { completion?(false, nil); return }
        
        let param: [String: String] = [
            "USER_TYPE": CarrifreeAppType.appStorage.user,
            "USER_SEQ": _user.seq,
            "ATTACH_GRP_SEQ": attachGrpSeq,
            "module": "1"
        ]
        
        let attaches: AttachForm = [("016", [imgData])]
        let url = getRequestUrl(body: "/sys/member/app/setProfileImage.do")
        apiManager.requestAttach(api: .registerProfilePicture, url: url, headers: headers, parameters: param, attaches: attaches, completion: completion)
    }
}
