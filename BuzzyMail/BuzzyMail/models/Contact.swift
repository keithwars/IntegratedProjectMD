//
//  Contact.swift
//  BuzzyMail
//
//  Created by Jérémy Keusters on 15/01/18.
//  Copyright © 2018 Jérémy Keusters. All rights reserved.
//

import Foundation

struct Contact {
    let id: String?
    let displayName: String?
    let givenName: String?
    let surname: String?
    let emailAddresses: [EmailAddress]?
}
