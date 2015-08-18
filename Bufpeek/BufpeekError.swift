import Foundation

// Error domains, codes and utility functions

public class BufpeekError {
    
    struct Code {
        // OAuth
        static let FailedOAuth = 1000
        static let OAuthMissingAccessToken = 1001
        static let OAuthInvalidResponse = 1002
        static let TokenNotAvailable = 1003
        // Mapping
        static let MappingError = 2000
        // Fetching
        static let MultipleFetchError = 3000
        
    }
    
    struct Domain {
        static let OAuth = "OAuth"
        static let Mapping = "Mapping"
        static let Fetching = "Fetching"
    }
    
    
    public class func authErrorWithMessage(msg: String) -> NSError {
        let userInfo = [NSLocalizedDescriptionKey: msg]
        let error = NSError(domain: Domain.OAuth, code: Code.FailedOAuth, userInfo: userInfo)
        return error
    }
    
    public class func accessTokenNotFoundInResponse(json: NSDictionary) -> NSError {
        let msg = "JSON response does not contain 'access_token' element"
        let userInfo = [NSLocalizedDescriptionKey: msg]
        let error = NSError(domain: Domain.OAuth, code: Code.OAuthMissingAccessToken, userInfo: userInfo)
        return error
    }
    
    public class func responseDataNotJSON(obj: AnyObject?) -> NSError {
        let msg = "Response is not a dictionary: \(obj)"
        let userInfo = [NSLocalizedDescriptionKey: msg]
        let error = NSError(domain: Domain.OAuth, code: Code.OAuthInvalidResponse, userInfo: userInfo)
        return error
    }
    
    public class func mappingError(json: String, className: String) -> NSError {
        let msg = "Error while trying to map \(className)"
        let userInfo = [NSLocalizedDescriptionKey: msg]
        let error = NSError(domain: Domain.Mapping, code: Code.MappingError, userInfo: userInfo)
        return error
    }
    
    public class func multipleFetchError(msg: String) -> NSError {
        let userInfo = [NSLocalizedDescriptionKey: msg]
        let error = NSError(domain: Domain.Fetching, code: Code.MultipleFetchError, userInfo: userInfo)
        return error
    }
    
    public class func tokenNotAvailable() -> NSError {
        let msg = "Token not available. Probably the user is not logged in"
        let userInfo = [NSLocalizedDescriptionKey: msg]
        let error = NSError(domain: Domain.OAuth, code: Code.TokenNotAvailable, userInfo: userInfo)
        return error
    }
    
   
}