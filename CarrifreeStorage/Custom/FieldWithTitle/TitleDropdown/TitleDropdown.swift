//
//  TitleDropdown.swift
//  TestProject
//
//  Created by plattics-kwon on 2021/03/19.
//

import UIKit
import DropDown

@objc protocol TitleDropdownDelegate {
    @objc optional func onSelect(index: Int, content: String)
}

class TitleDropdown: UIView {

    @IBOutlet weak var board: UIView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var content: UILabel!
    
    var dropdown: DropDown! = nil
    var dataSource: [String] = []
    var delegate: TitleDropdownDelegate? = nil
    var xibLoaded: Bool = false
    
    var text: String {
        get { return content.text ?? ""}
        set { content.text = newValue }
    }
        
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        loadXib()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadXib()
    }

    init(frame: CGRect, title: String, dataSource: [String]) {
        super.init(frame: frame)
        configure(title: title, dataSource: dataSource)
    }
    
    func loadXib() {
        if xibLoaded { return }
        guard let view = self.loadNib(name: String(describing: TitleDropdown.self)) else { return }
        xibLoaded = true
        view.frame = self.bounds
        self.addSubview(view)
    }
    
    override func configure() {
        loadXib()
        setDefault()
    }
    
    func configure(title: String, dataSource: [String]) {
        configure()
        setTitle(title: title)
        setDataSource(dataSource: dataSource)
    }
    
    func setDefault() {
        setBoard()
        setDropdown()
    }
    
    func setBoard() {
        board.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onBoard(_:))))
        board.layer.cornerRadius = 6
        board.layer.borderWidth = 1
        board.layer.borderColor = UIColor.systemGray.cgColor
    }
    
    func setDropdown() {
        guard nil == dropdown else { return }
        dropdown = DropDown()
        dropdown.dataSource = dataSource
        dropdown.anchorView = board
        dropdown.bottomOffset = CGPoint(x: 0, y: self.frame.height)
        dropdown.selectionAction = self.onSelect(index:item:)
    }
    
    func setDataSource(dataSource: [String]) {
        if nil == dropdown { return }
        if dataSource.isEmpty { return }
        
        self.dataSource.removeAll()
        self.dataSource = dataSource
        dropdown.dataSource = self.dataSource
        content.text = self.dataSource[0]
    }
    
    func setTitle(title: String) {
        self.title.text = " \(title) "
    }
    
    func setDataSource(title: String, dataSource: [String]) {
        setDataSource(dataSource: dataSource)
        setTitle(title: title)
    }
    
    func setContent(content: String) {
        self.content.text = content
    }
    
    func setTextColor(color: UIColor) {
        content.textColor = color
    }
    
    func setModifyEnable(enable: Bool) {
        self.isUserInteractionEnabled = enable
    }
    
    func getSelectedRow() -> Int? {
        return dropdown.indexForSelectedRow
    }

    func reset() {
        dataSource.removeAll()
        content.text = ""
        title.text = ""
        
        if nil != dropdown {
            dropdown.hide()
            dropdown.dataSource = []
        }
    }
}


// MARK:- Actions
extension TitleDropdown {
    @objc func onBoard(_ sender: UIGestureRecognizer) {
        dropdown.show()
    }
    
    func onSelect(index: Int, item: String) {
        dropdown.hide()
        content.text = dataSource[index]
        delegate?.onSelect?(index: index, content: item)
    }
}



