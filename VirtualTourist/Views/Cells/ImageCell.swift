//
//  ImageCell.swift
//  VirtualTourist
//
//  Created by Hamna Usmani on 7/1/18.
//  Copyright © 2018 Hamna Usmani. All rights reserved.
//

import Foundation
import UIKit

internal final class ImageCell : UICollectionViewCell, Cell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageActivityIndicator: UIActivityIndicatorView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }
}

