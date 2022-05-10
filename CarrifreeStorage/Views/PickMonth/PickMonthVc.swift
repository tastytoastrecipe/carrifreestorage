//
//  PickMonthVc.swift
//  TestProject
//
//  Created by orca on 2021/11/20.
//

import UIKit

@objc protocol PickMonthVcDelegate {
    @objc optional func onConfirm(month: Int)
}

class PickMonthVc: UIViewController {

//    @IBOutlet weak var exitBtn: UIButton!
    @IBOutlet weak var board: UIView!
    @IBOutlet weak var vcHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var vcTitle: UILabel!
    @IBOutlet weak var durationTitle: UILabel!
    @IBOutlet weak var duration: UILabel!
    @IBOutlet weak var month: UIPickerView!
    @IBOutlet weak var confirm: UIButton!
    
    var delegate: PickMonthVcDelegate?
    var monthData: [String] = [_strings[.month01],
                               _strings[.month02],
                               _strings[.month03],
                               _strings[.month04],
                               _strings[.month05],
                               _strings[.month06],
                               _strings[.month07],
                               _strings[.month08],
                               _strings[.month09],
                               _strings[.month10],
                               _strings[.month11],
                               _strings[.month12]]
    
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd hh:mm"
        formatter.locale = Locale.current
        formatter.timeZone = TimeZone.current
        return formatter
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        board.isHidden = false
        animateBoard(appear: true)
    }

    func configure() {
        board.layer.cornerRadius = 18
        board.clipsToBounds = true
        
        vcTitle.text = _strings[.selectMonth]
        vcTitle.font = UIFont(name: "NanumSquareEB", size: 20)
        
        durationTitle.text = "\(_strings[.duration]): "
        durationTitle.font = UIFont(name: "NanumSquareR", size: 15)
        
        let date = Date().localDate
        let currentMonthStartDay = dateFormatter.string(from: date.startOfMonth)
        let currentMonthEndDay = dateFormatter.string(from: date.endOfMonth)
        duration.text = "\(currentMonthStartDay) ~\n\(currentMonthEndDay)"
        duration.font = UIFont(name: "NanumSquareB", size: 15)
        
        month.dataSource = self
        month.delegate = self
        let currentMonth = date.get(.month)
        month.selectRow(currentMonth - 1, inComponent: 0, animated: false)
        
        confirm.setTitle(_strings[.ok], for: .normal)
        confirm.titleLabel?.font = UIFont(name: "NanumSquareR", size: 17)
        confirm.addTarget(self, action: #selector(self.onConfirm(_:)), for: .touchUpInside)
        
        // down gesture
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(self.onSwipe(_:)))
        swipe.numberOfTouchesRequired = 1
        swipe.direction = .down
        self.view.addGestureRecognizer(swipe)

        // exit button
        let exitBtn = UIButton()
        exitBtn.setImage(UIImage(systemName: "xmark"), for: .normal)
        exitBtn.tintColor = .systemGray
        exitBtn.addTarget(self, action: #selector(self.onExit(_:)), for: .touchUpInside)
        exitBtn.isHidden = true
        board.addSubview(exitBtn)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
            exitBtn.isHidden = false
            exitBtn.frame = CGRect(x: self.board.frame.width - 50, y: 0, width: 50, height: 50)
        }
    }
    
    func changeDuration(month: Int) {
        guard let monthDate = getMonthDate(month: month) else { return }
        let currentMonthStartDay = dateFormatter.string(from: monthDate.startOfMonth)
        let currentMonthEndDay = dateFormatter.string(from: monthDate.endOfMonth)
        duration.text = "\(currentMonthStartDay) ~\n\(currentMonthEndDay)"
        duration.font = UIFont(name: "NanumSquareB", size: 15)
    }
    
    func getMonthDate(month: Int) -> Date? {
        let date = Date().localDate
        let year = Calendar.current.component(.year, from: date)
        let calendar = Calendar(identifier: .gregorian)
        let comps = DateComponents(calendar: calendar, year: year, month: month)
        
        guard let tempDate = comps.date else { return nil }
        let components = calendar.dateComponents([.year, .month], from: tempDate)
        return  calendar.date(from: components)
    }
    
    func animateBoard(appear: Bool, completion: (() -> Void)? = nil) {
        if appear {
            board.frame.origin.y = self.view.frame.height
            UIView.animate(withDuration: 0.3, animations: {
                let boardY = self.view.frame.height - self.vcHeightConstraint.constant
                self.board.frame.origin.y = boardY
            }, completion: { (_) in
                completion?()
            })
        } else {

            UIView.animate(withDuration: 0.25, animations: {
                self.board.frame.origin.y = self.view.frame.height
            }, completion: { (_) in
                completion?()
            })
        }
        
    }
    
    func exit() {
        self.view.backgroundColor = .clear
        animateBoard(appear: false) {
            self.dismiss(animated: false)
        }
    }
}

// MARK: - Actions
extension PickMonthVc {
    @objc func onExit(_ sender: UIButton) {
        exit()
    }
    
    @objc func onSwipe(_ sender: UIGestureRecognizer) {
        exit()
    }
    
    @objc func onConfirm(_ sender: UIButton) {
        self.view.backgroundColor = .clear
        animateBoard(appear: false) {
            self.dismiss(animated: false) {
                let selectedMonth = self.month.selectedRow(inComponent: 0) + 1
                self.delegate?.onConfirm?(month: selectedMonth)
            }
        }
    }
    
}

// MARK: - UIPickerViewDelegate, UIPickerViewDataSource
extension PickMonthVc: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return monthData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return monthData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        changeDuration(month: row + 1)
//        _log.log("pickerView - didSelectRow(\(row))")
    }
    
}

