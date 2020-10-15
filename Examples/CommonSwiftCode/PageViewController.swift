//
//  PageViewController.swift
//  SnowplowSwiftDemo
//
//  Created by Michael Hadam on 3/4/19.
//  Copyright © 2019 snowplowanalytics. All rights reserved.
//

import UIKit
import SnowplowTracker
import AgillicSDK


class PageViewController:  UIPageViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource, UIPickerViewDelegate {
    var tracker : AgillicTracker?
    var madeCounter : Int = 0
    var sentCounter : Int = 0
    var methodType : SPRequestOptions = .post
    var protocolType : SPProtocol = .https
    var token : String = ""
    @objc dynamic var snowplowId: String! = "iOS/page view"

    let kAppId     = "com.agillic.sdk.demo"
    let kNamespace = "DemoAppNamespace"
    let userId = "dennis.schafroth@agillic.com"
    // Passed down in/after login;
    class SolutionInfo {
        var solutionId : String
        var key : String
        var secret : String
        init(_ id : String, key: String, secret: String) {
            self.solutionId = id;
            self.key = key;
            self.secret = secret;
        }
    }
    var truncintProd = SolutionInfo("15arnn5", key: "F6xRABtMVG9h", secret: "yOdwUJlBB6g9kZoi")
    var keys : [String: SolutionInfo] = [ 
        "agi-trunc-prod" : SolutionInfo("15arnn5", key: "F6xRABtMVG9h", secret: "yOdwUJlBB6g9kZoi"),
        "agi-trunc-stag" : SolutionInfo("16k01cn", key: "VIP4hwIKU1GZ", secret: "gUItpLA0U0PGsvYZ"),
        "agi-truncint-stag" : SolutionInfo("qrcqkw", key: "Z6SOrRon1TCe", secret: "q5i4R1GTVBpqvIYW"),
        "agi-tryit1-stag": SolutionInfo("o9257h", key : "?", secret: "?"),
        "agi-tryit8-stag": SolutionInfo("195b1q", key: "?", secret: "?")
    ]

    let selectedSolution = "agi-truncint-stag";

    func updateToken(_ newToken: String) {
        token = newToken
    }

    func getMethodType() -> SPRequestOptions {
        return self.methodType
    }

    func getProtocolType() -> SPProtocol {
        return self.protocolType
    }
    
    func setup(login : String?) {
        let agillicSDK = MobileSDK()
        let solutionInfo = keys[selectedSolution]
        let solutionId = solutionInfo!.solutionId
        let key : String = solutionInfo!.key
        let secret = solutionInfo!.secret
        agillicSDK.setAuth(BasicAuth(user: key, password: secret))
        tracker = agillicSDK.register(clientAppId: kAppId, clientAppVersion: "1.0", solutionId: solutionId, userID: login != nil ? login! : self.userId , pushNotificationToken: token)
        //Toast.show(message: "Registered device for " + login!, controller: self);
    }

    func newVc(viewController: String) -> UIViewController {
        let newViewController : UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: viewController)
        (newViewController as? PageObserver)?.getParentPageViewController(parentRef: self)
        return newViewController
    }

    lazy var orderedViewControllers: [UIViewController] = {
        return [self.newVc(viewController: "demo"),
                self.newVc(viewController: "metrics"),
                self.newVc(viewController: "additional")]
    }()

    // MARK: Data source functions.
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.firstIndex(of: viewController) else {
            return nil
        }

        let previousIndex = viewControllerIndex - 1

        // User is on the first view controller and swiped left to loop to
        // the last view controller.
        guard previousIndex >= 0 else {
            return orderedViewControllers.last
            // Uncommment the line below, remove the line above if you don't want the page control to loop.
            // return nil
        }

        guard orderedViewControllers.count > previousIndex else {
            return nil
        }

        return orderedViewControllers[previousIndex]
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.firstIndex(of: viewController) else {
            return nil
        }

        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = orderedViewControllers.count

        // User is on the last view controller and swiped right to loop to
        // the first view controller.
        guard orderedViewControllersCount != nextIndex else {
            return orderedViewControllers.first
            // Uncommment the line below, remove the line above if you don't want the page control to loop.
            // return nil
        }

        guard orderedViewControllersCount > nextIndex else {
            return nil
        }

        return orderedViewControllers[nextIndex]
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource = self
        //self.setup()
        // This sets up the first view that will show up on our page control
        if let firstViewController = orderedViewControllers.first {
            setViewControllers([firstViewController],
                               direction: .forward,
                               animated: true,
                               completion: nil)
        }
        // Do any additional setup after loading the view.
    }
    
    func onSuccess(withCount successCount: Int) {
        self.sentCounter += successCount;
    }

    func onFailure(withCount failureCount: Int, successCount: Int) {
        self.sentCounter += successCount;
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return keys.count
    }
    


}
