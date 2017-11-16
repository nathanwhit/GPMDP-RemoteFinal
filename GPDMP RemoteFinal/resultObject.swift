//
//  resultObject.swift
//  GPMDP RemoteFinal
//
//  Created by Nathan Whitaker on 3/17/17.
//  Copyright © 2017 Nathan Whitaker. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class resultObject {
    var theName: String?
    var theArtist: String?
    var thePicture: URL?
    var Track: JSON
    var theAlbum: String?
    var result: JSON
    
    init(name: String, artist: String, album: String, picture: String, track: JSON) {
        theName = name
        theArtist = artist
        let picStr = picture
        if picStr != "" {
            thePicture = URL(string: picStr)!
        }
        else {thePicture = nil}
        Track = track
        theAlbum = album
        self.result = JSON.null
    }
    
    init(name: String, artist: String, album: String, picture: String, result: JSON) {
        theName = name
        theArtist = artist
        let picStr = picture
        if picStr != "" {
            thePicture = URL(string: picStr)!
        }
        else {thePicture = nil}
        theAlbum = album
        self.result = result
        Track = JSON.null
    }
    
    
}
