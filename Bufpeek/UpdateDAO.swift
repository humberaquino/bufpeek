import Foundation
import ObjectMapper

public enum UpdateType {
    case Pending
    case Sent
}

// Represents a single update
public class UpdateDAO: Mappable, CustomStringConvertible {
    
    public var clientId: String?
    public var createdAt: NSDate?
    public var day: String?
    public var dueAt: NSDate?
    public var id: String?
    public var profileId: String?
    public var profileService: String?
    public var scheduledAt: NSDate?
    public var sentAt: NSDate?
    public var serviceLink: String?
    public var serviceUpdateId: String?
    public var sharedNow: Bool?
    public var status: String?
    public var text: String?
    public var type: String?
    public var updatedAt: NSDate?
    public var via: String?
    public var retweetText: String?
    public var retweetUsername: String?
    public var updateType: UpdateType?

//    public class func newInstance(map: Map) -> Mappable? {
//        return UpdateDAO()
//    }
    
    required public init?(_ map: Map) {
        
    }
    
    public func mapping(map: Map) {
        id <- map["id"]
        clientId <- map["client_id"]
        createdAt <- (map["created_at"], DateTransform())
        day <- map["day"]
        dueAt <- (map["due_at"], DateTransform())
        profileId <- map["profile_id"]
        profileService <- map["profile_service"]
        scheduledAt <- (map["scheduled_at"], DateTransform())
        sentAt <- (map["sent_at"], DateTransform())
        serviceLink <- map["service_link"]
        serviceUpdateId <- map["service_update_id"]
        sharedNow <- map["shared_now"]
        status <- map["status"]
        text <- map["text"]
        type <- map["type"]
        updatedAt <- (map["updated_at"], DateTransform())
        via <- map["via"]
        retweetText <- map["retweet.text"]
        retweetUsername <- map["retweet.username"]
        
    }
    
    // MARK: Printable
    
     public var description: String {
        return "[\(id!)] \(profileService!): \(type)"
    }
}