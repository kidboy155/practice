//
//  NamePictureCell.swift
//  TableView
//
//  Created by Nguyen Van  Quoc on 10/22/18.
//  Copyright © 2018 Nguyen Van  Quoc. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

class NamePictureCell: UITableViewCell {
    let nameLabel = UILabel()
    let pictureView = UIImageView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(nameLabel)
        contentView.addSubview(pictureView)
        
        nameLabel.clipsToBounds = true
        nameLabel.textColor = CommonColor.TintTitle
        nameLabel.font = CommonFont.TintFont
        
        pictureView.clipsToBounds = true
                
        pictureView.snp.makeConstraints { (make) in
            make.left.equalTo(20)
            make.width.height.equalTo(40)
            make.centerY.equalToSuperview()
        }
        
        nameLabel.snp.makeConstraints { (make) in
            make.left.equalTo(pictureView.snp.right).offset(20)
            make.top.bottom.equalToSuperview()
            make.right.equalTo(20)
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var item: ProfileViewModelItem? {
        didSet {
            guard let item = item as? ProfileviewModelNamePictureItem else {
                return
            }
            
            nameLabel.text = item.name
            pictureView.image = UIImage(named: (item.pictureUrl ?? nil)!)
        }
    }
    static var nib:UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    static var identifier: String {
        return String(describing: self)
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        
        pictureView.image = nil
    }
}
