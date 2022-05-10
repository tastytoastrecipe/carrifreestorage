//
//  ReviewBox.swift
//  CarrifreeStorage
//
//  Created by plattics-kwon on 2021/03/10.
//

/*
import UIKit

class ReviewBox: UIView {
    
    enum ReviewStatus {
        case review     // 리뷰만 있음
        case reply      // 댓글도 있음
        case writing    // 댓글 작성중
        case none
    }

    let heightConstraintId = "height"
    var board: UIView!                      // 모든 ui들의 parent view
    var userImg: UIImageView!               // 리뷰 작성자 이미지 (시스템 이미지)
    var userName: UILabel!                  // 리뷰 작성자 이름
    var starRatingView: StarRatingView!     // 별점
    var content: UILabel!                   // 리뷰 내용
    var reply: UIButton!                    // 댓글 버튼
    var replyImg: UIImageView!              // 댓글 아이콘
    var replyView: UITextView!              // 댓글 내용
    var replyCancel: UIButton!              // 댓글 작성 취소
    var replyRegister: UIButton!            // 작성한 댓글 등록
    var separator: UIView!                  // 구분선
    
    var reviewSeq: String = ""              // 리뷰 시퀀스
    var orderSeq: String = ""               // 주문 시퀀스
    var userSeq: String = ""                // 리뷰 작성햔 유저의 시퀀스
    var height: CGFloat = 0
    var status: ReviewStatus = .none {
        didSet { if oldValue != status { refresh() } }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    init(frame: CGRect, reviewSeq: String, orderSeq: String, upperUserSeq: String, writerName: String, rating: Float, content: String, reply: String) {
        super.init(frame: frame)
        configure(reviewSeq: reviewSeq, orderSeq: orderSeq, upperUserSeq: upperUserSeq, writerName: writerName, rating: rating, content: content, reply: reply)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func configure() {
        setDefault()
    }
    
    func configure(reviewSeq: String, orderSeq: String, upperUserSeq: String, writerName: String, rating: Float, content: String, reply: String) {
        configure()
        self.reviewSeq = reviewSeq; self.orderSeq = orderSeq; self.userSeq = upperUserSeq; userName.text = writerName; starRatingView.currentRating = rating; self.content.text = content; replyView.text = reply
        setStatus()
    }
    
    func setStatus() {
        let contentText = content.text ?? ""
        let replyText = replyView.text ?? ""
        
        
        if false == contentText.isEmpty && replyText.isEmpty {
            status = .review
        } else if false == contentText.isEmpty && false == replyText.isEmpty {
            status = .reply
        }
    }
    
    func refresh() {
        content.sizeToFit()
        replyView.sizeToFit()
        replyImg.frame.origin.y = content.frame.maxY + 20
        replyView.frame.origin.y = content.frame.maxY + 20
        
        switch status {
        case .review:
            reply.isHidden = false
            replyImg.isHidden = true
            replyView.isHidden = true
            replyCancel.isHidden = true
            replyRegister.isHidden = true
            separator.frame.origin.y = content.frame.maxY + 20
            height = separator.frame.maxY + 20
            
            if let heightConstriant = self.constraints.filter({ $0.identifier == "height" }).first {
                heightConstriant.constant = height
            }
            
        case .reply:
            reply.isHidden = true
            replyImg.isHidden = false
            replyView.isHidden = false
            replyView.isUserInteractionEnabled = false
            replyCancel.isHidden = true
            replyRegister.isHidden = true
            separator.frame.origin.y = replyView.frame.maxY + 20
            height = separator.frame.maxY + 20
            
        case .writing:
            reply.isHidden = true
            replyImg.isHidden = false
            let x: CGFloat = 48
            let width = self.frame.width - CGFloat(x + 10)
            replyView.frame = CGRect(x: x, y: content.frame.maxY + 20, width: width, height: 100)
            replyView.isHidden = false
            replyCancel.isHidden = false
            replyRegister.isHidden = false
            
            replyCancel.frame.origin.y = replyView.frame.maxY + 10
            replyRegister.frame.origin.y = replyView.frame.maxY + 10
            
            separator.frame.origin.y = replyCancel.frame.maxY + 15
            height = replyCancel.frame.maxY + 10
            
            if let heightConstriant = self.constraints.filter({ $0.identifier == "height" }).first {
                heightConstriant.constant += 150
            }
            
        default: break
            
        }
    }
}

// MARK:- Actions
extension ReviewBox {
    @objc func onReply(_ sender: UIButton) {
        status = .writing
    }
    
    @objc func onReplyCancel(_ sender: UIButton) {
        replyView.text = ""
        status = .review
    }
    
    @objc func onReplyRegister(_ sender: UIButton) {
        let replyText = replyView.text ?? ""
        if replyText.isEmpty { return }
        
        // "댓글을 등록하시겠습니까?\n 등록한 댓글은 수정할 수 없습니다".  --->  Alert 생성
        CarryRequest.shared.requestWriteReply(upperReviewSeq: reviewSeq, upperUserSeq: userSeq, orderSeq: orderSeq, reply: replyText) { (success, msg) in
            if success {
                self.status = .reply
            } else {
                var message = msg
                if message.isEmpty { message = "" }
                let alert = _utils.createSimpleAlert(title: "\(_strings[.alertFailedToRegisterReply]) \(_strings[.plzTryAgain])", message: "", buttonTitle: _strings[.ok])
                _utils.topViewController()?.present(alert, animated: true)
            }
        }
        
        
    }
}

// MARK:- 기본 UI 설정
extension ReviewBox {
    func setDefault() {
        setBoard()
        setUserImg()
        setName()
        setRatings()
        setContent()
        setReplyButton()
        setReplyImg()
        setReplyView()
        setReplyCancel()
        setReplyRegister()
        setSeparator()
    }
    
    func setBoard() {
        board = UIView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.width))
        board.backgroundColor = .white
        self.addSubview(board)
    }
    
    func setUserImg() {
        if nil == board { return }
        userImg = UIImageView(frame: CGRect(x: 8, y: 8, width: 34, height: 34))
        userImg.contentMode = .scaleAspectFit
        userImg.image = UIImage(systemName: "person.circle.fill")
        userImg.tintColor = .lightGray
        board.addSubview(userImg)
    }
    
    func setName() {
        if nil == userImg { return }
        if nil == board { return }
        
        let imgRect = userImg.frame
        userName = UILabel(frame: CGRect(x: imgRect.maxX + 8, y: imgRect.minY, width: 300, height: 18))
        userName.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        userName.textColor = .label
        userName.textAlignment = .left
        userName.text = "name"
        board.addSubview(userName)
    }
    
    func setRatings() {
        if nil == userImg { return }
        if nil == userName { return }
        if nil == board { return }
        
        starRatingView = StarRatingView(rating: 5, parent: board, direction: .leftTop, spacing: CGPoint(x: userImg.frame.maxX + 6, y: userName.frame.maxY + 1), color: .systemYellow, size: 12)
        board.addSubview(starRatingView)
    }
    
    func setContent() {
        if nil == userImg { return }
        if nil == board { return }
        
        content = UILabel(frame: CGRect(x: 12, y: userImg.frame.maxY + 20, width: self.frame.width - 24, height: 400))
        content.font = UIFont.systemFont(ofSize: 15)
        content.textColor = .label
        content.textAlignment = .left
        content.text = ""
        content.numberOfLines = 0
        content.sizeToFit()
        board.addSubview(content)
    }
    
    func setReplyButton() {
        if nil == userName { return }
        if nil == board { return }
        
        reply = UIButton(frame: CGRect(x: 0, y: userName.frame.origin.y - 5, width: 0, height: 30))
        reply.setImage(UIImage(systemName: "plus")?.withConfiguration(UIImage.SymbolConfiguration(pointSize: 15)), for: .normal)
        reply.imageEdgeInsets.right = 5
        reply.setTitle(_strings[.reply], for: .normal)
        reply.setTitleColor(.systemBlue, for: .normal)
        reply.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        reply.sizeToFit()
        reply.frame.origin.x = self.frame.maxX - reply.frame.width - 30
        reply.frame.size.width = reply.frame.width + 20
        reply.frame.size.height = 30
        reply.addTarget(self, action: #selector(onReply(_:)), for: .touchUpInside)
        board.addSubview(reply)
    }
    
    func setReplyImg() {
        if nil == board { return }
        replyImg = UIImageView(frame: CGRect(x: 12, y: content.frame.maxY + 20, width: 30, height: 30))
        replyImg.contentMode = .scaleAspectFit
        replyImg.image = UIImage(systemName: "quote.bubble.fill")
        replyImg.tintColor = .systemTeal
        board.addSubview(replyImg)
    }
    
    func setReplyView() {
        if nil == content { return }
        if nil == board { return }
        
        let x: CGFloat = 48
        let width = self.frame.width - CGFloat(x + 10)
        replyView = UITextView(frame: CGRect(x: x, y: content.frame.maxY + 20, width: width, height: 0))
        replyView.font = UIFont.systemFont(ofSize: 15)
        replyView.textColor = .label
        replyView.textAlignment = .left
        replyView.text = ""
        replyView.textContainerInset.left = 10
        replyView.textContainerInset.right = 10
        replyView.textContainerInset.bottom = 10
        replyView.sizeToFit()
        replyView.frame.size.width = width
        replyView.backgroundColor = UIColor(red: 255/255, green: 245/255, blue: 228/255, alpha: 1)
        replyView.layer.cornerRadius = 14
        replyView.smartQuotesType = .no
        replyView.smartDashesType = .no
        replyView.smartInsertDeleteType = .no
        replyView.spellCheckingType = .no
//        replyView.displayAccessory = true
        board.addSubview(replyView)
    }
    
    func setReplyCancel() {
        if nil == reply { return }
        if nil == board { return }
        
        replyCancel = UIButton()
        replyCancel.imageEdgeInsets.right = 5
        replyCancel.setTitle(_strings[.cancel], for: .normal)
        replyCancel.setTitleColor(.systemBlue, for: .normal)
        replyCancel.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        replyCancel.sizeToFit()
        
        let height: CGFloat = 26
        let width = replyCancel.frame.width + 30
        let x = self.frame.width - (width + 14)
        replyCancel.frame = CGRect(x: x, y: replyView.frame.maxY + 6, width: width, height: height)
        
        replyCancel.setTitleColor(.white, for: .normal)
        replyCancel.layer.cornerRadius = height / 2
        replyCancel.layer.backgroundColor = UIColor.systemTeal.cgColor
        
        replyCancel.addTarget(self, action: #selector(onReplyCancel(_:)), for: .touchUpInside)
        board.addSubview(replyCancel)
    }
    
    func setReplyRegister() {
        if nil == replyCancel { return }
        if nil == replyView { return }
        if nil == board { return }
        
        replyRegister = UIButton()
        replyRegister.imageEdgeInsets.right = 5
        replyRegister.setTitle(_strings[.registration], for: .normal)
        replyRegister.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        replyRegister.sizeToFit()
        
        let height: CGFloat = 26
        let width = replyRegister.frame.width + 30
        let x = replyCancel.frame.minX - (width + 10)
        replyRegister.frame = CGRect(x: x, y: replyView.frame.maxY + 6, width: width, height: height)
        
        replyRegister.setTitleColor(.white, for: .normal)
        replyRegister.layer.cornerRadius = height / 2
        replyRegister.layer.backgroundColor = UIColor.systemTeal.cgColor
        
        replyRegister.addTarget(self, action: #selector(onReplyRegister(_:)), for: .touchUpInside)
        board.addSubview(replyRegister)
    }

    func setSeparator() {
        if nil == content { return }
        if nil == board { return }
        
        var y: CGFloat = 0
        if replyView.isHidden { y = content.frame.maxY + 10 }
        else { y = replyView.frame.maxY + 10 }
        
        let width: CGFloat = self.frame.width - 16
        separator = UIView(frame: CGRect(x: self.frame.midX - (width / 2), y: y, width: width, height: 1))
        separator.backgroundColor = .systemGray5
        board.addSubview(separator)
    }
}
*/

