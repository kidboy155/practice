//
//  ViewController.swift
//  TableView
//
//  Created by Nguyen Van  Quoc on 10/16/18.
//  Copyright © 2018 Nguyen Van  Quoc. All rights reserved.
//

import UIKit
import SnapKit

class ViewController: UIViewController {
    var tableData = [String]()
    let viewModel = ProfileViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let tableView = UITableView(frame: self.view.frame, style:.plain)
        tableView.dataSource = viewModel
        
        //tableView.register(CustomCell.self, forCellReuseIdentifier: "cellID")
        self.view.addSubview(tableView)
        
        tableView.register(AboutCell.self, forCellReuseIdentifier: AboutCell.identifier)
        tableView.register(NamePictureCell.self, forCellReuseIdentifier: NamePictureCell.identifier)
        tableView.register(FriendsCell.self, forCellReuseIdentifier: FriendsCell.identifier)
        tableView.register(AttributeCell.self, forCellReuseIdentifier: AttributeCell.identifier)
        tableView.register(EmailCell.self, forCellReuseIdentifier: EmailCell.identifier)
//        tableView.register(AboutCell.nib, forCellReuseIdentifier: AboutCell.identifier)
//        tableView.register(NamePictureCell.nib, forCellReuseIdentifier: NamePictureCell.identifier)
//        tableView.register(FriendsCell.nib, forCellReuseIdentifier: FriendsCell.identifier)
//        tableView.register(AttributeCell.nib, forCellReuseIdentifier: AttributeCell.identifier)
        //tableView.register(EmailCell.nib, forCellReuseIdentifier: EmailCell.identifier)
//        tableView.estimatedRowHeight = 100
//        tableView.rowHeight = UITableView.automaticDimension
//        tableView.snp.makeConstraints { (make) in
//            make.edges.equalToSuperview()
//        }
        tableView.reloadData()
//        for count in 0...10 {
//            tableData.append("Item \(count)")
//        }
    }

//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return tableData.count
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "cellID", for: indexPath) as! CustomCell
//        cell.SetupCellView(string: tableData[indexPath.row])
//        return cell
//    }
    
}

