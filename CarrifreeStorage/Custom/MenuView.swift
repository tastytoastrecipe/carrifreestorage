//
//  MenuView.swift
//  innkeeper
//
//  Created by orca on 2020/07/06.
//  Copyright © 2020 example. All rights reserved.
//

import UIKit

protocol MenuViewDelegate {
    func onMenuSelected(selectedViewTitle: String?)
}

class MenuView: UIView {
    
    @IBOutlet var views: [UIView] = []
    
    class MenuItem {
        var title: UILabel
        var selectedBar: UIView
        var selectedView: UIView
        var badge: UIImageView
        var tag: Int = 0
        
        init(title: UILabel, selectedBar: UIView, selectedView: UIView, badge: UIImageView, tag: Int) {
            self.title = title
            self.selectedBar = selectedBar
            self.selectedView = selectedView
            self.badge = badge
            self.tag = tag
        }
    }
    
    var menuItems: [MenuItem] = []
    var selectedTag = 0//InnTags.MENU_VIEW_ITEM_INFO]
    var menuViewDelegate: MenuViewDelegate?
    var selectedColor: UIColor = _utils.symbolColorSemi
    var normalColor: UIColor = .darkGray
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func configure(titles: [String], selectedColor: UIColor = _utils.symbolColorSemi, normalColor: UIColor = .darkGray, callConfigure: Bool = true) {
        self.selectedColor = selectedColor
        self.normalColor = normalColor
        
        setMenuItems(titles: titles, views: views)
        
        if callConfigure { self.callConfigure() }
    }
    
    func configure(titles: [String], views: [UIView], selectedColor: UIColor = _utils.symbolColorSemi, normalColor: UIColor = .darkGray, callConfigure: Bool = true) {
        self.views = views
        configure(titles: titles, selectedColor: selectedColor, normalColor: normalColor, callConfigure: callConfigure)
    }
    
    func callConfigure() {
        let time = DispatchTime.now() + .milliseconds(300)
        DispatchQueue.main.asyncAfter(deadline: time, execute: {
            for v in self.views { v.configure() }
        })
    }
 
    // 타이틀의 개수 만큼 메뉴 아이템 생성
    func setMenuItems(titles: [String], views: [UIView]) {
        
        if titles.count != views.count {
            print("Each count does not match..")
            return
        }
        
        let viewWidth = self.frame.width
//        let screenWidth = UIScreen.main.bounds.width
        let itemCount = titles.count
        let itemWidth = viewWidth / CGFloat(itemCount)
        let itemHeightHalf = self.frame.height / 2
        
        // 하단 구분선 추가
        let bottomLineView: UIView = UIView(frame: CGRect(x: 0, y: self.frame.height - 1, width: viewWidth, height: 1))
        bottomLineView.backgroundColor = normalColor
        bottomLineView.alpha = 0.5
        self.addSubview(bottomLineView)
        
        let labelHeight: CGFloat = 32
        
        let selectedViewHeight: CGFloat = 3
        let selectedViewPosY = self.frame.height - selectedViewHeight
        
        var tag = 0//InnTags.MENU_VIEW_ITEM_INFO]
        var itemPosX: CGFloat = 0
        for title in titles {
            // ──────────── 각 아이템에 해당하는 view를 생성하고 width/tag/gesture ──────────── //
            let itemView: UIView = UIView(frame: CGRect(x: itemPosX, y: 0, width: itemWidth, height: self.frame.height))
            itemView.tag = tag
            
            let gesture = UITapGestureRecognizer(target: self, action: #selector(self.tappedItem(_:)))
            itemView.addGestureRecognizer(gesture)
            // ──────────────────────────────────────────────────────────────────────── //
            
            // ──────────────── 아이템안의 label과 선택됐음을 표시하는 view 생성 ──────────────── //
            let labelPosY = itemHeightHalf - (labelHeight / 2)
            let labelTitle: UILabel = UILabel(frame: CGRect(x: 0, y: labelPosY, width: itemWidth, height: labelHeight))
            labelTitle.text = title
            labelTitle.textColor = normalColor
            labelTitle.textAlignment = .center
        
            let selectedBar: UIView = UIView(frame: CGRect(x: 0, y: selectedViewPosY, width: itemWidth, height: selectedViewHeight))
            selectedBar.backgroundColor = selectedColor
//            selectedBar.alpha = 0.7
            
            itemView.addSubview(labelTitle)
            itemView.addSubview(selectedBar)
            // ──────────────────────────────────────────────────────────────────────── //
            
            // ─────────────────────────────── Badge 생성 ─────────────────────────────── //
            let img = UIImage(systemName: "1.circle.fill")
            let badge = UIImageView(image: img)
            let badgeWidth: CGFloat = 20
            badge.frame = CGRect(x: itemWidth - (badgeWidth + 5), y: 2, width: badgeWidth, height: badgeWidth)
            badge.tintColor = .systemRed
            badge.contentMode = .scaleAspectFit
            itemView.addSubview(badge)
            // ───────────────────────────────────────────────────────────────────────── //
            
            self.addSubview(itemView)
            let menuItem: MenuItem = MenuItem(title: labelTitle, selectedBar: selectedBar, selectedView: views[tag], badge: badge, tag: tag)
            menuItems.append(menuItem)
            
            itemPosX += itemWidth
            tag += 1
        }
        
        self.setBadges(hidden: true, badgeImgName: "")
        self.setSelected()
    }
    
    @objc func tappedItem(_ sender: UIGestureRecognizer) {
        guard let selectedView = sender.view else { return }
        
        selectedTag = selectedView.tag
//        print("selected tag : \(selectedTag)")
        
        setSelected()
    }
    
    func setSelected()
    {
        for item in menuItems {
            if item.tag == selectedTag {
                item.selectedBar.alpha = 1
                item.title.font = UIFont.systemFont(ofSize: item.title.font.pointSize, weight: .bold)
                item.title.textColor = selectedColor
                item.selectedView.isHidden = false
                item.selectedView.selectedByMenu()
                menuViewDelegate?.onMenuSelected(selectedViewTitle: item.title.text)
            }
            else {
                item.selectedBar.alpha = 0.0
                item.title.font = UIFont.systemFont(ofSize: item.title.font.pointSize, weight: .regular)
                item.title.textColor = normalColor
                item.selectedView.isHidden = true
            }
        }
    }
    
    func setSelected(at index: Int, selected: Bool) {
        selectedTag = index
        setSelected()
    }
    
    func setBadges(hidden: Bool, badgeImgName: String) {
        menuItems.forEach({
            $0.badge.isHidden = hidden
            $0.badge.image = UIImage(systemName: badgeImgName)
            if nil == $0.badge.image { $0.badge.image = UIImage(named: badgeImgName) }
        })
    }

    func setBadge(at index: Int, hidden: Bool, badgeImgName: String) {
        for (i, item) in menuItems.enumerated() {
            if i == index {
                item.badge.isHidden = hidden
                item.badge.image = UIImage(systemName: badgeImgName)
                if nil == item.badge.image { item.badge.image = UIImage(named: badgeImgName) }
            }
        }
    }
}
