//
//  TitleTextView.swift
//  CarrifreeDriver
//
//  Created by plattics-kwon on 2021/04/07.
//

import UIKit

@objc protocol TitleTextViewDelegate {
    @objc optional func onTextViewChanged(sender: TitleTextView, content: String)
    @objc optional func onTextViewBeginEditing(sender: TitleTextView)
    @objc optional func onTextViewEndEditing(sender: TitleTextView)
}

class TitleTextView: UIView {

    @IBOutlet weak var board: UIView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var content: UITextView!
    
    var text: String {
        get {
            var str = content.text ?? ""
            if str == placeHolder { str = "" }
            return str
        }
        set { content.text = newValue }
    }
    
    var isEmpty: Bool {
        get {
            let str = content.text ?? ""
            let empty = str == placeHolder || str.isEmpty
            return empty
        }
    }
    
    var isPlaceHolderHidden: Bool {
        get {
            let placeholderVisible = content.text == placeHolder && placeHolder.isEmpty == false
            return !placeholderVisible
        }
    }
    
    override var isUserInteractionEnabled: Bool {
        get { content.isUserInteractionEnabled }
        set { content.isUserInteractionEnabled = newValue }
    }
    
    var limit: Int = 20
    var placeHolder: String = ""
    var delegate: TitleTextViewDelegate? = nil
    var xibLoaded: Bool = false
        
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        loadXib()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadXib()
    }

    init(frame: CGRect, title: String) {
        super.init(frame: frame)
        configure(title: title)
    }
    
    func loadXib() {
        if xibLoaded { return }
        guard let view = self.loadNib(name: String(describing: TitleTextView.self)) else { return }
        xibLoaded = true
        view.frame = self.bounds
        self.addSubview(view)
    }
    
    override func configure() {
        loadXib()
        setDefault()
    }
    
    func configure(title: String) {
        configure()
        setTitle(title: title)
    }
    
    func setDefault() {
        content.delegate = self
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
    
    func setContent(content: String) {
        self.content.text = content
    }
    
    func tfResignFirstResponder() {
        content.resignFirstResponder()
    }
    
    func setTextColor(color: UIColor) {
        if content.textColor == color { return }
        content.textColor = color
    }
    
    func setMofidyEnable(enable: Bool) {
        content.isUserInteractionEnabled = enable
    }
    
    func setPlaceHolder(placeHolder: String) {
        self.placeHolder = placeHolder
        content.text = placeHolder
        content.textColor = .systemGray
    }
    
    func reset() {
        content.text = ""
//        title.text = ""
    }
}

// MARK:- UITextViewDelegate
extension TitleTextView: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentText = textView.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updateText = currentText.replacingCharacters(in: stringRange, with: text)
        return updateText.count <= limit
    }
    
    func textViewDidChange(_ textView: UITextView) {
        delegate?.onTextViewChanged?(sender: self, content: textView.text)
        if content.textColor != .label { content.textColor = .label }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        let contentText = content.text ?? ""
        if contentText == placeHolder { content.text = "" }
        content.textColor = .label
        delegate?.onTextViewBeginEditing?(sender: self)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if content.text.isEmpty {
            content.text = placeHolder
            content.textColor = .systemGray
        }
        
        delegate?.onTextViewEndEditing?(sender: self)
    }
}



