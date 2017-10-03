//
//  User.swift
//  KohZhanHwa_iOSFinalExam_TinderClone
//
//  Created by Alex Koh on 02/10/2017.
//  Copyright © 2017 AlexKoh. All rights reserved.
//

import Foundation
import UIKit

class User {
    var profileImgUrl: String?
    var name: String?
    var age: String?
    var gender: String?
    var email: String?
    var password: String?
    var description: String?
    var randomId: String?
    var matchListId: String?
    
    init() {
    }
    
    init(profileImgUrl: String, name: String, age: String, gender: String, email: String, password: String?, description: String, randomId: String, matchListId: String) {
        self.profileImgUrl = profileImgUrl
        self.name = name
        self.age = age
        self.gender = gender
        self.email = email
        self.password = password
        self.description = description
        self.randomId = randomId
        self.matchListId = matchListId
    }
}
