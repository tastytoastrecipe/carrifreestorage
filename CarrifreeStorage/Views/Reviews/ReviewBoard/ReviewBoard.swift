//
//  ReviewBoard.swift
//  TestProject
//
//  Created by plattics-kwon on 2021/03/11.
//

/*
import UIKit

class ReviewBoard: UIView {

    @IBOutlet weak var board: UIStackView!
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var emptyLabel: UILabel!
    
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
        guard let view = self.loadNib(name: String(describing: ReviewBoard.self)) else { return }
        xibLoaded = true
        view.frame = self.bounds
        self.addSubview(view)
    }
    
    override func configure() {
        loadXib()
        
        requestReviews()
    }
    
    func requestReviews() {
        CarryRequest.shared.requestReviews(firstRequest: true) { (success, msg) in
            if success {
                self.setReviews()
                
                let isEmpty = CarryUser.review.reviews.isEmpty
                self.setEmpty(hidden: !isEmpty)
            } else {
                let alert = _utils.createSimpleAlert(title: "\(_strings[.alertFailedToLoadReview]) \(_strings[.plzTryAgain])", message: "", buttonTitle: _strings[.ok])
                _utils.topViewController()?.present(alert, animated: true)
            }
        }
    }
    
    func setReviews() {
//        setDummyDatas()
        
        for review in CarryUser.review.reviews {
            let reviewSeq = review.reviewSeq
            let orderSeq = review.orderSeq
            let userSeq = review.userSeq
            let content = review.content
            let point = review.point
            let name = review.name
            let reply = review.reply
            
//            let date = review.date
            let reviewBox = ReviewBox(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: 300), reviewSeq: reviewSeq, orderSeq: orderSeq, upperUserSeq: userSeq, writerName: name, rating: point, content: content, reply: reply)
            let heightConstraint = reviewBox.heightAnchor.constraint(equalToConstant: reviewBox.height)
            heightConstraint.identifier = reviewBox.heightConstraintId
            heightConstraint.isActive = true
            board.addArrangedSubview(reviewBox)
        }
    }
    
    func setEmpty(hidden: Bool) {
        emptyView.isHidden = hidden
        emptyLabel.text = "\(_strings[.noReviews]).."
    }
}
*/
