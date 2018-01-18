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
    @IBOutlet weak var contentTextview: UITextView!
    @IBOutlet weak var attendeesLabel: UILabel!
    @IBOutlet weak var attendeesListTextView: UITextView!
    
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
        contentTextview.text = event?.bodyPreview
        self.contentTextview.textContainer.lineFragmentPadding = 0;

        if (event?.attendees?.count != 0) {
            attendeesLabel.isHidden = false
            attendeesListTextView.isHidden = false
            
            for i in (event?.attendees)! {
                attendeesListTextView.text! += i.emailAddress.address + "\n"
            }
            
            self.contentTextview.textContainer.lineFragmentPadding = 0;
        } else {
            attendeesLabel.isHidden = true
            self.attendeesLabel.isEnabled = false
            self.attendeesListTextView.isHidden = true
        }

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
