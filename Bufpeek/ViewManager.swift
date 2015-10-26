
import Cocoa
import CCNStatusItem

// Singleton used to coordinate CCNStatucItem view switching
class ViewManager {
    
    let sharedItem = CCNStatusItem.sharedInstance()
    
    var initialViewController: InitialViewController!
    var oAuthViewController: OAuthViewController!
    var updatesViewController: UpdatesViewController!
    
    // Configure and start with the initial view
    func start() {
        initialViewController = InitialViewController.viewController()
        sharedItem.windowConfiguration.presentationTransition = CCNPresentationTransition.SlideAndFade
        
        // Present the view controller
        let image = NSImage(named: AppIcons.StatusBar)
        sharedItem.presentStatusItemWithImage(image, contentViewController: initialViewController)
        // Go to the updates view if we already have a token
        initialViewController.showUpdatesIfTokenExists()
    }
    
    func showCleanOAuthViewController() {
        if oAuthViewController == nil {
            oAuthViewController = OAuthViewController.viewController()
            oAuthViewController.delegate = self
        }
        oAuthViewController.clean()        
        sharedItem.updateContentViewController(oAuthViewController)
        oAuthViewController.startAuthorizationProcess()
    }
    
    func showInitialViewController() {
        sharedItem.updateContentViewController(initialViewController)
        initialViewController.showUpdatesIfTokenExists()
    }
    
    func showCleanInitialViewController() {
        showInitialViewController()
        initialViewController.hideErrorMessage()
    }
    
    func showUpdatesViewController() {
        if updatesViewController == nil {
            updatesViewController = UpdatesViewController.viewController()
        }
        sharedItem.updateContentViewController(updatesViewController)
        updatesViewController.startTimerIfNeeded()
    }
    
    // Singleton declaration
    class func sharedInstance() -> ViewManager {
        struct Static {
            static let instance = ViewManager()
        }
        
        return Static.instance
    }
}

// MARK: - OAuthViewControllerDelegate

extension ViewManager: OAuthViewControllerDelegate {
    
    func successAuthWithAccessToken(accessToken: String) {
        // Persist access token
        UserSettings.sharedInstance().saveAccessToken(accessToken)
        bufferClient.setupAccessToken(accessToken)
        
        // Show updates
        showUpdatesViewController()
    }
    
    func failedAuthWithMessage(error: NSError) {
        logger.error(error.localizedDescription)
        // Mark the error
        initialViewController.showErrorMessage("Authentication failed: \(error.localizedDescription)")
        showInitialViewController()
    }
    
    func cancelledAuth() {
        let msg = "The authentication was canceled by the user"
        logger.info(msg)
        initialViewController.showErrorMessage(msg)
        showInitialViewController()
    }
    
}