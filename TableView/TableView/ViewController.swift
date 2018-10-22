//
//  ViewController.swift
//  TableView
//
//  Created by Nguyen Van  Quoc on 10/16/18.
//  Copyright © 2018 Nguyen Van  Quoc. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var tableData = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let tableView = UITableView(frame: self.view.frame, style:.plain)
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(CustomCell.self, forCellReuseIdentifier: "cellID")
        self.view.addSubview(tableView)
        tableView.reloadData()
        for count in 0...10 {
            tableData.append("Item \(count)")
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellID", for: indexPath) as! CustomCell
        cell.SetupCellView(string: tableData[indexPath.row])
        return cell
    }
    
}

