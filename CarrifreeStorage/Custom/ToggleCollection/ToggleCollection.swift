//
//  ToggleCollection.swift
//  TestProject
//
//  Created by plattics-kwon on 2021/10/27.
//

import UIKit

/*
@objc protocol ToggleCollectionDelegate {
    @objc func selected(index: Int)
}
*/
 
class ToggleCollection: UIView {
    
    let selectedColor = UIColor(red: 222/255, green: 125/255, blue: 94/255, alpha: 1)
    
    var toggleHeight: CGFloat = 30
    var currentToggle: UIButton!            // 현재 선택된 toggle
    var toggles: [UIButton] = []
    var status: UILabel!
    var invalidStatusString: String = ""
    var multiSelectable: Bool = false
//    var delegate: ToggleCollectionDelegate?
    
    var isSelected: Bool {                  // 선택된 toggle이 한개라도 있는지 여부
        get {
            let selectedIndexes = getSelectedIndexes()
            return selectedIndexes.count > 0
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func configure() {
    }
    
    func configure(multiSelectable: Bool, toggleTitles: [String]) {
        configure()
        self.multiSelectable = multiSelectable
        createToggleButtons(toggleTitles: toggleTitles)
        createStatusLabel()
    }
    
    func createToggleButtons(toggleTitles: [String]) {
        var togglePos: CGPoint = CGPoint.zero
        let toggleSpace: CGFloat = 10
        let rowSpace: CGFloat = 12
        for (i, title) in toggleTitles.enumerated() {
            let toggle = UIButton(frame: CGRect(x: togglePos.x, y: togglePos.y, width: 0, height: toggleHeight))
            toggle.setTitle(title, for: .normal)
            toggle.setTitleColor(.darkGray, for: .normal)
            toggle.setTitleColor(selectedColor, for: .selected)
            toggle.titleLabel?.font = fieldFont
            toggle.layer.borderWidth = 1
            toggle.layer.borderColor = UIColor.systemGray.cgColor
            toggle.sizeToFit()
            
            // 화면 밖으로 나가게되면 줄바꿈
            let toggleSize = CGSize(width: toggle.frame.width + 24, height: toggleHeight)
            if togglePos.x + toggleSize.width > self.frame.width {
                togglePos = CGPoint(x: 0, y: togglePos.y + toggleHeight + rowSpace)
            }
            
            toggle.frame = CGRect(x: togglePos.x, y: togglePos.y, width: toggleSize.width, height: toggleHeight)
            toggle.layer.cornerRadius = toggleHeight / 2
            toggle.tag = i
            toggle.addTarget(self, action: #selector(self.onToggle(_:)), for: .touchUpInside)
            self.addSubview(toggle)
            
            // 다음 x값 계산
            togglePos.x += (toggleSize.width + toggleSpace)
            
            toggles.append(toggle)
        }
    }
    
    func createStatusLabel() {
        var y: CGFloat = 0
        if toggles.count > 0 {
            y = toggles[toggles.count - 1].frame.maxY + 8
        }
        
        status = UILabel(frame: CGRect(x: 0, y: y, width: self.frame.width, height: 16))
        status.textAlignment = .center
        status.textColor = .systemRed
        status.font = descFont02
        status.isHidden = true
        self.addSubview(status)
    }

    private func updateToggleStatus(toggle: UIButton) {
        if toggle.isSelected {
            toggle.layer.borderColor = selectedColor.cgColor
            toggle.titleLabel?.font = fieldFontBold
        } else {
            toggle.layer.borderColor = UIColor.systemGray.cgColor
            toggle.titleLabel?.font = fieldFont
        }
    }
    
    func select(title: String) {
        for toggle in toggles {
            let toggleTitle = toggle.title(for: .normal)
            if toggleTitle == title {
                onToggle(toggle)
                return
            }
        }
    }
    
    func select(titles: [String]) {
        for toggle in toggles {
            let toggleTitle = toggle.title(for: .normal)
            
            for title in titles {
                if title == toggleTitle {
                    onToggle(toggle)
                    break
                }
            }
        }
    }
    
    /// 선택된  toggle button의 index 반환
    func getSelectedIndexes() -> [Int] {
        var selectedIndex: [Int] = []
        for (i, toggle) in toggles.enumerated() {
            if toggle.isSelected { selectedIndex.append(i) }
        }
        
        return selectedIndex
    }
    
    func updateStatus(valid: Bool, invalidString: String) {
        if nil == status { return }
        self.invalidStatusString = invalidString
        
        if valid {
            status.text = ""
        } else {
            status.text = invalidString
        }
        
        status.isHidden = valid
    }
}

// MARK:- Actions
extension ToggleCollection {
    @objc func onToggle(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        
        if false == multiSelectable && nil != currentToggle {
            currentToggle.isSelected = false
            updateToggleStatus(toggle: currentToggle)
        }
        
        updateToggleStatus(toggle: sender)
        currentToggle = sender
        
        updateStatus(valid: isSelected, invalidString: invalidStatusString)
    }
}


