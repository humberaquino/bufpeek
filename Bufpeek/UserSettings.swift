import Foundation

// Singleton used to persist the user settings and access token
class UserSettings {
    
    struct Keys {
        static let AccessToken = "bufpeek.oauth.access_token"
    }
    
    let userDefaults = NSUserDefaults.standardUserDefaults()
    
    func saveAccessToken(accessToken: String) {
        userDefaults.setValue(accessToken, forKey: Keys.AccessToken)                
    }
    
    func currentAccessToken() -> String? {
        return userDefaults.valueForKey(Keys.AccessToken) as? String
    }
    
    func sync() {        
        userDefaults.synchronize()
    }
    
    func forgetToken() {
        userDefaults.setValue(nil, forKey: Keys.AccessToken)
    }
    
    // Singleton declaration
    class func sharedInstance() -> UserSettings {
        struct Static {
            static let instance = UserSettings()
        }
        
        return Static.instance
    }
    
}