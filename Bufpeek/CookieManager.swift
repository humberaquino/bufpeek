
import Foundation

class CookieManager {
    
    func resetCookies() {
        let sharedStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        if let cookies = sharedStorage.cookies {
            print("Deleting \(cookies.count) cookies")
            
            for cookie in cookies {
                sharedStorage.deleteCookie(cookie)
            }
            
        } else {
            print("No cookies to delete")
        }
    }
    
    // Singleton declaration
    class func sharedInstance() -> CookieManager {
        struct Static {
            static let instance = CookieManager()
        }
        
        return Static.instance
    }
    
}