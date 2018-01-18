//
//  Attachment.swift
//  BuzzyMail
//
//  Created by Jérémy Keusters on 18/01/18.
//  Copyright © 2018 Jérémy Keusters. All rights reserved.
//

import Foundation

struct Attachment: Codable {
    var id: String
    var name: String
    var contentType: String
    var size: Int
    var contentBytes: String
}
