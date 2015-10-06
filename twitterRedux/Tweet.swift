//
//  Tweet.swift
//  twitterRedux

import UIKit

class Tweet: NSObject {
    var user: User!
    var text: String!
    var createdAtString: String!
    var createdAt: NSDate!
    var favoritesCount: Int!
    var favorited: Bool!
    var retweetCount: Int!
    var retweeted: Bool!
    
    init(dictionary: NSDictionary) {
        self.user = User(dictionary: dictionary["user"] as! NSDictionary)
        self.text = dictionary["text"] as? String
        self.createdAtString = dictionary["created_at"] as? String
        self.favoritesCount = dictionary["favorite_count"] as? Int
        self.favorited = dictionary["favorited"] as! Bool
        self.retweetCount = dictionary["retweet_count"] as? Int
        self.retweeted = dictionary["retweeted"] as! Bool
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "EEE MMM d HH:mm:ss Z y"
        self.createdAt = formatter.dateFromString(createdAtString!)
        
        formatter.dateFormat = "MMM d hh:mm a"
        self.createdAtString = formatter.stringFromDate(self.createdAt)
    }
    
    class func tweetsWithArray(array: [NSDictionary]) -> [Tweet] {
        var tweets = [Tweet]()
        
        for dictionary in array {
            tweets.append(Tweet(dictionary: dictionary))
        }
        return tweets
    }
}
