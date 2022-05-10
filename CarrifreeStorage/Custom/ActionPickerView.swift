//
//  TimePickerView.swift
//  CarrifreeStorage
//
//  Created by plattics-kwon on 2021/01/04.
//

import UIKit

@objc protocol ActionPickerViewDelegate {
    @objc optional func onConfirm(value: String, index: Int)
}

class ActionPickerView: UIView {
    
    static let pickerHeight: CGFloat = 240
    
    
    @IBOutlet weak var picker: UIPickerView!
    @IBOutlet weak var ok: UIButton!

    var xibLoaded: Bool = false
    var datas: [String] = []
    var exitBoard: UIView! = nil
    var delegate: ActionPickerViewDelegate?
        
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
        guard let view = self.loadNib(name: String(describing: ActionPickerView.self)) else { return }
        xibLoaded = true
        view.frame = self.bounds
        self.addSubview(view)
    }
    
    override func configure() {
        loadXib()
        
        ok.setTitle(_strings[.ok], for: .normal)
        ok.layer.cornerRadius = 8
        ok.addTarget(self, action: #selector(self.onConfirm(_:)), for: .touchUpInside)

        picker.dataSource = self
        picker.delegate = self
        picker.layer.cornerRadius = 8
        
        if nil == exitBoard {
            exitBoard = UIView()
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onExitBoard(_:)))
            exitBoard.addGestureRecognizer(tapGesture)
        }
        
        if let topView = _utils.topViewController()?.view {
            exitBoard.frame = topView.frame
            topView.addSubview(exitBoard)
            
        }
        exitBoard.backgroundColor = .clear
    }
    
    func configure(dataSource: [String]) {
        configure()
        if false == dataSource.isEmpty { datas = dataSource }
    }
    
    func setData(dataSource: [String]) {
        datas = dataSource
        picker.reloadAllComponents()
    }
    
    func show() {
        exitBoard.isHidden = false
    }
    
    func hide() {
        exitBoard.isHidden = true
    }
}

// MARK:- Actions
extension ActionPickerView {
    @objc func onConfirm(_ sender: UIButton) {
        let index = picker.selectedRow(inComponent: 0)
        let value = datas[index]
        
        UIView.animate(withDuration: 0.33, animations: { () -> Void in
            self.frame.origin.y = UIScreen.main.bounds.height
            _events.callHideActionPicker(value: value, index: index)
            self.delegate?.onConfirm?(value: value, index: index)
        })
        
        hide()
    }
    
    @objc func onExitBoard(_ sender: UIButton) {
        UIView.animate(withDuration: 0.33, animations: { () -> Void in
            self.frame.origin.y = UIScreen.main.bounds.height
        })
        
        hide()
    }
}

// MARK:- UIPickerViewDelegate, UIPickerViewDataSource
extension ActionPickerView: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return datas.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return datas[row]
    }
}
