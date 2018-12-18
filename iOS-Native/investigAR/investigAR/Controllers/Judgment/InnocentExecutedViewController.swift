import UIKit

class InnocentExecutedViewController: UIViewController {
    
    @IBOutlet weak var executedTextView: UITextView!
    @IBOutlet weak var continueBtn: UIButton!
    
    var crime: Crime!
    
    func warningText(charac: Occupation) {
        executedTextView.text = "Logo após a execução do \(charac.rawValue), a polícia conseguiu confirmar o seu álibi"
    }
    
    override func viewDidLoad() {
        self.warningText(charac: self.crime.sentenced.last!)
    }
}
