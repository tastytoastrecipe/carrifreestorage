//
//  HomeVm.swift
//  CarrifreeStorage
//
//  Created by plattics-kwon on 2021/10/21.
//

import Foundation

/*
@objc protocol HomeVmDelegate {
    @objc optional func ready()
}
*/

class HomeVm {
    var monthSales: String = ""
    var totalSales: String = ""
    var banners: [BannerData] = []
    
    /*
    var delegate: HomeVmDelegate?
    
    init(delegate: HomeVmDelegate) {
        monthSales = CarryUser.mainTap.monthSales.delimiter
        totalSales = "0"
        bannerDatas = [BannerData(imgUrl: "img-banner-0"), BannerData(imgUrl: "img-banner-1"), BannerData(imgUrl: "img-banner-2")]
        
        self.delegate = delegate
        self.delegate?.ready?()
    }
    */
    
    init() {
        monthSales = _user.monthlySales
        totalSales = "0"
    }
    
    /// 배너 요청
    func getBanners(completion: ResponseString = nil) {
        banners.removeAll()
        _cas.home.getBanners(bannerCase: BannerCase.storage.rawValue, bannerGroup: BannerGroup.storage01.rawValue) { (success, json) in
            guard let json = json, true == success else {
                completion?(false, ApiManager.getFailedMsg(defaultMsg: "배너 데이터를 받지 못했습니다.", json: json))
                return
            }
            
            let arr = json["bannerList"].arrayValue
            for val in arr {
                let seq = val["BOARD_SEQ"].stringValue
                let imgUrl = val["BANNER_ATTACH_INFO"].stringValue
                let pageUrl = val["LINK_URL"].stringValue
                let data = BannerData(seq: seq, pageUrl: pageUrl, imgUrl: imgUrl)
                self.banners.append(data)
            }
            
            completion?(true, "")
        }
    }
}
