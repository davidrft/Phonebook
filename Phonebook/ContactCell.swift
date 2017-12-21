//
//  ContactCell.swift
//  Phonebook
//
//  Created by David Riff on 20/12/17.
//  Copyright © 2017 David Riff. All rights reserved.
//

import UIKit

class ContactCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
    func configure(with contact: Contact) {
        nameLabel.text = contact.name
        numberLabel.text = contact.number
        emailLabel.text = contact.email
    }
}
