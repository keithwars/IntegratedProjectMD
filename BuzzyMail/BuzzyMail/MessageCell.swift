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

struct Message: Codable {
    var id: String
    var receivedDateTime: String?
    var hasAttachments: Bool?
    var subject: String?
    var bodyPreview: String?
    var isRead: Bool
    var isDraft: Bool?
    var body: Body?
    var from: EmailAddresses?
    var toRecipients: [EmailAddresses]?
    var ccRecipients: [EmailAddresses]?
    var bccRecipients: [EmailAddresses]?
}

struct Body: Codable {
    var contentType: String
    var content: String
}

struct EmailAddresses: Codable {
    var emailAddress: EmailAddress
}
struct EmailAddress: Codable {
    var name: String
    var address: String
}

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
    let messages: [Message]
    
    
    
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

        cell.from = message.from!.emailAddress.name
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
    
    
    
//    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
//        if editingStyle == .Delete {
//            deletePlanetIndexPath = indexPath
//            let planetToDelete = planets[indexPath.row]
//            confirmDelete(planetToDelete)
//        }
//    }
    
    
}
