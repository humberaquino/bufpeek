import XCGLogger

// This struct contain constants that are likely to change by the developer  
struct Config {
    
    // XCGLogger
    struct Logger {
        static let LogLevel = XCGLogger.LogLevel.Debug
        static let ShowLogLevel = true
        static let ShowFileNames = false
        static let ShowLineNumbers = true
        static let WriteToFile:String! = nil
        static let FileLogLevel = XCGLogger.LogLevel.Debug
        static let DateFormat = "hh:mm:ss:SSS"
    }
    
    // Buffer api constants 
    struct Buffer {
        static let ClientId = "55c54169c6eeaa233fa9f3d5"
        static let RedirectURI = "urn:ietf:wg:oauth:2.0:oob"
        static let ClientSecret = "a0e1aaaabc1a4d0559c34960782171d6"
        static let ResponseType = "code"
        static let GrantType = "authorization_code"
        // Used in the OAuth2 view controller
        static let CallbackHost = "ietf"
    }
    
    struct Updates {
        // Amount of seconds the timer waits until it fires it again
        static let Interval: NSTimeInterval = 10.0
        // Amount of seconds to wait until the list of updates is refreshed
        static let RefreshEverySecs: NSTimeInterval = 120.0
    }
    
}