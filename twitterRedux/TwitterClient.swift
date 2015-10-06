//
//  TwitterClient.swift
//  twitterRedux


import UIKit

let twitterConsumerKey = "TP4E0Tmbi1ePMEU4LQG9eFONT"
let twitterConsumerSecretKey = "GUeDL3UFAxTxPrbbBu3BxLqn6dYzkRsQD3swSU7bfzdyRRdFUv"
let twitterBaseURL = NSURL(string: "https://api.twitter.com")

//This class is to define a singleton.  Since Swift doesn't support class
// properties, it will support a computed property.  Nested Structs can have
// stored properties, so see below.  This shared instance is a type TwitterClient which returns a static instance.


class TwitterClient: BDBOAuth1RequestOperationManager {
    
    var loginCompletion: ((user: User?, error: NSError?) -> ())?
    
    class var sharedInstance: TwitterClient {
    struct Static {
        static let instance = TwitterClient(baseURL: twitterBaseURL, consumerKey: twitterConsumerKey, consumerSecret: twitterConsumerSecretKey)
        }
        
        return Static.instance
    }
    
    
    func loginWithCompletion(completion: (user: User?, error: NSError?) -> ()) {
        loginCompletion = completion
        
        //Fetch request token & redirect to authorization page
        TwitterClient.sharedInstance.requestSerializer.removeAccessToken()
        TwitterClient.sharedInstance.fetchRequestTokenWithPath("oauth/request_token", method: "GET", callbackURL: NSURL(string: "cptwitterredux2://oauth"), scope: nil, success: { (requestToken:BDBOAuthToken!) -> Void in
            //println("Got the request token from loginWithCompletion")
            let authURL = NSURL(string: "https://api.twitter.com/oauth/authorize?oauth_token=\(requestToken.token)")
            UIApplication.sharedApplication().openURL(authURL!)
            }) { (error: NSError!) -> Void in
                print("Failed to get the request token")
                self.loginCompletion?(user: nil, error: error)
        }
    }
    
    func postTweetWithCompletion(tweet: String, replyId: Int?, completion: (tweet: Tweet?, error: NSError?) -> Void) {
        var params = ["status": tweet]
        if (replyId != nil) {
            params.updateValue("\(replyId!)", forKey: "in_reply_to_status_id")
        }
        self.POST("/1.1/statuses/update.json", parameters: params, success: { (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
            let tweet = Tweet(dictionary: response as! NSDictionary)
            completion(tweet: tweet, error: nil)
            
            }) { (operation:AFHTTPRequestOperation!, error: NSError!) -> Void in
                print(error)
                completion(tweet: nil, error: error)
        }
    }
    
    func openURL(url: NSURL) {
        fetchAccessTokenWithPath("oauth/access_token", method: "POST", requestToken: BDBOAuthToken(queryString: url.query), success: { (accessToken: BDBOAuthToken!) -> Void in
            print("Got the access token!")
            TwitterClient.sharedInstance.requestSerializer.saveAccessToken(accessToken)
            
            //call to get current user
            TwitterClient.sharedInstance.GET("1.1/account/verify_credentials.json", parameters: nil, success: { (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
                //println("user: \(response)")
                let user = User(dictionary: response as! NSDictionary)
                User.currentUser = user  // set our current user
                //println("user: \(user.name)")
                self.loginCompletion?(user: user, error: nil)
                }, failure: { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                    print("Error getting current user")
                    self.loginCompletion?(user: nil, error: error)
            })
            }) { (error: NSError!) -> Void in
                print("Failed to receive the access token")
                self.loginCompletion?(user: nil, error: error)
        }
    }
    
    func homeTimelineWithParams(params: NSDictionary?, completion: (tweets: [Tweet]?, error: NSError?) -> ()) {
        //call to get home timeline
        GET("1.1/statuses/home_timeline.json", parameters: params, success:  { (operations: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
            //println("home timeline \(response)")
            let tweets = Tweet.tweetsWithArray(response as! [NSDictionary])
            completion(tweets: tweets, error: nil)
            
            // for tweet in tweets {
            //     println("text: \(tweet.text), created: \(tweet.createdAt)")
            // }
            }, failure: { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                print("Error getting home timeline")
                completion(tweets: nil, error: error)
        })
        
    }
   
}
