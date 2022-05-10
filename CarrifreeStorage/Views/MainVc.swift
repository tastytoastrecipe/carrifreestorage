//
//  MainCtr.swift
//  TestProject
//
//  Created by plattics-kwon on 2021/10/19.
//

import UIKit

class MainVc: UIViewController {
    
    // navi
    lazy var myNavi: MyNavi = {
        let naviHeight: CGFloat = 80
        let tempNavi = MyNavi(frame: CGRect.zero)
        tempNavi.delegate = self
        return tempNavi
    }()
    
    // tab
    lazy var myTabBar: MyTabBar = {
        let tabBarHeight: CGFloat = 100
        let tabBarFrame = CGRect(x: 0, y: self.view.frame.height - tabBarHeight, width: self.view.frame.width, height: tabBarHeight)
        let tabBarSources = [("홈", "icon-tabbar-0", "icon-tabbar-selected-0"),
                             ("주문대기", "icon-tabbar-1", "icon-tabbar-selected-1"),
                             ("보관중", "icon-tabbar-2", "icon-tabbar-selected-2"),
                             ("처리완료", "icon-tabbar-3", "icon-tabbar-selected-3"),
                             ("정산", "icon-tabbar-4", "icon-tabbar-selected-4")]
        let tempTabBar = MyTabBar(frame: tabBarFrame, itemSources: tabBarSources)
        tempTabBar.delegate = self
        return tempTabBar
    }()

    // [홈] 화면
    lazy var homeVc: HomeVc = {
        let tempHomeVc = HomeVc()
        tempHomeVc.delegate = self
        self.addChild(tempHomeVc)
        self.view.addSubview(tempHomeVc.view)
        tempHomeVc.didMove(toParent: self)
        
        tempHomeVc.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tempHomeVc.view.topAnchor.constraint(equalTo: myNavi.bottomAnchor, constant: 0),
            tempHomeVc.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0),
            tempHomeVc.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0),
            tempHomeVc.view.bottomAnchor.constraint(equalTo: myTabBar.safeAreaLayoutGuide.topAnchor, constant: 0)
        ])
//        tempHomeVc.view.isHidden = true
        return tempHomeVc
    }()
    
    // [의뢰 목록] 화면
    var orderListVc: OrderListVc?
    /*
    lazy var orderListVc: OrderListVc = {
        let vc = OrderListVc()
        vc.tab = .waiting
        vc.delegate = self
        self.addChild(vc)
        self.view.addSubview(vc.view)
        vc.didMove(toParent: self)
        
        vc.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            vc.view.topAnchor.constraint(equalTo: myNavi.bottomAnchor, constant: 0),
            vc.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0),
            vc.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0),
            vc.view.bottomAnchor.constraint(equalTo: myTabBar.safeAreaLayoutGuide.topAnchor, constant: 0)
        ])
//        vc.view.isHidden = true
        return vc
    }()
    */
    // [정산] 화면
    lazy var cashupListVc: CashupListVc = {
        let vc = CashupListVc()
        self.addChild(vc)
        self.view.addSubview(vc.view)
        vc.didMove(toParent: self)
        
        vc.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            vc.view.topAnchor.constraint(equalTo: myNavi.bottomAnchor, constant: 0),
            vc.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0),
            vc.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0),
            vc.view.bottomAnchor.constraint(equalTo: myTabBar.safeAreaLayoutGuide.topAnchor, constant: 0)
        ])
//        vc.view.isHidden = true
        return vc
    }()
    
    // [설정] 화면
    var settingsVc: UINavigationController?
    
    // [보관 파트너 신청] 화면
    var regVc: RegistrationVc?
    
    // [매장정보 등록] 화면
    var storeVc: StoreVc?
    
