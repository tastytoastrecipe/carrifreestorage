//
//  CashupCalendarVc.swift
//  TestProject
//
//  Created by plattics-kwon on 2021/11/19.
//

import UIKit
import FSCalendar
import Alamofire

protocol CashupCalendarVcDelegate {
    func willClose()
}

class CashupCalendarVc: UIViewController {
    
    @IBOutlet weak var month: UILabel!
    @IBOutlet weak var salesTitle01: UILabel!       // 매출
    @IBOutlet weak var sales01: UILabel!            // 매출 금액
    @IBOutlet weak var salesTitle02: UILabel!       // 정산
    @IBOutlet weak var sales02: UILabel!            // 정산 금액
    @IBOutlet weak var showCalendar: UIButton!
    @IBOutlet weak var fsCalendar: FSCalendar!

    var vm: CashupVm!
    var delegate: CashupCalendarVcDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setDefaults()
        
        if nil == vm { vm = CashupVm() }
        refresh()
    }
    
    func setDefaults() {
        salesTitle01.text = _strings[.sales]
        salesTitle01.font = UIFont(name: "NanumSquareR", size: 15)
        
        sales01.text = ""
        sales01.font = UIFont(name: "NanumSquareB", size: 17)
        
        salesTitle02.text = _strings[.cashup]
        salesTitle02.font = UIFont(name: "NanumSquareR", size: 15)
        
        sales02.text = ""
        sales02.font = UIFont(name: "NanumSquareB", size: 17)
        
        fsCalendar.delegate = self
        fsCalendar.dataSource = self
        fsCalendar.appearance.borderRadius = 0.2
        fsCalendar.today = nil
        fsCalendar.allowsSelection = true
//        if let prevMonthDate = Date().localDate.lastDateOfPreviousMonth { fsCalendar.currentPage = prevMonthDate }
        
        var monthText = "\(vm.currentMonth)"
        if vm.currentMonth < 10 { monthText = "0\(vm.currentMonth)" }
        let dateString: String = "\(vm.currentYear)-\(monthText)"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM"
        dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone?
        let date: Date = dateFormatter.date(from: dateString)!
        fsCalendar.currentPage = date
        
        showCalendar.setTitle(_strings[.showList], for: .normal)
        showCalendar.titleLabel?.font = UIFont(name: "NanumSquareR", size: 15)
        showCalendar.layer.borderWidth = 1
        showCalendar.setTitleColor(.white, for: .normal)
        showCalendar.layer.borderColor = UIColor.white.cgColor
        showCalendar.addTarget(self, action: #selector(self.onShowCalender(_:)), for: .touchUpInside)
        
        let monthStr = "\(vm.currentMonth)\(_strings[.month])"
        self.month.text = monthStr
        self.month.isUserInteractionEnabled = true
        self.month.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.onMonth(_:))))
    }
    
    func configure() {
        let monthStr = "\(vm.currentMonth)\(_strings[.month])"
        month.text = monthStr
        
        let currencyString = _utils.getCurrencyString()
        sales01.text = "\(vm.data.sales.delimiter)\(currencyString)"
        sales02.text = "\(vm.data.cashup.delimiter)\(currencyString)"
        
        fsCalendar.reloadData()
    }
    
    func moveMonth(isNext: Bool) {
        let calendar = Calendar.current
        var dateComponents = DateComponents()
        if isNext { dateComponents.month = 1 }
        else { dateComponents.month = -1 }
        
        if let targetPage = calendar.date(byAdding: dateComponents, to: fsCalendar.currentPage) {
//            fsCalendar.currentPage = targetPage
            fsCalendar.setCurrentPage(targetPage, animated: true)
        }
    }
    
    func refresh() {
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
    
    func getCost(date: Date) -> Int {
        let day = date.get(.day)
        let cost = vm.getCost(day: "\(day)")
        return cost
    }
    
}

// MARK: - Actions
extension CashupCalendarVc {
    @objc func onShowCalender(_ sender: UIButton) {
        delegate?.willClose()
        self.view.removeFromSuperview()
        self.removeFromParent()
    }
    
    @objc func onMonth(_ sender: UIGestureRecognizer) {
        let vc = PickMonthVc()
        vc.delegate = self
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: false)
    }
    
    @IBAction func onLeft(_ sender: UIButton) {
        if vm.currentMonth < 1 { vm.currentMonth = 12 }
        moveMonth(isNext: false)
    }
    
    @IBAction func onRight(_ sender: UIButton) {
        if vm.currentMonth > 12 { vm.currentMonth = 1 }
        moveMonth(isNext: true)
    }
}


// MARK: - FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance
extension CashupCalendarVc: FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        let currentPage = calendar.currentPage
        vm.currentMonth = Calendar.current.component(.month, from: currentPage)
        refresh()
    }
    
    func calendar(_ calendar: FSCalendar, subtitleFor date: Date) -> String? {
        // 현재 달력이 표시하는 월의 데이터만 표시함
        let isCurrentMonth = date.isInSameMonth(as: calendar.currentPage)
        guard isCurrentMonth else { return "" }
        
        // 매출 데이터 표시
        let cost = getCost(date: date)
        guard cost > 0 else { return "" }
        return "● \(cost.delimiter)"
    }
    
    /*
    /// 매출이 있는 날의 배경색을 변경함
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, fillDefaultColorFor date: Date) -> UIColor? {
        let day = date.get(.day)
        let isLuckyDay = vm.isLuckyDay(day: "\(day)")
        var color: UIColor = .white
        if isLuckyDay {
            color = UIColor(red: 245/255, green: 213/255, blue: 203/255, alpha: 1)
        }
        return color
    }
    */
    
    func calendar(_ calendar: FSCalendar, subtitle02For date: Date) -> String? {
        /*
        // 현재 달력이 표시하는 월의 데이터만 표시함
        let isvm.currentMonth = date.isInSameMonth(as: calendar.currentPage)
        guard isvm.currentMonth else { return "" }
        
        // 정산 데이터 표시
        let dayOfDate = date.get(.day)
        for sales in vm.data.dailySales {
            guard let day = Int(sales.day) else { continue }
            guard sales.cashup > 0 else { continue }
            
            if day == dayOfDate {
                return "○ \(sales.cashup.delimiter)"
            }
        }
        */
        
        return ""
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, subtitle02DefaultColorFor date: Date) -> UIColor? {
        return UIColor(red: 242/255, green: 123/255, blue: 87/255, alpha: 1)
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        let cost = getCost(date: date)
        guard cost > 0 else { return }
        
        let vc = CashupDetailVc()
        vc.salesTotal = cost
        vc.salesDate = date
        let day = date.get(.day)
        vc.datas = vm.getDailySales(day: "\(day)")
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: false)
    }
    
}

// MARK: - PickMonthVcDelegate
extension CashupCalendarVc: PickMonthVcDelegate {
    func onConfirm(month: Int) {
        vm.currentMonth = month
        
        let calendar = Calendar.current
        var dateComponents = DateComponents()
        dateComponents.month = month
        dateComponents.year = Date().localDate.get(.year)
        
        if let date = calendar.date(from: dateComponents) {
            vm.data.reset()
            fsCalendar.setCurrentPage(date, animated: true)
        }
        
    }
}
