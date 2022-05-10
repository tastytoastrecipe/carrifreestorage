//
//  OrderListVc.swift
//  TestProject
//
//  Created by plattics-kwon on 2021/11/09.
//

import UIKit
import CoreAudioTypes

protocol OrderListVcDelegate {
    func goToStoreInfoFromOrderList()
}

class OrderListVc: UIViewController {
    
    @IBOutlet weak var scroll: UIScrollView!
    @IBOutlet weak var vcTitle: UILabel!
    @IBOutlet weak var listBoard: UIView!
    @IBOutlet weak var all: UIButton!               // 전체
    @IBOutlet weak var storage: UIButton!           // 보관
    @IBOutlet weak var keep: UIButton!              // 위수탁
    @IBOutlet weak var search: UIButton!
    @IBOutlet weak var searchField: UITextField!
    @IBOutlet weak var listStack: UIStackView!
    @IBOutlet weak var emptyListView: UIView!
    @IBOutlet weak var emptyListTitle: UILabel!
    @IBOutlet weak var goToStore: UIButton!
    
    let btnSelectedColor = UIColor(red: 242/255, green: 123/255, blue: 87/255, alpha: 1)
    var buttons: [UIButton] = []
    var tab: MyTab = .waiting
    
    let loadingBarHeight: CGFloat = 10
    
    var vm: OrderListVm!
    var orderDetailVc: OrderDetailVc!
    var delegate: OrderListVcDelegate?
    
