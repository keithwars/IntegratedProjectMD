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
    
    @IBOutlet weak var creatorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        creatorLabel.text = event?.organizer?.emailAddress?.name
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onCancelPressed(_ sender: Any){
        dismiss(animated: true, completion: nil)
    }
    
}
