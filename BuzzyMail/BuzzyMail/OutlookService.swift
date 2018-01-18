//
//  OutlookService.swift
//  swift-tutorial
//
//  Created by Jérémy Keusters on 23/11/17.
//  Copyright © 2017 Jérémy Keusters. All rights reserved.
//

import Foundation
import p2_OAuth2
import SwiftyJSON

enum RequestTypes {
    case get
    case post
    case put
    case patch
    case delete
}

class OutlookService {
    // Configure the OAuth2 framework for Azure
    private static let oauth2Settings = [
        "client_id" : "9c5cb613-91a2-4807-bd5d-f4ced63a862d",
        "authorize_uri": "https://login.microsoftonline.com/common/oauth2/v2.0/authorize",
        "token_uri": "https://login.microsoftonline.com/common/oauth2/v2.0/token",
        "scope": "openid profile offline_access User.Read Mail.Read Mail.ReadWrite Mail.Send Calendars.ReadWrite Contacts.ReadWrite",
        "redirect_uris": ["buzzy-mail://oauth2/callback"],
        "verbose": true,
        ] as OAuth2JSON

    public var userEmail: String
    
    public var userGivenName: String

    private static var sharedService: OutlookService = {
        let service = OutlookService()
        return service
    }()

    private let oauth2: OAuth2CodeGrant

    private init() {
        oauth2 = OAuth2CodeGrant(settings: OutlookService.oauth2Settings)
        oauth2.authConfig.authorizeEmbedded = true
        userEmail = ""
        userGivenName = ""
    }

    class func shared() -> OutlookService {
        return sharedService
    }

    var isLoggedIn: Bool {
        get {
            return oauth2.hasUnexpiredAccessToken() || oauth2.refreshToken != nil
        }
    }

    func handleOAuthCallback(url: URL) -> Void {
        oauth2.handleRedirectURL(url)
    }

    func login(from: AnyObject, callback: @escaping (String? ) -> Void) -> Void {
        oauth2.authorizeEmbedded(from: from) {
            result, error in
            if let unwrappedError = error {
                callback(unwrappedError.description)
            } else {
                if let unwrappedResult = result, let token = unwrappedResult["access_token"] as? String {
                    // Print the access token to debug log
                    NSLog("Access token: \(token)")
                    callback(nil)
                }
            }
        }
    }

    func makeApiCall(api: String, requestType : RequestTypes, body: Message? = nil, json: [String:Any]? = nil, params: [String: String]? = nil, callback: @escaping (JSON?) -> Void) -> Void {
        // Build the request URL
        var urlBuilder = URLComponents(string: "https://graph.microsoft.com")!
        urlBuilder.path = api

        if let unwrappedParams = params {
            // Add query parameters to URL
            urlBuilder.queryItems = [URLQueryItem]()
            for (paramName, paramValue) in unwrappedParams {
                urlBuilder.queryItems?.append(
                    URLQueryItem(name: paramName, value: paramValue))
            }
        }

        let apiUrl = urlBuilder.url!
        NSLog("Making \(requestType) request to \(apiUrl)")

        var req = oauth2.request(forURL: apiUrl)
        req.addValue("application/json", forHTTPHeaderField: "Accept")

        switch requestType {
        case .get:
            req.httpMethod = "GET"
        case .post:
            req.httpMethod = "POST"
            req.addValue("application/json", forHTTPHeaderField: "Content-Type")
            if let unwrappedJson = json {
                let jsonDate = try? JSONSerialization.data(withJSONObject: unwrappedJson)
                req.httpBody = jsonDate
            }
            if let unwrappedBody = body {
                let jsonEncoder = JSONEncoder()
                let jsonData = try! jsonEncoder.encode(unwrappedBody)
                req.httpBody = jsonData
            }
        case .put:
            req.httpMethod = "PUT"
        case .patch:
            NSLog("Patch request received")
            req.httpMethod = "PATCH"
            req.addValue("application/json", forHTTPHeaderField: "Content-Type")
            let jsonEncoder = JSONEncoder()
            let jsonData = try! jsonEncoder.encode(body)
            req.httpBody = jsonData
        case .delete:
            NSLog("Delete request received")
            req.httpMethod = "DELETE"
        }

        if (!userEmail.isEmpty) {
            // Add X-AnchorMailbox header to optimize
            // API routing
            req.addValue(userEmail, forHTTPHeaderField: "X-AnchorMailbox")
        }

        let loader = OAuth2DataLoader(oauth2: oauth2)

        // Uncomment this line to get verbose request/response info in
        // Xcode output window
        //loader.logger = OAuth2DebugLogger(.trace)

        loader.perform(request: req) {
            response in
            do {
                let dict = try response.responseJSON()
                DispatchQueue.main.async {
                    let result = JSON(dict)
                    callback(result)
                }
            }
            catch let error {
                DispatchQueue.main.async {
                    let result = JSON(error)
                    callback(result)
                }
            }
        }
    }

