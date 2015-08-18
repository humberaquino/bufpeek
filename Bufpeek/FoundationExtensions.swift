import Foundation

extension NSDate {
    
    var formattedAsTime:String {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "H:mm a"
        return formatter.stringFromDate(self)
    }
    
    func formattedWith(format:String) -> String {
        let formatter = NSDateFormatter()
        formatter.dateFormat = format
        return formatter.stringFromDate(self)
    }
    
}