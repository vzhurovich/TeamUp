//
//  PrefferedSubView.swift
//  TeamUp
//
//  Created by Vladimir on 8/22/18.
//  Copyright © 2018 LULUZ Talent. All rights reserved.
//

import UIKit

class PrefferedSubView: UIView , UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var pickerView: UIPickerView!
    
    @IBOutlet weak var okButton: UIButton!
    
    @IBOutlet weak var pickerViewHeightConstraint: NSLayoutConstraint!
    
    var onSelectCompletion: ((LivePlayerView,String) -> ())?
    private var arraySubs = ["FirstFamily3456","Petrov","Ivanov","⚽️"]
    private var touchedLivePlayerView:LivePlayerView?
    
    private var lastSelection = -1
    
    init() {
        super.init(frame: CGRect.zero)
        fromNib()
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fromNib()
        setup()
    }
    
    public func setTouchedLivePlayerView(_ touchedLivePlayerView: LivePlayerView, prefferedSubs: [String]) {
        self.touchedLivePlayerView = touchedLivePlayerView
        arraySubs = prefferedSubs //touchedLivePlayerView.livePlayer.prefferedSubs
        arraySubs.append("⚽️")
        lastSelection = arraySubs.count > 2 ? 1 : 0
        pickerView.selectRow(lastSelection, inComponent: 0, animated: false)
        
        let heightOffset: CGFloat = arraySubs.count > 2 ? 0 : 30
        self.pickerViewHeightConstraint.constant = 120 - heightOffset
        self.frame = CGRect(x: self.frame.origin.x , y: self.frame.origin.y, width: self.frame.size.width, height: 150 - heightOffset)
        pickerView.reloadAllComponents()
    }
    
    @IBAction func
        okButtonPressed(_ sender: Any) {
        let selection = lastSelection > -1 ? arraySubs[lastSelection] : "None"
        onSelectCompletion?(touchedLivePlayerView!,selection)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return arraySubs.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return arraySubs[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        lastSelection = row
//        onSelectCompletion?(touchedLivePlayerView!,arraySubs[row])
        print("Selected: \(arraySubs[row])")
    }
    
    private func setup() {
        self.layer.cornerRadius = 5.0
        self.layer.masksToBounds = true
    }
}
