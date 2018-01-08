//
//  FirstViewController.swift
//  BuzzyMail
//
//  Created by Jérémy Keusters on 24/11/17.
//  Copyright © 2017 Jérémy Keusters. All rights reserved.
//

import UIKit

import MessageUI
import WebKit

var messageHtml: Message?

extension String {
    
//    First attempt at the HMTL parser
    
//    var html2AttributedString: NSAttributedString? {
//        do {
//            return try NSAttributedString(data:messageHtml!.body,
//                                          options: [.documentType: NSAttributedString.DocumentType.html,
//                                                    .characterEncoding: String.Encoding.utf8.rawValue],
//                                          documentAttributes: nil)
//        } catch {
//            print("error:", error)
//            return  nil
//        }
//    }
//
//    var html2String: String {
//        return html2AttributedString?.string ?? ""
//    }
}

class MailContentViewController: UIViewController {
    
    var email:Message?
    let service = OutlookService.shared()
    
    @IBOutlet weak var fromLabel: UILabel!
    
    @IBOutlet weak var subjectLabel: UILabel!

    @IBOutlet weak var contentWebView: WKWebView!
    
    @IBOutlet weak var richTextEditorNonEditable: RichTextEditorNonEditable!
    
    
    override func viewDidLoad() {
        
        navigationItem.largeTitleDisplayMode = .never
        super.viewDidLoad()
        fromLabel.text = email!.from.name

        //let htmlText = email!.body
        
        /*let htmlTextWithStyle = htmlText + ("<style type='text/css'> *{font-size: 17px;}html,body {font-size:\(24.0); font-family: '\(UIFont.systemFont(ofSize: 30.0))'; margin: 0;padding: 0;width: 100%;height: 100%;}html {display: table;}body {display: table-cell;vertical-align: top;padding: 20px;text-align: left;-webkit-text-size-adjust: none;}</style>")
    
        print(htmlTextWithStyle)*/
        NSLog("--------------------------------++++++")
        //print(htmlText)
        richTextEditorNonEditable.text = email!.body.content
        
//        let source = "var meta = document.createElement('meta');" +
//            "meta.name = 'viewport';" +
//            "meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';" +
//            "var head = document.getElementsByTagName('head')[0];" +
//        "head.appendChild(meta);"
//        
//        let script = WKUserScript(source: source, injectionTime: WKUserScriptInjectionTime.atDocumentEnd, forMainFrameOnly: true)
//        
//        let userContentController = WKUserContentController()
//        userContentController.addUserScript(script)
//        
//        let configuration = WKWebViewConfiguration()
//        configuration.userContentController = userContentController
//        
//        contentWebView = WKWebView(frame: CGRect.infinite, configuration: configuration)
        //contentWebView.loadHTMLString(htmlTextWithStyle, baseURL: nil)
       
        
    
        
        //let mailData = Bundle.main.path(forResource: email!.body, ofType: "html")
        //let url = URL(fileURLWithPath: mailData!)
        //let request = URLRequest(url: url)
        //contentWebView.load(request)
        
        //contentWebKitView.loadFileURL(mailData, allowingReadAccessTo: <#T##URL#>)
        
        subjectLabel.text = email!.subject
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
   
    }

    @IBAction func replyButtonPressed(_ sender: Any) {
        
        let replyActionHandler = { (action:UIAlertAction!) -> Void in
            let popup : ReplyMailViewController = self.storyboard?.instantiateViewController(withIdentifier: "ReplyMailViewController") as! ReplyMailViewController
            let navigationController = UINavigationController(rootViewController: popup)
            navigationController.modalPresentationStyle = UIModalPresentationStyle.pageSheet
            popup.replyToEmail = self.email
            self.present(navigationController, animated: true, completion: nil)
        }
        
    
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let replyAction = UIAlertAction(title: "Reply", style: .default, handler: replyActionHandler)
        alertController.addAction(replyAction)
        let replyAllAction = UIAlertAction(title: "Reply All", style: .default, handler: nil)
        alertController.addAction(replyAllAction)
        let forwardAction = UIAlertAction(title: "Forward", style: .default, handler: nil)
        alertController.addAction(forwardAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func cancelToMailContentViewController(_ segue: UIStoryboardSegue) {
    }

}


