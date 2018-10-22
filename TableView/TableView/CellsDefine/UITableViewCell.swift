//
//  UITableViewCell.swift
//  TableView
//
//  Created by Nguyen Van  Quoc on 10/16/18.
//  Copyright © 2018 Nguyen Van  Quoc. All rights reserved.
//

import Foundation
import UIKit
class CustomCell: UITableViewCell {
    
    let cellLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let imageSize: CGFloat = 40
    let labelHeight: CGFloat = 40
    lazy var cellImage: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.backgroundColor = UIColor.orange
        return image
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: "cellID")
        
    }
    
    //components của cell sẽ được setup trong này.
    //Trong cell có contentView để chứa các subviews
    public func SetupCellView(string: String?) {
        contentView.addSubview(cellImage)
        cellImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10).isActive = true
        cellImage.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10).isActive = true
        cellImage.heightAnchor.constraint(equalToConstant: imageSize).isActive = true
        cellImage.widthAnchor.constraint(equalToConstant: imageSize).isActive = true
        
        cellLabel.text = string
        contentView.addSubview(cellLabel)
        cellLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        cellLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        cellLabel.heightAnchor.constraint(equalToConstant: labelHeight).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
