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
    
    var startDate : String = ""
    var startTime : String = ""
    var endDate : String = ""
    var endTime : String = ""
    var content : String = ""
    var location : String = ""
    var subject : String = ""
    
    @objc func donePressed() {
        self.view.endEditing(true)
    }

    @IBAction func textfieldSubjectEditor(_ sender: UITextField) {
        subject = textfieldSubject.text!
        print("subject init test: " + "\(subject)")
    }
    
    @IBAction func textfieldLocationEditor(_ sender: UITextField) {
        location = textfieldLocation.text!
        print("Wat is de location? " + location)
    }
    
    @IBAction func textfieldContentEditor(_ sender: UITextField) {
        content = textfieldContent.text!
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
        // Do any additional setup after loading the view, typically from a nib.
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onCancelPressed(_ sender: Any){
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onButtonPressed(_ sender: Any) {
        
        let start : String = "\(self.startDate)" + "T" + "\(self.startTime)" + ":00"
        let end = "\(self.endDate)" + "T" + "\(self.endTime)" + ":00"
        
        testEvent.start.dateTime = start
        testEvent.end.dateTime = end
        testEvent.subject = subject
        testEvent.location.displayName = location
        print("WAT IS HIER MIUJN FUCKING LOCATION???" + testEvent.location.displayName)
        testEvent.body.content = content
        
        let jsonEncoder = JSONEncoder()
        jsonEncoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        
        // encode, convert to a String, and print it
        
        if let jsonData = try? jsonEncoder.encode(testEvent),
            let jsonString = try? JSONSerialization.jsonObject(with: jsonData, options: []) as! [String: Any] {
            print(jsonString)
            
            self.service.postEvent(json: jsonString) {_ in
                
            }
                    
        }
        dismiss(animated: true, completion: nil)        
    }
    
    struct CalendarEvent : Codable {
        var subject: String
        var body: Body
        var start: Time
        var end: Time
        var location: Location
        var attendees: [String]
    }
    
    struct Body : Codable {
        var contentType: String
        var content: String
    }
    
    struct Time : Codable {
        var dateTime: String
        var timeZone: String
    }
    
    struct Location : Codable {
        var displayName: String
    }
    
    var testEvent = CalendarEvent(subject: "Let's go for lunch",
                                  body: Body(contentType: "HTML",
                                             content: "Does late morning work for you?"),
                                  start: Time(dateTime:"2017-12-10T12:55:00",
                                              timeZone: "W. Europe Standard Time"),
                                  end: Time(dateTime:"2017-12-10T14:00:00",
                                            timeZone: "W. Europe Standard Time"),
                                  location: Location(displayName: "Antwerpen"),
                                  attendees: [])

}
