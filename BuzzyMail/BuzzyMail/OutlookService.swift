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
        "scope": "openid profile offline_access User.Read Mail.Read Mail.ReadWrite Mail.Send",
        "redirect_uris": ["buzzy-mail://oauth2/callback"],
        "verbose": true,
        ] as OAuth2JSON
    
    private var userEmail: String
    
    private static var sharedService: OutlookService = {
        let service = OutlookService()
        return service
    }()
    
    private let oauth2: OAuth2CodeGrant
    
    private init() {
        oauth2 = OAuth2CodeGrant(settings: OutlookService.oauth2Settings)
        oauth2.authConfig.authorizeEmbedded = true
        userEmail = ""
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
    
    func makeApiCall(api: String, requestType : RequestTypes, body: Message? = nil, params: [String: String]? = nil, callback: @escaping (JSON?) -> Void) -> Void {
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
        NSLog("Making request to \(apiUrl)")
        
        var req = oauth2.request(forURL: apiUrl)
        req.addValue("application/json", forHTTPHeaderField: "Accept")

        switch requestType {
        case .get:
            NSLog("Get request received")
        case .post:
            NSLog("Post request received")
            req.httpMethod = "POST"
            req.addValue("application/json", forHTTPHeaderField: "Content-Type")
        case .put:
            NSLog("Put request received")
        case .patch:
            NSLog("Patch request received")
            req.httpMethod = "PATCH"
            req.addValue("application/json", forHTTPHeaderField: "Content-Type")

            let jsonEmail = try? JSONSerialization.data(withJSONObject: body!)
            req.httpBody = jsonEmail
        case .delete:
            NSLog("Delete request received")
        }
        
//        else {
//            req.addValue("application/json", forHTTPHeaderField: "Accept")
//        }
        
        if (!userEmail.isEmpty) {
            // Add X-AnchorMailbox header to optimize
            // API routing
            req.addValue(userEmail, forHTTPHeaderField: "X-AnchorMailbox")
        }
        
        let loader = OAuth2DataLoader(oauth2: oauth2)
        
        // Uncomment this line to get verbose request/response info in
        // Xcode output window
//        loader.logger = OAuth2DebugLogger(.trace)
        
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
    
    func createReply(message: Message, callback: @escaping (JSON?) -> Void) -> Void {
        makeApiCall(api: "/v1.0/me/messages/" + message.id + "/createReply", requestType: RequestTypes.post) {
            result in
            callback(result)
        }
    }
    
    func sendReply(message: Message, callback: @escaping (JSON?) -> Void) -> Void {
        makeApiCall(api: "/v1.0/me/messages/" + message.id + "/reply", requestType: RequestTypes.post) {
            result in
            callback(result)
        }
    }

    func updateReply(message: Message, callback: @escaping (JSON?) -> Void) -> Void {
        makeApiCall(api: "/v1.0/me/messages/" + message.id, requestType: RequestTypes.patch, body: message) {
            result in
            callback(result)
        }
    }
    
    func logout() -> Void {
        oauth2.forgetTokens()
    }

}

