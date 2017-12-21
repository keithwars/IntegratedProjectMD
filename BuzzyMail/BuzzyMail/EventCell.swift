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
    let organizer: Organizer?
}

struct Organizer : Codable {
    var emailAddress : EmailAddress?
}

struct EmailAddress : Codable {
    var name : String?
    var address : String?
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
                    id: event["id"].stringValue,
                    organizer: Organizer(emailAddress: EmailAddress(name: event["organizer"]["emailAddress"]["name"].stringValue, address: event["organizer"]["emailAddress"]["address"].stringValue))
                )
                
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
        
        print("Organizer name: " + "\(event.organizer?.emailAddress?.address)")
        
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
    
//    func confirmDelete(event: String) {
//        let alert = UIAlertController(title: "Delete Planet", message: "Are you sure you want to permanently delete this event?", preferredStyle: .actionSheet)
//
//        //let DeleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: handleDeleteEvent)
//        let CancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: cancelDeleteEvent)
//
//        //alert.addAction(DeleteAction)
//        alert.addAction(CancelAction)
//
//        UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
//    }
//
//    func cancelDeleteEvent(alertAction: UIAlertAction!) {
//        print("cancel clicked")
//    }
    
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
