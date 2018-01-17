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
    
    var event:Event?

    @IBOutlet weak var eventNameLabel: UILabel!
    @IBOutlet weak var creatorLabel: UILabel!
    
    @IBAction func unwindToCalendar(segue: UIStoryboardSegue) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        creatorLabel.text = event?.organizer?.emailAddress?.name
        eventNameLabel.text = event?.subject
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
