import UIKit

class InnocentExecutedViewController: UIViewController {
    
    @IBOutlet weak var executedTextView: UITextView!
    @IBOutlet weak var continueBtn: UIButton!
    
    // criei essa função se precisar ficar alterando o texto,
    // se não pode jogar isso pra o viewDidLoad
    func warningText(charac: String) {
        executedTextView.text = "Logo após a execução do \(charac), a polícia conseguiu confirmar o seu álibi"
    }
    override func viewDidLoad() {
        warningText(charac: "professor")
    }
}
