import Cocoa
import Alamofire

// The view controller that is displayed whe n the user is not authenticated
class InitialViewController: NSViewController {

    static let ControllerName = "InitialViewController"

    let viewManager = ViewManager.sharedInstance()
    
    @IBOutlet weak var errorLabel: NSTextField!
    
    // Controller creation
    class func viewController() -> InitialViewController {
        return InitialViewController(nibName: ControllerName, bundle: nil)!
    }
    
    override var preferredContentSize: CGSize {
        get {
            return self.view.frame.size
        }
        set {}
    }
    
    // MARK: View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hideErrorMessage()        
    }
    
    func showUpdatesIfTokenExists() {        
        if let accessToken = UserSettings.sharedInstance().currentAccessToken() {
            // Token exists. Use updates view
            viewManager.showUpdatesViewController()
            return
        }
    }
    
    // MARK: Actions
    
    // Present's the OAuthViewController
    @IBAction func presentAuthView(sender: NSButton) {
        viewManager.showCleanOAuthViewController()
    }
    
    // MARK: Error message
    func showErrorMessage(msg: String) {
        errorLabel.stringValue = msg
        errorLabel.hidden = false
    }
    
    func hideErrorMessage() {
        errorLabel.hidden = true
    }
    
}
