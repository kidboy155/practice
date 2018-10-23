//
//  AboutCell.swift
//  TableView
//
//  Created by Nguyen Van  Quoc on 10/23/18.
//  Copyright © 2018 Nguyen Van  Quoc. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
class AboutCell: UITableViewCell {
    
    let aboutLabel =  UILabel()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(aboutLabel)
        
        aboutLabel.clipsToBounds = true
        aboutLabel.textColor = CommonColor.TintTitle
        aboutLabel.font = CommonFont.TintFont
        
        aboutLabel.snp.makeConstraints { (make) in
            make.left.equalTo(16)
            make.height.equalTo(20)
            make.width.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var item: ProfileViewModelItem? {
        didSet {
            guard  let item = item as? ProfileViewModelAboutItem else {
                return
            }
            
            aboutLabel.text = item.about
        }
    }
    
    static var nib:UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    static var identifier: String {
        return String(describing: self)
    }
}

