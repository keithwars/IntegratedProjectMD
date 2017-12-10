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

class OutlookService {
    // Configure the OAuth2 framework for Azure
    
    private static let oauth2Settings = [
        "client_id" : "9c5cb613-91a2-4807-bd5d-f4ced63a862d",
        "authorize_uri": "https://login.microsoftonline.com/common/oauth2/v2.0/authorize",
        "token_uri": "https://login.microsoftonline.com/common/oauth2/v2.0/token",
        "scope": "openid profile offline_access User.Read Mail.Read Calendars.ReadWrite",
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
    
    func makeApiCall(api: String, postRequest: Bool, json: [String:Any]? = nil, params: [String: String]? = nil, callback: @escaping (JSON?) -> Void) -> Void {
        // Build the request URL
        var urlBuilder = URLComponents(string: "https://graph.microsoft.com")!
        urlBuilder.path = api
        
        //let json = ["title": "ABC", "dict": ["1": "first", "2": "second"]] as [String: Any]
        
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
        if (postRequest) {
            req.httpMethod = OAuth2HTTPMethod.POST.rawValue
            req.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let jsonDate = try? JSONSerialization.data(withJSONObject: json!)
            //let decoded = try? JSONSerialization.jsonObject(with: jsonDate!, options: [])
            // here "decoded" is of type `Any`, decoded from JSON data
            
            // you can now cast it with the right type
            //if (decoded as? [String:String]) != nil {
               //   req.httpBody = jsonDate
            //}
            req.httpBody = jsonDate
          
            
        }
        /*else {
         req.addValue("application/json", forHTTPHeaderField: "Accept")
         }*/
        if (!userEmail.isEmpty) {
            // Add X-AnchorMailbox header to optimize
            // API routing
            req.addValue(userEmail, forHTTPHeaderField: "X-AnchorMailbox")
        }
        
        let loader = OAuth2DataLoader(oauth2: oauth2)
        
        // Uncomment this line to get verbose request/response info in
        // Xcode output window
        loader.logger = OAuth2DebugLogger(.trace)
        
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
            makeApiCall(api: "/v1.0/me", postRequest: false) {
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
            "$select": "subject,receivedDateTime,from,body",
            "$orderby": "receivedDateTime DESC",
            "$top": "20"
        ]
        
        makeApiCall(api: "/v1.0/me/mailfolders/inbox/messages", postRequest: false, json: nil, params: apiParams) {
            result in
            callback(result)
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
            "$select": "subject,start,end",
            "$orderby": "start/dateTime ASC",
            "$top": "10"
        ]
    
        makeApiCall(api: "/v1.0/me/calendar/calendarView", postRequest: false, params: apiParams) {
            result in
            callback(result)
        }
    }
    
    func postEvent(json: [String:Any], callback: @escaping ([String:Any]?) -> Void) -> Void {
        
        makeApiCall(api: "/v1.0/me/calendar/events", postRequest: true, json: json) {
            result in
            callback(result?.dictionary)
            dump(json)
        }
    }
    
    func logout() -> Void {
        oauth2.forgetTokens()
    }
}

