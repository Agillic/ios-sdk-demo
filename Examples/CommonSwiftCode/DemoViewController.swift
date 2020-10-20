//
//  ViewController.swift
//  SnowplowSwiftDemo
//
//  Created by Michael Hadam on 1/17/18.
//  Copyright © 2018 snowplowanalytics. All rights reserved.
//

import UIKit
import Foundation
import CoreData
import AgillicSDK

// Used for all child views
protocol PageObserver: class {
    func getParentPageViewController(parentRef: PageViewController)
}

class DemoViewController: UIViewController, UITextFieldDelegate, PageObserver, UIPickerViewDelegate, UIPickerViewDataSource {
    private let keyRecipientField = "recipientEmail";

    @IBOutlet weak var recipientField: UITextField!
    @IBOutlet weak var trackingSwitch: UISegmentedControl!
    @IBOutlet weak var protocolSwitch: UISegmentedControl!
    @IBOutlet weak var methodSwitch: UISegmentedControl!
    @IBOutlet weak var pickerView : UIPickerView!;
    @IBOutlet weak var statusField : UILabel!;
    weak var tracker : AgillicTracker?
    var uuid : UUID = UUID.init();

    var parentPageViewController: PageViewController!
    @objc dynamic var snowplowId: String! = "demo view"

    func getParentPageViewController(parentRef: PageViewController) {
        parentPageViewController = parentRef
        tracker = parentRef.tracker
    }
    
    @objc func action() {
        
        let tracking: Bool = (trackingSwitch.selectedSegmentIndex == 0)
        if (tracking && !(tracker?.isTracking() ?? false)) {
            tracker?.resumeTracking()
        } else if (tracker?.isTracking() ?? false) {
            tracker?.pauseTracking()
        }
    }
    
    @objc func updateStatus(_ notification: NSNotification) {
        if let status = notification.userInfo?["status"] as? String? {
            DispatchQueue.main.async { [unowned self] in
                    self.statusField.text = status;
                Toast.show(message: status!, controller: self);
                }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.recipientField.delegate = self
        let mainQueue = OperationQueue.main
        //self.trackingSwitch.addTarget(self, action: #selector(action), for: .valueChanged)
        // Do any additional setup after loading the view, typically from a nib.
        recipientField.text = UserDefaults.standard.string(forKey: keyRecipientField) ?? ""
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateStatus(_:)), name: NSNotification.Name(rawValue: "registration"), object: nil)
        // NotificationCenter.default.addObserver(self, selector: #selector(self.updateStatus(_:)), name: NSNotification.Name(rawValue: "registration"), object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func inputUri(_ sender: UITextField) {
        //self.parentPageViewController.userId = recipientField.text!
    }
    
    @IBAction func toggleMethod(_ sender: UISegmentedControl) {
        self.parentPageViewController.methodType = (methodSwitch.selectedSegmentIndex == 0) ?
            .get : .post
    }
    
    @IBAction func toggleProtocol(_ sender: UISegmentedControl) {
        self.parentPageViewController.protocolType = (protocolSwitch.selectedSegmentIndex == 0) ?
            .http: .https
    }
    
    @IBAction func loginAndRegister(_ sender: UIButton) {
        UserDefaults.standard.set(recipientField.text ?? "", forKey: keyRecipientField);
        let selected = pickerView.selectedRow(inComponent: 0)
        let login = self.recipientField.text
        DispatchQueue.global(qos: .default).async {
            self.parentPageViewController.setup(login: login, selected: selected)
            
            let event = AppViewEvent(self.uuid.uuidString, screenName: "ios_protocol://iosapp/demo/1")
            self.parentPageViewController.tracker?.track(event)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        let event = AppViewEvent(uuid.uuidString, screenName: "ios_protocol://iosapp/demo/1")
        parentPageViewController.tracker?.track(event)
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return parentPageViewController.keys[row].name;
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return parentPageViewController.keys.count
    }
    




}
