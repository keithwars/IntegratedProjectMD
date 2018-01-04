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
    var updatedEmail:Message?
    var container: MailContentTableViewController?
    
    let dispatchGroup = DispatchGroup()
    
    weak var embeddedMailContentTableViewController:MailContentTableViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func sendButtonPressed(_ sender: Any) {
        
        NSLog("DEBUG001")
        self.dispatchGroup.enter()
        if let richTextEditor = container?.richTextEditor {
            NSLog("-----------------------------------------------------------------")
            var testText = ""
            richTextEditor.delegate?.textDidChange(text: testText)
            NSLog("DEBUG701")
            NSLog(testText)
            NSLog(richTextEditor.text!)
            NSLog(container!.subjectTextField.text!)
            NSLog("-----------------------------------------------------------------\n\n")
            self.newEmail?.body.content = richTextEditor.text!
            self.newEmail?.subject = container!.subjectTextField.text!
//                NSLog("DEBUG002")
//                self.updatedEmail = Message(
//                    id: newEmail.id,
//                    receivedDateTime: newEmail.receivedDateTime,
//                    hasAttachments: newEmail.hasAttachments,
//                    subject: (container?.subjectTextField.text)!,
//                    bodyPreview: newEmail.bodyPreview,
//                    isRead: newEmail.isRead,
//                    isDraft: newEmail.isDraft,
//                    body: Body(contentType: newEmail.body.contentType,
//                               content: (richTextEditor.text)!),
//                    from: EmailAddresses(emailAddress: EmailAddress(name: newEmail.from.emailAddress.name,
//                                                                    address: newEmail.from.emailAddress.address)),
//                    toRecipients: newEmail.toRecipients,
//                    ccRecipients: newEmail.ccRecipients,
//                    bccRecipients: newEmail.bccRecipients)
//                NSLog("DEBUG003")
            self.dispatchGroup.leave()
        }
        NSLog("DEBUG004")
        self.dispatchGroup.notify(queue: .main) {
            self.updateReply()
        }
        //sendReply()
    }

    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "embeddedSegue") {
            let childViewController = segue.destination as! MailContentTableViewController
            childViewController.email = self.newEmail
            self.container = (segue.destination as! MailContentTableViewController)
        }
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        
        let deleteDraftActionHandler = { (action:UIAlertAction!) -> Void in
            self.performSegue(withIdentifier: "cancelDraft", sender: action) //executing the segue on cancel
        }
        
        let saveDraftActionHandler = { (action:UIAlertAction!) -> Void in
            self.performSegue(withIdentifier: "cancelDraft", sender: action) //executing the segue on cancel
        }
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let deleteDraftAction = UIAlertAction(title: "Delete Draft", style: .destructive, handler: deleteDraftActionHandler)
        alertController.addAction(deleteDraftAction)
        let saveDraftAction = UIAlertAction(title: "Save Draft", style: .default, handler: saveDraftActionHandler)
        alertController.addAction(saveDraftAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)

        present(alertController, animated: true, completion: nil)
    }


    
    func sendReply() {
        NSLog("sendReply called")
        service.sendReply(message: newEmail!) {
            message in
            if let message = message {
                NSLog("Send Reply Success")
            } else {
                NSLog("Send Reply Fail")
            }
        }
    }
    
    func updateReply() {
        service.updateReply(message: newEmail!) {
            message in
            if let message = message {
                NSLog("Update Reply Success")
            } else {
                NSLog("Update Reply Fail")
            }
        }
    }

    
}
