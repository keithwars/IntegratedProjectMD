//
//  Event.swift
//  BuzzyMail
//
//  Created by Jérémy Keusters on 15/01/18.
//  Copyright © 2018 Jérémy Keusters. All rights reserved.
//

import Foundation

struct Event {
    let subject: String?
    let start: String?
    let end: String?
    let startTime: String?
    let id: String?
    let organizer: Organizer?
}

struct Organizer : Codable {
    var emailAddress : EmailAddress?
}

