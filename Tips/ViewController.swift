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
    
    private var splitViews: [UIView]!
    private var kbHeight: CGFloat!
    private var center: CGFloat!
    
    private var editActive: Bool = false
    private var currentString = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Capture keyboard events
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        
        // Set field delegate
        billField.delegate = self
        
        // Set initial values for text fields
        tipLabel.text = "+$0.00"
        totalLabel.text = "$0.00"
        totalSplit2Label.text = "$0.00"
        totalSplit3Label.text = "$0.00"
        totalSplit4Label.text = "$0.00"
        billField.text = "$0.00"
        
        // Set initial style for labels
        totalSplit2View.alpha = 0
        totalSplit3View.alpha = 0
        totalSplit4View.alpha = 0
        tipAmount.alpha = 0
        
        // Store views
        splitViews = [totalSplit2View, totalSplit3View, totalSplit4View]
        
        // Set-up gesture recognizers
        let tapRecognizer = UITapGestureRecognizer(target: self, action: "startEditing")
        tapRecognizer.numberOfTapsRequired = 1
        tapRecognizer.numberOfTouchesRequired = 1
        containerView.addGestureRecognizer(tapRecognizer)
        
        let panRecognizer = UIPanGestureRecognizer(target: self, action: "handleDrag:")
        containerView.addGestureRecognizer(panRecognizer)
        // Focus field
        startEditing()
    }
    
    func startEditing() {
        billField.becomeFirstResponder()
        self.editActive = true
    }
    
    func handleDrag(pan: UIPanGestureRecognizer) {
        
        let translation = pan.translationInView(pan.view!)
        
        // Calculate distance of swipe relative to size of containerView
        let d: CGFloat = (translation.y / pan.view!.frame.height) * 2.0

        switch pan.state {
        case .Began:
            break
        case .Changed:
            // Update our transition
            if d < 0 && self.editActive == true {
                // Swiping out
                if (d < -1.5) {
                    endEditing() // Force complete at 150%
                } else {
                    transitionToEditMode(d, reverse: true)
                }
            } else if d > 0 && self.editActive == false {
                // Swiping in
                if d > 1.5 {
                    startEditing() // Force complete at 150%
                } else {
                    transitionToEditMode(d, reverse: false)
                }
            }
            break
        default:
            // Finish our transition
            if (d > 0.5) {
                startEditing()
            } else {
                endEditing()
            }
            break
        }
    }
    
    func transitionToEditMode(percentage: CGFloat, reverse: Bool) {
        var p = percentage
        
        if reverse == true {
            p = p * -1
        }
        
        var h:CGFloat = 0.0
        var s:CGFloat = 0.0
        var b:CGFloat = 0.0
        var a:CGFloat = 0.0
        
        let startColor = UIColor.groupTableViewBackgroundColor()
        startColor.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        
        
        let s2 = reverse ? s * p : s - (s * p)
        let b2 = reverse ? (b-1) * p + 1 : ((1-b) * p) + b
        
        let editPos = (self.center - (self.containerView.frame.height / 2))
        
        let currentPos = reverse ? (0-editPos) * p + editPos : editPos * p
        
        containerView.transform = CGAffineTransformMakeTranslation(0, currentPos)
        containerView.backgroundColor = UIColor(hue: h, saturation: s2, brightness: b2, alpha: 1.0)
        
        let currentAlpha = reverse ? p : 1 - p
        
        tipAmount.alpha = currentAlpha
        
        for view in splitViews {
            view.alpha = currentAlpha
        }
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
                self.center = (viewHeight - keyboardHeight)/2
                self.containerView.transform = CGAffineTransformMakeTranslation(0, self.center-(containerHeight/2))
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
        endEditing()
    }
    
    func endEditing() {
        view.endEditing(true)
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
        self.editActive = false
    }
    
    @IBAction func onTap(sender: AnyObject) {
        endEditing()
    }
}

