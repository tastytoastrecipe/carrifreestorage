//
//  RegDate.swift
//  TestProject
//
//  Created by plattics-kwon on 2021/10/27.
//

import UIKit

class RegDate: UIView {
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var desc: UILabel!
    @IBOutlet var days: [UIButton]!
    @IBOutlet weak var holiday: UIButton!

    let selectedColor = UIColor(red: 222/255, green: 125/255, blue: 94/255, alpha: 1)
    var xibLoaded: Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadXib()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        loadXib()
    }
    
    func loadXib() {
        if xibLoaded { return }
        guard let view = self.loadNib(name: String(describing: RegDate.self)) else { return }
        xibLoaded = true
        view.frame = self.bounds
        self.addSubview(view)
    }
    
    override func configure() {
        loadXib()
        title.text = "휴무일 선택"
        title.font = UIFont(name: "NanumSquareR", size: 14)
        
        desc.text = "*중복선택 가능"
        desc.font = descFont02
        
        for (i, day) in Weekday.allCases.enumerated() {
            if i > days.count - 1 { continue }
            let btn = days[i]
            btn.setTitle(day.name, for: .normal)
            btn.setTitleColor(.darkGray, for: .normal)
            btn.setTitleColor(selectedColor, for: .selected)
            btn.layer.borderWidth = 1
            btn.layer.borderColor = UIColor.darkGray.cgColor
            btn.addTarget(self, action: #selector(self.onWeekday(_:)), for: .touchUpInside)
            btn.tag = day.rawValue
        }
        
        holiday.setTitle("법정 공휴일", for: .normal)
        holiday.setTitleColor(.darkGray, for: .normal)
        holiday.setTitleColor(selectedColor, for: .selected)
        holiday.layer.borderWidth = 1
        holiday.layer.borderColor = UIColor.darkGray.cgColor
        holiday.addTarget(self, action: #selector(self.onHoliday(_:)), for: .touchUpInside)
    }
    
    func configure(selectedDays: [Int], selectedHoliday: Bool) {
        configure()
        refresh(selectedDays: selectedDays, selectedHoliday: selectedHoliday)
    }
    
    func refresh(selectedDays: [Int], selectedHoliday: Bool) {
        
        for btn in days {
            var selected: Bool = false
            for dayIndex in selectedDays {
                if btn.tag == dayIndex { selected = true }
            }
            
            btn.isSelected = selected
            updateButtonStatus(btn: btn)
        }
        
        holiday.isSelected = selectedHoliday
        self.updateButtonStatus(btn: holiday)
    }
    
    func refresh(selectedDays: [Weekday], selectedHoliday: Bool) {
        var weekday: [Int] = []
        for day in selectedDays {
            weekday.append(day.rawValue)
        }
        
        refresh(selectedDays: weekday, selectedHoliday: selectedHoliday)
    }
    
    func updateButtonStatus(btn: UIButton) {
        if btn.isSelected {
            btn.layer.borderColor = selectedColor.cgColor
            btn.titleLabel?.font = UIFont(name: "NanumSquareB", size: 14)
        } else {
            btn.layer.borderColor = UIColor.darkGray.cgColor
            btn.titleLabel?.font = UIFont(name: "NanumSquareR", size: 14)
        }
    }

    /// 선택된 날짜를 ','로 구분하는 문자열로 반환
    func getSelectedDayString() -> String {
        let separator = ","
        var str = ""
        for day in days {
            guard day.isSelected else { continue }
            str += "\(day.tag)\(separator)"
        }
        str = String(str.dropLast())
        
        return str
    }
    
    /// 선택된 날짜를 [Int]로 반환
    func getSelectedDays() -> [Int] {
        var daysArr: [Int] = []
        for day in days {
            guard day.isSelected else { continue }
            daysArr.append(day.tag)
        }
        return daysArr
    }
    
    /// 공휴일을 휴무일로 지정했는지 여부 (holiday 버튼의 상태)
    func isDayoffInHoilday() -> Bool {
        return holiday.isSelected
    }
}

// MARK:- Actions
extension RegDate {
    @objc func onWeekday(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        self.updateButtonStatus(btn: sender)
    }
    
    @objc func onHoliday(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        self.updateButtonStatus(btn: sender)
    }
}

