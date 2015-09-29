import Cocoa
import Alamofire
import CCNStatusItem
import BufpeekKit
import XCGLogger

// Global buffer client
var bufferClient: BufferClient!

// Global logger
let logger = XCGLogger.defaultInstance()

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(-1)

    let viewManager = ViewManager.sharedInstance()
    
    var initialViewController: InitialViewController!
    
    // MARK: - NSApplicationDelegate
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        
        // 1. XCGLogger setup
        setupLogging()
        
        // 2. Configuring Buffer client
        setupBufferClient()
        
        // 3. Status bar item setup
        viewManager.start()
    }

    func applicationWillTerminate(notification: NSNotification) {
        bufferClient.stop()
        UserSettings.sharedInstance().sync()
    }
    
    // MARK: - Setup
    
    private func setupBufferClient() {
        bufferClient = BufferClient(clientId: Config.Buffer.ClientId, clientSecret: Config.Buffer.ClientSecret, redirectURI: Config.Buffer.RedirectURI, responseType: Config.Buffer.ResponseType, grantType: Config.Buffer.GrantType, accessToken: UserSettings.sharedInstance().currentAccessToken())
    }        
    
    private func setupLogging() {
        logger.setup(Config.Logger.LogLevel, showLogLevel: Config.Logger.ShowLogLevel, showFileNames: Config.Logger.ShowFileNames, showLineNumbers: Config.Logger.ShowLineNumbers, writeToFile: Config.Logger.WriteToFile, fileLogLevel: Config.Logger.FileLogLevel)
        
        // Setup to show only the time
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = Config.Logger.DateFormat
        dateFormatter.locale = NSLocale.currentLocale()
        logger.dateFormatter = dateFormatter
    }

}

