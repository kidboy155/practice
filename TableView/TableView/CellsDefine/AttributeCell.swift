//
//  AttributeCell.swift
//  TableView
//
//  Created by Nguyen Van  Quoc on 10/23/18.
//  Copyright © 2018 Nguyen Van  Quoc. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

class AttributeCell: UITableViewCell {
    let titleLabel = UILabel()
    let valueLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(titleLabel)
        contentView.addSubview(valueLabel)
        
        titleLabel.clipsToBounds = true
        titleLabel.textColor = CommonColor.TintTitle
        titleLabel.font = CommonFont.TintFont
        
        valueLabel.clipsToBounds = true
        
        valueLabel.snp.makeConstraints { (make) in
            make.left.equalTo(16)
//            make.width.equalTo(200)
            make.height.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { (make) in
            //make.left.equalTo(valueLabel.snp.right).offset(12)
            make.top.bottom.equalToSuperview()
            make.right.equalToSuperview().offset(-16)
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var item: Attribute? {
        didSet {
            titleLabel.text = item?.key
            valueLabel.text = item?.value
        }
    }
    static var nib:UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    static var identifier: String {
        return String(describing: self)
    }
}
