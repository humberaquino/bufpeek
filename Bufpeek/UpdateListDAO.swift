import ObjectMapper

// Represents a list of updates for a single profile
public class UpdateListDAO: Mappable {
    
    public var total: Int?
    public var updates: [UpdateDAO]?
    
    public class func newInstance(map: Map) -> Mappable? {
        return UpdateListDAO()
    }
    
    public func mapping(map: Map) {
        total <- map["total"]
        updates <- map["updates"]
    }
}