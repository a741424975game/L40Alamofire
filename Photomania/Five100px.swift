//
//  Five100px.swift
//  Photomania
//
//  Created by Essan Parto on 2014-09-25.
//  Copyright (c) 2014 Essan Parto. All rights reserved.
//

import UIKit
import Alamofire

//自定义Serialization
extension Request {
    
    /**
     创建一个 image serializer
     */
    public static func ImageResponseSerializer()
        -> ResponseSerializer<UIImage, NSError>
    {
        return ResponseSerializer { _, response, data, error in
            guard error == nil else { return .Failure(error!) }
            
            if let response = response where response.statusCode == 204 { return .Success(UIImage()) }
            
            guard let validData = data where validData.length > 0 else {
                let failureReason = "Data could not be serialized. Input data was nil or zero length."
                let error = Error.errorWithCode(.DataSerializationFailed, failureReason: failureReason)
                return .Failure(error)
            }
            
            if let image = UIImage(data: data!) {
                return .Success(image)
            } else {
                return .Failure(error! as NSError)
            }
            
        }
    }
    
    /**
     处理 image 闭包
     */
    public func responseImage(
        queue queue: dispatch_queue_t? = nil,
              completionHandler: Response<UIImage, NSError> -> Void)
        -> Self
    {
        return response(
            queue: queue,
            responseSerializer: Request.ImageResponseSerializer(),
            completionHandler: completionHandler
        )
    }
}



struct Five100px {
  enum ImageSize: Int {
    case Tiny = 1
    case Small = 2
    case Medium = 3
    case Large = 4
    case XLarge = 5
  }
    

    

        //组合url枚举类型
    enum Router: URLRequestConvertible {
        static let baseURLString = "https://api.500px.com/v1"
        static let consumerKey = "c3EQxcUE9TnWtfXZ0sUru81OJtHmJBf0yAe8ups5"
        
        case Photo(Int,ImageSize)
        case Popular(Int)
        
            var URLRequest: NSMutableURLRequest { 
            
            let str:(path:String, paramenters: [String: AnyObject] ) = {
                switch self {
                case .Photo(let id, let imageSize):
                    let params = [
                        "consumer_key":Router.consumerKey,
                        "image_size":"\(imageSize.rawValue)",
                    ]
                    return ("/photos/\(id)",params)
                case .Popular(let page):
                    let params = [
                        "consumer_key":Router.consumerKey,
                        "page":"\(page)",
                    ]
                    return ("/photos",params)
                }
            }()
            
            
            let url = NSURL(string: Router.baseURLString)!
            let request = NSURLRequest(URL: url.URLByAppendingPathComponent(str.path))
            
            return Alamofire.ParameterEncoding.URL.encode(request, parameters: str.paramenters).0
            
        }
        
    }
    
    
  enum Category: Int, CustomStringConvertible {
    case Uncategorized = 0, Celebrities, Film, Journalism, Nude, BlackAndWhite, StillLife, People, Landscapes, CityAndArchitecture, Abstract, Animals, Macro, Travel, Fashion, Commercial, Concert, Sport, Nature, PerformingArts, Family, Street, Underwater, Food, FineArt, Wedding, Transportation, UrbanExploration
    
    var description: String {
      get {
        switch self {
        case .Uncategorized: return "Uncategorized"
        case .Celebrities: return "Celebrities"
        case .Film: return "Film"
        case .Journalism: return "Journalism"
        case .Nude: return "Nude"
        case .BlackAndWhite: return "Black And White"
        case .StillLife: return "Still Life"
        case .People: return "People"
        case .Landscapes: return "Landscapes"
        case .CityAndArchitecture: return "City And Architecture"
        case .Abstract: return "Abstract"
        case .Animals: return "Animals"
        case .Macro: return "Macro"
        case .Travel: return "Travel"
        case .Fashion: return "Fashion"
        case .Commercial: return "Commercial"
        case .Concert: return "Concert"
        case .Sport: return "Sport"
        case .Nature: return "Nature"
        case .PerformingArts: return "Performing Arts"
        case .Family: return "Family"
        case .Street: return "Street"
        case .Underwater: return "Underwater"
        case .Food: return "Food"
        case .FineArt: return "Fine Art"
        case .Wedding: return "Wedding"
        case .Transportation: return "Transportation"
        case .UrbanExploration: return "Urban Exploration"
        }
      }
    }
  }
}

class PhotoInfo: NSObject {
  let id: Int
  let url: String
  
  var name: String?
  
  var favoritesCount: Int?
  var votesCount: Int?
  var commentsCount: Int?
  
  var highest: Float?
  var pulse: Float?
  var views: Int?
  var camera: String?
  var focalLength: String?
  var shutterSpeed: String?
  var aperture: String?
  var iso: String?
  var category: Five100px.Category?
  var taken: String?
  var uploaded: String?
  var desc: String?
  
  var username: String?
  var fullname: String?
  var userPictureURL: String?
  
