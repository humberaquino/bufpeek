import ObjectMapper

// Represents a list of updates for a single profile
public class UpdateListDAO: Mappable {
    
    public var total: Int?
    public var updates: [UpdateDAO]?
    
    required public init?(_ map: Map) {
        
    }
    
    public func mapping(map: Map) {
        total <- map["total"]
        updates <- map["updates"]
    }
}