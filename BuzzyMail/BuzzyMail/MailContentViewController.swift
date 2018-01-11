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

extension String {
}

class MailContentViewController: UIViewController {
    
    var email:Message?
    
    let service = OutlookService.shared()
    
    @IBOutlet weak var fromLabel: UILabel!
    
    @IBOutlet weak var subjectLabel: UILabel!

    @IBOutlet weak var contentWebView: WKWebView!
    
    @IBOutlet weak var richTextEditorNonEditable: RichTextEditorNonEditable!
    
    var unreadEmail: Message?
    
    override func viewDidLoad() {
        
        navigationItem.largeTitleDisplayMode = .never
        super.viewDidLoad()
       
        if (!email!.isRead){
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
       
        
        
        
        
        
//        service.updateIsReadStatus(message: email!) {
//            message in
//            if let message = message {
//                NSLog("success")
////                let newMsg = Message(
////                    id: message["id"].stringValue,
////                    receivedDateTime: Formatter.dateToString(date: message["receivedDateTime"]),
////                    hasAttachments: message["hasAttachments"].boolValue,
////                    subject: message["subject"].stringValue,
////                    bodyPreview: message["bodyPreview"].stringValue,
////                    isRead: message["isRead"].boolValue,
////                    isDraft: message["isDraft"].boolValue,
////                    body: Body(contentType: message["body"]["contentType"].stringValue,
////                               content: message["body"]["content"].stringValue),
////                    from: EmailAddress(name: message["from"]["emailAddress"]["name"].stringValue,
////                                       address: message["from"]["emailAddress"]["address"].stringValue),
////                    toRecipients: [EmailAddress(name: message["toRecipients"][0]["emailAddress"]["name"].stringValue,
////                                                address: message["toRecipients"][0]["emailAddress"]["address"].stringValue)],
////                    ccRecipients: [EmailAddress(name: message["ccRecipients"][0]["emailAddress"]["name"].stringValue,
////                                                address: message["ccRecipients"][0]["emailAddress"]["address"].stringValue)],
////                    bccRecipients: [EmailAddress(name: message["bccRecipients"][0]["emailAddress"]["name"].stringValue,
////                                                 address: message["bccRecipients"][0]["emailAddress"]["address"].stringValue)])
////                //                NSLog("RESULT: " + newMsg.bodyContent)
//            } else {
//                NSLog("Fail")
//            }
//        }
        
        fromLabel.text = email!.from!.emailAddress.name
        richTextEditorNonEditable.text = email!.body!.content
        subjectLabel.text = email!.subject
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
    
    func updateIsReadStatusToRead(message: Message){
        
        service.updateReply(message: message){
            message in
            if let message = message{
                NSLog("JANNET1")
            }else{
                NSLog("JANNET2")
            }
        }
        
        
    }
    
    

}


