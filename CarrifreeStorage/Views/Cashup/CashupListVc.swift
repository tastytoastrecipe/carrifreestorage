//
//  CashupVc.swift
//  TestProject
//
//  Created by plattics-kwon on 2021/11/18.
//

import UIKit

class CashupListVc: UIViewController {

    @IBOutlet weak var monthBoard: UIView!
    @IBOutlet weak var scroll: UIScrollView!
    
    @IBOutlet weak var cashupTtile: UILabel!
    @IBOutlet weak var showCalendar: UIButton!
    
    @IBOutlet weak var prevMonth: UIButton!
    @IBOutlet weak var nextMonth: UIButton!
    @IBOutlet weak var month: UILabel!
    @IBOutlet weak var salesTitle01: UILabel!       // 매출
    @IBOutlet weak var sales01: UILabel!            // 매출 금액
    @IBOutlet weak var salesTitle02: UILabel!       // 정산
    @IBOutlet weak var sales02: UILabel!            // 정산 금액
    
    @IBOutlet weak var search: UIButton!
    @IBOutlet weak var searchField: UITextField!
    @IBOutlet weak var listBoard: UIView!
    @IBOutlet weak var listStack: UIStackView!
    @IBOutlet weak var emptyListView: UIView!
    @IBOutlet weak var emptyListTitle: UILabel!
    
    let btnSelectedColor = UIColor(red: 242/255, green: 123/255, blue: 87/255, alpha: 1)
    
    var vm: CashupVm!
    
    var isHidden: Bool {
        get { return self.view.isHidden }
        set { self.view.isHidden = newValue }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        vm = CashupVm()
        setDefaults()
        changeMonth(month: vm.currentMonth)
    }
    
    func setDefaults() {
        monthBoard.roundCorners(cornerRadius: 18, maskedCorners: [.layerMinXMinYCorner, .layerMaxXMinYCorner])
        
        let font15 = UIFont(name: "NanumSquareR", size: 15)
        cashupTtile.text = "정산"
        cashupTtile.font = UIFont(name: "NanumSquareEB", size: 20)
        
        showCalendar.setTitle("달력보기", for: .normal)
        showCalendar.titleLabel?.font = font15
        showCalendar.layer.borderWidth = 1
        showCalendar.setTitleColor(.white, for: .normal)
        showCalendar.layer.borderColor = UIColor.white.cgColor
        showCalendar.addTarget(self, action: #selector(self.onShowCalender(_:)), for: .touchUpInside)
    
        // 현재 월 가져오기
        self.month.isUserInteractionEnabled = true
        self.month.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.onMonth(_:))))
        updateMonthText()
        
        salesTitle01.text = _strings[.sales]
        salesTitle01.font = font15
        
        sales01.text = ""
        sales01.font = UIFont(name: "NanumSquareB", size: 17)
        
        salesTitle02.text = "정산"
        salesTitle02.font = font15
        
        sales02.text = ""
        sales02.font = UIFont(name: "NanumSquareB", size: 17)
        
        listBoard.layer.cornerRadius = 18
        listBoard.layer.shadowOffset = CGSize(width: 0, height: 0)
        listBoard.layer.shadowRadius = 4
        listBoard.layer.shadowOpacity = 0.4

        scroll.delegate = self
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(self.pullRefresh(_:)), for: .valueChanged)
        scroll.refreshControl = refreshControl
        
        search.addTarget(self, action: #selector(self.onSearch(_:)), for: .touchUpInside)
        searchField.addTarget(self, action: #selector(self.onEditBegin(_:)), for: .editingDidBegin)
        
        emptyListView.isHidden = true
        emptyListTitle.text = "해당월에는 정산 정보가 없습니다."
        emptyListTitle.font = UIFont(name: "NanumSquareEB", size: 20)
    }
    
    func configure() {
        let monthStr = "\(vm.currentMonth)\(_strings[.month])"
        month.text = monthStr
        
        emptyListView.isHidden = vm.data.dailySales.count > 0
        
        let currencyString = _utils.getCurrencyString()
        sales01.text = "\(vm.data.sales.delimiter)\(currencyString)"
        sales02.text = "\(vm.data.cashup.delimiter)\(currencyString)"
        
        for (i, data) in vm.data.dailySales.enumerated() {
            let cell = CashupCell()
            
            let cellCase = CashupCellCase.sales
//            if data.cashup > 0 { cellCase = .cashup }
            
//            cell.configure(cellCase: cellCase, orderCategory: data.category, day: data.day, orderNo: "orderNumber", orderInfo: "\(_strings[.orderCount]): n건, \(_strings[.during]): n시간", duration: "", sales: data.sales)
            cell.configure(cellCase: cellCase, data: data)
            cell.tag = i
            cell.delegate = self
            listStack.addArrangedSubview(cell)
            
            NSLayoutConstraint.activate([
                cell.heightAnchor.constraint(equalToConstant: 58)
            ])
        }
    }
    
    func updateMonthText() {
        let monthStr = "\(vm.currentMonth)\(_strings[.month])"
        self.month.text = monthStr
    }
    
    func refresh() {
        removeAllReviewItem()
        
        var monthText = "\(vm.currentMonth)"
        if vm.currentMonth < 10 { monthText = "0\(vm.currentMonth)"}
        let yearMonthText = "\(vm.currentYear)\(monthText)"
        vm.getMonthlySales(month: yearMonthText) { (success, msg) in
            guard success else {
                let alert = _utils.createSimpleAlert(title: "정산", message: msg, buttonTitle: _strings[.ok])
                self.present(alert, animated: true)
                return
            }
            
            self.configure()
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
    
    func createNotReadyAlert() {
        let alert = _utils.createSimpleAlert(title: _strings[.search], message: "정산, 매출 내역 검색기능은 아직 준비중입니다.", buttonTitle: _strings[.ok])
        self.present(alert, animated: true)
    }
    
    func moveToCalendar() {
        let vc = CashupCalendarVc()
        vc.vm = vm
        vc.delegate = self
        
        self.addChild(vc)
        self.view.addSubview(vc.view)
        
        vc.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            vc.view.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0),
            vc.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0),
            vc.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0),
            vc.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0)
        ])
    }
    
    func changeMonth(month: Int) {
        vm.currentMonth = month
        refresh()
    }
    
}

