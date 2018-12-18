import UIKit

class KidnappingViewController: UIViewController {
    @IBOutlet weak var kidnappingTextView: UITextView!
    @IBOutlet weak var continueBtn: UIButton!
    
    var crime: Crime!
    
    func warningText(charac: Occupation) {
        self.kidnappingTextView.text = "O \(charac.rawValue) foi sequestrado e não poderá mais ajudar nas investigaçãoes"
    }
    
    override func viewDidLoad() {
        self.warningText(charac: self.crime.sentenced.last!)
    }
}
