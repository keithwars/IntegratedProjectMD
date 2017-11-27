//
//  FirstViewController.swift
//  BuzzyMail
//
//  Created by Jérémy Keusters on 24/11/17.
//  Copyright © 2017 Jérémy Keusters. All rights reserved.
//

import UIKit

class MailContentViewController: UIViewController {
    
    var email:Message?
    let service = OutlookService.shared()
    
    @IBOutlet weak var fromLabel: UILabel!
    
    @IBOutlet weak var subjectLabel: UILabel!
    
    override func viewDidLoad() {
        navigationItem.largeTitleDisplayMode = .never
        super.viewDidLoad()
        NSLog(email!.from)
        
        
        fromLabel.text = email!.from
        subjectLabel.text = email!.subject
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
}


