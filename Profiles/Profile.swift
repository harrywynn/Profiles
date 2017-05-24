//
//  Profile.swift
//  Passport-Challenge
//
//  Created by Harry J Wynn IV on 5/23/17.
//  Copyright © 2017 Harry J Wynn IV. All rights reserved.
//

import Foundation
import RandomKit
import FirebaseDatabase
import Firebase


class Profile {
    
    var id: UInt!
    var age: Int!
    
    var name: String!
    var gender: String!
    var hobbies: String!
    var avatar: String!
    
    
    required init?() {
        id = UInt.random(using: &Xoroshiro.default)
    }
    
    init(snapshot: FIRDataSnapshot) {
        let snapshotValue = snapshot.value as! [String: AnyObject]
        
        id = UInt(snapshotValue["id"] as! String)
        age = Int(snapshotValue["age"] as! NSNumber)
        name = snapshotValue["name"] as! String
        gender = snapshotValue["gender"] as! String
        hobbies = snapshotValue["hobbies"] as! String
        avatar = snapshotValue["avatar"] as! String
    }
    
    func serialize() -> Dictionary<String, Any> {
        return [
            "id": String(id),
            "name": name,
            "gender": gender,
            "age": age,
            "hobbies": hobbies,
            "avatar": avatar
        ]
    }
}