// MARK: - Actions
extension CashupListVc {
    @objc func pullRefresh(_ sender: UIRefreshControl) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300)) {
            self.scroll.refreshControl?.endRefreshing()
        }
    }
    
    @objc func onSearch(_ sender: UIButton) {
        createNotReadyAlert()
    }
    
    @objc func onEditBegin(_ sender: UITextField) {
        createNotReadyAlert()
    }
    
    @objc func onMonth(_ sender: UIGestureRecognizer) {
        let vc = PickMonthVc()
        vc.delegate = self
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: false)
    }
    
    @objc func onShowCalender(_ sender: UIButton) {
        moveToCalendar()
    }
    
    @IBAction func onPrevMonth(_ sender: UIButton) {
        /*
        if vm.currentMonth == 1 { return }
        if vm.currentMonth < 1 { vm.currentMonth = 2 }
        changeMonth(month: vm.currentMonth - 1)
        */
        
        if vm.currentMonth == 1 {
            changeMonth(month: 12)
            vm.currentYear -= 1
            return
        }
        changeMonth(month: vm.currentMonth - 1)
    }
    
    @IBAction func onNextMonth(_ sender: UIButton) {
        /*
        if vm.currentMonth == 12 { return }
        if vm.currentMonth > 12 { vm.currentMonth = 11 }
        changeMonth(month: vm.currentMonth + 1)
        */
        
        if vm.currentMonth == 12 {
            changeMonth(month: 1)
            vm.currentYear += 1
            return
        }
        
        changeMonth(month: vm.currentMonth + 1)
    }
}

// MARK: - UIScrollViewDelegate
extension CashupListVc: UIScrollViewDelegate {
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
            // 주문 요청
//            getOrders(orderCategory: getCurrentOderCategory(), orderStatus: getCurrentOrderStatus(), needRefresh: false)
        }
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if(velocity.y < -0.1) {
            refresh()
        }
    }
    
}

// MARK: - UITextFieldDelegate
extension CashupListVc: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == searchField {
            textField.resignFirstResponder()
            createNotReadyAlert()
        }
        
        return true
    }
}

// MARK: - PickMonthVcDelegate
extension CashupListVc: PickMonthVcDelegate {
    func onConfirm(month: Int) {
        changeMonth(month: month)
    }
}

// MARK: - CashupCellDelegate
extension CashupListVc: CashupCellDelegate {
    func cashupCellTapped(index: Int) {
        if vm == nil || vm.data == nil { return }
        if vm.data.dailySales.count <= index { return }
        
        let sales = vm.data.dailySales[index]
//        let cellCase = CashupCellCase.sales
//        if sales.cashup > 0 { cellCase = .cashup }
        
//        switch cellCase {
//        case .sales:
            let vc = SalesDetailVc()
            vc.orderSeq = sales.orderSeq
            vc.orderCategory = sales.category
            vc.modalPresentationStyle = .overFullScreen
            self.present(vc, animated: false)
//        case .cashup:
//            let vc = CashupDetailVc()
//            vc.modalPresentationStyle = .overFullScreen
//            self.present(vc, animated: false)
//        }
    }
}

extension CashupListVc: CashupCalendarVcDelegate {
    func willClose() {
        refresh()
    }
}
