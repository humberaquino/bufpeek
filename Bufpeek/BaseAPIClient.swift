import Foundation
import Alamofire
import ObjectMapper
import PromiseKit


// This is a single request API client
// Most methods are promise based to be able to chain them at higher levels of abstraction
public class BaseAPIClient {
    
    public var accessToken: String?
    
    let clientId: String
    let clientSecret: String
    let redirectURI: String
    let responseType: String
    let grantType: String
    
    public init(clientId: String, clientSecret: String, redirectURI: String, responseType: String, grantType: String) {
        self.clientId = clientId
        self.clientSecret = clientSecret
        self.redirectURI = redirectURI
        self.responseType = responseType
        self.grantType = grantType
    }
    
    // MARK: Promise based requests
    
    // Get the list of sent updates for a list of profiles
    public func fetchSentUpdateForProfiles(profileList:[ProfileDAO]) ->  Promise<[UpdateListDAO]> {
        let promise = Promise<[UpdateListDAO]> { fulfill, reject in
            
            var sentUpdatePromiseList:[Promise<UpdateListDAO>] = []
            
            for profile in profileList {
                let sentUpdate = self.fetchSentUpdates(profile.id!)
                sentUpdatePromiseList.append(sentUpdate)
            }
            
            when(sentUpdatePromiseList).then { result in
                fulfill(result)
            }.error { error in
                reject(error)
            }
        }
        
        return promise
    }
    
    // Get the list of pending updates for a list of profiles
    public func fetchPendingUpdateForProfiles(profileList:[ProfileDAO]) ->  Promise<[UpdateListDAO]> {
        let promise = Promise<[UpdateListDAO]> { fulfill, reject in
            
            var pendingUpdatePromiseList:[Promise<UpdateListDAO>] = []
            
            for profile in profileList {
                let pendingUpdate = self.fetchPendingUpdate(profile.id!)
                pendingUpdatePromiseList.append(pendingUpdate)
            }
            
            when(pendingUpdatePromiseList).then { result in
                fulfill(result)
            }.error{ error in
                reject(error)
            }
        }
        
        return promise
    }
    
    
    // Get the list of sent updates for a single profile
    public func fetchSentUpdates(profileId: String) -> Promise<UpdateListDAO>  {
        let url = URL.SentUpdatesForProfile(profileId)
        let promise = promiseFetchOfUpdatesUsingURL(url)
        return promise
    }
    
    // Get the list of sent updates for a single profile
    public func fetchPendingUpdate(profileId: String) -> Promise<UpdateListDAO>  {
        let urlString = URL.PendingUpdatesForProfile(profileId)
        let promise = promiseFetchOfUpdatesUsingURL(urlString)
        return promise
    }
    
    // Utility method to get a list of updates for a specific URL
    func promiseFetchOfUpdatesUsingURL(urlString: String) -> Promise<UpdateListDAO> {
        
        let promise = Promise<UpdateListDAO> { fulfill, reject in
            
            if accessToken == nil {
                let error = BufpeekError.tokenNotAvailable()
                reject(error)
                return
            }
            
            let parameters = [
                ParamKeys.AccessToken: self.accessToken!
            ]
            
            Alamofire.request(.GET, urlString, parameters: parameters, headers: nil).response {
                (_, _, data, error) in
                if let error = error {
                    reject(error)
                    return
                }
                
                if let JSONString = NSString(data: data!, encoding: NSUTF8StringEncoding) as? String {
                    // Success. Map
                    if let updateList = Mapper<UpdateListDAO>().map(JSONString) {
                        fulfill(updateList)
                    } else {
                        // Error while mapping
                        let error = BufpeekError.mappingError(JSONString, className: NSStringFromClass(UpdateListDAO))
                        reject(error)
                    }
                } else {
                    // Not a string
                    let error = BufpeekError.responseDataNotJSON(data)
                    reject(error)
                }
                
            }

        }
            
        return promise
    }
    
