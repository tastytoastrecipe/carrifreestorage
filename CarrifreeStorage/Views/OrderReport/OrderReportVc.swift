//
//  OrderReportVc.swift
//  TestProject
//
//  Created by orca on 2021/11/16.
//

import UIKit

enum OrderReportCase {
    case orderStart
    case orderDone
}

class OrderReportVc: UIViewController {

    @IBOutlet weak var board: UIView!
    @IBOutlet weak var boardLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var reportTitle: UILabel!
    @IBOutlet weak var reportDesc: UILabel!
    @IBOutlet weak var reportBtn: UIButton!
    @IBOutlet weak var circleImg: UIImageView!
    
    var reportCase: OrderReportCase = .orderStart
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        board.layer.cornerRadius = 18
        board.clipsToBounds = true
        
        reportBtn.setTitle(_strings[.ok], for: .normal)
        reportBtn.titleLabel?.font = UIFont(name: "NanumSquareR", size: 17)
        reportBtn.addTarget(self, action: #selector(self.onOk(_:)), for: .touchUpInside)
        
        reportDesc.font = UIFont(name: "NanumSquareR", size: 14)
        reportDesc.textColor = .systemGray
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        updateReport(reportCase: reportCase)
        animateBoard(appear: true)
    }
    
    func animateBoard(appear: Bool, completion: (() -> Void)? = nil) {
        if appear {
            board.frame.origin.x = self.view.frame.width
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                self.board.frame.origin.x = self.boardLeadingConstraint.constant
                completion?()
            })
        } else {
            UIView.animate(withDuration: 0.25, animations: { () -> Void in
                self.board.frame.origin.x = self.view.frame.width
                completion?()
            })
        }
        
    }
    
    func updateReport(reportCase: OrderReportCase) {
        self.reportCase = reportCase
        
        switch reportCase {
        case .orderStart:
            // localization
            let titleParagraphStyle = NSMutableParagraphStyle()
            titleParagraphStyle.lineSpacing = 10
            
            let attributedString = NSMutableAttributedString(string: _strings[.orderBegin], attributes: [
              .font: UIFont(name: "NanumSquareR", size: 24)!,
              .foregroundColor: UIColor(white: 0.0, alpha: 1.0),
              NSAttributedString.Key.paragraphStyle: titleParagraphStyle
            ])
            attributedString.addAttributes([
              .font: UIFont(name: "NanumSquareEB", size: 24)!,
              .foregroundColor: UIColor(red: 242.0 / 255.0, green: 123.0 / 255.0, blue: 87.0 / 255.0, alpha: 1.0)
            ], range: NSRange(location: 0, length: 4))
            reportTitle.attributedText = attributedString
            
            reportDesc.text = _strings[.orderBeginDesc]
            
            circleImg.image = UIImage(named: "img-circle-with-box-1")
            
        case .orderDone:
            // localization
            let titleParagraphStyle = NSMutableParagraphStyle()
            titleParagraphStyle.lineSpacing = 10
            
            let attributedString = NSMutableAttributedString(string: _strings[.orderComplete], attributes: [
              .font: UIFont(name: "NanumSquareR", size: 24.25)!,
              .foregroundColor: UIColor(white: 0.0, alpha: 1.0),
              NSAttributedString.Key.paragraphStyle: titleParagraphStyle
            ])
            attributedString.addAttributes([
              .font: UIFont(name: "NanumSquareEB", size: 24.25)!,
              .foregroundColor: UIColor(red: 242.0 / 255.0, green: 123.0 / 255.0, blue: 87.0 / 255.0, alpha: 1.0)
            ], range: NSRange(location: 0, length: 4))
            reportTitle.attributedText = attributedString
            
            reportDesc.text = _strings[.orderCompleteDesc]
            
            circleImg.image = UIImage(named: "img-circle-with-box-2")
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
extension OrderReportVc {
    @objc func onOk(_ sender: UIButton) {
        exit()
    }
}
