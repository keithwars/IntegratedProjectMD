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
import QuickLook

var messageHtml: Message?

class MailContentViewController: UIViewController, QLPreviewControllerDataSource, QLPreviewControllerDelegate {

    let service = OutlookService.shared()
    
    let quickLookController = QLPreviewController()
    
    let dispatchGroup = DispatchGroup()
    let dispatchGroup2 = DispatchGroup()
    let dispatchGroup3 = DispatchGroup()
    
    let dispatchGroupAttachments1 = DispatchGroup()
    
    var email:Message?
    var unreadEmail: Message?
    var newEmail:Message?
    
    var attachment: Attachment?

    @IBOutlet weak var fromLabel: UILabel!
    @IBOutlet weak var subjectLabel: UILabel!
    @IBOutlet weak var contentWebView: WKWebView!
    @IBOutlet weak var richTextEditorNonEditable: RichTextEditorNonEditable!

    @IBOutlet weak var previewAttachmentButton: UIButton!
    @IBAction func previewAttachmentButtonPressed(_ sender: UIButton) {
        let viewPDF = QLPreviewController()
        viewPDF.dataSource = self
        
        self.present(viewPDF, animated: true, completion: nil)
    }
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
        
        if (email!.hasAttachments!) {
            NSLog("Pompernikkel Attachments")
            var attachmentsList = [Attachment]()
            dispatchGroupAttachments1.enter()
            service.listAttachments(message: email!) {
                attachments in
                if let unwrappedAttachments = attachments {
                    NSLog("Pompernikkel 4 " + unwrappedAttachments["value"].arrayValue[0]["name"].stringValue)
                    for (attachment) in unwrappedAttachments["value"].arrayValue {
                        NSLog("Run!")
                        let newAttachment = Attachment(id: attachment["id"].stringValue, name: attachment["name"].stringValue, contentType: attachment["contentType"].stringValue, size: attachment["size"].intValue, contentBytes: attachment["contentBytes"].stringValue)
                        attachmentsList.append(newAttachment)
                    }
                    self.dispatchGroupAttachments1.leave()
                } else {
                    NSLog("Fail")
                    self.dispatchGroupAttachments1.leave()
                }
            }
            self.dispatchGroupAttachments1.notify(queue: .main) {
                NSLog("Number of attachments: " + String(attachmentsList.count))
                for attachment in attachmentsList {
                    NSLog("Name of attachment: " + attachment.name)
                    self.saveBase64StringToPDF(attachment.contentBytes, fileName: attachment.name)
                    self.attachment = attachment
                    self.richTextEditorNonEditable.text! += attachment.name
                }
            }
        }
        else {
            previewAttachmentButton.isHidden = true
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return 1
    }

    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        var pdfURL = (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)).last! as URL
        pdfURL = pdfURL.appendingPathComponent(attachment!.name) as URL
        
        return pdfURL as QLPreviewItem
    }

    
    func previewControllerWillDismiss(_ controller: QLPreviewController) {
        self.dismiss(animated: true, completion: nil)
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


        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        let replyAction = UIAlertAction(title: "Reply", style: .default, handler: replyActionHandler)
        alertController.addAction(replyAction)
        let replyAllAction = UIAlertAction(title: "Reply All", style: .default, handler: replyAllActionHandler)
        alertController.addAction(replyAllAction)
        let forwardAction = UIAlertAction(title: "Forward", style: .default, handler: forwardActionHandler)
        alertController.addAction(forwardAction)
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
        
    func saveBase64StringToPDF(_ base64String: String, fileName: String) {
        
        guard
            var documentsURL = (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)).last,
            let convertedData = Data(base64Encoded: base64String)
            else {
                //handle error when getting documents URL
                return
        }
        
        //name your file however you prefer
        documentsURL.appendPathComponent(fileName)
        
        do {
            try convertedData.write(to: documentsURL)
        } catch {
            //handle write error here
        }
        
        //if you want to get a quick output of where your
        //file was saved from the simulator on your machine
        //just print the documentsURL and go there in Finder
        print(documentsURL)
    }
        


}
