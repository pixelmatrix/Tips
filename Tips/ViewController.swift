//
//  ViewController.swift
//  Tips
//
//  Created by Josh Pyles on 2/17/15.
//  Copyright (c) 2015 Josh Pyles. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var billField: UITextField!
    @IBOutlet weak var tipAmount: UISegmentedControl!
    
    @IBOutlet weak var tipLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    
    @IBOutlet weak var totalSplit2Label: UILabel!
    @IBOutlet weak var totalSplit3Label: UILabel!
    @IBOutlet weak var totalSplit4Label: UILabel!
    
    @IBOutlet weak var totalSplit2View: UIView!
    @IBOutlet weak var totalSplit3View: UIView!
    @IBOutlet weak var totalSplit4View: UIView!
    
    private var splitViews: NSArray!
    private var kbHeight: CGFloat!
    
    private var currentString = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        
        billField.delegate = self
        
        tipLabel.text = "+$0.00"
        totalLabel.text = "$0.00"
        totalSplit2Label.text = "$0.00"
        totalSplit3Label.text = "$0.00"
        totalSplit4Label.text = "$0.00"
        billField.text = "$0.00"
        
        totalSplit2View.alpha = 0
        totalSplit3View.alpha = 0
        totalSplit4View.alpha = 0
        tipAmount.alpha = 0
        
        splitViews = [totalSplit2View, totalSplit3View, totalSplit4View]
        
        // Focus field
        billField.becomeFirstResponder()
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        switch string {
        case "0","1","2","3","4","5","6","7","8","9":
            currentString += string
            formatCurrency(string: currentString)
        default:
            var array = Array(string)
            var currentStringArray = Array(currentString)
            if array.count == 0 && currentStringArray.count != 0 {
                currentStringArray.removeLast()
                currentString = ""
                for character in currentStringArray {
                    currentString += String(character)
                }
                formatCurrency(string: currentString)
            }
        }
        return false
    }
    
    func formatCurrency(#string: String) {
        
        let formatter = NSNumberFormatter()
        formatter.numberStyle = NSNumberFormatterStyle.CurrencyStyle
        formatter.locale = NSLocale(localeIdentifier: "en_US")
        
        var numberFromField = (NSString(string: string).doubleValue)/100
        billField.text = formatter.stringFromNumber(numberFromField)
        updateTotals()
    }
    
    func updateTotals() {
        
        let formatter = NSNumberFormatter()
        formatter.numberStyle = NSNumberFormatterStyle.CurrencyStyle
        formatter.locale = NSLocale(localeIdentifier: "en_US")
        
        let billAmount = formatter.numberFromString(billField.text)!.doubleValue
        
        var tipPercentages = [0.18, 0.2, 0.22]
        
        var tipPercentage = tipPercentages[tipAmount.selectedSegmentIndex]
        var tip = billAmount * tipPercentage
        var total = billAmount + tip
        
        var split2Amount = total / 2
        var split3Amount = total / 3
        var split4Amount = total / 4
        
        tipLabel.text = String(format: "+$%.2f", tip)
        totalLabel.text = String(format: "$%.2f", total)
        
        totalSplit2Label.text = String(format: "$%.2f", split2Amount)
        totalSplit3Label.text = String(format: "$%.2f", split3Amount)
        totalSplit4Label.text = String(format: "$%.2f", split4Amount)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func keyboardWillShow(sender: NSNotification) {
        
        let viewHeight = self.view.frame.height
        let containerHeight = containerView.frame.height
        
        if let userInfo = sender.userInfo {
            if let keyboardHeight = userInfo[UIKeyboardFrameEndUserInfoKey]?.CGRectValue().size.height {
                let center = (viewHeight - keyboardHeight)/2
                self.containerView.transform = CGAffineTransformMakeTranslation(0, center-(containerHeight/2))
            }
        }
    }
    
    func keyboardWillHide(sender: NSNotification) {
        UIView.animateWithDuration(0.4, animations: {
            self.containerView.transform = CGAffineTransformIdentity
        })
    }
    
    @IBAction func onEditingBegan(sender: AnyObject) {
        UIView.animateWithDuration(0.2, animations: {
            self.containerView.backgroundColor = UIColor.whiteColor()
            self.tipAmount.alpha = 0
            self.tipAmount.alpha = 0
            self.totalSplit2View.alpha = 0
            self.totalSplit3View.alpha = 0
            self.totalSplit4View.alpha = 0
        })
    }

    @IBAction func onEditingChanged(sender: AnyObject) {
        updateTotals()
    }

    @IBAction func onEditingEnded(sender: AnyObject) {
        UIView.animateWithDuration(0.3, animations: {
            self.containerView.backgroundColor = UIColor.groupTableViewBackgroundColor()
            self.containerView.transform = CGAffineTransformIdentity
            self.tipAmount.alpha = 1
        })
        
        for (var i=0; i < splitViews.count; i++) {
            
            var delay = (CGFloat(i) * 0.1) + 0.2
            let label = splitViews[i] as UIView
            
            UIView.animateWithDuration(0.3, delay: NSTimeInterval(delay), options: nil, animations: {
                label.alpha = 1
            }, completion: nil)
            
        }
        
        
    }
    
    @IBAction func onTap(sender: AnyObject) {
        view.endEditing(true)
    }
}

