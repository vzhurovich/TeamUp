//
//  PopUpViewController.swift
//  TeamUp
//
//  Created by Vladimir on 8/22/18.
//  Copyright © 2018 LULUZ Talent. All rights reserved.
//

import UIKit

class PopUpViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    
    @IBOutlet weak var pickerView: UIPickerView!
    let arrayVals = ["Goldenberg","Petrov","Ivanov"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.view.frame = CGRect(x: 20, y: 20, width: 150, height: 150)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: UIPickerView Delegate
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return arrayVals.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return arrayVals[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print("Selected: \(arrayVals[row])")
        print("Bounds: \(self.view.bounds)")
        
    }
    
}

