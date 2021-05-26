//Harpreet kaur
import UIKit

class product3: UIViewController {

    @IBOutlet weak var ID: UITextView!
    
    @IBOutlet weak var Provider: UITextView!
    @IBOutlet weak var Price: UITextView!
    @IBOutlet weak var Description: UITextView!
    @IBOutlet weak var Name: UITextView!
    var selectedProduct: ProductItems? {
        didSet {
            editMode = true
        }
    }
    
    // edit mode by default is false
    var editMode: Bool = false
    
    // an  instance of the productFiles in productFiles - delegate
    weak var delegate: product2?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ID.backgroundColor = .systemFill
        Name.backgroundColor = .systemFill
        Description.backgroundColor = .systemFill
        Price.backgroundColor = .systemFill
        Provider.backgroundColor = .systemFill
        ID.text = selectedProduct?.productID
        Name.text = selectedProduct?.productName
        Description.text = selectedProduct?.productDescription
        Price.text = selectedProduct?.productPrice
        Provider.text = selectedProduct?.productProvider
        view.backgroundColor = .white
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if editMode {
            delegate!.delete(note: selectedProduct!)
        }
        guard ID.text != "" else {return}
        delegate!.updateProduct(with: ID.text , with: Name.text , with: Description.text , with: Price.text, with: Provider.text )
    }

}