    func getUserEmail(callback: @escaping (String?) -> Void) -> Void {
        // If we don't have the user's email, get it from
        // the API
        if (userEmail.isEmpty) {
            makeApiCall(api: "/v1.0/me", requestType: RequestTypes.get) {
                result in
                if let unwrappedResult = result {
                    let email = unwrappedResult["mail"].stringValue
                    //NSLog("POMPERNIKKEL5 " + unwrappedResult["givenName"].stringValue)
                    self.userGivenName = unwrappedResult["givenName"].stringValue
                    self.userEmail = email
                    callback(email)
                } else {
                    callback(nil)
                }
            }
        } else {
            callback(userEmail)
        }
    }

    func getInboxMessages(callback: @escaping (JSON?) -> Void) -> Void {
        let apiParams = [
            "$orderby": "receivedDateTime DESC",
            "$top": "50"
        ]

        makeApiCall(api: "/v1.0/me/mailfolders/inbox/messages", requestType: RequestTypes.get, params: apiParams) {
            result in
            callback(result)
        }
    }
    
    func getMailFolderMessages(mailFolderId: String, callback: @escaping (JSON?) -> Void) -> Void {
        let apiParams = [
            "$orderby": "receivedDateTime DESC",
            "$top": "10"
        ]
        
        makeApiCall(api: "/v1.0/me/mailfolders/" + mailFolderId + "/messages", requestType: RequestTypes.get, params: apiParams) {
            result in
            callback(result)
        }
    }
    
    func getMailFolderByName(mailFolderName: String, callback: @escaping (JSON?) -> Void) -> Void {
        makeApiCall(api: "/v1.0/me/mailfolders/" + mailFolderName, requestType: RequestTypes.get) {
            result in
            callback(result)
        }
    }
    
    func createMail(message: Message, callback: @escaping (JSON?) -> Void) -> Void {
        makeApiCall(api: "/v1.0/me/messages", requestType: RequestTypes.post, body: message) {
            result in
            if let unwrappedResult = result {
                callback(unwrappedResult)
            } else {
                callback(nil)
            }
        }
    }

    func createReply(message: Message, callback: @escaping (JSON?) -> Void) -> Void {
        makeApiCall(api: "/v1.0/me/messages/" + message.id! + "/createReply", requestType: RequestTypes.post) {
            result in
            if let unwrappedResult = result {
                callback(unwrappedResult)
            } else {
                callback(nil)
            }
        }
    }
    
    func createReplyAll(message: Message, callback: @escaping (JSON?) -> Void) -> Void {
        makeApiCall(api: "/v1.0/me/messages/" + message.id! + "/createReplyAll", requestType: RequestTypes.post) {
            result in
            if let unwrappedResult = result {
                callback(unwrappedResult)
            } else {
                callback(nil)
            }
        }
    }

    func createForward(message: Message, callback: @escaping (JSON?) -> Void) -> Void {
        makeApiCall(api: "/v1.0/me/messages/" + message.id! + "/createForward", requestType: RequestTypes.post) {
            result in
            if let unwrappedResult = result {
                callback(unwrappedResult)
            } else {
                callback(nil)
            }
        }
    }
    
    func listAttachments(message: Message, callback: @escaping (JSON?) -> Void) -> Void {
        makeApiCall(api: "/v1.0/me/messages/" + message.id! + "/attachments", requestType: RequestTypes.get) {
            result in
            if let unwrappedResult = result {
                callback(unwrappedResult)
            } else {
                callback(nil)
            }
        }
    }

