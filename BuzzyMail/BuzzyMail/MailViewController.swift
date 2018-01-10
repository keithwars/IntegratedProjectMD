//
//  FirstViewController.swift
//  BuzzyMail
//
//  Created by Jérémy Keusters on 24/11/17.
//  Copyright © 2017 Jérémy Keusters. All rights reserved.
//

import UIKit
import SideMenu

class MailViewController: UIViewController {

    let service = OutlookService.shared()
    
    var messagesList:[Message]?
    
    let customSideMenuManager = SideMenuManager()
    
    @IBOutlet weak var tableView: UITableView!
    var dataSource: MessagesDataSource?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.rowHeight = 80;
        
        // Do any additional setup after loading the view, typically from a nib.
        if(service.isLoggedIn) {
            loadUserData()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showMailContent" {
            let row = self.tableView.indexPathForSelectedRow
            let rowint = Int(row![1])
            
            messagesList = dataSource?.getMessagesArray()
            
                if let destination = segue.destination as? MailContentViewController {
                    destination.email = messagesList![rowint]
                }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        SideMenuManager.default.menuWidth = max(round(min((UIScreen.main.bounds.width), (UIScreen.main.bounds.height)) * 0.80), 240)
        //SideMenuManager.default.menuFadeStatusBar = true
        SideMenuManager.default.menuAnimationBackgroundColor = UIColor.clear
        //SideMenuManager.default.menuAnimationBackgroundColor = UIColor(rgb: 0x0096FF)
        super.viewWillAppear(animated)
        
        if let selectionIndexPath = self.tableView.indexPathForSelectedRow {
            self.tableView.deselectRow(at: selectionIndexPath, animated: animated)
        }
    }



    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadUserData() {
        service.getUserEmail() {
            email in
            self.service.getInboxMessages() {
                messages in
                if let unwrappedMessages = messages {
                    self.dataSource = MessagesDataSource(messages: unwrappedMessages["value"].arrayValue)
                    self.tableView.dataSource = self.dataSource
                    self.tableView.reloadData()
                }
            }
        }
    }
}

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
}

