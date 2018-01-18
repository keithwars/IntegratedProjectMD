//
//  FirstViewController.swift
//  BuzzyMail
//
//  Created by Jérémy Keusters on 24/11/17.
//  Copyright © 2017 Jérémy Keusters. All rights reserved.
//

import UIKit

import MessageUI
import WebKit

var messageHtml: Message?

class MailContentViewController: UIViewController {

    let service = OutlookService.shared()
    
    let dispatchGroup = DispatchGroup()
    let dispatchGroup2 = DispatchGroup()
    let dispatchGroup3 = DispatchGroup()
    
    var email:Message?
    var unreadEmail: Message?
    var newEmail:Message?

    @IBOutlet weak var fromLabel: UILabel!
    @IBOutlet weak var subjectLabel: UILabel!
    @IBOutlet weak var contentWebView: WKWebView!
    @IBOutlet weak var richTextEditorNonEditable: RichTextEditorNonEditable!

    override func viewDidLoad() {
        navigationItem.largeTitleDisplayMode = .never
        super.viewDidLoad()

        if (!email!.isRead!){
            email!.isRead = true
            unreadEmail = Message(
                    id: email!.id,
                    receivedDateTime: nil,
                    hasAttachments: nil,
                    subject: nil,
                    bodyPreview: nil,
                    isRead: true,
                    isDraft: nil,
                    body: nil,
                    from: nil,
                    toRecipients: nil,
                    ccRecipients:nil,
                    bccRecipients: nil)

             updateIsReadStatusToRead(message: unreadEmail!)

        }

        fromLabel.text = email!.from!.emailAddress.name
        richTextEditorNonEditable.text = email!.body!.content
        subjectLabel.text = email!.subject
        richTextEditorNonEditable.text = email!.body!.content
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func replyButtonPressed(_ sender: Any) {

        let replyActionHandler = { (action:UIAlertAction!) -> Void in
            self.dispatchGroup.enter()
            self.createReply()
            self.dispatchGroup.notify(queue: .main) {
                let popup : ReplyMailViewController = self.storyboard?.instantiateViewController(withIdentifier: "ReplyMailViewController") as! ReplyMailViewController
                let navigationController = UINavigationController(rootViewController: popup)
                navigationController.modalPresentationStyle = UIModalPresentationStyle.pageSheet
                popup.newEmail = self.newEmail
                self.present(navigationController, animated: true, completion: nil)
            }
        }
        
        let replyAllActionHandler = { (action:UIAlertAction!) -> Void in
            self.dispatchGroup3.enter()
            self.createReplyAll()
            self.dispatchGroup3.notify(queue: .main) {
                let popup : ReplyMailViewController = self.storyboard?.instantiateViewController(withIdentifier: "ReplyMailViewController") as! ReplyMailViewController
                let navigationController = UINavigationController(rootViewController: popup)
                navigationController.modalPresentationStyle = UIModalPresentationStyle.pageSheet
                popup.newEmail = self.newEmail
                self.present(navigationController, animated: true, completion: nil)
            }
        }

        let forwardActionHandler = { (action:UIAlertAction!) -> Void in
            self.dispatchGroup2.enter()
            self.createForward()
            self.dispatchGroup2.notify(queue: .main) {
                let popup : ReplyMailViewController = self.storyboard?.instantiateViewController(withIdentifier: "ReplyMailViewController") as! ReplyMailViewController
                let navigationController = UINavigationController(rootViewController: popup)
                navigationController.modalPresentationStyle = UIModalPresentationStyle.pageSheet
                popup.newEmail = self.newEmail
                self.present(navigationController, animated: true, completion: nil)
            }
        }

        let printActionHandler = { (action:UIAlertAction!) -> Void in
            let printController = UIPrintInteractionController.shared
            
            let printInfo = UIPrintInfo(dictionary:nil)
            printInfo.outputType = UIPrintInfoOutputType.general
            printInfo.jobName = "print Job"
            printController.printInfo = printInfo
            
            let formatter = UIMarkupTextPrintFormatter(markupText: self.email!.body!.content)
            formatter.perPageContentInsets = UIEdgeInsets(top: 72, left: 72, bottom: 72, right: 72)
            printController.printFormatter = formatter
            
            printController.present(animated: true, completionHandler: nil)
        }
        
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let replyAction = UIAlertAction(title: "Reply", style: .default, handler: replyActionHandler)
        alertController.addAction(replyAction)
        if (email!.ccRecipients!.count > 1 || email!.toRecipients!.count > 1) {
            let replyAllAction = UIAlertAction(title: "Reply All", style: .default, handler: replyAllActionHandler)
            alertController.addAction(replyAllAction)
        }
        let forwardAction = UIAlertAction(title: "Forward", style: .default, handler: forwardActionHandler)
        alertController.addAction(forwardAction)
        let printAction = UIAlertAction(title: "Print", style: .default, handler: printActionHandler)
        alertController.addAction(printAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }

    @IBAction func cancelToMailContentViewController(_ segue: UIStoryboardSegue) { }


    func createReply() {
        NSLog("createMessage called")
        service.createReply(message: email!) {
            message in
            if let message = message {
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

                self.newEmail = Message(
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
                self.dispatchGroup.leave()
            } else {
                NSLog("Fail")
            }
        }
    }
    
    func createReplyAll() {
        NSLog("createMessage called")
        service.createReplyAll(message: email!) {
            message in
            if let message = message {
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
                
                self.newEmail = Message(
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
                self.dispatchGroup3.leave()
            } else {
                NSLog("Fail")
            }
        }
    }

    func createForward() {
        NSLog("createForward called")
        service.createForward(message: email!) {
            message in
            if let message = message {
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

                self.newEmail = Message(
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
                self.dispatchGroup2.leave()
            } else {
                NSLog("Fail")
            }
        }
    }

    func updateIsReadStatusToRead(message: Message){
        service.updateReply(message: message){
            message in
            if let message = message{
                NSLog("")
            }else{
                NSLog("")
            }
        }
    }


}
