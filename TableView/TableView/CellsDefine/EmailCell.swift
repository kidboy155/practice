//
//  EmailCell.swift
//  TableView
//
//  Created by Nguyen Van  Quoc on 10/23/18.
//  Copyright © 2018 Nguyen Van  Quoc. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
class EmailCell: UITableViewCell {
    
    let emailLabel =  UILabel()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(emailLabel)
        
        emailLabel.clipsToBounds = true
        emailLabel.textColor = CommonColor.TintTitle
        emailLabel.font = CommonFont.TintFont
        
        emailLabel.snp.makeConstraints { (make) in
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
            guard  let item = item as? ProfileViewModelEmailItem else {
                return
            }
            
            emailLabel.text = item.email
        }
    }
    
    static var nib:UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    static var identifier: String {
        return String(describing: self)
    }
}