    var isHidden: Bool {
        get { return self.view.isHidden }
        set { self.view.isHidden = newValue }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        vcTitle.text = tab.title
        vcTitle.font = UIFont(name: "NanumSquareEB", size: 20)
        
        search.setTitle("", for: .normal)
        search.addTarget(self, action: #selector(self.onSearch(_:)), for: .touchUpInside)
        
        searchField.placeholder = _strings[.enterNameOrOrderNo]
        searchField.delegate = self
        
        setOrderButton(button: all, title: _strings[.all])
        setOrderButton(button: storage, title: _strings[.storage])
        setOrderButton(button: keep, title: _strings[.consignment])
        
        buttons = [all, storage, keep]
        
        listBoard.layer.cornerRadius = 18
        listBoard.layer.shadowOffset = CGSize(width: 0, height: 0)
        listBoard.layer.shadowRadius = 3
        listBoard.layer.shadowOpacity = 0.2
        
        scroll.delegate = self
        emptyListView.isHidden = true
        emptyListTitle.text = "주문내역이 없습니다.\n매장정보를 더 상세하게 해보세요!\n관심도가 높아집니다."
        emptyListTitle.font = UIFont(name: "NanumSquareEB", size: 20)
        
        _utils.setText(bold: .bold, size: 17, text: "매장정보 수정", color: _symbolColor, button: goToStore)
        goToStore.addTarget(self, action: #selector(self.onGoToStore(_:)), for: .touchUpInside)
        goToStore.layer.cornerRadius = goToStore.frame.height / 2
        goToStore.layer.borderWidth = 1
        goToStore.layer.borderColor = _symbolColor.cgColor
        goToStore.layer.shadowOffset = CGSize(width: 2, height: 2)
        goToStore.layer.shadowRadius = 1
        goToStore.layer.shadowOpacity = 0.2
        
        setTitleAndDesc()
        
        vm = OrderListVm(delegate: self)
        onButtonTap(all)
    }
    
    func setTitleAndDesc() {
        if let orderStatus = OrderStatus(rawValue: getCurrentOrderStatus()) {
            vcTitle.text = orderStatus.orderTitle
        }
    }
    
    func setOrderButton(button: UIButton, title: String) {
        let btnFont = UIFont(name: "NanumSquareR", size: 15)
        button.titleLabel?.font = btnFont
        button.setTitle(title, for: .normal)
        button.setTitleColor(.systemGray, for: .normal)
        button.setTitleColor(.white, for: .selected)
//        button.setBackgroundColor(.white, for: .normal)
//        button.setBackgroundColor(btnSelectedColor, for: .selected)
        button.layer.borderColor = UIColor.systemGray.cgColor
        button.layer.shadowOffset = CGSize(width: 2, height: 2)
        button.layer.shadowRadius = 2
        button.layer.shadowOpacity = 0.2
        button.layer.cornerRadius = button.frame.height / 2
        button.addTarget(self, action: #selector(self.onButtonTap(_:)), for: .touchUpInside)
        button.isSelected = false
    }
    
    /// 의뢰 목록 새로고침 (목록 지운 후 새로 생성)
    func refresh() {
        if nil == vm { return }
        scroll.setContentOffset(.zero, animated: false)
        emptyListView.isHidden = vm.orders.count > 0
        removeAllReviewItem()
        
        for order in self.vm.orders {
            let cell = self.createCell(order: order)
            self.listStack.addArrangedSubview(cell)
        }
    }
    
    /// emptyListView를 제외한 모든 review item 제거
    func removeAllReviewItem() {
        listStack.arrangedSubviews.forEach({
            if emptyListView != $0 {
                $0.removeFromSuperview()
                NSLayoutConstraint.deactivate($0.constraints)
            }
        })
    }
    
    /// 새로 받은 의뢰 목록 추가 (페이지 변경 - 기존에 표시된 목록에 새로 받은 목록 추가)
    func addOrders() {
        if nil == vm { return }
        for order in vm.tempOrders {
            let cell = createCell(order: order)
            listStack.addArrangedSubview(cell)
        }
    }
    
    /// 목록에 추가될 의뢰 UI 생성
    func createCell(order: OrderData) -> OrderCell {
        let cell = OrderCell()
        cell.configure(orderSeq: order.orderSeq, category: order.category, imgUrl: order.attachInfo, orderNo: order.orderNo, orderName: order.name, orderLuggage: order.luggages, orderDuration: order.during, orderTime: order.orderDate)
        cell.delegate = self
        listStack.addArrangedSubview(cell)
        cell.heightAnchor.constraint(equalToConstant: 132).isActive = true
        return cell
    }
    
    /// 서버에 의뢰 목록 요청
    func getOrders(orderCategory: String, orderStatus: String, orderNo: String = "", orderName: String = "", needRefresh: Bool) {
        vm.getOrders(orderCategory: orderCategory, orderStatus: orderStatus, orderNo: orderNo, orderName: orderName, refresh: needRefresh) { (success, msg) in
            if success {
                
                // LoadingBar 갱신 후 새로받은 목록 표시
                if needRefresh { self.refresh() }
                else { self.addOrders() }
                
            } else {
                self.createSimpleAlert(title: _strings[.requestFailed], msg: msg)
            }
        }
    }
    
    /// 현재 선택된 의뢰 종류 (전체, 보관, 위수탁)
    func getCurrentOderCategory() -> String {
        if all != nil && all.isSelected {
            return OrderCategory.all.rawValue
        }

        if keep != nil && keep.isSelected {
            return OrderCategory.keep.rawValue
        }

        if storage != nil && storage.isSelected {
            return OrderCategory.storage.rawValue
        }
        
        return ""
    }
    
    /// 현재 선택된 의뢰 상태 (주문대기, 보관중, 처리완료)
    func getCurrentOrderStatus() -> String {
        let status = OrderStatus(rawValue: tab.status)?.rawValue ?? ""
        return status
    }
    
    /// 다른 탭 터치 (목록 새로고침)
    func tabChanged(tab: MyTab) {
        if self.tab == tab { return }
        if nil != orderDetailVc { orderDetailVc.exit() }
        
        self.tab = tab
        setTitleAndDesc()
        
        // 해당 탭(주문대기 or 보관중 or 처리완료)의 의뢰 목록 요청
        getOrders(orderCategory: getCurrentOderCategory(), orderStatus: tab.status, needRefresh: true)
    }
    
    /// OrderDetailVc로 이동
    func moveToOrderDetailVc(orderSeq: String, orderCategory: String) {
        if orderSeq.isEmpty || orderCategory.isEmpty {
            let msg = "\(_strings[.wrongOrderInfo])\n(orderSeq: \(orderSeq), orderCategory: \(orderCategory)"
            let alert = _utils.createSimpleAlert(title: _strings[.requestFailed], message: msg, buttonTitle: _strings[.ok])
            self.present(alert, animated: true)
        }
        
        if nil == orderDetailVc {
            orderDetailVc = OrderDetailVc()
            orderDetailVc.orderSeq = orderSeq
            orderDetailVc.orderCategory = orderCategory
            orderDetailVc?.delegate = self
        }
        
        self.addChild(orderDetailVc)
        self.view.addSubview(orderDetailVc.view)
        
        orderDetailVc.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            orderDetailVc.view.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0),
            orderDetailVc.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0),
            orderDetailVc.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0),
            orderDetailVc.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0)
        ])
    }
    
    func search(text: String) {
        
        if let _ = Int(text) {
            getOrders(orderCategory: getCurrentOderCategory(), orderStatus: getCurrentOrderStatus(), orderNo: text, needRefresh: true)
        } else {
            getOrders(orderCategory: getCurrentOderCategory(), orderStatus: getCurrentOrderStatus(), orderName: text, needRefresh: true)
        }
    }
    
    func createSimpleAlert(title: String, msg: String) {
        let alert = _utils.createSimpleAlert(title: title, message: msg, buttonTitle: _strings[.ok])
        self.present(alert, animated: true)
    }
}

