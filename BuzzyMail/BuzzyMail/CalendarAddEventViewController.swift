//
//  CalendarAddEventViewController.swift
//  BuzzyMail
//
//  Created by Lennart Schelfhout on 07/12/2017.
//  Copyright © 2017 Jérémy Keusters. All rights reserved.
//

import UIKit

class CalendarAddEventViewController: UIViewController {
    
    let service = OutlookService.shared()
    
    let calendarEvent = [
            "subject": "Let's go for lunch",
            "body": [
                
                    "contentType": "HTML",
                    "content": "Does late morning work for you?",
                    
            ],
            "start": [
                
                    "dateTime":"2017-12-10T12:55:00",
                    "timeZone": "W. Europe Standard Time"
                    
            ],
            "end": [
                
                    "dateTime": "2017-12-10T14:00:00",
                    "timeZone": "W. Europe Standard Time"
                
            ],
            "location": [
                
                    "displayName": "Antwerpen"
                
            ],
            "attendees": [],
    ] as [String: Any]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.service.postEvent(json: calendarEvent) {_ in
            
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
