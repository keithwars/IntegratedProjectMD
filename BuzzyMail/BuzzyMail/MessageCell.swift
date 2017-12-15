//
//  MessageCell.swift
//  BuzzyMail
//
//  Created by Keith Vella on 24/11/2017.
//  Copyright © 2017 Keith Vella. All rights reserved.
//

import UIKit
import SwiftyJSON

struct Message {
    
    let from: String
    let received: String
    let subject: String
    let hasAttachments: Bool
    let body: String
    let bodyPreview: String
    let isRead: Bool
    
}

class MessageCell: UITableViewCell {
    @IBOutlet weak var fromLabel: UILabel!
    @IBOutlet weak var receivedLabel: UILabel!
    @IBOutlet weak var subjectLabel: UILabel!
    @IBOutlet weak var bodyPreviewLabel: UILabel!
    @IBOutlet weak var attachmentImageView: UIImageView!
    
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
                
                let newMsg = Message(
                    
                    from: message["from"]["emailAddress"]["name"].stringValue,
                    received: Formatter.dateToString(date: message["receivedDateTime"]),
                    subject: message["subject"].stringValue,
                    hasAttachments: message["hasAttachments"].boolValue,
                    body: message["body"]["content"].stringValue,
                    bodyPreview: message["bodyPreview"].stringValue,
                    isRead: message["isRead"].boolValue)
                
                msgArray.append(newMsg)
                
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
        
        if (message.hasAttachments == true){
            cell.attachmentImageView.isHidden = false
        }else{
            cell.attachmentImageView.isHidden = true
        }
        
        
        
        cell.from = message.from
        cell.received = message.received
        cell.subject = message.subject
        cell.bodyPreview = (message.bodyPreview)
        
        if (message.isRead == false){
            print("read Yes")
            cell.backgroundColor = #colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1)
        }
        
        return cell
        
    }
}
