//
//  ReplyMailViewController.swift
//  BuzzyMail
//
//  Created by Jérémy Keusters on 1/12/17.
//  Copyright © 2017 Jérémy Keusters. All rights reserved.
//

import Foundation
import UIKit


class ReplyMailViewController: UIViewController {

    let service = OutlookService.shared()
    
    var replyToEmail:Message?
    
    weak var embeddedMailContentTableViewController:MailContentTableViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //NSLog("DEBUG2: " + replyToEmail!.subject)
        createNewReply()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "embeddedSegue") {
            //let secondViewController = segue.destination  as! MailContentTableViewController
            let childViewController = segue.destination as! MailContentTableViewController
            childViewController.email = replyToEmail
        }
        
    }
    
    func createNewReply() {
        NSLog("createNewReply called")
        service.createReply(message: replyToEmail!) {
            message in
            if let unwrappedMessage = message {
                let newMsg = Message(
                    from: unwrappedMessage["from"]["emailAddress"]["name"].stringValue,
                    received: Formatter.dateToString(date: unwrappedMessage["receivedDateTime"]),
                    subject: unwrappedMessage["subject"].stringValue,
                    messageId: unwrappedMessage["id"].stringValue,
                    bodyContent: unwrappedMessage["body"]["content"].stringValue)
                NSLog("RESULT: " + newMsg.bodyContent)
                
            } else {
                NSLog("Fail")
            }
        }
    }

    
}
