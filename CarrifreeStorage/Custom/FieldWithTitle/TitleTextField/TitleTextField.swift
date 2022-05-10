//
//  TitleTextField.swift
//  TestProject
//
//  Created by plattics-kwon on 2021/03/19.
//

import UIKit

@objc protocol TitleTextFieldDelegate {
    @objc optional func onTextfieldChanged(sender: TitleTextField, content: String)
    @objc optional func onTextfieldBeginEditing(sender: TitleTextField)
    @objc optional func onTextfieldEndEditing(sender: TitleTextField)
    @objc optional func onButtonTouch(sender: TitleTextField)
}

class TitleTextField: UIView {

    @IBOutlet weak var board: UIView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var content: UITextField!
    @IBOutlet weak var buttonView: UIView!
    @IBOutlet weak var buttonLabel: UILabel!
    @IBOutlet weak var textTrailing: NSLayoutConstraint!
    
    var text: String {
        get { return content.text ?? ""}
        set { content.text = newValue }
    }
    
    var isEmpty: Bool {
        get { return content.text?.isEmpty ?? true }
    }
    
    var isSecureTextEntry: Bool {
        get { return content.isSecureTextEntry }
        set { content.isSecureTextEntry = newValue }
    }
    
    var isFirstResponderField: Bool {
        get { return content.isFirstResponder }
    }
    
    var delegate: TitleTextFieldDelegate? = nil
    var xibLoaded: Bool = false
        
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        loadXib()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadXib()
    }

    init(frame: CGRect, title: String, placeHolder: String = "") {
        super.init(frame: frame)
        configure(title: title, placeHolder: placeHolder)
    }
    
    func loadXib() {
        if xibLoaded { return }
        guard let view = self.loadNib(name: String(describing: TitleTextField.self)) else { return }
        xibLoaded = true
        view.frame = self.bounds
        self.addSubview(view)
    }
    
    override func configure() {
        loadXib()
        setDefault()
    }
    
    func configure(title: String, placeHolder: String = "") {
        configure()
        setTitle(title: title)
        setPlaceHolder(placeHolder: placeHolder)
    }
    
    func setDefault() {
        content.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
        content.addTarget(self, action: #selector(self.textFieldBeginEditing(_:)), for: .editingDidBegin)
        content.addTarget(self, action: #selector(self.textFieldEndEditing(_:)), for: .editingDidEnd)
//        content.delegate = self
        setBoard()
    }

    func setBoard() {
        board.layer.cornerRadius = 6
        board.layer.borderWidth = 1
        board.layer.borderColor = UIColor.systemGray.cgColor
    }
    
    func setTitle(title: String) {
        self.title.text = " \(title) "
    }
    
    func setPlaceHolder(placeHolder: String) {
        content.placeholder = placeHolder
    }
    
    func setContent(content: String) {
        self.content.text = content
    }
    
    func setKeyboardType(keyboardType: UIKeyboardType) {
        content.keyboardType = keyboardType
    }
    
    func setAlignment(alignment: NSTextAlignment) {
        content.textAlignment = alignment
    }
    
    func tfResignFirstResponder() {
        content.resignFirstResponder()
    }
    
    func setTextColor(color: UIColor) {
        content.textColor = color
    }
    
    func setModifyEnable(enable: Bool) {
        content.isUserInteractionEnabled = enable
    }
    
    func setButton(title: String, needUnderLine: Bool) {
        if title.isEmpty { return }
        buttonView.isHidden = false
        buttonView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.onButtonTouch(_:))))
        buttonLabel.attributedText = NSAttributedString(string: title, attributes: [.underlineStyle: NSUnderlineStyle.single.rawValue])
        
        DispatchQueue.main.async {
            let buttonViewWidth = self.buttonView.frame.width + 20
            self.textTrailing.constant = buttonViewWidth
        }
        
    }
    
    func reset() {
        content.text = ""
    }
}


// MARK:- Actions
extension TitleTextField {
    @objc func textFieldDidChange(_ textField: UITextField) {
        let str = content.text ?? ""
        delegate?.onTextfieldChanged?(sender: self, content: str)
    }
    
    @objc func textFieldBeginEditing(_ textField: UITextField) {
        delegate?.onTextfieldBeginEditing?(sender: self)
    }
    
    @objc func textFieldEndEditing(_ textField: UITextField) {
        delegate?.onTextfieldEndEditing?(sender: self)
    }
    
    @objc func onButtonTouch(_ sender: UIButton) {
        delegate?.onButtonTouch?(sender: self)
    }
}

/*
extension TitleTextField: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if content.textContentType == .password {
            var characterSet = CharacterSet()
            characterSet.formUnion(.lowercaseLetters) // e.g. a,b,c..
            characterSet.formUnion(.uppercaseLetters) // e.g. A,B,C..
            characterSet.formUnion(.decimalDigits) // e.g. 1,2,3
    //        characterSet.formUnion(.whitespaces) // " "
            characterSet.insert(charactersIn: "!@#$%^&*") // Specific Characters
            
            let invertedCharacterSet = characterSet.inverted
            let components = string.components(separatedBy: invertedCharacterSet)
            let filtered = components.joined(separator: "")
            
            return string == filtered
        }
        
        let str = content.text ?? ""
        delegate?.onTextfieldChanged?(sender: self, content: str)
        return true
    }
}
*/
