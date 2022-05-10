//
//  CarryApis.swift
//  CarrifreeStorage
//
//  Created by plattics-kwon on 2021/01/05.
//

import Foundation

enum ApiType {
    case uploadPreSign
    case uploadData
    case uploadDataComplete
    case getAttachGrpSeq
    case requestPrivateDownload
    case signin
    case signout
    case withdraw
    case deviceInfo
    case getUpdateInfo
    case idDuplicationCheck
    case getEmailAuthCode
    case authorizeEmail
    case signup
    case phoneAuth
    case getIdCode
    case authorizeIdCode
    case getPwCode
    case authorizePwCode
    case changePw
    case findId
    case resetPw
    case main
    case getUserInfo
    case getBanks
    case getWeeks
    case getMerits
    case getAuthCode
    case auth
    case registerLicense
    case registerBiz
    case requestApprove
    case getStoreInfo
    case getFeature
    case registerMerits
    case getAppearance
    case setAppearance
    case registerStorePicture
    case getStorePicture
    case getDayoff
    case registerDayoff
    case registerPr
    case getCategories
    case registerCategories
    case registerLuggages
    case getDefaultCosts
    case getMyCosts
    case registerCosts
    case updateStep
    case getOrders
    case getOrderDetail
    case getOrderPictures
    case updateOrderStatus
    case getMonthlySales
    case getTerms
    case getProfilePicture
    case registerProfilePicture
    case getWorktime
    case registerWorktime
    case getBanners
    case none
    
    var isProcessing: Bool {
        return self != .none
    }
    
    var title: String {
        switch self {
        case .uploadPreSign: return "업로드 URL 요청"
        case .uploadData: return "데이터 업로드 요청"
        case .uploadDataComplete: return "데이터 업로드 완료 요청"
        case .getAttachGrpSeq: return "그룹 시퀀스 요청"
        case .requestPrivateDownload: return "비공개 파일 다운로드 요청"
        case .signin: return "로그인"
        case .signout: return "로그아웃"
        case .withdraw: return "탈퇴"
        case .deviceInfo: return "기기 정보 전송"
        case .getUpdateInfo: return "앱 업데이트 정보 요청"
        case .idDuplicationCheck: return "ID 중복 확인"
        case .getEmailAuthCode: return "이메일 인증 코드 요청"
        case .authorizeEmail: return "이메일 인증"
        case .signup: return "회원 가입"
        case .phoneAuth: return "휴대폰 인증"
        case .getIdCode: return "ID 찾기 코드 발급"
        case .authorizeIdCode: return "ID 찾기 코드 인증"
        case .getPwCode: return "PW 찾기 코드 발급"
        case .authorizePwCode: return "PW 찾기 코드 인증"
        case .changePw: return "PW 변경"
        case .findId: return "아이디 찾기"
        case .resetPw: return "비밀번호 재설정"
        case .main: return "메인(홈)화면 정보 요청"
        case .getUserInfo: return "회원정보/사업자정보 조회"
        case .getBanks: return "은행 정보 조회"
        case .getWeeks: return "요일 정보 조회"
        case .getMerits: return "보관장점 정보 조회"
        case .getAuthCode: return "SMS 인증 코드 요청"
        case .auth: return "SMS 인증"
        case .registerLicense: return "사업자등록증/통장사본 등록"
        case .registerBiz: return "사업자 정보 등록/수정"
        case .requestApprove: return "보관 파트너 신청"
        case .getStoreInfo: return "매장 정보 조회"
        case .registerMerits: return "보관 장점 등록/수정"
        case .getAppearance: return "노출/비노출 조회"
        case .setAppearance: return "노출/비노출 설정"
        case .registerStorePicture: return "매장 사진 등록"
        case .getStorePicture: return "매장 사진 조회"
        case .getDayoff: return "쉬는날 조회"
        case .registerDayoff: return "쉬는날 등록/수정"
        case .registerPr: return "소개글 등록/수정"
        case .getCategories: return "업종 정보 조회"
        case .registerCategories: return "업종 등록"
        case .registerLuggages: return "짐 보관 개수 등록"
        case .getDefaultCosts: return "기본 가격 조회"
        case .getMyCosts: return "내가 설정한 가격 조회"
        case .registerCosts: return "가격 등록"
        case .updateStep: return "등록 단계 수정"
        case .getOrders: return "의뢰 목록 요청"
        case .getOrderDetail: return "의뢰 상세 정보 요청"
        case .getOrderPictures: return "의뢰 물품 사진 요청"
        case .updateOrderStatus: return "의뢰 진행 상태 변경"
        case .getMonthlySales: return "월 매출 조회"
        case .getTerms: return "약관 조회"
        case .getProfilePicture: return "프로필 사진 조회"
        case .registerProfilePicture: return "프로필 사진 등록"
        case .getWorktime: return "영업 시간 조회"
        case .registerWorktime: return "영업 시간 등록"
        case .getBanners: return "배너 조회"
        default: return ""
        }
    }
}