//    var vm: MainVm!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        
        // set navi
        myNavi.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(myNavi)
        NSLayoutConstraint.activate([
            myNavi.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 0),
            myNavi.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0),
            myNavi.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0),
            myNavi.heightAnchor.constraint(equalToConstant: 62)
        ])
        
        // set tab bar
        myTabBar.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(myTabBar)
        NSLayoutConstraint.activate([
            myTabBar.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0),
            myTabBar.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0),
            myTabBar.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0),
            myTabBar.heightAnchor.constraint(equalToConstant: 100)
        ])
        
        myTabBar.select(index: 0)
        myNavi.setName(name: _user.bizName)
        myNavi.setApproval(approval: _user.approval)
    }
    
    func showOrderListVc(tab: MyTab) {
        if let vc = orderListVc {
            self.view.bringSubviewToFront(vc.view)
            vc.tabChanged(tab: tab)
        } else {
            let vc = OrderListVc()
            vc.tab = tab
            vc.delegate = self
            self.addChild(vc)
            self.view.addSubview(vc.view)
            vc.didMove(toParent: self)
            
            vc.view.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                vc.view.topAnchor.constraint(equalTo: myNavi.bottomAnchor, constant: 0),
                vc.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0),
                vc.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0),
                vc.view.bottomAnchor.constraint(equalTo: myTabBar.safeAreaLayoutGuide.topAnchor, constant: 0)
            ])
        }
    }
    
    // show SettingsVc
    func showSettingsVc() {
        if nil == settingsVc {
            let tempSettingsVc = SettingsVc()
            tempSettingsVc.delegate = self
            settingsVc = UINavigationController(rootViewController: tempSettingsVc)
            settingsVc?.modalPresentationStyle = .fullScreen
            tempSettingsVc.didMove(toParent: self)
            tempSettingsVc.delegate = self
        }
        
        guard let settingsVc = settingsVc else { return }
        
        self.addChild(settingsVc)
        self.view.addSubview(settingsVc.view)
        
        settingsVc.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            settingsVc.view.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 0),
            settingsVc.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0),
            settingsVc.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0),
            settingsVc.view.bottomAnchor.constraint(equalTo: myTabBar.safeAreaLayoutGuide.topAnchor, constant: 0)
        ])
        
        self.view.bringSubviewToFront(settingsVc.view)
        self.view.bringSubviewToFront(myTabBar)
    }
    
    // show RegistrationVc
    func showRegVc() {
        if nil == regVc {
            regVc = RegistrationVc()
            regVc?.delegate = self
        }
        
        guard let regVc = regVc else { return }
        
        self.addChild(regVc)
        self.view.addSubview(regVc.view)
        
        regVc.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            regVc.view.topAnchor.constraint(equalTo: myNavi.safeAreaLayoutGuide.bottomAnchor, constant: 0),
            regVc.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0),
            regVc.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0),
            regVc.view.bottomAnchor.constraint(equalTo: myTabBar.safeAreaLayoutGuide.topAnchor, constant: 0)
        ])
        
        self.view.bringSubviewToFront(myTabBar)
    }
    
    // show StoreVc
    func showStoreVc() {
        _cas.general.getMainTapInfo() { (_, _) in
            if _user.approval == .beforeRequest {
                let alert = _utils.createSimpleAlert(title: "사업자 정보 필요", message: "보관사업자 승인 요청을 완료해주시기 바랍니다.", buttonTitle: _strings[.ok])
                self.present(alert, animated: true)
                return
            }
            
            
            // 매장정보 등록 화면으로 이동
            if nil == self.storeVc {
                self.storeVc = StoreVc()
                self.storeVc?.delegate = self
            }
            
            guard let storeVc = self.storeVc else { return }
            
            self.addChild(storeVc)
            self.view.addSubview(storeVc.view)
            
            storeVc.view.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                storeVc.view.topAnchor.constraint(equalTo: self.myNavi.safeAreaLayoutGuide.bottomAnchor, constant: 0),
                storeVc.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0),
                storeVc.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0),
                storeVc.view.bottomAnchor.constraint(equalTo: self.myTabBar.safeAreaLayoutGuide.topAnchor, constant: 0)
            ])
            
            self.view.bringSubviewToFront(self.myTabBar)
        }
        
        
    }
    
    func closeCurrentVc() {
        if regVc != nil {
            regVc?.view.removeFromSuperview()
            regVc?.removeFromParent()
            regVc = nil
        }
        
        if storeVc != nil {
            storeVc?.view.removeFromSuperview()
            storeVc?.removeFromParent()
            storeVc = nil
        }
        
        if settingsVc != nil {
            settingsVc?.view.removeFromSuperview()
            settingsVc?.removeFromParent()
            settingsVc = nil
        }
    }

}

