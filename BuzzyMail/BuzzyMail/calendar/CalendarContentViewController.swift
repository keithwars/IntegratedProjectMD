//
//  CalendarContentViewController.swift
//  BuzzyMail
//
//  Created by Lennart Schelfhout on 15/12/2017.
//  Copyright © 2017 Jérémy Keusters. All rights reserved.
//

import Foundation
import UIKit
import MessageUI

class CalendarContentViewController: UIViewController {
    
    let service = OutlookService.shared()
    
    var event:CalendarEvent?

    @IBOutlet weak var eventNameLabel: UILabel!
    @IBOutlet weak var creatorLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    
    @IBAction func unwindToCalendar(segue: UIStoryboardSegue) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        creatorLabel.text = event?.organizer?.emailAddress?.name
        eventNameLabel.text = event?.subject
        durationLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        durationLabel.numberOfLines = 2
        durationLabel.text = (Formatter.convertDateFormater(date: (event?.start?.dateTime)!)) + " at " + (event?.startTime)! + " until " + (event?.end?.dateTime)!
        locationLabel.text = event?.location?.displayName
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
