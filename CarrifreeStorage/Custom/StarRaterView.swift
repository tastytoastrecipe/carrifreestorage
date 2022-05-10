//
//  StarRaterView.swift
//  Carrifree
//
//  Created by orca on 2020/12/20.
//  Copyright © 2020 plattics. All rights reserved.
//

import UIKit

final class StarRaterView: UIView {
    
    static let width: CGFloat = 130
    
    @IBOutlet var stars: [UIImageView] = []
    
    var rating: Int = 5

    override init(frame: CGRect) {
        super.init(frame: frame)
        loadNib()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        loadNib()
    }
    
    func loadNib() {
        guard let view = self.loadNib(name: "StarRaterView") else { return }
        view.frame = self.bounds
        self.addSubview(view)
    }

    override func configure() {
        for (index, star) in stars.enumerated() {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tappedStar(_:)))
            star.addGestureRecognizer(tapGesture)
            star.tag = index
        }
    }
    
    @objc func tappedStar(_ sender: UIGestureRecognizer) {
        guard let selectedStar = sender.view else { return }
        
        for (index, star) in stars.enumerated() {
            if index <= selectedStar.tag {
                star.image = UIImage(systemName: "star.fill")
                rating = index + 1
            } else {
                star.image = UIImage(systemName: "star")
            }
        }
    }
    
}
