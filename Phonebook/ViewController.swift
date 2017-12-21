//
//  ViewController.swift
//  Phonebook
//
//  Created by David Riff on 20/12/17.
//  Copyright © 2017 David Riff. All rights reserved.
//

import UIKit
import RealmSwift

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var contactToEdit: Contact?
    var contacts: Results<Contact>!
    var notificationToken: NotificationToken?
    let realm = RealmService.shared.realm
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "+", style: .done, target: self, action: #selector(addTapped))
    
        contacts = realm.objects(Contact.self)
        
        RealmService.shared.observeErrors(in: self) { (error) in
            print(error ?? "No error detected")
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.navigationBar.tintAdjustmentMode = .normal
        self.navigationController?.navigationBar.tintAdjustmentMode = .automatic
        
//        notificationToken?.invalidate()
        RealmService.shared.stopObservingErrors(in: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        notificationToken = realm.observe { notification, realm in
//            self.tableView.reloadData()
//        }
        
        contactToEdit = nil
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowAddContactSegue" {
            if let destination = segue.destination as? AddContactViewController {
                destination.contactToEdit = self.contactToEdit
            }
        }
    }
    
    @objc func addTapped() {
        performSegue(withIdentifier: "ShowAddContactSegue", sender: self)
        print("add")
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ContactCell") as? ContactCell else { return UITableViewCell() }
        
        let contact = contacts[indexPath.row]
        cell.configure(with: contact)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.contactToEdit = contacts[indexPath.row]
        performSegue(withIdentifier: "ShowAddContactSegue", sender: self)
        print("selected")
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        let contact = contacts[indexPath.row]
        RealmService.shared.delete(contact)
        self.tableView.deleteRows(at: [indexPath], with: .automatic)
        print("delete")
    }
}

