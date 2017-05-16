//
//  ViewController.swift
//  GuestList
//
//  Created by Pierre Binon on 2017-05-16.
//  Copyright © 2017 Pierre Binon. All rights reserved.
//

import UIKit
import CoreData


class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    //var names: [String] = []
    var people: [NSManagedObject] = []
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        title = "The List"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear (animated)
        
        /* 1 - Pull up the application delegate and grab a reference to its persistent container to get your hands on its NSManagedObjectContext */
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        /* 2 - Fetch from Core Data */
        let fetchRequest = NSFetchRequest<NSManagedObject> (entityName: "Person")
        
        /* 3 - hand the fetch request over to the managed object context to do the heavy lifting.fetch(_:)returns an array of managed objects meeting the criteria specified by the fetch request */
        do {
            
            people = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            
            print ("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    
    // Implement the addName IBAction
    @IBAction func addName(_ sender: UIBarButtonItem) {
        
        let alert = UIAlertController (title: "New Name", message: "Add a new name", preferredStyle: .alert)
        let saveAction = UIAlertAction (title: "Save", style: .default) {
            [unowned self] action in
            
            guard let textField = alert.textFields?.first, let nameToSave = textField.text else {
                
                return
            }
            
            //self.names.append(nameToSave)
            self.save (name: nameToSave)
            self.tableView.reloadData()
        }
        
        let cancelAction = UIAlertAction (title: "Cancel", style: .default)
        
        alert.addTextField()
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present (alert, animated: true)
        
    }
    
    
    func save (name: String) {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            
            return
        }
        
        /* 1 - Before you can save or retrieve anything from your Core Data store,you first need to get your hands on an NSManagedObjectContext. You can consider a managed object context as an in-memory “scratchpad” for working with managed objects */
        let managedContext = appDelegate.persistentContainer.viewContext
        
        /* 2 - Create a new managed object and insert it into the managed object context.You can do this in one step with NSManagedObject’s static method: entity(forEntityName:in:) */
        let entity =    NSEntityDescription.entity(forEntityName: "Person", in: managedContext)!
        let person = NSManagedObject (entity: entity, insertInto: managedContext)
        
        /* 3 - With an NSManagedObject in hand,you set the name attribute using key-value coding.You must spell the KVC key (name in this case) exactly as it appears in your Data Model */
        person.setValue(name, forKey: "name")
        
        /* 4 - Commit your changes to person and save to disk by calling save on the managed object context . Also, insert the new managed object into the people array so it shows up when the table view reloads */
        do {
            
            try managedContext.save()
            people.append(person)
        } catch let error as NSError {
            
            print ("Could not save. \(error), \(error.userInfo)")
        }
    }
}


// MARK: - UITableViewDataSource
extension ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        //return names.count
        return people.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let person = people[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        //cell.textLabel?.text = names[indexPath.row]
        //Grab the name attribute from the NSManagedObject - person is the entity
        cell.textLabel?.text = person.value(forKeyPath: "name") as? String
        
        return cell
    }
}
