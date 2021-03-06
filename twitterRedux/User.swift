//
//  User.swift
//  twitterRedux


import UIKit

var _currentUser: User?
let currentUserKey = "kCurrentUserKey"
let userDidLoginNotification = "userDidLoginNotifcation"
let userDidLogoutNotification = "userDidLogoutNotifcation"


class User: NSObject {
    var name: String!
    var screenName: String!
    var profileImageURL: NSURL!
    var bannerImageUrl: NSURL!
    var tagline: String!
    var followersCount: Int!
    var friendsCount: Int!
    var tweetsCount: Int!
    var dictionary: NSDictionary!
    
    init(dictionary: NSDictionary) {
        self.dictionary = dictionary
        
        self.name = dictionary["name"] as! String
        self.screenName = dictionary["screen_name"] as! String
        var profileImageURL = (dictionary["profile_image_url"] as! String).stringByReplacingOccurrencesOfString("normal", withString: "bigger", options: NSStringCompareOptions.LiteralSearch, range: nil)
        self.profileImageURL = NSURL(string: dictionary["profile_image_url"] as! String)
        
        self.tagline = dictionary["description"] as? String
        self.followersCount = dictionary["followers_count"] as! Int
        self.friendsCount = dictionary["friends_count"] as! Int
        self.tweetsCount = dictionary["statuses_count"] as! Int
    }
    
    func logout() {
        User.currentUser = nil
        TwitterClient.sharedInstance.requestSerializer.removeAccessToken()
        NSNotificationCenter.defaultCenter().postNotificationName(userDidLogoutNotification, object: nil)
    }
    
    class var currentUser: User? {
        get {
        if _currentUser == nil {
        let data = NSUserDefaults.standardUserDefaults().objectForKey(currentUserKey) as? NSData
        if data != nil {
        let dictionary = (try! NSJSONSerialization.JSONObjectWithData(data!, options: [])) as! NSDictionary
        _currentUser = User(dictionary: dictionary)
        
        }
        }
        return _currentUser
        }
        set(user) {
            _currentUser = user
            
            if _currentUser != nil {
                let data = try? NSJSONSerialization.dataWithJSONObject(user!.dictionary, options: [])
                NSUserDefaults.standardUserDefaults().setObject(data, forKey: currentUserKey)
            } else {
                NSUserDefaults.standardUserDefaults().setObject(nil, forKey: currentUserKey)
            }
            NSUserDefaults.standardUserDefaults().synchronize()
            
        }
    }
    
    class func loginWithCompletion(completion: () -> Void) {
        TwitterClient.sharedInstance.loginWithCompletion { (user, error) -> () in
            if (user != nil) {
               // println("my login worked")
                NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: userDidLoginNotification, object: nil))
                completion()
            } else {
                print("error logging in")
            }
        }
    }
    
    class func isLoggedIn() -> Bool {
        return (currentUser != nil)
    }
}
