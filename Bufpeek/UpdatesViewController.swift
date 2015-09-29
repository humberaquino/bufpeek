import Cocoa
import PromiseKit
import BufpeekKit
import DateTools

// Main view controller that list Buffer Today's updates
class UpdatesViewController: NSViewController {
    
    @IBOutlet weak var settingsOptionsMenu: NSMenu!
    @IBOutlet weak var lastUpdateLabel: NSTextField!
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var completedLabel: NSTextField!
    @IBOutlet weak var completedProgressIndicator: NSProgressIndicator!
    @IBOutlet weak var refreshProgress: NSProgressIndicator!
    @IBOutlet weak var updatesScrollView: NSScrollView!    
    @IBOutlet weak var errorMessage: NSTextField!
    // List of update types
    // // Obs: The order of the array is the same as the order in the UI segment
    let updateTypes = [UpdateType.Pending, UpdateType.Sent]
    @IBOutlet weak var updateTypeSegment: NSSegmentedControl!

    // List of service types
    // Obs: The order of the array is the same as the order in the UI segment
    let serviceTypes = [SocialService.Twitter.rawValue, SocialService.Facebook.rawValue,
        SocialService.GPlus.rawValue, SocialService.LinkedIn.rawValue]
    @IBOutlet weak var serviceTypeSegment: NSSegmentedControl!
    
    // The tableView's data source
    var updatesDataSource: UpdatesDataSource!
    
    // The last time the app updated the list of updates
    var lastUpdate: NSDate?
    
    // Update interval configuration
    var UpdateInterval = Config.Updates.Interval
    var RefreshEverySecs = Config.Updates.RefreshEverySecs
    
    // The timer used to perform regular updates
    weak var timer: NSTimer?
    
    var globalRefreshRunning: Bool = false
    // MARK: Controller creation
    
    class func viewController() -> UpdatesViewController {
        return UpdatesViewController(nibName: "UpdatesViewController", bundle: nil)!
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

        // Setup delegates
        updatesDataSource = UpdatesDataSource()
        tableView.setDataSource(updatesDataSource)
        tableView.setDelegate(updatesDataSource)
      
        // Initial setup
        initUI()
        
        startTimerIfNeeded()
    }
    
    
    func startTimerIfNeeded() {
        if timer == nil {
            logger.debug("Starting Timer")
            showErrorMessage(false)
            // Setup timer
            timer = NSTimer.scheduledTimerWithTimeInterval(UpdateInterval, target: self, selector: Selector("timerFired:"), userInfo: nil, repeats: true)
            timer?.fire()
        }
    }
    
    // MARK: UI setup and update
    
    func initUI() {
        completedLabel.stringValue = "-- %"
        completedProgressIndicator.doubleValue = 0.0
        lastUpdateLabel.stringValue = "Last update: --"
        refreshProgress.hidden = true
        
        // Select everything
        updatesDataSource.updateServiceIds(serviceTypes)
        updatesDataSource.updateUpdateTypes(updateTypes)
        
        // Error message
        showErrorMessage(false)
    }
    
    func updateUILastUpdate() {
        var msg: String = ""
        if let lastUpdate = lastUpdate {
            msg = "Last update: \(lastUpdate.timeAgoSinceNow())"
        }
        
        lastUpdateLabel.stringValue = msg
    }
    
    func updateUICompleteIndicator() {
        let currentValue = updatesDataSource.currentUpdateProgressValue()
        completedProgressIndicator.doubleValue = currentValue
        completedLabel.stringValue = NSString(format: "%.0f%%", currentValue*100.0) as String
    }
    
    func enableRefreshProgress(enable: Bool) {
        if enable {
            refreshProgress.hidden = false
            refreshProgress.startAnimation(self)
        } else{
            refreshProgress.hidden = true
            refreshProgress.stopAnimation(self)
        }
    }
    
    func showErrorMessage(show: Bool, msg: String? = nil) {
        if show {
            if let msg = msg {
                errorMessage.stringValue = msg
                errorMessage.toolTip = msg
            } else {
                errorMessage.stringValue = "Error!" // This should not happen
            }
            errorMessage.hidden = false
        } else {
            errorMessage.hidden = true
            errorMessage.toolTip = nil
        }
    }
    
    // MARK: Timer 
    
