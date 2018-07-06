//
//  FlikrConvenience.swift
//  VirtualTourist
//
//  Created by Hamna Usmani on 7/1/18.
//  Copyright © 2018 Hamna Usmani. All rights reserved.
//

import Foundation

extension FlikrClient {
    
    //Getting photos from Flikr
    func getPhotosFromFlikr(latitude: Double, longitude: Double, completionHandlerForGetPhotos: @escaping(_ count: Int? ,_ result: [[String: AnyObject]]?, _ errorString: String?) -> Void) {
        let bboxStringValue = bboxString(latitude: latitude, longitude: longitude)
        
        let parameters = [
            FlickrParameterKeys.Method: FlickrParameterValues.SearchMethod,
            FlickrParameterKeys.APIKey : FlickrParameterValues.APIKey,
            FlickrParameterKeys.Extras: FlickrParameterValues.MediumURL,
            FlickrParameterKeys.Format: FlickrParameterValues.ResponseFormat,
            FlickrParameterKeys.SafeSearch: FlickrParameterValues.UseSafeSearch,
            FlickrParameterKeys.BoundingBox : bboxStringValue,
            FlickrParameterKeys.NoJSONCallback: FlickrParameterValues.DisableJSONCallback,
            FlickrParameterKeys.PerPage: FlickrParameterValues.PerPage
        ]
        
        let _ = taskForGetMethod(parameters: parameters as [String: AnyObject]) { (result, error) in
            guard error == nil else {
                completionHandlerForGetPhotos(nil, nil, error?.localizedDescription)
                return
            }
            
            if let result = result {
                
                /* GUARD: Did Flickr return an error (stat != ok)? */
                guard let stat = result[FlickrResponseKeys.Status] as? String, stat == FlickrResponseValues.OKStatus else {
                    completionHandlerForGetPhotos(nil, nil, "Flickr API returned an error.")
                    return
                }
                
                /* GUARD: Is "photos" key in our result? */
                guard let photosDictionary = result[FlickrResponseKeys.Photos] as? [String:AnyObject] else {
                    completionHandlerForGetPhotos(nil, nil, "Flickr API returned an error.")
                    return
                }
                
                /* GUARD: Is "pages" key in the photosDictionary? */
                guard let totalPages = photosDictionary[FlickrResponseKeys.Pages] as? Int else {
                    completionHandlerForGetPhotos(nil, nil, "Flickr API returned an error.")
                    return
                }
                
                // pick a random page - Setting Page for next request for picture with same coordinates
                let pageLimit = min(totalPages, 4000/21)
                let randomPage = Int(arc4random_uniform(UInt32(pageLimit))) + 1
                
                self.getPhotosFromFlikrFromRandomPage(bboxString: bboxStringValue, page: randomPage, completionHandlerForGetPhotos: completionHandlerForGetPhotos)
                
            } else {
                completionHandlerForGetPhotos(nil, nil, "Flickr API returned an error.")
            }
        }
    }
    
    
    //Getting photos from Flikr
    func getPhotosFromFlikrFromRandomPage(bboxString: String, page: Int, completionHandlerForGetPhotos: @escaping(_ count: Int? ,_ result: [[String: AnyObject]]?, _ errorString: String?) -> Void) {
        
        let parameters = [
            FlickrParameterKeys.Method: FlickrParameterValues.SearchMethod,
            FlickrParameterKeys.APIKey : FlickrParameterValues.APIKey,
            FlickrParameterKeys.Extras: FlickrParameterValues.MediumURL,
            FlickrParameterKeys.Format: FlickrParameterValues.ResponseFormat,
            FlickrParameterKeys.SafeSearch: FlickrParameterValues.UseSafeSearch,
            FlickrParameterKeys.BoundingBox : bboxString,
            FlickrParameterKeys.NoJSONCallback: FlickrParameterValues.DisableJSONCallback,
            FlickrParameterKeys.PerPage: FlickrParameterValues.PerPage,
            FlickrParameterKeys.Page : "\(page)"
        ]
        
        let _ = taskForGetMethod(parameters: parameters as [String: AnyObject]) { (result, error) in
            guard error == nil else {
                completionHandlerForGetPhotos(nil, nil, error?.localizedDescription)
                return
            }
            
            if let result = result {
                
                /* GUARD: Did Flickr return an error (stat != ok)? */
                guard let stat = result[FlickrResponseKeys.Status] as? String, stat == FlickrResponseValues.OKStatus else {
                    completionHandlerForGetPhotos(nil, nil, "Flickr API returned an error.")
                    return
                }
                
                /* GUARD: Is "photos" key in our result? */
                guard let photosDictionary = result[FlickrResponseKeys.Photos] as? [String:AnyObject] else {
                    completionHandlerForGetPhotos(nil, nil, "Flickr API returned an error.")
                    return
                }
                
                /* GUARD: Is "pages" key in the photosDictionary? */
                guard let totalPages = photosDictionary[FlickrResponseKeys.Pages] as? Int else {
                    completionHandlerForGetPhotos(nil, nil, "Flickr API returned an error.")
                    return
                }
                
                // pick a random page - Setting Page for next request for picture with same coordinates
                let pageLimit = min(totalPages, 40)
                let randomPage = Int(arc4random_uniform(UInt32(pageLimit))) + 1
                FlickrResponseValues.page = "\(randomPage)"
                
                /* GUARD: Is the "photo" key in photosDictionary? */
                guard let photosArray = photosDictionary[FlickrResponseKeys.Photo] as? [[String: AnyObject]] else {
                    completionHandlerForGetPhotos(nil, nil, "Flickr API returned an error.")
                    return
                }
                
                //Returning photos count
                let count = photosArray.count
                completionHandlerForGetPhotos(count, photosArray, nil)
                
            } else {
                completionHandlerForGetPhotos(nil, nil, "Flickr API returned an error.")
            }
        }
    }
    
    
    
    
    //Helper Method
    private func bboxString(latitude: Double, longitude: Double) -> String {
        
        // ensure bbox is bounded by minimum and maximums
        let minimumLon = max(longitude - Flickr.SearchBBoxHalfWidth, Flickr.SearchLonRange.0)
        let minimumLat = max(latitude - Flickr.SearchBBoxHalfHeight, Flickr.SearchLatRange.0)
        let maximumLon = min(longitude + Flickr.SearchBBoxHalfWidth, Flickr.SearchLonRange.1)
        let maximumLat = min(latitude +  Flickr.SearchBBoxHalfHeight, Flickr.SearchLatRange.1)
        return "\(minimumLon),\(minimumLat),\(maximumLon),\(maximumLat)"
    }
    
}