    func sendMessage(message: Message, callback: @escaping (JSON?) -> Void) -> Void {
        makeApiCall(api: "/v1.0/me/messages/" + message.id! + "/send", requestType: RequestTypes.post) {
            result in
            callback(result)
        }
    }

    func updateReply(message: Message, callback: @escaping (JSON?) -> Void) -> Void {
        makeApiCall(api: "/v1.0/me/messages/" + message.id!, requestType: RequestTypes.patch, body: message) {
            result in
            callback(result)
        }
    }

    func updateIsReadStatus(message: Message, callback: @escaping (JSON?) -> Void) -> Void {
        makeApiCall(api: "/v1.0/me/messages/" + message.id!, requestType: RequestTypes.patch, body: message) {
          result in
          callback(result)
        }
    }

    func deleteMessage(message: Message, callback: @escaping (JSON?) -> Void) -> Void {
        makeApiCall(api: "/v1.0/me/messages/" + message.id!, requestType: RequestTypes.delete, body: message) {
            result in
            callback(result)
        }
    }

    func postEvent(json: [String:Any], callback: @escaping ([String:Any]?) -> Void) -> Void {

        makeApiCall(api: "/v1.0/me/calendar/events", requestType: RequestTypes.post, json: json) {
            result in
            callback(result?.dictionary)
            dump(json)
        }
    }

    func getEvent(id: String, callback: @escaping (String?) -> Void) -> Void {
        makeApiCall(api: "/v1.0/me/calendar/events/" + "\(id)", requestType: RequestTypes.get, json: id as Any as? [String : Any]) {
            result in
            callback(result?.string)
        }
    }

    func getEvents(callback: @escaping (JSON?) -> Void) -> Void {

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        let iso8601String = dateFormatter.string(from: Date())

        let datePlus1Week = Calendar.current.date(byAdding: .month, value: 1, to: Date())
        print("Dateplus1week: " + "\(describing: datePlus1Week)")
        let test = dateFormatter.string(from: datePlus1Week!)
        print("test: " + "\(test)")

        let apiParams = [
            "startDateTime": "\(iso8601String)",
            "endDateTime": "\(test)",
            "$orderby": "start/dateTime ASC",
            "$top": "10"
        ]

        makeApiCall(api: "/v1.0/me/calendar/calendarView", requestType: RequestTypes.get, params: apiParams) {
            result in
            callback(result)
        }
    }

    func deleteEvent(id: String, callback: @escaping (String?) -> Void) -> Void {
        makeApiCall(api: "/v1.0/me/calendar/events/" + "\(id)", requestType: RequestTypes.delete, json: id as Any as? [String : Any]) {
            result in
            callback(result?.string)
        }
    }
    
    func getContacts(callback: @escaping (JSON?) -> Void) -> Void {
        let apiParams = [
            "$select": "id, displayName, givenName, surname, emailAddresses",
            "$orderby": "surname ASC",
            "$top": "10"
        ]
        
        makeApiCall(api: "/v1.0/me/contacts", requestType: RequestTypes.get, params: apiParams) {
            result in
            callback(result)
        }
    }
    
    func deleteContact(id: String, callback: @escaping (String?) -> Void) -> Void {
        makeApiCall(api: "/v1.0/me/contacts/" + "\(id)", requestType: RequestTypes.delete, json: id as Any as? [String : Any]) {
            result in
            callback(result?.string)
        }
    }
    
    func postContact(json: [String:Any], callback: @escaping ([String:Any]?) -> Void) -> Void {
        
        makeApiCall(api: "/v1.0/me/contacts", requestType: RequestTypes.post, json: json) {
            result in
            callback(result?.dictionary)
            dump(json)
        }
    }

    func getMailFolders(callback: @escaping (JSON?) -> Void) -> Void {
        let apiParams = [
            "$orderby": "totalItemCount DESC"
        ]
        makeApiCall(api: "/v1.0/me/mailfolders", requestType: RequestTypes.get, params: apiParams) {
            result in
            callback(result)
        }
    }
    
    func logout() -> Void {
        oauth2.forgetTokens()
    }

}