    // Get the list of profiles for a logged in user
    public func fetchProfileList() -> Promise<[ProfileDAO]> {
        let promise = Promise<[ProfileDAO]> {
            fulfill, reject in
            
            if accessToken == nil {
                let error = BufpeekError.tokenNotAvailable()
                reject(error)
                return
            }
            
            let url = URL.Profiles
            
            let parameters = [
                ParamKeys.AccessToken: accessToken!
            ]
            
            Alamofire.request(.GET, url, parameters: parameters, headers: nil).response {
                (request, response, data, error) in
                if let error = error {
                    reject(error)
                    return
                }
                
                if let JSONString = NSString(data: data!, encoding: NSUTF8StringEncoding) as? String {
                    let profiles = Mapper<ProfileDAO>().mapArray(JSONString)
                    // Success
                    fulfill(profiles)
                } else {
                    // Not a string
                    let error = BufpeekError.responseDataNotJSON(data)
                    reject(error)
                }
            }
            
        }
        
        return promise
    }
    
   
    // Request the access token using the code string
    public func requestAccessToken(code: String, completionHandler: (accessToken: String!, error: NSError?) -> Void) {
        let url = "https://api.bufferapp.com/1/oauth2/token.json"
        let parameters: [String: String] = [
            ParamKeys.ClientId: clientId,
            ParamKeys.ClientSecret: clientSecret,
            ParamKeys.RedirectURI: redirectURI,
            ParamKeys.Code: code,
            ParamKeys.GrantType: grantType
        ]
        
        let encoding = Alamofire.ParameterEncoding.URL
        Alamofire.request(.POST, url, parameters: parameters, encoding: encoding, headers: nil).responseJSON {
            response in
            
            
            
            switch response.result {
            case .Success:
                var error: NSError? = nil
                if let jsonDict = response.result.value as? NSDictionary {
                    if let accessToken = jsonDict["access_token"] as? String {
                        // Success
                        
                        completionHandler(accessToken: accessToken, error: nil)
                        return
                    } else {
                        error = BufpeekError.accessTokenNotFoundInResponse(jsonDict)
                    }
                } else {
                    error = BufpeekError.responseDataNotJSON(response.result.error)
                }
                
                // Error
                completionHandler(accessToken: nil, error: error)
            case .Failure(let error):
                print(error)
                completionHandler(accessToken: nil, error: error)
                return
            }
            
        }
    }
    
    
    // Forgets about hte access token
    public func logout() {
        accessToken = nil
    }
    
    public func urlForAuthorize() -> NSURL {
        let parameters = "\(BaseAPIClient.ParamKeys.ClientId)=\(clientId)&\(BaseAPIClient.ParamKeys.RedirectURI)=\(redirectURI)&\(BaseAPIClient.ParamKeys.ResponseType)=\(responseType)"
        
        let url = "\(BaseAPIClient.URL.Authorize)?\(parameters)"
        
        return NSURL(string: url)!
    }

}


// Constants used by the client
extension BaseAPIClient {
    
    struct ParamKeys {
        static let ClientId = "client_id"
        static let ClientSecret = "client_secret"
        static let RedirectURI = "redirect_uri"
        static let ResponseType = "response_type"
        static let GrantType = "grant_type"
        static let Code = "code"
        static let AccessToken = "access_token"
    }
    
    struct URL {
        // Auth
        static let Authorize = "https://bufferapp.com/oauth2/authorize"

        // API
        static let BaseAPIURL = "https://api.bufferapp.com"
        static let Profiles = "\(BaseAPIURL)/1/profiles.json"
        
        static func PendingUpdatesForProfile(profileId: String) -> String {
            return "\(BaseAPIURL)/1/profiles/\(profileId)/updates/pending.json"
        }
        static func SentUpdatesForProfile(profileId: String) -> String {
            return "\(BaseAPIURL)/1/profiles/\(profileId)/updates/sent.json"
        }
    }
    
}