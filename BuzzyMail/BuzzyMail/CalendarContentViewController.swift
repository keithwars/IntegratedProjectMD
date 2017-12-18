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
    
    var event:Event?
    let service = OutlookService.shared()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onCancelPressed(_ sender: Any){
        dismiss(animated: true, completion: nil)
    }
    
}
