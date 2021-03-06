//
//  ContainerViewController.swift
//  twitterRedux


import UIKit

class ContainerViewController: UIViewController, PanelDelegate, UIGestureRecognizerDelegate {
    var leftViewController: SidePanelViewController!
    var loginController: LoginViewController!
    var profileController: UINavigationController!
    var centerViewController: UINavigationController!
    
    @IBOutlet weak var panGesture: UIView!
    @IBOutlet weak var sideView: UIView!
    @IBOutlet weak var contentView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // use NotificationCenter to catch my login/logout actions
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "userDidLogin", name: userDidLoginNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "userDidLogout", name: userDidLogoutNotification, object: nil)

        // first set up left panel
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        self.leftViewController = storyboard.instantiateViewControllerWithIdentifier("SidePanelViewController") as! SidePanelViewController
        addChildViewController(self.leftViewController)
        self.sideView.addSubview(self.leftViewController.view)
        self.leftViewController.view.frame = self.view.frame
        self.leftViewController.didMoveToParentViewController(self)
        self.leftViewController.panelDelegate = self
        
        // What my Center VC is depends upon whether I'm logged in or not.  Note that I instantiate the Tweets Nav Controller if logged in, since TweetsVC is embedded in that NC.
        if (User.currentUser != nil) {
            self.centerViewController = storyboard.instantiateViewControllerWithIdentifier("TweetsNavigationViewController") as! UINavigationController
            self.addChildViewController(self.centerViewController)
            self.contentView.addSubview(self.centerViewController.view)
            self.centerViewController.view.frame = self.view.frame
            self.centerViewController.didMoveToParentViewController(self)
            setColorScheme()
            
            
        } else {
            self.loginController = storyboard.instantiateViewControllerWithIdentifier("LoginViewController") as! LoginViewController
            addChildViewController(self.loginController)
            self.contentView.addSubview(self.loginController.view)
            self.loginController.view.frame = self.view.frame
            self.loginController.didMoveToParentViewController(self)
            
        }
        // I have two views on my container VC.  Bring the right one to the front.
        self.view.bringSubviewToFront(self.contentView)
    
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func setTimelineInCenterViewController() {
        if (self.centerViewController == nil) {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            self.centerViewController = storyboard.instantiateViewControllerWithIdentifier("TweetsNavigationViewController") as! UINavigationController
 
            self.addChildViewController(self.centerViewController)
        }
            self.contentView.addSubview(self.centerViewController.view)
            self.centerViewController.view.frame = self.view.frame
            self.centerViewController.didMoveToParentViewController(self)
    }
    
    
    func showMyTimeline() {
        setTimelineInCenterViewController()
        slideContentView()
        }
        
    func showMyProfile() {
        if (self.profileController == nil) {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            self.profileController = storyboard.instantiateViewControllerWithIdentifier("ProfileNavigationController") as! UINavigationController
            self.addChildViewController(self.profileController)
        }
        self.contentView.addSubview(self.profileController.view)
        self.profileController.view.frame = self.view.frame
        self.profileController.didMoveToParentViewController(self)
        
        slideContentView()
        
    }
    
    func setColorScheme() {
        
        //set my colors
        //next three lines are how to set text color for buttons AND text color for title of all nav bars for all controllers.
        let navigationBarAppearance = UINavigationBar.appearance()
        navigationBarAppearance.tintColor = UIColor.whiteColor()   // how you set text color for nav bar button items.
        navigationBarAppearance.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.whiteColor()] //set's color for title
        
        return
        
    }
    
    func userDidLogin() {
        // load content on side panel
        self.leftViewController.initProfileView()
        
        setColorScheme()
        
        if (self.centerViewController == nil) {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            self.centerViewController = storyboard.instantiateViewControllerWithIdentifier("TweetsNavigationViewController") as! UINavigationController
            self.addChildViewController(self.centerViewController)
        }
        
        self.contentView.addSubview(self.centerViewController.view)
        self.centerViewController.view.frame = self.view.frame
        self.centerViewController.didMoveToParentViewController(self)
    }
    
    func userDidLogout() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        self.loginController = storyboard.instantiateViewControllerWithIdentifier("LoginViewController") as! LoginViewController
        addChildViewController(self.loginController)
        self.contentView.addSubview(self.loginController.view)
        self.loginController.view.frame = self.view.frame
        self.loginController.didMoveToParentViewController(self)
    }
    
 
    @IBAction func onPanGesture(sender: UIPanGestureRecognizer) {
        if (User.isLoggedIn()) {
            let location = sender.locationInView(self.view)
            
            if (sender.state == UIGestureRecognizerState.Began || sender.state == UIGestureRecognizerState.Changed) {
                let quarter = self.view.frame.width / 4
                if (location.x <= (quarter * 3)) {
                    self.contentView.frame.origin.x = location.x
                }
            } else if (sender.state == UIGestureRecognizerState.Ended) {
                let center = self.view.center
                if (location.x < center.x) {
                    self.slideContentView()
                } else {
                    let quarter = self.view.frame.width / 4
                    UIView.animateWithDuration(0.5, animations: { () -> Void in
                        self.contentView.frame.origin.x = (quarter * 3)
                    })
                }
            }
        }
    }

    func slideContentView() {
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.contentView.frame.origin.x = 0;
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

