//
//  ProfileViewModel.swift
//  TableView
//
//  Created by Nguyen Van  Quoc on 10/22/18.
//  Copyright © 2018 Nguyen Van  Quoc. All rights reserved.
//

import Foundation
import UIKit

enum ProfileViewModelItemType : String{
    case nameAndPicture
    case about
    case email
    case friend
    case attribute
    
    var description : String {
        get{
            return self.rawValue
        }
    }
}

protocol ProfileViewModelItem {
    var type: ProfileViewModelItemType { get }
    var sectionTitle: String {get}
    var rowCount: Int {get}
}

class ProfileViewModel: NSObject {
    var items = [ProfileViewModelItem]()
    
    override init() {
        super.init()
        
        guard let data = getDataFromFile("TableData"), let profile = Profile(data: data) else {
            return
        }
        
        if let name = profile.fullName, let pictureUrl = profile.pictureUrl{
            let nameAndPictureItem = ProfileviewModelNamePictureItem(name: name, pictureUrl: pictureUrl)
            items.append(nameAndPictureItem)
        }
        
        if let about = profile.about{
            let aboutItem = ProfileViewModelAboutItem(about: about)
            items.append(aboutItem)
        }
        if let email = profile.email {
            let dobItem = ProfileViewModelEmailItem(email: email)
            items.append(dobItem)
        }
        
        let attributes = profile.profileAttribute
        if !attributes.isEmpty{
            let attributeItem = ProfileViewModelAttributeItem(attributes: attributes)
            items.append(attributeItem)
        }
        
        let friends = profile.friends
        if !friends.isEmpty {
            let friendsItem = ProfileViewModeFriendsItem(friends: friends)
            items.append(friendsItem)
        }
    }
}

extension ProfileViewModel: UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items[section].rowCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = items[indexPath.section]
        switch item.type {
            
        case .nameAndPicture:
            if let cell = tableView.dequeueReusableCell(withIdentifier: NamePictureCell.identifier, for: indexPath) as? NamePictureCell{
                cell.item = item
                return cell
            }
        case .about:
            if let cell = tableView.dequeueReusableCell(withIdentifier: AboutCell.identifier, for: indexPath) as? AboutCell {
                cell.item = item
                return cell
            }
        case .email:
            if let cell = tableView.dequeueReusableCell(withIdentifier: EmailCell.identifier, for: indexPath) as? EmailCell {
                cell.item = item
                return cell
            }

        case .friend:
            if let item = item as? ProfileViewModeFriendsItem, let cell = tableView.dequeueReusableCell(withIdentifier: FriendsCell.identifier, for: indexPath) as? FriendsCell {
                let friend = item.friends[indexPath.row]
                cell.item = friend
                return cell
            }
        case .attribute:
            if let item = item as? ProfileViewModelAttributeItem, let cell = tableView.dequeueReusableCell(withIdentifier: AttributeCell.identifier, for: indexPath) as? AttributeCell {
                cell.item = item.attributes[indexPath.row]
                return cell
            }
        }
        return UITableViewCell()
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return items[section].sectionTitle
    }
}

extension ProfileViewModel: UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = items[indexPath.section]
        print(item.sectionTitle + " type :" + item.type.rawValue)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 1.0
    }
}



class ProfileviewModelNamePictureItem: ProfileViewModelItem {
    var name: String?
    var pictureUrl: String?
    init(name: String, pictureUrl: String) {
        self.name = name
        self.pictureUrl = pictureUrl
    }
    var type: ProfileViewModelItemType {
        return .nameAndPicture
    }
    var sectionTitle: String{
        return "Main Info"
    }
    var rowCount: Int{
        return 1
    }
}
class ProfileViewModelAboutItem: ProfileViewModelItem {
    var type: ProfileViewModelItemType {
        return .about
    }
    
    var sectionTitle: String {
        return "About"
    }
    
    var rowCount: Int {
        return 1
    }
    
    var about: String
    
    init(about: String) {
        self.about = about
    }
}

class ProfileViewModelEmailItem: ProfileViewModelItem {
    var type: ProfileViewModelItemType {
        return .email
    }
    
    var sectionTitle: String {
        return "Email"
    }
    
    var rowCount: Int {
        return 1
    }
    
    var email: String
    
    init(email: String) {
        self.email = email
    }
}

class ProfileViewModelAttributeItem: ProfileViewModelItem {
    var type: ProfileViewModelItemType {
        return .attribute
    }
    
    var sectionTitle: String {
        return "Attributes"
    }
    
    var rowCount: Int {
        return attributes.count
    }
    
    var attributes: [Attribute]
    
    init(attributes: [Attribute]) {
        self.attributes = attributes
    }
}

class ProfileViewModeFriendsItem: ProfileViewModelItem {
    var type: ProfileViewModelItemType {
        return .friend
    }
    
    var sectionTitle: String {
        return "Friends"
    }
    
    var rowCount: Int {
        return friends.count
    }
    
    var friends: [Friend]
    
    init(friends: [Friend]) {
        self.friends = friends
    }
}
