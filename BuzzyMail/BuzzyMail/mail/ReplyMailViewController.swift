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
    
    var container: MailContentTableViewController?
    
    var newEmail:Message?
    var isNewMail:Bool = false

    var email: String?
    
    let dispatchGroup = DispatchGroup()
    let dispatchGroup2 = DispatchGroup()
    let dispatchGroup3 = DispatchGroup()

    override func viewDidLoad() {
        super.viewDidLoad()
        if (self.email != nil) {
            self.container?.toTextField.text = self.email!
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "embeddedSegue") {
            let childViewController = segue.destination as! MailContentTableViewController
            childViewController.email = self.newEmail
            self.container = (segue.destination as! MailContentTableViewController)
        }
    }

    @IBAction func sendButtonPressed(_ sender: Any) {
        
        if (newEmail == nil) {
            self.newEmail = Message()
            self.isNewMail = true
        }
        self.dispatchGroup.enter()
        if let richTextEditor = container?.richTextEditor {
            if self.newEmail?.body == nil {
                self.newEmail?.body = Body(contentType: "html", content: richTextEditor.updatedText!)
            }
            else {
                self.newEmail?.body?.content = richTextEditor.updatedText!
            }
            self.newEmail?.subject = container!.subjectTextField.text!
            
            self.newEmail?.toRecipients = [EmailAddresses]()
            if email == nil {
                let toTextFieldArray = container!.toTextField.text!.components(separatedBy: ", ")
                for toTextField in toTextFieldArray {
                    self.newEmail?.toRecipients?.append(EmailAddresses(emailAddress: EmailAddress(name: "", address: toTextField)))
                }
            } else {
                self.newEmail?.toRecipients?.append(EmailAddresses(emailAddress: EmailAddress(name: "", address: email!)))
            }
            
            self.newEmail?.ccRecipients = [EmailAddresses]()
            let ccTextFieldArray = container!.ccTextField.text!.components(separatedBy: ", ")
            for ccTextField in ccTextFieldArray {
                self.newEmail?.ccRecipients?.append(EmailAddresses(emailAddress: EmailAddress(name: "", address: ccTextField)))
            }
            self.dispatchGroup.leave()
        }
        self.dispatchGroup.notify(queue: .main) {
            self.dispatchGroup2.enter()
            if self.isNewMail {
                self.createMail()
            }
            else {
                self.updateReply()
            }
            self.dispatchGroup2.notify(queue: .main) {
                self.sendReply()
                if self.email == nil {
                    self.performSegue(withIdentifier: "closeDraft", sender: sender)
                } else {
                    self.performSegue(withIdentifier: "unwindToContactInformation", sender: sender)
                }
                
            }
        }
    }

    @IBAction func cancelButtonPressed(_ sender: Any) {

        let deleteDraftActionHandler = { (action:UIAlertAction!) -> Void in
            if (self.newEmail != nil) {
                self.service.deleteMessage(message: self.newEmail!) {_ in }
            }
            if self.email == nil {
                self.performSegue(withIdentifier: "closeDraft", sender: action)
            } else {
                self.performSegue(withIdentifier: "unwindToContactInformation", sender: sender)
            }
        }

        let saveDraftActionHandler = { (action:UIAlertAction!) -> Void in
            if (self.newEmail != nil) {
                self.dispatchGroup3.enter()
                if let richTextEditor = self.container?.richTextEditor {
                    self.newEmail?.body!.content = richTextEditor.updatedText!
                    self.newEmail?.subject = self.container!.subjectTextField.text!
                    self.dispatchGroup3.leave()
                }
                self.dispatchGroup3.notify(queue: .main) {
                    self.service.updateReply(message: self.newEmail!) {_ in }
                    if self.email == nil {
                        self.performSegue(withIdentifier: "closeDraft", sender: action)
                    } else {
                        self.performSegue(withIdentifier: "unwindToContactInformation", sender: sender)
                    }
                }
            }
            else {
                if self.email == nil {
                    self.performSegue(withIdentifier: "closeDraft", sender: action)
                } else {
                    self.performSegue(withIdentifier: "unwindToContactInformation", sender: sender)
                }
            }
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

    func createMail() {
        NSLog("createMail called")
        service.createMail(message: newEmail!) {
            message in
            if let message = message {
                NSLog("Create Mail Success")
                NSLog("Pompernikkel3: " + message["subject"].stringValue)
  
                var toRecipientsList = [EmailAddresses]()
                for row in message["toRecipients"].arrayValue {
                    toRecipientsList.append(EmailAddresses(emailAddress: EmailAddress(name: row["emailAddress"]["name"].stringValue,
                                                                                      address: row["emailAddress"]["address"].stringValue)))
                }
                
                var ccRecipientsList = [EmailAddresses]()
                for row in message["ccRecipients"].arrayValue {
                    ccRecipientsList.append(EmailAddresses(emailAddress: EmailAddress(name: row["emailAddress"]["name"].stringValue,
                                                                                      address: row["emailAddress"]["address"].stringValue)))
                }
                
                var bccRecipientsList = [EmailAddresses]()
                for row in message["bccRecipients"].arrayValue {
                    bccRecipientsList.append(EmailAddresses(emailAddress: EmailAddress(name: row["emailAddress"]["name"].stringValue,
                                                                                       address: row["emailAddress"]["address"].stringValue)))
                }
                
                //receivedDateTime: Formatter.dateToString(date: message["receivedDateTime"]),
                let newMsg = Message(
                    id: message["id"].stringValue,
                    receivedDateTime: message["receivedDateTime"].stringValue,
                    hasAttachments: message["hasAttachments"].boolValue,
                    subject: message["subject"].stringValue,
                    bodyPreview: message["bodyPreview"].stringValue,
                    isRead: message["isRead"].boolValue,
                    isDraft: message["isDraft"].boolValue,
                    body: Body(contentType: message["body"]["contentType"].stringValue,
                               content: message["body"]["content"].stringValue),
                    from: EmailAddresses(emailAddress: EmailAddress(name: message["from"]["emailAddress"]["name"].stringValue,
                                                                    address: message["from"]["emailAddress"]["address"].stringValue)),
                    toRecipients: toRecipientsList,
                    ccRecipients: ccRecipientsList,
                    bccRecipients: bccRecipientsList)
                
                self.newEmail = newMsg
                self.dispatchGroup2.leave()
            } else {
                NSLog("Create Mail Fail")
                self.dispatchGroup2.leave()
            }
        }
    }
    

    func sendReply() {
        NSLog("sendReply called")
        service.sendMessage(message: newEmail!) {
            message in
            if let message = message {
                NSLog("Send Reply Success")
            } else {
                NSLog("Send Reply Fail")
            }
        }
    }

    func updateReply() {
        NSLog("updateReply called")
        service.updateReply(message: newEmail!) {
            message in
            if let message = message {
                NSLog("Update Reply Success")
                self.dispatchGroup2.leave()
            } else {
                NSLog("Update Reply Fail")
                self.dispatchGroup2.leave()
            }
        }
    }


}
