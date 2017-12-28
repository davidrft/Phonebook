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
    let searchController = UISearchController(searchResultsController: nil)
    var filteredContacts = [Contact]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "+", style: .done, target: self, action: #selector(addTapped))
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Contacts"
        navigationItem.searchController = searchController
        definesPresentationContext = true

    
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
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
            return filteredContacts.count
        }
        return contacts.count
    }
        
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ContactCell") as? ContactCell else { return UITableViewCell() }
        
        let contact: Contact
        if isFiltering() {
            contact = filteredContacts[indexPath.row]
        }
        else {
            contact = contacts[indexPath.row]
        }
        cell.configure(with: contact)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isFiltering() {
            contactToEdit = filteredContacts[indexPath.row]
        }
        else {
            contactToEdit = contacts[indexPath.row]
        }
        performSegue(withIdentifier: "ShowAddContactSegue", sender: self)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        let contact: Contact
        if isFiltering() {
            contact = filteredContacts[indexPath.row]
        }
        else {
            contact = contacts[indexPath.row]
        }
        RealmService.shared.delete(contact)
        self.tableView.deleteRows(at: [indexPath], with: .automatic)
    }
}

extension ViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
    
    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String, scop: String = "All") {
        filteredContacts = contacts.filter({(contact: Contact) -> Bool in
            return contact.name.lowercased().contains(searchText.lowercased())
        })
        
        tableView.reloadData()
    }
    
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
}
