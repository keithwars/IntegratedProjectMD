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
        
        let sixDaysAgo = Calendar.current.date(byAdding: .day, value: -6, to: Date())
        let sixDaysAgoFromStart = Calendar.current.startOfDay(for: sixDaysAgo!)
        
        toStringFormatter.timeStyle = DateFormatter.Style.full
        toStringFormatter.dateStyle = DateFormatter.Style.full
        
        if (NSCalendar.current.isDateInToday(dateObj!)) {
            toStringFormatter.dateStyle = DateFormatter.Style.none
            toStringFormatter.timeStyle = DateFormatter.Style.short
            toStringFormatter.timeZone = TimeZone.current
        }
        else if (NSCalendar.current.isDateInYesterday(dateObj!)) {
            toStringFormatter.dateStyle = .long
            toStringFormatter.doesRelativeDateFormatting = true
            toStringFormatter.timeStyle = DateFormatter.Style.none
            toStringFormatter.timeZone = TimeZone.current
        }
        else if ((sixDaysAgoFromStart ... Date()).contains(dateObj!)) {
            toStringFormatter.dateFormat = "EEEE"
            /*toStringFormatter.dateStyle = .long
            toStringFormatter.doesRelativeDateFormatting = true
            toStringFormatter.timeStyle = DateFormatter.Style.none*/
            toStringFormatter.timeZone = TimeZone.current
        }
        else {
            toStringFormatter.dateStyle = DateFormatter.Style.short
            toStringFormatter.timeStyle = DateFormatter.Style.none
            toStringFormatter.timeZone = TimeZone.current
        }
        
        return toStringFormatter.string(from: dateObj!)
    }
}

extension Date {
    func isBetweeen(date date1: NSDate, andDate date2: NSDate) -> Bool {
        return date1.compare(self as Date).rawValue * self.compare(date2 as Date).rawValue >= 0
    }
}
