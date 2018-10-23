//
//  ProfileModel.swift
//  TableView
//
//  Created by Nguyen Van  Quoc on 10/22/18.
//  Copyright © 2018 Nguyen Van  Quoc. All rights reserved.
//

import Foundation

public func getDataFromFile(_ fileName: String) -> Data?{
    @objc class TestClass:NSObject {}
    
    let bundle = Bundle(for: TestClass.self)
    if let path = bundle.path(forResource: fileName, ofType: "json"){
        return (try? Data(contentsOf: URL(fileURLWithPath: path)))
    }
    return nil
}

class Friend {
    var name: String?
    var pictureUrl: String?
    
    init(json: [String: Any]) {
        self.name = json["name"] as? String
        self.pictureUrl = json["pictureUrl"] as? String
    }
}

class Attribute {
    var key: String?
    var value: String?
    
    init(json: [String: Any]) {
        self.key = json["key"] as? String
        self.value = json["value"] as? String
    }
}

class  Profile {
    var fullName: String?
    var pictureUrl: String?
    var email: String?
    var about: String?
    var friends = [Friend]()
    var profileAttribute = [Attribute]()
    
    init?(data: Data) {
        do{
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any], let body = json["data"] as? [String: Any]{
                self.fullName = body["fullName"] as? String
                self.pictureUrl = body["pictureUrl"] as? String
                self.about = body["about"] as? String
                self.email = body["email"] as? String
                
                if let friends = body["friends"] as? [[String: Any]]{
                    self.friends = friends.map{ Friend(json: $0) }
                }
                
                if let profileAttribute = body["profileAttributes"] as? [[String: Any]]{
                    self.profileAttribute = profileAttribute.map{ Attribute(json: $0)}
                }
            }
        }catch{
            print("Error deseralizing Json: \(error)")
            return nil
        }
    }

}