// MARK: - Actions
extension OrderListVc {
    @objc func onSearch(_ sender: UIButton) {
        searchField.resignFirstResponder()
        
        guard let searchText = searchField.text, searchText.count > 0 else { return }
        search(text: searchText)
    }
    
    @objc func onButtonTap(_ sender: UIButton) {
        if nil == vm { return }
        if sender.isSelected { return }
        
        // 버튼 상태 변경
        sender.isSelected = !sender.isSelected
            
        for btn in buttons {
            if btn == sender {
                btn.layer.borderWidth = 0
                btn.backgroundColor = btnSelectedColor
            } else {
                btn.isSelected = false
                btn.layer.borderWidth = 1
                btn.backgroundColor = .white
            }
        }
        
        if keep === sender {
            if nil == vm { return }
            scroll.setContentOffset(.zero, animated: false)
            emptyListView.isHidden = false
            removeAllReviewItem()
            vm.reset()
            return
        }
        
        // 선택된 버튼에 해당하는 의뢰 목록 표시
        let currentCategory = getCurrentOderCategory()
        getOrders(orderCategory: currentCategory, orderStatus: getCurrentOrderStatus(), needRefresh: true)
    }
    
    @objc func onGoToStore(_ sender: UIButton) {
        delegate?.goToStoreInfoFromOrderList()
    }
}

// MARK: - OrderListVmDelegate
extension OrderListVc: OrderListVmDelegate {
    func ready() {
        refresh()
    }
}

// MARK: - UITextFieldDelegate
extension OrderListVc: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        guard let searchText = searchField.text, searchText.count > 0 else { return true }
        search(text: searchText)
        
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        textField.text = ""
        
        // 로딩바 0으로 리셋 후 의뢰 새로 받아옴
        getOrders(orderCategory: getCurrentOderCategory(), orderStatus: getCurrentOrderStatus(), needRefresh: true)
        return false
    }
}

// MARK: - UIScrollViewDelegate
extension OrderListVc: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
       let scrollViewHeight = scrollView.frame.size.height
        let scrollContentSizeHeight = scrollView.contentSize.height
         let scrollOffset = scrollView.contentOffset.y

        // drag to top
        if (scrollOffset == 0)
        {
        }
        // drag to bottom
        else if (scrollOffset + scrollViewHeight == scrollContentSizeHeight) {
            // 로딩바 0으로 리셋 후 의뢰 새로 받아옴
            getOrders(orderCategory: getCurrentOderCategory(), orderStatus: getCurrentOrderStatus(), needRefresh: false)
        }
    }
}

// MARK: - OrderCellDelegate
extension OrderListVc: OrderCellDelegate {
    func onTapCell(orderSeq: String, orderCategory: String) {
        moveToOrderDetailVc(orderSeq: orderSeq, orderCategory: orderCategory)
    }
}

// MARK: - OrderDetailVc
extension OrderListVc: OrderDetailVcDelegate {
    func deletedOrderDetailVc() {
        orderDetailVc = nil
    }
}