// MARK: - MyTabBarDelegate
extension MainVc: MyTabBarDelegate {
    func itemSelected(index: Int) {
        closeCurrentVc()
        
        if index == MyTab.home.rawValue {
            self.view.bringSubviewToFront(homeVc.view)
//            orderListVc.tabChanged(tab: MyTab.home)
        } else {
            if _user.approval != .approved {
                let noticeVc = OrderNoticeVc()
                noticeVc.status = ""
                noticeVc.modalPresentationStyle = .overFullScreen
                noticeVc.delegate = self
                self.present(noticeVc, animated: false)
                myTabBar.select(index: 0)
                return
            }
            
            if index == MyTab.waiting.rawValue {
                showOrderListVc(tab: MyTab.waiting)
            } else if index == MyTab.ongoing.rawValue {
                showOrderListVc(tab: MyTab.ongoing)
            } else if index == MyTab.done.rawValue {
                showOrderListVc(tab: MyTab.done)
            } else if index == MyTab.cashup.rawValue {
                self.view.bringSubviewToFront(cashupListVc.view)
            }
        }
        
        self.view.bringSubviewToFront(myNavi)
        self.view.bringSubviewToFront(myTabBar)
    }
}

// MARK: - MyNaviDelegate
extension MainVc: MyNaviDelegate {
    func tapApproval() {
        showRegVc()
    }
    
    func tapInfo() {
        showStoreVc()
    }
    
    func tapSetting() {
        showSettingsVc()
    }
    
    func tapNoti() {
        let alert = _utils.createSimpleAlert(title: "알림 설정", message: "알림 설정 화면은 아직 준비중입니다.", buttonTitle: _strings[.ok])
        self.present(alert, animated: true)
    }
}

// MARK: - RegistrationVcDelegate, StoreVcDelegate
extension MainVc: RegistrationVcDelegate, StoreVcDelegate {
    func registeredBiz() {
        homeVc.refreshSales()
        self.myNavi.setName(name: _user.bizName)
        self.myNavi.setApproval(approval: _user.approval)
    }
    
    func registrationVcDeleted() {
        regVc = nil
    }
    
    func storeVcDeleted() {
        storeVc = nil
    }
    
    func registeredStore() {
        homeVc.refreshSales()
    }
}

// MARK: - OrderNoticeVcDelegate
extension MainVc: OrderNoticeVcDelegate {
    func onExitWithRegistration() {
        if _user.approval == .approved {
            showStoreVc()
        } else {
            showRegVc()
        }
        
    }
}


// MARK: - HomeVcDelegate
extension MainVc: HomeVcDelegate {
    func tappedCashup() {
        let index = MyTab.cashup.rawValue
        myTabBar.select(index: index)
        itemSelected(index: index)
    }
    
    func tappedRegistration() {
        if _user.approval != .approved {
            showRegVc()
        } else if _user.approval == .approved && _user.stored == false {
            showStoreVc()
        }
    }
    
    func homeUpdated() {
        myNavi.setApproval(approval: _user.approval)
    }
}

// MARK: - SettingVcDelegate
extension MainVc: SettingsVcDelegate {
    func settingVcDeleted() {
        settingsVc = nil
        storeVc?.update()
    }
}


// MARK: -
extension MainVc: OrderListVcDelegate {
    func goToStoreInfoFromOrderList() {
        showRegVc()
    }
}
