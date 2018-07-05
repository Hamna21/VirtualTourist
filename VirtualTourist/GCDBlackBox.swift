//
//  GCDBlackBox.swift
//  VirtualTourist
//
//  Created by Hamna Usmani on 7/1/18.
//  Copyright © 2018 Hamna Usmani. All rights reserved.
//

import Foundation

func performUIUpdatesOnMain(_ updates: @escaping() -> Void){
    DispatchQueue.main.async {
        updates()
    }
    
}
