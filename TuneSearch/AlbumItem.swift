//
//  AlbumItem.swift
//  TuneSearch
//
//  Created by Srini Motheram on 2/6/17.
//  Copyright © 2017 Srini Motheram. All rights reserved.
//

import UIKit

class AlbumItem: NSObject {
    var artistName  :String!
    var albumName   :String!
    var songName    :String!
    
    init(artist: String, album: String, song: String) {
        
        self.artistName = artist
        self.albumName = album
        self.songName = song
    }

}
