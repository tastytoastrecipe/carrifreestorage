//
//  RegTime.swift
//  TestProject
//
//  Created by plattics-kwon on 2021/10/27.
//

import UIKit

@objc protocol RegTimeDelegate {
    @objc optional func timeSelected(time: String)
}

class RegTime: UIView {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var line: UIView!
    @IBOutlet weak var status: UILabel!
    
    var timeDatas: [String] = ["00:00", "01:00", "02:00", "03:00", "04:00", "05:00", "06:00", "07:00", "08:00", "09:00", "10:00", "11:00", "12:00", "13:00",
                           "14:00", "15:00", "16:00", "17:00", "18:00", "19:00", "20:00", "21:00", "22:00", "23:00"]
    
    var delegate: RegTimeDelegate?
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
        guard let view = self.loadNib(name: String(describing: RegTime.self)) else { return }
        xibLoaded = true
        view.frame = self.bounds
        self.addSubview(view)
    }
    
    override func configure() {
        loadXib()
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.onTap(_:))))
    }

    func configure(title: String, time: String) {
        configure()
        self.title.text = title
        setTime(time: time)
    }
    
    func setTime(time: String) {
        self.time.text = time
    }
    
    func getTime() -> String {
        return time.text ?? ""
    }
    
    func updateStatus(valid: Bool) {
        var color = UIColor.systemRed
        var statusText = ""
        if valid { color = .systemGray5 }
        else { statusText = "시간을 올바르게 입력해주세요." }
        line.backgroundColor = color
        status.text = statusText
        status.isHidden = valid
    }
}

// MARK:- Action
extension RegTime {
    @objc func onTap(_ sender: UIGestureRecognizer) {
        _utils.timePicker(show: true, dataSource: timeDatas, delegate: self)
    }
}

extension RegTime: ActionPickerViewDelegate {
    func onConfirm(value: String, index: Int) {
        time.text = value
        delegate?.timeSelected?(time: value)
    }
}


