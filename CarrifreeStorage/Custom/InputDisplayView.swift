//
//  InputDisplayView.swift
//  CarrifreeStorage
//
//  Created by plattics-kwon on 2021/01/07.
//

import UIKit

class InputDisplayView: UIView {
    
    class DisplayPair {
        var title: String = ""
        var textField: UITextField!
    }
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var content: UILabel!
    
    var xibLoaded: Bool = false
    var displays: [DisplayPair] = []
        
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
        guard let view = self.loadNib(name: String(describing: InputDisplayView.self)) else { return }
        xibLoaded = true
        view.frame = self.bounds
        self.addSubview(view)
    }
    
    override func configure() {
        loadXib()
    }
    
    func configure(textField: UITextField, title: String) {
        addTextField(textField: textField, title: title)
        
        self.title.text = title
        self.content.text = ""
    }
    
    func addTextField(textField: UITextField, title: String) {
        let display = DisplayPair()
        display.textField = textField
        display.title = title
        displays.append(display)
        
        textField.delegate = self
        textField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
    }
    
    func setContent(content: String) {
        self.content.text = content
    }

}

// MARK:- UITextFieldDelegate
extension InputDisplayView: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        for display in displays {
            if display.textField == textField {
                self.title.text = display.title
                self.content.text = display.textField.text
                break
            }
        }
        self.isHidden = false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.isHidden = true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.isHidden = true
        return true
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        setContent(content: textField.text ?? "")
    }
}
