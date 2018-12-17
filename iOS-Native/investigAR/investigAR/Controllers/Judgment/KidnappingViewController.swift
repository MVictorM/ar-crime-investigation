import UIKit

class KidnappingViewController: UIViewController {
    @IBOutlet weak var kidnappingTextView: UITextView!
    @IBOutlet weak var continueBtn: UIButton!
    let character = "Professor"
    
    // criei essa função se precisar ficar alterando o texto,
    // se não pode jogar isso pra o viewDidLoad
    func warningText(charac: String) {
        kidnappingTextView.text = "O \(charac) foi sequestrado e não poderá mais ajudar nas investigaçãoes"
    }
    
    override func viewDidLoad() {
        warningText(charac: "Professor")
    }
}
