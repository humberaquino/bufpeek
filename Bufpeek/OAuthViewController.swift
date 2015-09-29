import Cocoa
import WebKit
import Alamofire
import BufpeekKit


protocol OAuthViewControllerDelegate: class {
    func successAuthWithAccessToken(token: String)
    func failedAuthWithMessage(error: NSError)
    func cancelledAuth()
}

// View controller used for authenticatin with Buffer using OAuth2
class OAuthViewController: NSViewController {

    static let ControllerName = "OAuthViewController"
    
    // Outlets
    @IBOutlet weak var webView: WebView!
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    
    // Property parameters
    var urlString: String!
    
    // Flag that indicates if that the auth was displayed
    var authRequestDisplayed = false
    
    weak var delegate: OAuthViewControllerDelegate?
    
    // MARK: Controller creation
    
    class func viewController() -> OAuthViewController {
        return OAuthViewController(nibName: ControllerName , bundle: nil)!
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
        
        // 1. Setup delegate
        webView.policyDelegate = self
        webView.frameLoadDelegate = self
    }                
    
    // MARK: UI update
    
    func enableProgressIndicator(enable: Bool) {
        if enable {
            progressIndicator.startAnimation(self)
            progressIndicator.hidden = false
        } else {
            progressIndicator.stopAnimation(self)
            progressIndicator.hidden = true
            
        }
    }
    
    func clean() {
        if let webView = webView {
            let url = NSURL(string: "about:blank")!
            let request = NSURLRequest(URL: url)
            webView.mainFrame.loadRequest(request)
            webView.hidden = false
            authRequestDisplayed = false
            logger.debug("WebView cleaned")
        }
    }
    
   // MARK: Actions
    
    @IBAction func backAction(sender: NSButton) {
        cancelAuth()
    }
    
    // MARK: Business logic
    
    func startAuthorizationProcess() {
        enableProgressIndicator(true)
        let url = bufferClient.baseAPIClient.urlForAuthorize()
        let request = NSURLRequest(URL: url)
        webView.mainFrame.loadRequest(request)
    }
    
    func cancelAuth() {
        webView.stopLoading(self)
        delegate?.cancelledAuth()
    }
    
}


// MARK: - WebFrameLoadDelegate informal Protocol

extension OAuthViewController: WebFrameLoadDelegate {
    
     func webView(sender: WebView!, didFinishLoadForFrame frame: WebFrame!) {
        enableProgressIndicator(false)
        
        if let dataSource = frame.dataSource {
            
            if let url = dataSource.request.URL {
                logger.debug("URL: \(url)")
            } else {
                logger.warning("No url!")
            }
            
            if authRequestDisplayed {
                // Auth already displayed. The response should have the token
                
                if let title = dataSource.pageTitle {
                    let parts = title.componentsSeparatedByString("=")
                    if parts.count >= 2 {
                        logger.info("Code: \(parts[1])")
                        
                        // Success: 1/2
                        
                        // Get the acces token
                        bufferClient.baseAPIClient.requestAccessToken(parts[1]) {
                            (accessToken, error) in
                            if let error = error {
                                self.delegate?.failedAuthWithMessage(error)
                                return
                            }
                            
                            // Success 2/2
                            logger.info("Success: \(accessToken)")
                            self.delegate?.successAuthWithAccessToken(accessToken)
                        }
                        
                    } else {
                        // Error: Invalid title response
//                        logger.error("Invalid title: \(title)")
//                        let error = BufpeekError.authErrorWithMessage(title)
//                        delegate?.failedAuthWithMessage(error)
                    }
                } else {
                    // Error: No page title to get the code from
                    // FIXME
                    logger.info("No title")
                    let error = BufpeekError.authErrorWithMessage("No title in response")
                    delegate?.failedAuthWithMessage(error)
                }
                
            } else {
                // The first frame loaded is the authentication page
                // Mark as displayed
                // Obs: This assumes that the next frame will have the response code.
                logger.debug("Displaying authentication page")
                authRequestDisplayed = true
            }
        }
    }
    
     func webView(sender: WebView!, didFailLoadWithError error: NSError!, forFrame frame: WebFrame!) {
        logger.error(error.localizedDescription)
        delegate?.failedAuthWithMessage(error)
        
    }
    
     func webView(sender: WebView!, didFailProvisionalLoadWithError error: NSError!, forFrame frame: WebFrame!) {
        logger.error(error.localizedDescription)
        delegate?.failedAuthWithMessage(error)
    }

}

// MARK: - WebPolicyDelegate informal protocol
// https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/DisplayWebContent/Tasks/PolicyDecisions.html

extension OAuthViewController: WebPolicyDelegate {
    
     func webView(webView: WebView!, decidePolicyForNavigationAction actionInformation: [NSObject : AnyObject]!, request: NSURLRequest!, frame: WebFrame!, decisionListener listener: WebPolicyDecisionListener!) {
        
        // Check if the navigation link is the redirect uri. This means that the
        // "No thanks" link was clicked and we should cancel the auth
        if let host = request.URL?.host {
            if host == Config.Buffer.CallbackHost {
                if let queryString = request.URL?.query {
                    let paramStrings = queryString.componentsSeparatedByString("&")
                    for param in paramStrings {
                        let pair = param.componentsSeparatedByString("=")
                        if pair.count == 2 {
                            if pair[0] == "error" && pair[1] == "access_denied" {
                                listener.ignore()
                                cancelAuth()
                            }
                        }
                    }
                }
            }
        }
        
        
        
        // The link is not the redirect uri link. Just use it to continue
        listener.use()
    }
}
