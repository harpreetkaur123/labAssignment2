//Harpreet kaur

import UIKit
import CoreData

class product2: UITableViewController {

    @IBOutlet weak var trashBtn: UIBarButtonItem!
 
    var flag = true
    var deletingMovingOption: Bool = false
    
    // create notes
    var products = [ProductItems]()
    
    var chosenProductFolder: ProductFolder? {
        didSet {
            load()
        }
    }
    
    // create the context
    
    var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
   // define a search controller
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.title = chosenProductFolder?.name
        showSearchBar()
         defaultData()
   }
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "product2", for: indexPath)
        let p = products[indexPath.row]
        let p1 = "Product =  " + p.productName!
        cell.textLabel?.text = p1
        cell.textLabel?.textColor = .black
        cell.backgroundColor = .white
        return cell
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            delete(note: products[indexPath.row])
            save()
            products.remove(at: indexPath.row)
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    //MARK: - Core data interaction functions
    /// load products core data
    /// - Parameter predicate: parameter comming from search bar - by default is nil
    func load(predicate: NSPredicate? = nil) {
        let request: NSFetchRequest<ProductItems> = ProductItems.fetchRequest()
        let folderPredicate = NSPredicate(format: "parentFolder.name=%@", chosenProductFolder!.name!)
      //  request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        if let additionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [folderPredicate, additionalPredicate])
        } else {
            request.predicate = folderPredicate
        }
        
        do {
            products = try context.fetch(request)
        } catch {
            print("Error loading products \(error.localizedDescription)")
        }
        tableView.reloadData()
    }
    
    /// delete product  from context
    /// - Parameter note: note defined in Core Data
    func delete(note: ProductItems) {
        context.delete(note)
    }
    
    /// update product in core data
    /// - Parameter title: note's title
    func updateProduct(with ID: String , with name : String , with description : String , with price : String , with provider : String ) {
        products = []
        let newNote = ProductItems(context: context)
        newNote.productID = ID
        newNote.productName = name
        newNote.productDescription = description
        newNote.productPrice = price
        newNote.productProvider = provider
        newNote.parentFolder = chosenProductFolder
        save()
        
        load()
    }
    
    /// Save notes into core data
    func save() {
        do {
            try context.save()
        } catch {
            print("Error saving the products \(error.localizedDescription)")
        }
    }
    
    //MARK: - Action methods
    
    /// trash bar button functionality
    /// - Parameter sender: bar button
    @IBAction func trashBtnPressed(_ sender: UIBarButtonItem) {
        if let indexPaths = tableView.indexPathsForSelectedRows {
            let rows = (indexPaths.map {$0.row}).sorted(by: >)
            
            let _ = rows.map {delete(note: products[$0])}
            let _ = rows.map {products.remove(at: $0)}
            
            tableView.reloadData()
            save()
        }
    }
    
    /// editing option functionality - when three dots is pressed this function is executed
    /// - Parameter sender: bar button
    @IBAction func editingBtnPressed(_ sender: UIBarButtonItem) {
        deletingMovingOption = !deletingMovingOption
        
        trashBtn.isEnabled = !trashBtn.isEnabled
       
        tableView.setEditing(deletingMovingOption, animated: true)
    }
    
    //MARK: - show search bar func
    func showSearchBar() {
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Enter product name for Search"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        searchController.searchBar.searchTextField.textColor = .lightGray
    }
    // MARK: - Navigation
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        guard identifier != "moveNotesSegue" else {
            return true
        }
        return deletingMovingOption ? false : true
    }
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        if let destination = segue.destination as? product3 {
            destination.delegate = self
            
            if let cell = sender as? UITableViewCell {
                if let index = tableView.indexPath(for: cell)?.row {
                    destination.selectedProduct = products[index]
                }
            }
        }
     }
    
    @IBAction func unwindToNoteTVC(_ unwindSegue: UIStoryboardSegue) {
        //let sourceViewController = unwindSegue.source
        // Use data from the view controller which initiated the unwind segue
        save()
        load()
        tableView.setEditing(false, animated: true)
    }
}

