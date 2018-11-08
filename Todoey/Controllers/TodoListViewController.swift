//
//  ViewController.swift
//  Todoey
//
//  Created by Deniz Tutuncu on 11/4/18.
//  Copyright © 2018 Deniz Tutuncu. All rights reserved.
//

import UIKit
import RealmSwift
import  ChameleonFramework

class TodoListViewController: SwipeTableViewController {
    
    var todoItems: Results<Item>?
    let realm = try! Realm()
    
    var selectedCategory : Category? {
        didSet {
           loadItems()
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        tableView.separatorStyle = .none
        
      
        

        
 
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        title = selectedCategory?.name
        
        guard let colorHEx = selectedCategory?.color else  { fatalError()   }
        
        updateNavBar(withHexCode: colorHEx)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        updateNavBar(withHexCode: "1D9BF6")
    }
    
    //MARK: - NAV BAR SETUP METHODS
    
    func updateNavBar(withHexCode colorHExCode: String) {
        guard let navBar = navigationController?.navigationBar else {fatalError("Navigation Controller does not exist.")}
        
        guard let navBarColor = UIColor(hexString: colorHExCode) else { fatalError() }
        
        navBar.barTintColor = navBarColor
        
        navBar.tintColor = ContrastColorOf(navBarColor, returnFlat: true)
        
        navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : ContrastColorOf(navBarColor, returnFlat: true)]
        
        searchBar.barTintColor = navBarColor
    }
    

    //MARK - TableView Datasource Methods ( TABELVIEW OLUSTURMA)
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
       if let item = todoItems?[indexPath.row] {
            
            cell.textLabel?.text = item.title
        
        if let color = UIColor(hexString: selectedCategory!.color)?.darken(byPercentage:CGFloat(indexPath.row) / CGFloat(todoItems!.count)) {
             cell.backgroundColor = color
             cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
        }
        
    
        
            cell.accessoryType = item.done ? .checkmark : .none
            
        } else {
            cell.textLabel?.text = "No items Added"
        }
        
        
        

        
        return cell
    }
    
    //TableView Delegate Methods OLUSTURDUGUN CELLERI VIEW E YANSITMA VE SECINCE OLUSAN ANIMASYON , CHECK MARK ,
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let item = todoItems?[indexPath.row] {
            
            do {
            
            try realm.write {
                
            item.done = !item.done
                }
            } catch {
                print("Error saving done status, \(error)")
            }
        }
        tableView.reloadData()
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    // MARK: - ADD NEW ITEMS
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            // WHAT WILL HAPPEN ONCE USER CLICKS THE ADD ITEM BUTTON ON OUR UIALERT
            
            if let currentCategory = self.selectedCategory{
                
                do {
                try self.realm.write {

                    let newItem = Item()
                    newItem.title = textField.text!
                    newItem.dateCreated = Date()
                    newItem.color = UIColor.randomFlat.hexValue()
                    currentCategory.items.append(newItem)
                }
                } catch {
                    print("Error saving new items, \(error)")
                }
            }
            
            self.tableView.reloadData()
        }
        
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create New Item"
            textField = alertTextField
            
        }
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
        
    }
    
    
    // MARK:- MODEL MANUPULATION METHODS
    
    
    
    func loadItems() {
        
        todoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
    
    
        tableView.reloadData()
    }
    
    
    override func updateModel(at indexPath: IndexPath) {
        
        if let item = todoItems?[indexPath.row] {
            
        do {
            
          try  realm.write {
            
                realm.delete(item)
        
            }
        } catch {
            print("Error deleting Item, \(error)")
        }
        
    }
    
}
    
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    
    
}

 extension TodoListViewController: UISearchBarDelegate {
  
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        
        tableView.reloadData()
         }
    
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
            DispatchQueue.main.async {
                
                searchBar.resignFirstResponder()
   

            }
        }
   }
 }