    init(id: Int, url: String) {
        self.id = id
        self.url = url
    }
    
    required init(photo: NSDictionary) {
        self.id = photo.valueForKey("id") as! Int
        self.url = photo.valueForKey("image_url") as! String
        
        self.name = photo.valueForKey("name") as? String
        
        self.favoritesCount = photo.valueForKey("favorites_Count") as? Int
        self.votesCount = photo.valueForKey("votes_count") as? Int
        self.commentsCount = photo.valueForKey("comments_count") as? Int
        
        self.highest = photo.valueForKey("highest_rating") as? Float
        self.pulse = photo.valueForKey("rating") as? Float
        self.views = photo.valueForKey("times_viewed") as? Int
        self.camera = photo.valueForKey("camera") as? String
        self.focalLength = photo.valueForKey("focal_length") as? String
        self.shutterSpeed = photo.valueForKey("shutter_speed") as? String
        self.aperture = photo.valueForKey("aperture") as? String
        self.iso = photo.valueForKey("iso") as? String
        self.category = photo.valueForKey("category") as? Five100px.Category
        self.taken = photo.valueForKey("taken_at") as? String
        uploaded = photo.valueForKey("created_at") as? String
        self.desc = photo.valueForKey("description") as? String
        
        self.username = photo.valueForKey("user")?.valueForKey("username") as? String
        self.fullname = photo.valueForKey("user")?.valueForKey("fullname") as? String
        self.userPictureURL = photo.valueForKey("user")?.valueForKey("https://pacdn.500px.org/118456/d01fb5d601955e87f7ab61c01acd1b12c8e0581a/1.jpg?13") as? String
        
    }
    
  required init(
    id: Int,
    url: String,
    name: String?,
    
    favoritesCount: Int?,
    votesCount: Int?,
    commentsCount: Int?,
    
    highest: Float?,
    pulse: Float?,
    views: Int?,
    camera: String?,
    focalLength: String?,
    shutterSpeed: String?,
    aperture: String?,
    iso: String?,
    category: Five100px.Category?,
    taken: String?,
    uploaded: String?,
    desc: String?,
    
    username: String?,
    fullname: String?,
    userPictureURL: String?
    ) {
    self.id = id
    self.url = url
    
    self.favoritesCount = favoritesCount
    self.votesCount = votesCount
    self.commentsCount = commentsCount
    self.highest = highest
    self.pulse = pulse
    self.views = views
    self.camera = camera
    self.focalLength = focalLength
    self.shutterSpeed = shutterSpeed
    self.aperture = aperture
    self.iso = iso
    self.taken = taken
    self.uploaded = uploaded
    self.desc = desc
    self.name = name
    
    self.username = username
    self.fullname = fullname
    self.userPictureURL = userPictureURL
    
  }
  
  required init(response: NSHTTPURLResponse, representation: AnyObject) {
    self.id = representation.valueForKeyPath("photo.id") as! Int
    self.url = representation.valueForKeyPath("photo.image_url") as! String
    
    self.favoritesCount = representation.valueForKeyPath("photo.favorites_count") as? Int
    self.votesCount = representation.valueForKeyPath("photo.votes_count") as? Int
    self.commentsCount = representation.valueForKeyPath("photo.comments_count") as? Int
    self.highest = representation.valueForKeyPath("photo.highest_rating") as? Float
    self.pulse = representation.valueForKeyPath("photo.rating") as? Float
    self.views = representation.valueForKeyPath("photo.times_viewed") as? Int
    self.camera = representation.valueForKeyPath("photo.camera") as? String
    self.focalLength = representation.valueForKeyPath("photo.focal_length") as? String
    self.shutterSpeed = representation.valueForKeyPath("photo.shutter_speed") as? String
    self.aperture = representation.valueForKeyPath("photo.aperture") as? String
    self.iso = representation.valueForKeyPath("photo.iso") as? String
    self.taken = representation.valueForKeyPath("photo.taken_at") as? String
    self.uploaded = representation.valueForKeyPath("photo.created_at") as? String
    self.desc = representation.valueForKeyPath("photo.description") as? String
    self.name = representation.valueForKeyPath("photo.name") as? String
    
    self.username = representation.valueForKeyPath("photo.user.username") as? String
    self.fullname = representation.valueForKeyPath("photo.user.fullname") as? String
    self.userPictureURL = representation.valueForKeyPath("photo.user.userpic_url") as? String
  }
  
  override func isEqual(object: AnyObject!) -> Bool {
    return (object as! PhotoInfo).id == self.id
  }
  
  override var hash: Int {
    return (self as PhotoInfo).id
  }
}

class Comment {
  let userFullname: String
  let userPictureURL: String
  let commentBody: String
  
  init(JSON: AnyObject) {
    userFullname = JSON.valueForKeyPath("user.fullname") as! String
    userPictureURL = JSON.valueForKeyPath("user.userpic_url") as! String
    commentBody = JSON.valueForKeyPath("body") as! String
  }
}