//
//  providerTVC.swift
//  A2_FA_iOS_Harpreet_c0808294
//
//

import UIKit
import CoreData
class providerTVC: UITableViewController {
    
    // create a  products of array  to populate the table
    var products = [ProductItems]()
    var deletingMovingOption: Bool = false
    // create a context to work with core data
    @IBOutlet var trashBtn: UIBarButtonItem!
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
   //MARK: - view lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        //print("harpreet")
     // defaultData()
        
        load()
       //  self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
  
   // override func viewWillAppear(_ animated: Bool) {
   //     tableView.reloadData()
   // }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return products.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "provider1", for: indexPath)
        let p = products[indexPath.row]
        let p1 = p.productName! + ":" + p.productProvider!
        cell.textLabel?.text = p1
       // cell.textLabel?.text =  "harpreet"
        cell.textLabel?.textColor = .black
        cell.detailTextLabel?.textColor = .black
        cell.imageView?.image = UIImage(systemName: "Provider's Name")
        cell.backgroundColor = .white
        cell.selectionStyle = .none
        
        return cell
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
           // deleteProduct(note: products[indexPath.row])
           //deleteProducts(folder: products[indexPath.row])saveProducts()
            products.remove(at: indexPath.row)
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
   }
    func delete(note: ProductItems) {
        context.delete(note)
    }
    // Save products into core data
    func save() {
        do {
            try context.save()
        } catch {
            print("Error saving the products \(error.localizedDescription)")
        }
    }
    func load() {
        let request: NSFetchRequest<ProductItems> = ProductItems.fetchRequest()
        
        do {
            products = try context.fetch(request)
           for data in products as [NSManagedObject] {
            data.value(forKey: "productProvider")as! String
            }
        }
        catch {
            print("Error loading products \(error.localizedDescription)")
        }
        tableView.reloadData()
       }
    
    //delete function
   func delete(folder: ProductItems) {
        context.delete(folder)
    }
    
 //trash button
    @IBAction func trashBtnpressed(_ sender: UIBarButtonItem) {
    
    if let indexPaths = tableView.indexPathsForSelectedRows {
                let rows = (indexPaths.map {$0.row}).sorted(by: >)
                
              let _ = rows.map {delete(note: products[$0])}
                let _ = rows.map {products.remove(at: $0)}
                tableView.reloadData()
                save()
        }
      }
    
    
    }

