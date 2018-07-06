//
//  DownloadImage.swift
//  VirtualTourist
//
//  Created by Hamna Usmani on 7/4/18.
//  Copyright © 2018 Hamna Usmani. All rights reserved.
//

import Foundation
import CoreData

class DownloadImage{
    class func downloadImagesForUrl(_ photos: [Photo], _ dataController: DataController,completionHandlerForDownload: @escaping() -> Void) {
        for photo in photos {
            if let url = URL(string: photo.url!),let imageData = try? Data(contentsOf: url){
                photo.image = imageData
                try? dataController.backgroundContext.save()
            }
        }
        completionHandlerForDownload()
    }
}
