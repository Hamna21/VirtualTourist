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
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
}

