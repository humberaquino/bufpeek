

public enum SocialService: String {
    case Twitter = "twitter"
    case Facebook = "facebook"
    case LinkedIn = "linkedin"
    case GPlus = "gplus"
    case Pinterest = "pinterest"
    case TwitterRetweet = "retweet"
}

// Class responsible of filtering updates base on service and type criterias
public class UpdatesManager {
    
    var updates: [UpdateDAO] = []
    var profiles: [ProfileDAO] = []
    
    // Empty means all
    public var serviceIdFilter: [String] = []
    public var updateTypeFilter: [UpdateType] = [.Pending]
    
    public init () {
        
    }
    
    // The core method of the update. Get the list of filtered updates
    public var filteredUpdates: [UpdateDAO] {
        return updates.filter { (update) -> Bool in
            
            if !self.updateTypeFilter.contains(update.updateType!) {
                return false
            }
           
            if !self.serviceIdFilter.contains(update.profileService!) {
                return false
            }
            
            return true
        }
    }
    
    public func setup(profiles: [ProfileDAO], updates: [UpdateDAO]) {
        self.updates = updates
        self.profiles = profiles
    }
    
    // Calculates a percentage value (represented in a double number from 0 to 1)
    // to know the progress of the updates. 
    // It's basically: sent updates / (sent updates + pending updates)
    public func currentUpdateProgressValue() -> Double {
        var pending = 0
        var sent = 0
        
        for update in self.updates {
            if let type = update.updateType {
                if type == UpdateType.Pending {
                    pending += 1
                } else {
                    sent += 1
                }
            } else {
                // Workaround for now
                sent += 1
            }
        }
        
        let total = pending + sent
        if total == 0 {
            return 1.0
        }
        
        return Double(sent) / Double(total)
        
    }
            
}