import SwiftyJSON

class Formatter {
    class func dateToString(date: JSON) -> String {
        let graphDateString = date.stringValue
        if (graphDateString.isEmpty) {
            return ""
        }
        
        let toDateFormatter = DateFormatter()
        toDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        
        let dateObj = toDateFormatter.date(from: graphDateString)
        if (dateObj == nil) {
            return ""
        }
        
        let toStringFormatter = DateFormatter()

        
        return toStringFormatter.string(from: dateObj!)
    }
}
