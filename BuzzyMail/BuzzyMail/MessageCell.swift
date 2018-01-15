//
//  MessageCell.swift
//  BuzzyMail
//
//  Created by Keith Vella on 24/11/2017.
//  Copyright © 2017 Keith Vella. All rights reserved.
//

import UIKit
import SwiftyJSON
import Foundation

let service = OutlookService.shared()

class MessageCell: UITableViewCell {
    @IBOutlet weak var fromLabel: UILabel!
    @IBOutlet weak var receivedLabel: UILabel!
    @IBOutlet weak var subjectLabel: UILabel!
    @IBOutlet weak var bodyPreviewLabel: UILabel!
    @IBOutlet weak var attachmentImageView: UIImageView!
    @IBOutlet weak var unReadMarker: UIImageView!


    var from: String? {
        didSet {
            fromLabel.text = from
        }
    }

    var received: String? {

        didSet {
            receivedLabel.text = received
        }
    }


    var subject: String? {
        didSet {
            subjectLabel.text = subject
        }
    }
    var bodyPreview: String? {
        didSet {
            bodyPreviewLabel.text = bodyPreview
        }
    }
    var hasAttachments: Bool? {
        didSet {
            attachmentImageView.isHidden = false
        }
    }
    var unRead: Bool? {
        didSet {
            unReadMarker.isHidden = false
        }
    }
    var isRead: Bool? {
        didSet {

        }
    }
}

class MessagesDataSource: NSObject {

    var messages: [Message]
   
    init(messages: [JSON]?) {
        var msgArray = [Message]()

        if let unwrappedMessages = messages {
            for (message) in unwrappedMessages {

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

                msgArray.append(newMsg)
            }
        }

        self.messages = msgArray
    }

    func getMessagesArray() -> [Message]{
        return messages
    }
}

extension MessagesDataSource: UITableViewDataSource, UITableViewDelegate{

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: MessageCell.self)) as! MessageCell
        let message = messages[indexPath.row]

        //var mailViewController: MailViewController = MailViewController(nibName: nil, bundle: nil)

        if (message.toRecipients!.count > 0 && (message.from!.emailAddress.address == service.userEmail || message.isDraft!)) {
            NSLog("We're in a Sent Items Folder!")
            var fromList: String = ""

                for i in 0...message.toRecipients!.count - 1 {
                    if (i != 0) {
                        fromList += ", "
                    }
                    fromList += message.toRecipients![i].emailAddress.name
                    NSLog("ToRecipient: " + message.toRecipients![i].emailAddress.name)
                    NSLog("From: " + message.from!.emailAddress.address)
                }
                cell.from = fromList
        }
        else {
            cell.from = message.from!.emailAddress.name
        }

        cell.received = message.receivedDateTime


        if (message.hasAttachments == true){
            cell.attachmentImageView.isHidden = false
        }
        else{
            cell.attachmentImageView.isHidden = true
        }

        if (message.isRead == false){
            cell.unReadMarker.isHidden = false
        }
        else{
            cell.unReadMarker.isHidden = true
        }


        cell.subject = message.subject
        cell.bodyPreview = (message.bodyPreview)
    
        return cell
        
        
        
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let alertController = UIAlertController(title: "Warning!", message: "Are you sure you want to delete this e-mail?", preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action in
                print(action)
            }
            alertController.addAction(cancelAction)
            
            let destroyAction = UIAlertAction(title: "Delete", style: .destructive) { action in
                let rowint = Int(indexPath[1])
                
                let emailToDelete = Message(
                    id: self.messages[rowint].id,
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
                
                let messageToDelete = self.messages[rowint].id
                //confirmDelete(event: eventToDelete)
                // delete from events
                self.messages.remove(at: indexPath.row)
                
                // delete the table view row
                tableView.deleteRows(at: [indexPath], with: .automatic)
                
                
                self.deleteMessageFunction(message: emailToDelete)
                
                tableView.reloadData()
            }
            
            
            
            alertController.addAction(destroyAction)
            
            let vc = getVisibleViewController(UIApplication.shared.keyWindow?.rootViewController)
            
            vc?.present(alertController, animated: true) {
                print("Run ik hier wel?")
            }
            
        } else if editingStyle == .insert{
        }
        
    }
    
    func deleteMessageFunction(message: Message){
        service.deleteMessage(message: message) {
            message in
            if let message = message{
                NSLog("")
            }else{
                NSLog("")
            }
        }
    }
    
    func getVisibleViewController(_ rootViewController: UIViewController?) -> UIViewController? {
        
        var rootVC = rootViewController
        if rootVC == nil {
            rootVC = UIApplication.shared.keyWindow?.rootViewController
        }
        
        if rootVC?.presentedViewController == nil {
            return rootVC
        }
        
        if let presented = rootVC?.presentedViewController {
            if presented.isKind(of: UINavigationController.self) {
                let navigationController = presented as! UINavigationController
                return navigationController.viewControllers.last!
            }
            
            if presented.isKind(of: UITabBarController.self) {
                let tabBarController = presented as! UITabBarController
                return tabBarController.selectedViewController!
            }
            
            return getVisibleViewController(presented)
        }
        return nil
    }


}
