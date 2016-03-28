//  AppConfig.swift
//  onthemap
//
//  Created by antonio silva on 12/5/15.
//  Copyright © 2015 antonio silva. All rights reserved.
//

import Foundation

//OnTheMap Constants and JSON keys
class Constants:NSObject{

    
    struct Flickr {
        
        
        static let APIScheme = "https"
        static let APIHost = "api.flickr.com"
        static let APIPath = "/services/rest"
        
        static let SearchBBoxHalfWidth = 1.0
        static let SearchBBoxHalfHeight = 1.0
        static let SearchLatRange = (-90.0, 90.0)
        static let SearchLonRange = (-180.0, 180.0)


    }
    // MARK: Flickr Parameter Keys
    struct FlickrParameterKeys {
        static let Method = "method"
        static let APIKey = "api_key"
        static let GalleryID = "gallery_id"
        static let Extras = "extras"
        static let Format = "format"
        static let NoJSONCallback = "nojsoncallback"
        static let SafeSearch = "safe_search"
        static let Text = "text"
        static let BoundingBox = "bbox"
        static let Page = "page"
        static let Per_Page = "per_page"
    }
    
    // MARK: Flickr Parameter Values
    struct FlickrParameterValues {
        static let SearchMethod = "flickr.photos.search"
        static let APIKey = "2e7e31a3efe59ab3778d409451361800"
        static let ResponseFormat = "json"
        static let DisableJSONCallback = "1" /* 1 means "yes" */
        static let GalleryPhotosMethod = "flickr.galleries.getPhotos"
        static let GalleryID = "5704-72157622566655097"
        static let MediumURL = "url_m"
        static let UseSafeSearch = "1"
        static let MAX_PER_PAGE = "30"
    }
    
    // MARK: Flickr Response Keys
    struct FlickrResponseKeys {
        static let Status = "stat"
        static let Photos = "photos"
        static let Photo = "photo"
        static let Title = "title"
        static let MediumURL = "url_m"
        static let Pages = "pages"
        static let Total = "total"
    }
    
    
    // MARK: Flickr Response Values
    struct FlickrResponseValues {
        static let OKStatus = "ok"
    }
    
    struct JSONKeys {
        
        static let OBJECT_ID_KEY = "objectId"
        
            static let URL = "url"
            static let File = "file"

    }
    struct Notifications {
        static  let ALL_PHOTO_LOADED_NOTIFICATION="ALL_PHOTO_LOADED_NOTIFICATION"
        static  let PHOTO_LOADED_NOTIFICATION="PHOTO_LOADED_NOTIFICATION"
    }
    
    
    

    

}