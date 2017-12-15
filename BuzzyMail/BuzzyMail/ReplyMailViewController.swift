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
    var newEmail:Message?
    var container: MailContentTableViewController?
    
    weak var embeddedMailContentTableViewController:MailContentTableViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //NSLog("DEBUG2: " + replyToEmail!.subject)
        createNewReply()
    }
    
    @IBAction func sendButtonPressed(_ sender: Any) {
        updateReply()
        //sendReply()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "embeddedSegue") {
            //let secondViewController = segue.destination  as! MailContentTableViewController
            let childViewController = segue.destination as! MailContentTableViewController
            childViewController.email = replyToEmail
            self.container = (segue.destination as! MailContentTableViewController)
        }
    }
    
    func createNewReply() {
        NSLog("createNewReply called")
        service.createReply(message: replyToEmail!) {
            message in
            if let message = message {
                let newMsg = Message(
                    id: message["id"].stringValue,
                    receivedDateTime: Formatter.dateToString(date: message["receivedDateTime"]),
                    hasAttachments: message["hasAttachments"].boolValue,
                    subject: message["subject"].stringValue,
                    bodyPreview: message["bodyPreview"].stringValue,
                    isRead: message["isRead"].boolValue,
                    isDraft: message["isDraft"].boolValue,
                    body: Body(contentType: message["body"]["contentType"].stringValue,
                               content: message["body"]["content"].stringValue),
                    from: EmailAddress(name: message["from"]["emailAddress"]["name"].stringValue,
                                       address: message["from"]["emailAddress"]["address"].stringValue),
                    toRecipients: [EmailAddress(name: message["toRecipients"][0]["emailAddress"]["name"].stringValue,
                                                address: message["toRecipients"][0]["emailAddress"]["address"].stringValue)],
                    ccRecipients: [EmailAddress(name: message["ccRecipients"][0]["emailAddress"]["name"].stringValue,
                                                address: message["ccRecipients"][0]["emailAddress"]["address"].stringValue)],
                    bccRecipients: [EmailAddress(name: message["bccRecipients"][0]["emailAddress"]["name"].stringValue,
                                                 address: message["bccRecipients"][0]["emailAddress"]["address"].stringValue)])
//                NSLog("RESULT: " + newMsg.bodyContent)
            } else {
                NSLog("Fail")
            }
        }
    }
    
    func sendReply() {
        NSLog("sendReply called")
        service.sendReply(message: replyToEmail!) {
            message in
            if let message = message {
                let newMsg = Message(
                    id: message["id"].stringValue,
                    receivedDateTime: Formatter.dateToString(date: message["receivedDateTime"]),
                    hasAttachments: message["hasAttachments"].boolValue,
                    subject: message["subject"].stringValue,
                    bodyPreview: message["bodyPreview"].stringValue,
                    isRead: message["isRead"].boolValue,
                    isDraft: message["isDraft"].boolValue,
                    body: Body(contentType: message["body"]["contentType"].stringValue,
                               content: message["body"]["content"].stringValue),
                    from: EmailAddress(name: message["from"]["emailAddress"]["name"].stringValue,
                                       address: message["from"]["emailAddress"]["address"].stringValue),
                    toRecipients: [EmailAddress(name: message["toRecipients"][0]["emailAddress"]["name"].stringValue,
                                                address: message["toRecipients"][0]["emailAddress"]["address"].stringValue)],
                    ccRecipients: [EmailAddress(name: message["ccRecipients"][0]["emailAddress"]["name"].stringValue,
                                                address: message["ccRecipients"][0]["emailAddress"]["address"].stringValue)],
                    bccRecipients: [EmailAddress(name: message["bccRecipients"][0]["emailAddress"]["name"].stringValue,
                                                 address: message["bccRecipients"][0]["emailAddress"]["address"].stringValue)])
//                NSLog("RESULT: " + newMsg.bodyContent)
                
            } else {
                NSLog("Fail")
            }
        }
    }
    
    func updateReply() {
//        replyToEmail?.bodyContent = (container?.richTextEditor.text)!
        service.updateReply(message: replyToEmail!) {
            message in
            if let message = message {
                let newMsg = Message(
                    id: message["id"].stringValue,
                    receivedDateTime: Formatter.dateToString(date: message["receivedDateTime"]),
                    hasAttachments: message["hasAttachments"].boolValue,
                    subject: message["subject"].stringValue,
                    bodyPreview: message["bodyPreview"].stringValue,
                    isRead: message["isRead"].boolValue,
                    isDraft: message["isDraft"].boolValue,
                    body: Body(contentType: message["body"]["contentType"].stringValue,
                               content: message["body"]["content"].stringValue),
                    from: EmailAddress(name: message["from"]["emailAddress"]["name"].stringValue,
                                       address: message["from"]["emailAddress"]["address"].stringValue),
                    toRecipients: [EmailAddress(name: message["toRecipients"][0]["emailAddress"]["name"].stringValue,
                                                address: message["toRecipients"][0]["emailAddress"]["address"].stringValue)],
                    ccRecipients: [EmailAddress(name: message["ccRecipients"][0]["emailAddress"]["name"].stringValue,
                                               address: message["ccRecipients"][0]["emailAddress"]["address"].stringValue)],
                    bccRecipients: [EmailAddress(name: message["bccRecipients"][0]["emailAddress"]["name"].stringValue,
                                                address: message["bccRecipients"][0]["emailAddress"]["address"].stringValue)])
//                NSLog("RESULT: " + newMsg.bodyContent)
                
            } else {
                NSLog("Fail")
            }
        }
    }

    
}
