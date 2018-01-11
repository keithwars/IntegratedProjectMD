//
//  ReplyMailViewController.swift
//  BuzzyMail
//
//  Created by Jérémy Keusters on 1/12/17.
//  Copyright © 2017 Jérémy Keusters. All rights reserved.
//

import Foundation
import UIKit

class ReplyMailViewController: UIViewController {

    let service = OutlookService.shared()
    var newEmail:Message?
    var container: MailContentTableViewController?

    let dispatchGroup = DispatchGroup()
    let dispatchGroup2 = DispatchGroup()
    let dispatchGroup3 = DispatchGroup()

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func sendButtonPressed(_ sender: Any) {

        self.dispatchGroup.enter()
        if let richTextEditor = container?.richTextEditor {
            self.newEmail?.body.content = richTextEditor.updatedText!
            self.newEmail?.subject = container!.subjectTextField.text!
            self.newEmail?.toRecipients?.append(EmailAddresses(emailAddress: EmailAddress(name: "Test", address: container!.toTextField.text!)))
            self.dispatchGroup.leave()
        }
        self.dispatchGroup.notify(queue: .main) {
            self.dispatchGroup2.enter()
            self.updateReply()
            self.dispatchGroup2.notify(queue: .main) {
                self.sendReply()
                self.performSegue(withIdentifier: "closeDraft", sender: sender)
            }
        }
    }



    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "embeddedSegue") {
            let childViewController = segue.destination as! MailContentTableViewController
            childViewController.email = self.newEmail
            self.container = (segue.destination as! MailContentTableViewController)
        }
    }

    @IBAction func cancelButtonPressed(_ sender: Any) {

        let deleteDraftActionHandler = { (action:UIAlertAction!) -> Void in
            self.service.deleteMessage(message: self.newEmail!) {_ in }
            self.performSegue(withIdentifier: "closeDraft", sender: action)
        }

        let saveDraftActionHandler = { (action:UIAlertAction!) -> Void in
            self.dispatchGroup3.enter()
            if let richTextEditor = self.container?.richTextEditor {
                self.newEmail?.body.content = richTextEditor.updatedText!
                self.newEmail?.subject = self.container!.subjectTextField.text!
                self.dispatchGroup3.leave()
            }
            self.dispatchGroup3.notify(queue: .main) {
                self.service.updateReply(message: self.newEmail!) {_ in }
                self.performSegue(withIdentifier: "closeDraft", sender: action)
            }
        }

        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        let deleteDraftAction = UIAlertAction(title: "Delete Draft", style: .destructive, handler: deleteDraftActionHandler)
        alertController.addAction(deleteDraftAction)
        let saveDraftAction = UIAlertAction(title: "Save Draft", style: .default, handler: saveDraftActionHandler)
        alertController.addAction(saveDraftAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)

        present(alertController, animated: true, completion: nil)
    }



    func sendReply() {
        NSLog("sendReply called")
        service.sendMessage(message: newEmail!) {
            message in
            if let message = message {
                NSLog("Send Reply Success")
            } else {
                NSLog("Send Reply Fail")
            }
        }
    }

    func updateReply() {
        NSLog("updateReply called")
        service.updateReply(message: newEmail!) {
            message in
            if let message = message {
                NSLog("Update Reply Success")
                self.dispatchGroup2.leave()
            } else {
                NSLog("Update Reply Fail")
                self.dispatchGroup2.leave()
            }
        }
    }


}
