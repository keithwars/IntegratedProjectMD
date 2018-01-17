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
    var events: [CalendarEvent]
    
    init(events: [JSON]?) {
        var evtArray = [CalendarEvent]()
        var eventAttendeesList = [Attendees]()
        
        if let unwrappedEvents = events {
            for (event) in unwrappedEvents {
                //print("formatted:" + Formatter.deduceTime(start: currentDate))
                
                for i in event["attendees"].arrayValue {
                    eventAttendeesList.append(Attendees(type: i["type"].stringValue, status: Status(response: i["status"]["response"].stringValue, time: i["status"]["time"].stringValue), emailAddress: EmailAddress(name: i["emailAddress"]["name"].stringValue, address: i["emailAddress"]["address"].stringValue)))
                    print("hihihih"
                    )
                    print(eventAttendeesList)
                }
                
                let newEvent = CalendarEvent(
                    subject: event["subject"].stringValue,
                    bodyPreview: event["bodyPreview"].stringValue,
                    start: Time(dateTime: Formatter.dateTimeTimeZoneToString(date: event["start"]), timeZone: "Europe/Paris"),
                    end: Time(dateTime: Formatter.dateTimeToTime(date: event["end"]), timeZone: "Europe/Paris"),
                    startTime: Formatter.timeToHourAndMin(date: event["start"]),
                    id: event["id"].stringValue,
                    location: Location(displayName: event["location"]["displayName"].stringValue),
                    attendees: eventAttendeesList,
                    organizer: Organizer(emailAddress: EmailAddress(name: event["organizer"]["emailAddress"]["name"].stringValue, address: event["organizer"]["emailAddress"]["address"].stringValue))
                )
            
                evtArray.append(newEvent)
                eventAttendeesList.removeAll()
                
            }
        }
        
        self.events = evtArray
    }
}

extension EventsDataSource: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return events.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: EventCell.self)) as! EventCell
        let event = events[indexPath.row]
        
        cell.subject = event.subject
        cell.start = event.start?.dateTime
        cell.end = "Ends at: " + (event.end?.dateTime)!
        cell.startTime = event.startTime
        cell.id = event.id
        
        return cell
        
    }
    
    func getEventsArray() -> [CalendarEvent] {
        return events
    }
    
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped cell number \(indexPath.row).")
    }
    
    // this method handles row deletion
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {

            let alertController = UIAlertController(title: "Warning!", message: "Are you sure you want to delete this event?", preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action in
                print(action)
            }
            alertController.addAction(cancelAction)
            
            let destroyAction = UIAlertAction(title: "Delete", style: .destructive) { action in
                let rowint = Int(indexPath[1])
                
                let eventToDelete = self.events[rowint].id!
                //confirmDelete(event: eventToDelete)
                // delete from events
                self.events.remove(at: indexPath.row)
                
                // delete the table view row
                tableView.deleteRows(at: [indexPath], with: .automatic)
                service.deleteEvent(id: eventToDelete) {_ in
                    
                }
                
                tableView.reloadData()
            }
            alertController.addAction(destroyAction)
            
            let vc = getVisibleViewController(UIApplication.shared.keyWindow?.rootViewController)
            
            vc?.present(alertController, animated: true) {
                print("Run ik hier wel?")
            }
            
        } else if editingStyle == .insert {
            // Not used in our example, but if you were adding a new row, this is where you would do it.
        }
        
    }
    
    func getVisibleViewController(_ rootViewController: UIViewController?) -> UIViewController? {
        
        var rootVC = rootViewController
        if rootVC == nil {
            rootVC = UIApplication.shared.keyWindow?.rootViewController
        }
        
        if rootVC?.presentedViewController == nil {
            return rootVC
        }
        
        if let presented = rootVC?.presentedViewController {
            if presented.isKind(of: UINavigationController.self) {
                let navigationController = presented as! UINavigationController
                return navigationController.viewControllers.last!
            }
            
            if presented.isKind(of: UITabBarController.self) {
                let tabBarController = presented as! UITabBarController
                return tabBarController.selectedViewController!
            }
            
            return getVisibleViewController(presented)
        }
        return nil
    }
}
