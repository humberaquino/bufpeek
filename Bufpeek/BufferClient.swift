import BufpeekKit
import PromiseKit
import XCGLogger

// This client uses the BaseAPIClient to compound REST calls and provide utility methods
// to work at a higher level of abstraction with the client. E.g. globalRefreshPromise()
public class BufferClient {
    
    public private(set) var baseAPIClient: BaseAPIClient!
    
    public private(set) var profiles: [ProfileDAO] = []
    public private(set) var allUpdates: [UpdateDAO] = []
    
    // Starts the client and setups the basicAPIClient
    public init(clientId: String, clientSecret: String, redirectURI: String, responseType: String, grantType: String, accessToken: String?) {
        baseAPIClient = BaseAPIClient(clientId: clientId, clientSecret: clientSecret, redirectURI: redirectURI, responseType: responseType, grantType: grantType)
        setupAccessToken(accessToken)
    }
    // Updates the access token
    public func setupAccessToken(accessToken: String?) {
        baseAPIClient.accessToken = accessToken
    }        
    
    // Performs a global refresh which gets all the profies of the logged in user and today's updates 
    // for each one
    public func globalRefreshPromise() -> Promise<String> {
        
        let promise = Promise<String> {
            fulfill, reject in
            
            var pendingUpdatesList:[UpdateListDAO] = []
            var sentUpdatesList:[UpdateListDAO] = []
            
            let profileListFuture = baseAPIClient.fetchProfileList()
            
            profileListFuture.then { profileList -> Promise<[UpdateListDAO]> in
                self.profiles = profileList
                return self.baseAPIClient.fetchPendingUpdateForProfiles(profileList)
            }.then { pendingUpdatesResult -> Promise<[UpdateListDAO]> in
                
                pendingUpdatesList = pendingUpdatesResult
                
                let sentUpdatePromise = self.baseAPIClient.fetchSentUpdateForProfiles(self.profiles)
                
                return sentUpdatePromise

            }.then { sentUpdatesResult -> Void in
                sentUpdatesList = sentUpdatesResult
                
                // Process both lists
                self.joinUpdatesAndFilter(pendingUpdatesList, sentUpdates: sentUpdatesList)
                fulfill("Success")
            
            }.catch { error in
                println(error.localizedDescription)
                reject(error)
            }
        }
        
        return promise
    }
    
    // Utility method to join pending nd sent updates, and also filter the ones that that have today's date
    func joinUpdatesAndFilter(pendingUpdates: [UpdateListDAO], sentUpdates: [UpdateListDAO]) {
        var result:[UpdateDAO] = []
        
        for element in pendingUpdates {
            if let updates = element.updates {
                
                for update in updates {
                    update.updateType = .Pending
                    
                    if let scheduledAt = update.scheduledAt {
                        if NSCalendar.currentCalendar().isDateInToday(scheduledAt) {
                            result.append(update)
                        }
                    } else {
                        // Buffer time. Use due_at
                        if let dueAt = update.dueAt {
                            if NSCalendar.currentCalendar().isDateInToday(dueAt) {
                                result.append(update)
                            }
                        } else {
                            // Weird. This should not happend, right?
                            // Just skip
                            println("WARN: A pending update without scheduled_at attribute")
                        }
                    }
                    
                }
            }
        }
        
        for element in sentUpdates {
            if let updates = element.updates {
                for update in updates {
                    update.updateType = .Sent
                    if let sentAt = update.sentAt {
                        if NSCalendar.currentCalendar().isDateInToday(sentAt) {
                            result.append(update)
                        }
                    } else {
                        // Weird. This should not happend, right?
                        // Just skip
                        println("WARN: A sent update without sent_at attribute")
                    }
                }
            }
        }
        
        self.allUpdates = result
    }
    
    
    public func stop() {
        // TODO: Code to cancel the requests
    }
    
   
    
}
