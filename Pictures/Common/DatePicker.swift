//
//  UIView+Extension.swift
//  Pictures
//
//  Created by Sajal Gupta on 21/11/21.
//

import UIKit

internal final class DatePicker: UIDatePicker {
    
    internal typealias PickerDone = (_ selection: String, _ date: Date) -> Void
    private var doneBlock: PickerDone!
    private var datePickerFormat: String = ""
    
    
    private var dateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = self.datePickerFormat
        return dateFormatter
    }
    
    
    internal class func openDatePickerIn(_ textField: UITextField?,
                                outPutFormat: String,
                                mode: UIDatePicker.Mode,
                                minimumDate: Date,
                                maximumDate: Date = Date(),
                                minuteInterval: Int = 1,
                                selectedDate: Date?, doneBlock: @escaping PickerDone) {
        
        let picker = DatePicker()
        picker.doneBlock = doneBlock
        picker.datePickerFormat = outPutFormat
        picker.datePickerMode = mode
        picker.preferredDatePickerStyle = .inline
        picker.dateFormatter.dateFormat = outPutFormat
        
        if let sDate = selectedDate {
            picker.setDate(sDate, animated: false)
        }
        picker.minuteInterval = minuteInterval
        
        if mode == .time {
            let dateFormatte = DateFormatter()
            dateFormatte.dateFormat = "dd MMM yy"
            let today = dateFormatte.string(from: Date())
            let minDay = dateFormatte.string(from: minimumDate)
            let maxDay = dateFormatte.string(from: maximumDate)
            
            picker.minimumDate = today.lowercased() == minDay.lowercased() ? Date() : minimumDate
            picker.maximumDate = today.lowercased() == maxDay.lowercased() ? Date() : maximumDate
        }
        else {
            picker.minimumDate = minimumDate
            picker.maximumDate = maximumDate
        }
        
        picker.openDatePickerInTextField(textField)
    }
    
    private func openDatePickerInTextField(_ textField: UITextField?) {

        if let text = textField?.text, !text.isEmpty, let selDate = self.dateFormatter.date(from: text) {
            self.setDate(selDate, animated: false)
        }

        let cancelButton = UIBarButtonItem(barButtonSystemItem:  UIBarButtonItem.SystemItem.cancel,
                                           target: self,
                                           action: #selector(pickerCancelButtonTapped))
        cancelButton.tintColor = UIColor.black

        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.done,
                                         target: self,
                                         action: #selector(pickerDoneButtonTapped))

        doneButton.tintColor = UIColor.black

        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace,
                                          target: nil,
                                          action:nil)

        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 35))
        let array = [cancelButton, spaceButton, doneButton]
        toolbar.setItems(array, animated: true)
        textField?.inputView = self
        textField?.inputAccessoryView = toolbar
    }
    


    @IBAction private func pickerCancelButtonTapped() {
        UIApplication.shared.keyWindow?.endEditing(true)
    }
    
    @IBAction private func pickerDoneButtonTapped() {
        UIApplication.shared.keyWindow?.endEditing(true)
        let selected = self.dateFormatter.string(from: self.date)
        self.doneBlock(selected,self.date)
    }
}

