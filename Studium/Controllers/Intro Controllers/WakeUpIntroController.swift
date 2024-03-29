//
//  WakeUpIntroController.swift
//  Studium
//
//  Created by Vikram Singh on 5/27/20.
//  Copyright © 2020 Vikram Singh. All rights reserved.
//

import Foundation
import UIKit

//this controls the page that the user sees in the beginning, when they must enter what times they wake up at.
class WakeUpIntroController: UIViewController{
    
    //reference to defaults - that is where we will be storing the time data for when the user wakes up
    let defaults = UserDefaults.standard
    
    //reference to certain UIKit elements that we need access to.
    @IBOutlet var days: Array<UIButton>?
    
    @IBOutlet weak var sunLabel: UILabel!
    @IBOutlet weak var monLabel: UILabel!
    @IBOutlet weak var tueLabel: UILabel!
    @IBOutlet weak var wedLabel: UILabel!
    @IBOutlet weak var thuLabel: UILabel!
    @IBOutlet weak var friLabel: UILabel!
    @IBOutlet weak var satLabel: UILabel!
    
    @IBOutlet var weekdayLabels: Array<UILabel>?
    
    @IBOutlet weak var timePicker: UIDatePicker!
    @IBOutlet weak var nextButton: UIButton!
    
    var selectedDay: UIButton?
    
    @IBOutlet weak var secondaryBackground: UIView!
    
    //dictionaries that help keep the data organized
    
    //the String is the day (e.g: "Sun") and the Date is the wake up time
    var times: [String: Date] = [:]
    
    //the String is the day (e.g: "Sun") and the UILabel is a reference to the label that it corresponds to
    var labels: [String: UILabel] = [:]
    var dayLabels: [String: UILabel] = [:]
    
    //boolean that tells whether the user wakes up at different times depending on the day.
    var differentTimes: Bool = true
    
    let tintColor: UIColor = UIColor(named: "Studium Secondary Theme Color") ?? .label
    let labelColor: UIColor = UIColor(named: "Studium Label Color") ?? .label

    
    override func viewDidLoad() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { (granted, error) in
            if error != nil{
                print(error!)
            }
        }

        nextButton.titleLabel?.text = "Next"
        nextButton.titleLabel?.textColor = .orange
        nextButton.layer.cornerRadius = 10
        
        secondaryBackground.layer.cornerRadius = 10

        //selects sunday by default
        
        //selects the time 7:30AM by default
        let date = Calendar.current.date(bySettingHour: 7, minute: 30, second: 0, of: Date())!
        timePicker.setDate(date, animated: true)
        
        //initialize the dictionaries. The only one that will have data that changes (potentially) is the times dictionary
        times = ["Sun": date, "Mon": date, "Tue": date, "Wed": date, "Thu": date, "Fri": date, "Sat": date]
        labels = ["Sun": sunLabel, "Mon": monLabel, "Tue": tueLabel, "Wed": wedLabel, "Thu": thuLabel, "Fri": friLabel, "Sat": satLabel]
        
        if weekdayLabels != nil{
            dayLabels = ["Sun": weekdayLabels![0], "Mon": weekdayLabels![1], "Tue": weekdayLabels![2], "Wed": weekdayLabels![3], "Thu": weekdayLabels![4], "Fri": weekdayLabels![5], "Sat": weekdayLabels![6]]
        }
        
        selectSunday()
    }
    
    //function that is called when the user switches between whether they wake up at different times or at the same time.
    @IBAction func habitChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0{ //different times
            differentTimes = true
            for day in days!{
                day.isSelected = false
                day.isEnabled = true
            }
            selectSunday()
            
        }else{ //same time everyday
            differentTimes = false
            for day in days!{
                day.setTitleColor(.lightGray, for: .disabled)
                day.isSelected = false
                day.isEnabled = false
                
                labels[day.titleLabel!.text!]?.textColor = labelColor
                dayLabels[day.titleLabel!.text!]?.textColor = labelColor
            }
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "h:mm a"
            let formattedDate = dateFormatter.string(from: timePicker.date)
            for (day, _) in times{
                times[day] = timePicker.date
            }
            for (_, label) in labels{
                label.text = formattedDate
            }
        }
    }
    
    //function that is called when the user selects a day button
    @IBAction func dayButtonPressed(_ sender: UIButton) {
        selectedDay = sender
        for day in days!{
            day.isSelected = false
            labels[day.titleLabel!.text!]?.textColor = labelColor
            dayLabels[day.titleLabel!.text!]?.textColor = labelColor
        }
        sender.isSelected = true
        sender.setTitleColor(.label, for: .selected)
        
        labels[sender.titleLabel!.text!]?.textColor = tintColor
        if weekdayLabels != nil{
            dayLabels[sender.titleLabel!.text!]?.textColor = tintColor
        }
    }
    
    //function that is called when the user edits a timePicker
    @IBAction func timePickerChanged(_ sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        let formattedDate = dateFormatter.string(from: timePicker.date)
        if differentTimes {
            if let day = selectedDay{
                times[day.titleLabel!.text!] = timePicker.date
            }
            labels[selectedDay!.titleLabel!.text!]!.text = formattedDate
        }else{
            for (_, label) in labels{
                label.text = formattedDate
            }
            
            for (day, _) in times{
                times[day] = timePicker.date
            }
        }
        
    }
    
    //selects Sunday
    func selectSunday(){
        for day in days!{ //select sunday at start
//            day.setTitleColor(.label, for: .selected)
            if day.titleLabel?.text == "Sun"{
                labels["Sun"]!.textColor = tintColor
                dayLabels["Sun"]!.textColor = tintColor
                day.setTitleColor(.label, for: .selected)
                day.isSelected = true
                selectedDay = day
                break
            }
        }
    }
    
    //function called when the user is finished and wants to move on
    @IBAction func nextPressed(_ sender: UIButton) {
        storeData()
        defaults.set(true, forKey: "didFinishIntro")
        performSegue(withIdentifier: "toMain", sender: self)
    }
    
    //function that stores the data in UserDefaults
    func storeData(){
        defaults.set([times["Sun"]], forKey: "sunWakeUp")
        defaults.set([times["Mon"]], forKey: "monWakeUp")
        defaults.set([times["Tue"]], forKey: "tueWakeUp")
        defaults.set([times["Wed"]], forKey: "wedWakeUp")
        defaults.set([times["Thu"]], forKey: "thuWakeUp")
        defaults.set([times["Fri"]], forKey: "friWakeUp")
        defaults.set([times["Sat"]], forKey: "satWakeUp")
    }
}