//MARK: - search bar delegate methods
extension product2: UISearchBarDelegate {
    /// search button on keypad functionality
    /// - Parameter searchBar: search bar is passed to this function
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // add predicate
        let predicate = NSPredicate(format: "productName  CONTAINS[cd] %@", searchBar.text! )
        load(predicate: predicate )
    }
    /// when the text in text bar is changed
    /// - Parameters:
    ///   - searchBar: search bar is passed to this function
    ///   - searchText: the text that is written in the search bar
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            load()
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
    
    
    func save(productId: String,productName: String,productDescription: String,productPrice: String,productProvider: String) {
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        let request: NSFetchRequest<ProductItems> = ProductItems.fetchRequest()
        let managedContext =
            appDelegate.persistentContainer.viewContext
        let entity =
            NSEntityDescription.entity(forEntityName: "ProductItems",
                                       in: managedContext)!
      let company = NSManagedObject(entity: entity,
                                     insertInto: managedContext)
      company.setValue(productId, forKeyPath: "productID")
      company.setValue(productName, forKeyPath: "productName")
      company.setValue(productDescription, forKeyPath: "productDescription")
      company.setValue(productPrice, forKeyPath: "productPrice")
      company.setValue(productProvider, forKeyPath: "productProvider")
        do {
            products = try context.fetch(request)
            try managedContext.save()
        } catch let error as NSError {
           // print("Could not save. \(error), \(error.userInfo)")
            //print("Error loading products \(error.localizedDescription)")
        }
        tableView.reloadData()
    }
    
// saving static data into core data
    func defaultData() {
   // flag = false
   // deleteNote(note: ProductDetail)
    guard let appDelegate =
        UIApplication.shared.delegate as? AppDelegate else {
            return
    }
    
    let managedContext =
        appDelegate.persistentContainer.viewContext
    let entity =
            NSEntityDescription.entity(forEntityName: "ProductItems",
                                       in: managedContext)!
    let detail = NSManagedObject(entity: entity,
                                      insertInto: managedContext)
        
    detail.setValue("1",forKeyPath: "productID")
    detail.setValue("Apple", forKeyPath: "productName")
    detail.setValue("MacOs", forKeyPath: "productDescription")
    detail.setValue("$89000", forKeyPath: "productPrice")
    detail.setValue("joy", forKeyPath: "productProvider")
    let details = NSManagedObject(entity: entity,
                                      insertInto: managedContext)
    details.setValue("2",forKeyPath: "productID")
    details.setValue("Amazon", forKeyPath: "productName")
    details.setValue("clothes", forKeyPath: "productDescription")
    details.setValue("$900", forKeyPath: "productPrice")
    details.setValue("Tommy", forKeyPath: "productProvider")
    let details1 = NSManagedObject(entity: entity,
                                      insertInto: managedContext)
    details1.setValue("3",forKeyPath: "productID")
    details1.setValue("Acraft", forKeyPath: "productName")
    details1.setValue("clothes", forKeyPath: "productDescription")
    details1.setValue("$98", forKeyPath: "productPrice")
    details1.setValue("TommyHilfigher", forKeyPath: "productProvider")
                      

        self.save(productId: "9",productName: "strawberry",productDescription: "Good to eat",productPrice: "$5.5",productProvider: "Hedgerow")
        self.save(productId: "4",productName: "refrigerator",productDescription: "keeps items cool",productPrice: "$500",productProvider: "steels")
        self.save(productId: "5",productName: "vaseline",productDescription: "Smooth skin",productPrice: "$30",productProvider: "Albert")
        self.save(productId: "6",productName: "nivea",productDescription: "anticeptic cream",productPrice: "$6",productProvider: "Maple")
        self.save(productId: "7",productName: "cold drink",productDescription: "keeps mind fresh",productPrice: "$8",productProvider: "Jimmy")
        self.save(productId: "8",productName: "bread",productDescription: "healthy food",productPrice: "$3",productProvider: "Levis")
        
       
        
}

}
