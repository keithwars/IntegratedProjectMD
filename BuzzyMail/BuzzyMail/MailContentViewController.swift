//
//  FirstViewController.swift
//  BuzzyMail
//
//  Created by Jérémy Keusters on 24/11/17.
//  Copyright © 2017 Jérémy Keusters. All rights reserved.
//

import UIKit
import MessageUI

class MailContentViewController: UIViewController {
    
    var email:Message?
    let service = OutlookService.shared()
    
    @IBOutlet weak var fromLabel: UILabel!
    
    @IBOutlet weak var subjectLabel: UILabel!
    
    override func viewDidLoad() {
        navigationItem.largeTitleDisplayMode = .never
        super.viewDidLoad()
        fromLabel.text = email!.from.name
        subjectLabel.text = email!.subject
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func replyButtonPressed(_ sender: Any) {
        
        let replyActionHandler = { (action:UIAlertAction!) -> Void in
            let popup : ReplyMailViewController = self.storyboard?.instantiateViewController(withIdentifier: "ReplyMailViewController") as! ReplyMailViewController
            let navigationController = UINavigationController(rootViewController: popup)
            navigationController.modalPresentationStyle = UIModalPresentationStyle.pageSheet
            popup.replyToEmail = self.email
            self.present(navigationController, animated: true, completion: nil)
        }
        
    
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let replyAction = UIAlertAction(title: "Reply", style: .default, handler: replyActionHandler)
        alertController.addAction(replyAction)
        let replyAllAction = UIAlertAction(title: "Reply All", style: .default, handler: nil)
        alertController.addAction(replyAllAction)
        let forwardAction = UIAlertAction(title: "Forward", style: .default, handler: nil)
        alertController.addAction(forwardAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func cancelToMailContentViewController(_ segue: UIStoryboardSegue) {
    }
}


