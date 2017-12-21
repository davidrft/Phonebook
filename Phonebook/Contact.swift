//
//  Contact.swift
//  Phonebook
//
//  Created by David Riff on 20/12/17.
//  Copyright © 2017 David Riff. All rights reserved.
//

import Foundation
import RealmSwift

@objcMembers class Contact: Object {
    dynamic var name: String = ""
    dynamic var number: String = ""
    dynamic var email: String = ""
    
    convenience init(name: String, number: String, email: String) {
        self.init()
        self.name = name
        self.number = number
        self.email = email
    }
}
