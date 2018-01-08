//
//  MenuCell.swift
//  BuzzyMail
//
//  Created by Jérémy Keusters on 8/01/18.
//  Copyright © 2018 Jérémy Keusters. All rights reserved.
//

import Foundation
import SwiftyJSON

class MenuCell: UITableViewCell {
    

    @IBOutlet weak var numberUnreadMailsLabel: UILabel!
    @IBOutlet weak var displayNameLabel: UILabel!
    
    var displayName: String? {
        didSet {
            displayNameLabel.text = displayName
        }
    }
    var numberUnreadMails: String? {
        didSet {
            numberUnreadMailsLabel.text = numberUnreadMails
        }
    }
}

class MailFoldersDataSource: NSObject {
    let mailFolders: [MailFolder]
    
    init(mailFolders: [JSON]?) {
        var mailFoldersArray = [MailFolder]()
        var mailFoldersArraySorted = [MailFolder]()
        
        NSLog("POMPERNIKKEL 3")
        
        if let unwrappedMailFolders = mailFolders {
            for (mailFolder) in unwrappedMailFolders {

                let newMailFolder = MailFolder(
                    id: mailFolder["id"].stringValue,
                    displayName: mailFolder["displayName"].stringValue,
                    parentFolderId: mailFolder["parentFolderId"].stringValue,
                    childFolderCount: mailFolder["childFolderCount"].intValue,
                    unreadItemCount: mailFolder["unreadItemCount"].intValue,
                    totalItemCount: mailFolder["totalItemCount"].intValue)
                
                mailFoldersArray.append(newMailFolder)
            }
        }
        mailFoldersArraySorted = mailFoldersArray.sorted(by: { $0.totalItemCount > $1.totalItemCount })
        self.mailFolders = mailFoldersArraySorted
    }
    
    func getMessagesArray() -> [MailFolder]{
        return mailFolders
    }
}

extension MailFoldersDataSource: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mailFolders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: MenuCell.self)) as! MenuCell
        let mailFolder = mailFolders[indexPath.row]
        
        cell.displayName = mailFolder.displayName
        cell.numberUnreadMails = String(mailFolder.unreadItemCount)

        return cell
        
    }
}
