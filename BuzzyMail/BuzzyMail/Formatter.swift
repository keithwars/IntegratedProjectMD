//
//  Formatter.swift
//  BuzzyMail
//
//  Created by Lennart Schelfhout on 24/11/2017.
//  Copyright © 2017 Jérémy Keusters. All rights reserved.
//

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

    class func dateTimeTimeZoneToString(date: JSON) -> String {
        let graphTimeZone = date["timeZone"].stringValue
        let graphDateString = date["dateTime"].stringValue
        if (graphDateString.isEmpty) {
            return ""
        }

        let toDateFormatter = DateFormatter()
        toDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.sss"
        toDateFormatter.timeZone = TimeZone(identifier: graphTimeZone)

        let dateObj = toDateFormatter.date(from: graphDateString)
        if (dateObj == nil) {
            return ""
        }

        let toStringFormatter = DateFormatter()
        toStringFormatter.dateStyle = DateFormatter.Style.long
        toStringFormatter.timeStyle = DateFormatter.Style.none
        toStringFormatter.timeZone = TimeZone.current

        return toStringFormatter.string(from: dateObj!)
    }

    class func dateTimeToTime(date: JSON) -> String {
        let graphTimeZone = date["timeZone"].stringValue
        let graphDateString = date["dateTime"].stringValue
        if (graphDateString.isEmpty) {
            return ""
        }

        let toDateFormatter = DateFormatter()
        toDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.sss"
        toDateFormatter.timeZone = TimeZone(identifier: graphTimeZone)

        let dateObj = toDateFormatter.date(from: graphDateString)
        if (dateObj == nil) {
            return ""
        }

        let toStringFormatter = DateFormatter()
        toStringFormatter.dateStyle = DateFormatter.Style.short
        toStringFormatter.timeStyle = DateFormatter.Style.short
        toStringFormatter.timeZone = TimeZone.current

        return toStringFormatter.string(from: dateObj!)
    }

    class func timeToHourAndMin(date: JSON) -> String {
        let graphTimeZone = date["timeZone"].stringValue
        let graphDateString = date["dateTime"].stringValue
        if (graphDateString.isEmpty) {
            return ""
        }

        let toDateFormatter = DateFormatter()
        toDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.sss"
        toDateFormatter.timeZone = TimeZone(identifier: graphTimeZone)
        print("tijdzone")
        print(graphTimeZone)

        let dateObj = toDateFormatter.date(from: graphDateString)
        if (dateObj == nil) {
            return ""
        }

        let toStringFormatter = DateFormatter()
        toStringFormatter.dateStyle = DateFormatter.Style.none
        toStringFormatter.timeStyle = DateFormatter.Style.short
        toStringFormatter.timeZone = TimeZone.current

        return toStringFormatter.string(from: dateObj!)
    }
    
    class func convertDateFormater(date: String) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        let dateum = dateFormatter.date(from: date)
     
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss z"
        dateFormatter.dateStyle = DateFormatter.Style.short
        dateFormatter.timeStyle = DateFormatter.Style.none
        dateFormatter.timeZone = TimeZone.current
        let newString = dateFormatter.string(from: dateum!)

        return newString
        
    }
}
