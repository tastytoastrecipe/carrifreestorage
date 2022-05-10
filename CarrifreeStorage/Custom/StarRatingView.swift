//
//  StartRatingView.swift
//  Carrifree
//
//  Created by orca on 2020/10/15.
//  Copyright © 2020 plattics. All rights reserved.
//

import UIKit

class StarRatingView: UIView {
    enum Direction {
        case leftTop
        case rightTop
        case leftBottom
        case rightBottom
        case center
    }
    
    static let identifier = "StarRatingView"

    let maxRating: Int = 5                  // 별의 최대 개수
    let gap: CGFloat = 2                    // 별의 간격
    var starSize: CGFloat = 20              // 별 넓이, 높이
    var verticalSpacing: CGFloat = 5        // 각 모서리에서 StarRatingView의 세로 간격
    var horizontalSpacing: CGFloat = 5      // 각 모서리에서 StarRatingView의 가로 간격
    var parent: UIView? = nil               // StarRatingView의 부모 view
    var direction: Direction = .rightTop    // parent의 어느 모서리에 위치할지
    var fillStars: [UIImageView] = []
    var emptyStars: [UIImageView] = []
    var starColor: UIColor = _utils.symbolColor
    var currentRating: Float = 0 {
        didSet { setRating() }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
     
    init(rating: Float, parent: UIView, direction: Direction, spacing: CGPoint = CGPoint(x: 5, y: 5), color: UIColor? = nil, size: CGFloat = 20) {
        let width = (CGFloat(maxRating) * (starSize + gap))
        super.init(frame: CGRect(x: 0, y: 0, width: width, height: starSize))
        self.backgroundColor = .clear
        
        self.parent = parent
        self.direction = direction
        currentRating = rating
        verticalSpacing = spacing.y
        horizontalSpacing = spacing.x
        starSize = size
        if let color = color { starColor = color }
        configure()
        setRating()
        
        let pos = getPosition()
        self.frame = CGRect(x: pos.x, y: pos.y, width: width, height: starSize)
    }
    
    override func configure() {
        var x: CGFloat = 0
        for i in 0 ..< maxRating {
            x = CGFloat(i) * (starSize + gap)
            let starFrame = CGRect(x: x, y: 0, width: starSize, height: starSize)
            
            let emptyStar = getStarImageView(isFill: false)
            emptyStar.frame = starFrame
            emptyStars.append(emptyStar)
            self.addSubview(emptyStar)
            
            let fillStar = getStarImageView(isFill: true)
            fillStar.frame = starFrame
            fillStar.isHidden = true
            fillStars.append(fillStar)
            self.addSubview(fillStar)
        }
    }
    
    func getPosition() -> CGPoint {
        var pos = CGPoint.zero
        guard let parentFrame = self.parent?.frame else { return pos }
        
        switch direction {
        case .leftTop:
            pos.x = horizontalSpacing
            pos.y = verticalSpacing
        case .rightTop:
            pos.x = parentFrame.width - self.frame.width - horizontalSpacing
            pos.y = verticalSpacing
        case .leftBottom:
            pos.x = horizontalSpacing
            pos.y = parentFrame.height - self.frame.height - verticalSpacing
        case .rightBottom:
            pos.x = parentFrame.width - self.frame.width - horizontalSpacing
            pos.y = parentFrame.height - self.frame.height - verticalSpacing
        case .center:
            pos.x = (parentFrame.width / 2) - (self.frame.width / 2)
            pos.y = (parentFrame.height / 2) - (self.frame.height / 2)
        }
        
        return pos
    }
    
    func getStarImageView(isFill: Bool) -> UIImageView {
        var imgName = ""
        if isFill {
            imgName = "star.fill"
        } else {
            imgName = "star"
        }
        
        let imgView = UIImageView(image: UIImage(systemName: imgName))
        imgView.frame.size = CGSize(width: starSize, height: starSize)
        imgView.tintColor = starColor
        return imgView
    }
    
    func setRating() {
        for index in 0 ..< maxRating {
            let hidden = Float(index) >= currentRating
            fillStars[index].isHidden = hidden
        }
    }
}
