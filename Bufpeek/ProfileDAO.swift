import ObjectMapper


// Represents a single profile
public class ProfileDAO: Mappable, Printable {
    
    public var id: String?
    public var avatar: String?
    public var service: String?
    public var serviceId: String?
    public var serviceUsername: String?
    public var userId: String?
    public var defaultProfile: Bool?
    public var coverPhoto: String?
    public var disconnected: Bool?
    public var serviceType: String?
    public var timezone: String?

    
    public class func newInstance(map: Map) -> Mappable? {
        return ProfileDAO()
    }
    
    public func mapping(map: Map) {
        id <- map["id"]
        avatar <- map["avatar"]
        service <- map["service"]
        serviceId <- map["service_id"]
        serviceUsername <- map["service_username"]
        userId <- map["user_id"]
        defaultProfile <- map["default"]
        coverPhoto <- map["cover_photo"]
        disconnected <- map["disconnected"]
        serviceType <- map["service_type"]
        timezone <- map["timezone"]                
    }
    
    // MARK: Printable
    
    public var description: String {
        return "[\(id!)] \(service!)"
    }
    
}