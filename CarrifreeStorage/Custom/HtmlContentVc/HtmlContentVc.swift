//
//  HtmlContentVc.swift
//  CarrifreeStorage
//
//  Created by plattics-kwon on 2021/02/23.
//  Copyright © 2021 plattics. All rights reserved.
//

import UIKit

class HtmlContentVc: UIViewController {
    
    @IBOutlet weak var navi: UINavigationBar!
    @IBOutlet weak var board: UIView!
    
    var vcTitle: String = ""
    var content: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        navi.topItem?.title = vcTitle
        setContents()
    }
        
    func setContents() {
        let termsView = UITextView(frame: CGRect(x: 0, y: 0, width: board.frame.width, height: board.frame.height))
        let data = Data(content.utf8)
        if let attributedString = try? NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil) {
            termsView.attributedText = attributedString
        }
        termsView.isScrollEnabled = true
        termsView.isUserInteractionEnabled = true
        termsView.isEditable = false
        board.addSubview(termsView)
    }

}
