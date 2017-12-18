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
    
    @IBOutlet weak var creatorLabel: UILabel!
    
    var event:Event?
    let service = OutlookService.shared()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        creatorLabel.text = event?.subject
        print("creatorlabel:" + "\(creatorLabel.text)")
        print("event subject:" + "\(event?.subject)")

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onCancelPressed(_ sender: Any){
        dismiss(animated: true, completion: nil)
    }
    
}
