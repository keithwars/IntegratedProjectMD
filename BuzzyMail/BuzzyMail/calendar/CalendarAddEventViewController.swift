//
//  CalendarAddEventViewController.swift
//  BuzzyMail
//
//  Created by Lennart Schelfhout on 07/12/2017.
//  Copyright © 2017 Jérémy Keusters. All rights reserved.
//

import UIKit
import Foundation

class CalendarAddEventViewController: UITableViewController, UITextFieldDelegate {
    
    let service = OutlookService.shared()
    
    @IBOutlet weak var textfieldSubject: UITextField!
    @IBOutlet weak var textfieldLocation: UITextField!
    @IBOutlet weak var textfieldContent: UITextField!
    
    @IBOutlet weak var textfieldStart: UITextField!
    @IBOutlet weak var textfieldStartTime: UITextField!
    
    @IBOutlet weak var textfieldEnd: UITextField!
    @IBOutlet weak var textfieldEndTime: UITextField!
    
    @IBOutlet weak var textfieldAttendees: UITextField!
    
    var startDate : String = ""
    var startTime : String = ""
    var endDate : String = ""
    var endTime : String = ""
    var content: String = ""
    
    var selectedUser: String?
    
    @objc func donePressed() {
        self.view.endEditing(true)
    }
    
    @IBAction func textfieldStartEditor(_ sender: UITextField) {
        let datePickerView = UIDatePicker()
        datePickerView.datePickerMode = .date
        sender.inputView = datePickerView
        datePickerView.addTarget(self, action: #selector(handleDatePickerStartDay(sender:)), for: .valueChanged)
    }
    
    @IBAction func textfieldStartTimeEditor(_ sender: UITextField) {
        let datePickerView = UIDatePicker()
        datePickerView.datePickerMode = .time
        sender.inputView = datePickerView
        datePickerView.addTarget(self, action: #selector(handleDatePickerStartTime(sender:)), for: .valueChanged)
    }
    
    @objc func handleDatePickerStartDay(sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        textfieldStart.text = dateFormatter.string(from: sender.date)
        
        getStartDate(textfieldStart)
    }

    @objc func handleDatePickerStartTime(sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        textfieldStartTime.text = dateFormatter.string(from: sender.date)
        
        getStartTime(textfieldStartTime)
    }
    
    @IBAction func textfieldEndEditor(_ sender: UITextField) {
        let datePickerView = UIDatePicker()
        datePickerView.datePickerMode = .date
        sender.inputView = datePickerView
        datePickerView.addTarget(self, action: #selector(handleDatePickerEndDay(sender:)), for: .valueChanged)
    }
    
    @IBAction func textfieldContentEditor(_ sender: UITextField) {
        content = textfieldContent.text!
        print("dit is de fucking content" + content)
    }
    
    @IBAction func textfieldEndTime(_ sender: UITextField) {
        let datePickerView = UIDatePicker()
        datePickerView.datePickerMode = .time
        sender.inputView = datePickerView
        datePickerView.addTarget(self, action: #selector(handleDatePickerEndTime(sender:)), for: .valueChanged)
    }
    
    @objc func handleDatePickerEndDay(sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        textfieldEnd.text = dateFormatter.string(from: sender.date)
        
        getEndDate(textfieldEnd)
    }
    
    @objc func handleDatePickerEndTime(sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        textfieldEndTime.text = dateFormatter.string(from: sender.date)
        
        getEndTime(textfieldEndTime)
    }
    
    func getStartDate(_ textField: UITextField){
        startDate = textField.text!
        print(startDate)
    }
    
    func getStartTime(_ textField: UITextField){
        startTime = textField.text!
        print(startTime)
    }
    
    func getEndDate(_ textField: UITextField){
        endDate = textField.text!
        print(endDate)
    }
    
    func getEndTime(_ textField: UITextField){
        endTime = textField.text!
        print(endTime)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(donePressed))
        toolbar.setItems([flexibleSpace, doneButton], animated: true)
        
        textfieldSubject.inputAccessoryView = toolbar
        textfieldLocation.inputAccessoryView = toolbar
        textfieldContent.inputAccessoryView = toolbar
        textfieldStart.inputAccessoryView = toolbar
        textfieldStartTime.inputAccessoryView = toolbar
        textfieldEnd.inputAccessoryView = toolbar
        textfieldEndTime.inputAccessoryView = toolbar
        
        if (selectedUser != nil) {
            textfieldAttendees.text = selectedUser
        }
        // Do any additional setup after loading the view, typically from a nib.
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onCancelPressed(_ sender: Any){
        if (selectedUser != nil) {
            self.performSegue(withIdentifier: "unwindToContactInformation", sender: sender)
        } else {
            self.performSegue(withIdentifier: "cancelToCalendar", sender: sender)
        }
        
    }
    
    @IBAction func onButtonPressed(_ sender: Any) {
        
        let start : String = "\(self.startDate)" + "T" + "\(self.startTime)" + ":00"
        let end = "\(self.endDate)" + "T" + "\(self.endTime)" + ":00"
        var eventAttendeesList = [Attendees]()
        
        if (selectedUser == nil) {
            let forTextFieldArray = textfieldAttendees.text!.components(separatedBy: ", ")
            for forTextField in forTextFieldArray {
                eventAttendeesList.append(Attendees(type: "required", status: Status(response: "none", time: "0001-01-01T00:00:00Z"), emailAddress: EmailAddress(name: "", address: forTextField)))
            }
        } else {
            eventAttendeesList.append(Attendees(type: "required", status: Status(response: "none", time: "0001-01-01T00:00:00Z"), emailAddress: EmailAddress(name: "", address: selectedUser!)))
        }
        
        let eventToAdd = CalendarEvent(
            subject: textfieldSubject.text!,
            bodyPreview: nil,
            body: Body(contentType: "html", content: textfieldContent.text),
            start: Time(dateTime: start,
                        timeZone: "Europe/Paris"),
            end: Time(dateTime: end,
                      timeZone: "Europe/Paris"),
            startTime: nil,
            id: "",
            location: Location(displayName: textfieldLocation.text!),
            attendees: eventAttendeesList,
            organizer: Organizer()
        )
        print("fucking event")
        print(eventToAdd)
        
        let jsonEncoder = JSONEncoder()
        jsonEncoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        
        // encode, convert to a String, and print it
        
        if let jsonData = try? jsonEncoder.encode(eventToAdd),
            let jsonString = try? JSONSerialization.jsonObject(with: jsonData, options: []) as! [String: Any] {
            print(jsonString)
            
            self.service.postEvent(json: jsonString) {_ in
                
            }
        
                    
        }
        if (selectedUser != nil) {
            self.performSegue(withIdentifier: "unwindToContactInformation", sender: sender)
        } else {
            self.performSegue(withIdentifier: "cancelToCalendar", sender: sender)
        }
        
        dismiss(animated: true, completion: nil)
     
    }
    
}