    func timerFired(timer: AnyObject) {
        updateUILastUpdate()
        refreshUpdateListIfLastUpdateSecondsAgo(RefreshEverySecs)
    }
    
    func refreshUpdateListIfLastUpdateSecondsAgo(seconds: NSTimeInterval) {
        if let lastUpdate = lastUpdate {
            let interval = abs(lastUpdate.timeIntervalSinceNow)
            if abs(interval) > seconds {
                logger.debug("\(interval) seconds passed. Refresing update list")
                refreshUpdateList()
            }
        } else {
            logger.debug("First update")
            refreshUpdateList()
        }
    }
    
    // Handles the updates refresh process
    func refreshUpdateList() {
        // Show progress
        enableRefreshProgress(true)
        showErrorMessage(false)
        
        if globalRefreshRunning {
            logger.debug("Global refresh is already running. Skip update")
            return
        }
        // Mark as running
        globalRefreshRunning = true
        
        // Fet today updates
        let globalRefreshPromise = bufferClient.globalRefreshPromise()
            
        globalRefreshPromise.then { result -> Void in
            logger.debug("Full fetch complete")
            // Update the datasource
            self.updatesDataSource.setupDataSource(bufferClient.profiles, updates: bufferClient.allUpdates)
            // Hide the progress
            self.enableRefreshProgress(false)
            // Mark the last update with the current time
            self.lastUpdate = NSDate()
            // Reload the UI
            self.reloadUpdateUI()
            self.updateUILastUpdate()
            // Mark as not running
            self.globalRefreshRunning = false
        }.report { error in
            // Hide the progress
            self.enableRefreshProgress(false)
            // Show error
            // FIXME: Error message
            self.showErrorMessage(true, msg: "\(error)")
            self.updateUILastUpdate()
            self.globalRefreshRunning = false
        }
        
    }
    
    // Forces a UI reload
    func reloadUpdateUI() {
        updateUICompleteIndicator()
        tableView.reloadData()
    }
    
    // MARK: Actions
    
    // Handles the selection of type segments and updates the update list UI
    @IBAction func updateTypeChanged(sender: NSSegmentedControl) {
        
        var selectedUpdateTypes:[UpdateType] = []
        var noneSelected = true
        for i in 0..<sender.segmentCount {
            if sender.isSelectedForSegment(i) {
                selectedUpdateTypes.append(updateTypes[i])
                noneSelected = false
            }
        }
        
        if noneSelected {
            // you can't deselect everything
            sender.setSelected(true, forSegment: sender.selectedSegment)
            selectedUpdateTypes.append(updateTypes[sender.selectedSegment])
        }
        
        updatesDataSource.updateUpdateTypes(selectedUpdateTypes)
        reloadUpdateUI()
    }
    
    // Handles the selection of service segments and updates the update list UI
    @IBAction func serviceChanged(sender: NSSegmentedControl) {
        var selectedServiceIds:[String] = []
        var noneSelected = true
        
        for i in 0..<sender.segmentCount {
            if sender.isSelectedForSegment(i) {
                selectedServiceIds.append(serviceTypes[i])
                noneSelected = false
            }
        }
        
        if noneSelected {
            // you can't deselect everything
            sender.setSelected(true, forSegment: sender.selectedSegment)
            selectedServiceIds.append(serviceTypes[sender.selectedSegment])
        }
        
        updatesDataSource.updateServiceIds(selectedServiceIds)
        reloadUpdateUI()
    }
    
    @IBAction func showSettingsAction(sender: NSButton) {
        NSMenu.popUpContextMenu(settingsOptionsMenu, withEvent: NSApplication.sharedApplication().currentEvent!, forView: sender)
    }
    
    @IBAction func refreshAction(sender: NSMenuItem) {
        logger.info("Refresh the update list")
        refreshUpdateList()
    }
    
    @IBAction func logoutAction(sender: NSMenuItem) {
        logger.info("Logout")
        
        // Logout
        bufferClient.baseAPIClient.logout()
        UserSettings.sharedInstance().forgetToken()
        
        // Stop the timer
        logger.debug("Stopping timer")
        timer?.invalidate()
        
        ViewManager.sharedInstance().showCleanInitialViewController()
    }
    
    @IBAction func quitAction(sender: NSMenuItem) {
        logger.info("Quit")
        NSApplication.sharedApplication().terminate(self)
    }
    
}
