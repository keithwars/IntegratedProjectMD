//
//  MessageCell.swift
//  BuzzyMail
//
//  Created by Keith Vella on 24/11/2017.
//  Copyright © 2017 Keith Vella. All rights reserved.
//

import UIKit
import SwiftyJSON

struct Message: Codable {
    var id: String
    var receivedDateTime: String
    var hasAttachments: Bool
    var subject: String
    var bodyPreview: String
    var isRead: Bool
    var isDraft: Bool
    var body: Body
    var from: EmailAddress
    var toRecipients: [EmailAddress]?
    var ccRecipients: [EmailAddress]?
    var bccRecipients: [EmailAddress]?
}

struct Body: Codable {
    var contentType: String
    var content: String
}

struct EmailAddress: Codable {
    var name: String
    var address: String
}

class MessageCell: UITableViewCell {
    @IBOutlet weak var fromLabel: UILabel!
    @IBOutlet weak var receivedLabel: UILabel!
    @IBOutlet weak var subjectLabel: UILabel!
    
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
    
}

class MessagesDataSource: NSObject {
    let messages: [Message]
    
    init(messages: [JSON]?) {
        var msgArray = [Message]()
        
        if let unwrappedMessages = messages {
            for (message) in unwrappedMessages {
                NSLog("Testing")
                
//                for emailAddress in message["toRecipients"] {
//                    NSLog("testje: " + emailAddress.0)
//                }
                
                NSLog("DEBUG003: " + String(message["toRecipients"].arrayValue.count))
                
                var toRecipientsList = [EmailAddress]()
                for row in message["toRecipients"].arrayValue {
                    toRecipientsList.append(EmailAddress(name: row["emailAddress"]["name"].stringValue,
                                                         address: row["emailAddress"]["address"].stringValue))
                }
                
                var ccRecipientsList = [EmailAddress]()
                for row in message["ccRecipients"].arrayValue {
                    ccRecipientsList.append(EmailAddress(name: row["emailAddress"]["name"].stringValue,
                                                         address: row["emailAddress"]["address"].stringValue))
                }
                
                var bccRecipientsList = [EmailAddress]()
                for row in message["bccRecipients"].arrayValue {
                    bccRecipientsList.append(EmailAddress(name: row["emailAddress"]["name"].stringValue,
                                                          address: row["emailAddress"]["address"].stringValue))
                }
                
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
                    toRecipients: toRecipientsList,
                    ccRecipients: ccRecipientsList,
                    bccRecipients: bccRecipientsList)
                
                msgArray.append(newMsg)
                
                // Debugging
//                print("-----------------------------------------------------------")
//                print("DEBUG001")
//                print("-----------------------------------------------------------")
//                print(newMsg.id)
//                print(newMsg.receivedDateTime)
//                print(newMsg.hasAttachments)
//                print(newMsg.subject)
//                print("BODYPREVIEW: " + newMsg.bodyPreview)
//                print(newMsg.isRead)
//                print(newMsg.isDraft)
//                //print(newMsg.body.content)
//                print(newMsg.body.contentType)
//                print(newMsg.from.name)
//                print(newMsg.from.address)
//                print(newMsg.toRecipients)
//                print(newMsg.ccRecipients)
//                print(newMsg.bccRecipients)
//                print("-----------------------------------------------------------")
            }
        }
        
        self.messages = msgArray
    }
    
    func getMessagesArray() -> [Message]{
        return messages
    }
}

extension MessagesDataSource: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: MessageCell.self)) as! MessageCell
        let message = messages[indexPath.row]
        cell.from = message.from.name
        cell.received = message.receivedDateTime
        cell.subject = message.subject
        return cell
    }
}
