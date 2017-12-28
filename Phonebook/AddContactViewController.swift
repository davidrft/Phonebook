//
//  AddContactViewController.swift
//  Phonebook
//
//  Created by David Riff on 20/12/17.
//  Copyright © 2017 David Riff. All rights reserved.
//

import Eureka

class AddContactViewController: FormViewController {

    var contactToEdit: Contact?
    var edit = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        edit = contactToEdit != nil
        
        self.title = edit ? "Edit Contact" : "New Contact"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneTapped))
        form +++ Section("")
            <<< TextRow(){ row in
                row.title = "Name"
                row.placeholder = edit ? contactToEdit?.name : "John Smith"
                row.tag = "name"
                row.add(rule: RuleRequired())
                row.validationOptions = .validatesOnChange
            }
                .cellUpdate({ (cell, row) in
                    if !row.isValid {
                        cell.titleLabel?.textColor = .red
                    }
                })
            <<< PhoneRow(){ row in
                row.title = "Phone Number"
                row.placeholder = edit ? contactToEdit?.number : "+1-202-555-0182"
                row.tag = "number"
                row.add(rule: RuleRequired())
                row.validationOptions = .validatesOnChange
                }
                .cellUpdate({ (cell, row) in
                    if !row.isValid {
                        cell.titleLabel?.textColor = .red
                    }
                })
            <<< EmailRow() { row in
                row.title = "Email"
                row.placeholder = edit ? contactToEdit?.email : "johnsmith@gmail.com"
                row.tag = "email"
                row.add(rule: RuleEmail())
                row.validationOptions = .validatesOnChangeAfterBlurred
                }
                .cellUpdate({ (cell, row) in
                    if !row.isValid {
                        cell.titleLabel?.textColor = .red
                    }
                })
    }

    @objc func doneTapped() {
        let formValues = self.form.values()
        let name = formValues["name"]!
        let number = formValues["number"]!
        let email = formValues["email"]!
        
        if name != nil, number != nil, email != nil {
            if !edit {
                let newContact = Contact(name: name as! String, number: number as! String, email: email as! String)
                RealmService.shared.create(newContact)
            }
            else {
                let dict: [String: Any?] = ["name": name,
                                            "number": number,
                                            "email": email]
                RealmService.shared.update(contactToEdit!, with: dict)
            }
            self.contactToEdit = nil
            navigationController?.popToRootViewController(animated: true)
        }
        else {
            let alert = UIAlertController(title: "Please fill all the fields", message: "", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
}

