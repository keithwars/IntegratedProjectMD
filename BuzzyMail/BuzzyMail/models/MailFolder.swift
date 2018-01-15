//
//  MailFolder.swift
//  BuzzyMail
//
//  Created by Jérémy Keusters on 8/01/18.
//  Copyright © 2018 Jérémy Keusters. All rights reserved.
//

import Foundation

struct MailFolder: Codable {
    var id: String
    var displayName: String
    var parentFolderId: String
    var childFolderCount: Int
    var unreadItemCount: Int
    var totalItemCount: Int
}
