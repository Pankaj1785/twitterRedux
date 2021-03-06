//
//  TweetsViewController.swift
//  twitterRedux


import UIKit

class TweetsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var tweets = [Tweet]()
    var refreshControl:UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Home"
 
        //set my colors: sets text color for buttons AND text color for title of all nav bars for all controllers.
        let navigationBarAppearance = UINavigationBar.appearance()
        navigationBarAppearance.tintColor = UIColor.whiteColor()   // how you set text color for nav bar button items.
        navigationBarAppearance.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.whiteColor()] //set's color for title
        
        setUpRefreshControl()
        homeTimeLine()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.reloadData()

        // Do any additional setup after loading the view.
    }

    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TweetCell") as! TweetCell
        cell.tweet = self.tweets[indexPath.row]
        
        return cell
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tweets.count
    }
    
    func homeTimeLine() {
        showLoadingProgress()
        self.navigationItem.title = "Updating..."
        TwitterClient.sharedInstance.homeTimelineWithParams(nil, completion: { (tweets, error) -> () in
            if (error == nil) {
                self.tweets = tweets!
                self.tableView.reloadData()
                self.refreshControl.endRefreshing()
                self.tableView.reloadData()
            } else {
                print("error loading tweets")
            }
        })
        // Hide the progress indicator
        MBProgressHUD.hideHUDForView(self.view, animated: true)
        self.navigationItem.title = "Home"
    }
    
    func setUpRefreshControl() {
        // set up pull to refresh
        self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refreshControl)
    }
    
    func refresh(sender: AnyObject) {
        homeTimeLine()
    }
    
    func showLoadingProgress() {
        let loading = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        loading.mode = MBProgressHUDModeDeterminate
        loading.labelText = "Loading...";
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "tweetDetailsSegue") {
            let detailsController = segue.destinationViewController as! TweetDetailViewController
            let cell = sender as! TweetCell
            detailsController.tweet = cell.tweet
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onSignout(sender: AnyObject) {
        User.currentUser?.logout()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func onNewButton(sender: AnyObject) {
         self.performSegueWithIdentifier("newTweetSegue", sender: self)
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
