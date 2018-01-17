//
//  Event.swift
//  BuzzyMail
//
//  Created by Jérémy Keusters on 15/01/18.
//  Copyright © 2018 Jérémy Keusters. All rights reserved.
//

import Foundation

//struct Event {
//    let subject: String?
//    let start: String?
//    let end: String?
//    let startTime: String?
//    let id: String?
//    let organizer: Organizer?
//}

struct CalendarEvent : Encodable {
    var subject: String?
    var bodyPreview: String?
    var start: Time?
    var end: Time?
    var startTime: String?
    let id: String?
    var location: Location?
    var attendees: [Attendees]?
    var organizer: Organizer?
}

struct Time : Codable {
    var dateTime: String
    var timeZone: String
}

struct Location : Codable {
    var displayName: String
}

struct Attendees: Codable {
    var type: String?
    var status: Status
    var emailAddress: EmailAddress
}

struct Status: Codable {
    var response: String
    var time: String
}

struct Organizer : Codable {
    var emailAddress : EmailAddress?
}

