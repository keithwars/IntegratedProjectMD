//
//  EventCell.swift
//  BuzzyMail
//
//  Created by Lennart Schelfhout on 24/11/2017.
//  Copyright © 2017 Jérémy Keusters. All rights reserved.
//

import UIKit
import SwiftyJSON

let currentDate = Date()
let service = OutlookService.shared()

struct Event {
    let subject: String?
    let start: String?
    let end: String?
    let startTime: String?
    let id: String?
}

class EventCell: UITableViewCell {
    @IBOutlet weak var subjectLabel: UILabel!
    @IBOutlet weak var startLabel: UILabel!
    @IBOutlet weak var endLabel: UILabel!
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var idLabel: UILabel!
    
    var subject: String? {
        didSet {
            subjectLabel.text = subject
        }
    }
    
    var start: String? {
        didSet {
            startLabel.text = start
        }
    }
    
    var end: String? {
        didSet {
            endLabel.text = end
        }
    }
    
    var startTime: String? {
        didSet {
            startTimeLabel.text = startTime
        }
    }
    
    var id: String? {
        didSet {
            idLabel.text = id
        }
    }

}

class EventsDataSource: NSObject {
    var events: [Event]
    
    init(events: [JSON]?) {
        var evtArray = [Event]()
        
        if let unwrappedEvents = events {
            for (event) in unwrappedEvents {
                //print("formatted:" + Formatter.deduceTime(start: currentDate))
                
                let newEvent = Event(
                    subject: event["subject"].stringValue,
                    start: Formatter.dateTimeTimeZoneToString(date: event["start"]),
                    end: Formatter.dateTimeToTime(date: event["end"]),
                    startTime: Formatter.timeToHourAndMin(date: event["start"]),
                    id: event["id"].stringValue)
                
                evtArray.append(newEvent)
                
            }
        }
        
        self.events = evtArray
    }
}

extension EventsDataSource: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        NSLog("total of events:" +  "\(events.count)")

        return events.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: EventCell.self)) as! EventCell
        let event = events[indexPath.row]
        
        cell.subject = event.subject
        cell.start = event.start
        cell.end = "Ends at: \(event.end!)"
        cell.startTime = event.startTime
        cell.id = event.id
        
        return cell
        
    }
    
    func getEventsArray() -> [Event] {
        return events
    }
    
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped cell number \(indexPath.row).")
    }
    
    // this method handles row deletion
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            // delete from outlook as well
            
            //            let row = indexPath
            //            let rowint = Int(row[0])
            
            let rowint = Int(indexPath[1])
            NSLog("TEST: " + "\(String (rowint))")
            
            NSLog("TEST2: " + "\(events.count)")
            NSLog("KEK GEDELETETE ID: " + "\(events[rowint].id!)")
            
            let eventToDelete = events[rowint].id!
            
            // delete from events
            events.remove(at: indexPath.row)
            
            // delete the table view row
            tableView.deleteRows(at: [indexPath], with: .automatic)
            service.deleteEvent(id: eventToDelete) {_ in
                
            }

            tableView.reloadData()
            
        } else if editingStyle == .insert {
            // Not used in our example, but if you were adding a new row, this is where you would do it.
        }

    }
    
//    // method to run when table view cell is tapped
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        print("You tapped cell number \(indexPath.row).")
//    }
//    
//    // this method handles row deletion
//    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
//
//        if editingStyle == .delete {
//            
//            // delete from events
//            events.remove(at: indexPath.row)
//            
//            // delete the table view row
//            tableView.deleteRows(at: [indexPath], with: .automatic)
//            
//            // delete from outlook as well
//            events = getEventsArray()
//            
//            let row = indexPath
//            let rowint = Int(row[0])
//            NSLog(String (rowint))
//            
//            NSLog("KEK GEDELETETE ID: " + "\(events[rowint].id!)")
//            
////            service.deleteEvent(id: cellID as! [String : Any]) {_ in
////
////            }
//            
//        } else if editingStyle == .insert {
//            // Not used in our example, but if you were adding a new row, this is where you would do it.
//        }
//        
//    }
}
