//
//  UserData.swift
//  CarrifreeStorage
//
//  Created by plattics-kwon on 2021/12/17.
//

import Foundation
import SwiftyJSON

var _user: UserData = {
    return UserData.shared
}()


struct UserData {
    static let shared = UserData(signIn: false, id: "", pw: "", name: "", seq: "", masterSeq: "", token: "", email: "", contact: "", joinType: "", code: "")
    
    var id: String
    var pw: String
    var signIn: Bool                    // 로그인 여부
    var name: String                    // 이름 (업체명이 아닌 가입시 작성한 이름)
    var seq: String                     // 유저 seq
    var masterSeq: String               // 마스터 seq
    var token: String                   // 토큰 (모든 API 요청 헤더에 사용)
    var email: String                   // 이메일
    var contact: String                 // 연락처
    var joinType: String                // 가입 방식 (일반, 소셜)
    var code: String                    // 유저 코드
    var stored: Bool = false            // 매장 정보 등록 여부
    var bizName: String = ""            // 상호명
    var attachGrpSeq: String = ""
     
    var signcase: SignCase {            // 가입 방식 타입 (일반, 소셜)
        get {
            switch joinType {
            case SignCase.kakao.type: return .kakao
            case SignCase.facebook.type: return .facebook
            case SignCase.naver.type: return .naver
            case SignCase.apple.type: return .apple
            case SignCase.google.type: return .google
            default: return .normal
            }
        }
    }
    
    lazy var monthlySales = "0"                 // 월 매출
    lazy var approval = ApprovalStatus.none     // 사업자 승인 상태
    lazy var profilePicture = PictureData()     // 프로필 사진
    
    private init(signIn: Bool, id: String, pw: String, name: String, seq: String, masterSeq: String, token: String, email: String, contact: String, joinType: String, code: String) {
        self.signIn = signIn
        self.id = id
        self.pw = pw
        self.name = name
        self.seq = seq
        self.masterSeq = masterSeq
        self.token = token
        self.email = email
        self.contact = contact
        self.joinType = joinType
        self.code = code
    }
    
    mutating func setData(signIn: Bool, id: String, pw: String, name: String, seq: String, masterSeq: String, token: String, email: String, contact: String, joinType: String, code: String) {
        self.signIn = signIn
        self.id = id
        self.pw = pw
        self.name = name
        self.seq = seq
        self.masterSeq = masterSeq
        self.token = token
        self.email = email
        self.contact = contact
        self.joinType = joinType
        self.code = code
    }
    
    mutating func saveData(userId: String, userPw: String, json: JSON?) {
        guard let json = json else { return }
        
        id = userId
        pw = userPw
        token = json["sha_token"].stringValue
        seq = json["memberInfo"]["user_SEQ"].stringValue
        email = json["memberInfo"]["user_EMAIL"].stringValue
        joinType = json["memberInfo"]["join_TYPE"].stringValue
        masterSeq = json["memberInfo"]["master_SEQ"].stringValue
        contact = json["memberInfo"]["user_HP"].stringValue
        name = json["memberInfo"]["user_NAME"].stringValue
        bizName = json["memberInfo"]["params"].stringValue
        attachGrpSeq = json["memberInfo"]["attach_GRP_SEQ"].stringValue
        
//        let enpw = _utils.encrypt(string: pw)
        UserDefaults.standard.setValue(userId, forKey: _identifiers[.keyUserId])
        UserDefaults.standard.setValue(userPw, forKey: _identifiers[.keyUserPw])
        UserDefaults.standard.setValue(token, forKey: _identifiers[.keyShaToken])
        UserDefaults.standard.setValue(name, forKey: _identifiers[.keyUserName])
        UserDefaults.standard.setValue(seq, forKey: _identifiers[.keyUserSeq])
        UserDefaults.standard.setValue(email, forKey: _identifiers[.keyUserEmail])
        UserDefaults.standard.setValue(joinType, forKey: _identifiers[.keyUserJoinType])
        UserDefaults.standard.setValue(masterSeq, forKey: _identifiers[.keyMasterSeq])
        UserDefaults.standard.setValue(contact, forKey: _identifiers[.keyUserContact])
    }
    
    mutating func removeData() {
        signIn = false; id = ""; name = ""; seq = ""; token = ""; email = "";
        
        UserDefaults.standard.removeObject(forKey: _identifiers[.keyUserId])
        UserDefaults.standard.removeObject(forKey: _identifiers[.keyShaToken])
        UserDefaults.standard.removeObject(forKey: _identifiers[.keyUserName])
        UserDefaults.standard.removeObject(forKey: _identifiers[.keyUserSeq])
        UserDefaults.standard.removeObject(forKey: _identifiers[.keyUserEmail])
        UserDefaults.standard.removeObject(forKey: _identifiers[.keyUserJoinType])
        UserDefaults.standard.removeObject(forKey: _identifiers[.keyMasterSeq])
        UserDefaults.standard.removeObject(forKey: _identifiers[.keyUserContact])
        UserDefaults.standard.removeObject(forKey: _identifiers[.keyUserPw])
    }
}
