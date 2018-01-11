//
//  Message.swift
//  BuzzyMail
//
//  Created by Jérémy Keusters on 4/01/18.
//  Copyright © 2018 Jérémy Keusters. All rights reserved.
//

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
