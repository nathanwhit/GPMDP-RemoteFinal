//
//  player.swift
//  GPMDP RemoteFinal
//
//  Created by Nathan Whitaker on 3/14/17.
//  Copyright © 2017 Nathan Whitaker. All rights reserved.
//

import Foundation
import SwiftyJSON
import os.log

class player: NSObject, NSCoding {
    
    var ipAddress: String
    var playerName: String
    var isPermVerified: Bool
    var permVerifCode: String?
    
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("players")
    
    struct PropertyKey {
        static let playerName = "name"
        static let ipAddress = "192.168.1.1"
        static let isPermVerified = false
        static let permVerifCode = "CODE_REQUIRED"
    }
    
    init?(ipAdd: String, name: String, permCode: String) {
        if name.isEmpty || ipAdd.isEmpty  {
            return nil
        }
        ipAddress = ipAdd
        playerName = name
        permVerifCode = permCode
        if permVerifCode != "CODE_REQUIRED"{
            isPermVerified = true
        }
        else {
            isPermVerified = false
        }
    }
    
    init?(ipAdd: String, name: String) {
        if ipAdd.isEmpty || name.isEmpty {
            return nil
        }
        ipAddress = ipAdd
        playerName = name
        isPermVerified = false
        
    }
    
    func getIP() -> String {
        return ipAddress
    }
    
    func getName() -> String {
        return playerName
    }
    
    //MARK: NSCoding
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(playerName, forKey: PropertyKey.playerName)
        aCoder.encode(ipAddress, forKey: PropertyKey.ipAddress)
        aCoder.encode(permVerifCode, forKey: PropertyKey.permVerifCode)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        // The name is required. If we cannot decode a name string, the initializer should fail.
        guard let theipAddress = aDecoder.decodeObject(forKey: PropertyKey.ipAddress) as? String else {
            os_log("Unable to decode the ipAdd for a player object.", log: OSLog.default, type: .debug)
            return nil
        }
        guard let theplayerName = aDecoder.decodeObject(forKey: PropertyKey.playerName) as? String else {
            return nil
        }
        guard let thepermVerifCode = aDecoder.decodeObject(forKey: PropertyKey.permVerifCode) as? String else {
            return nil
        }
        self.init(ipAdd: theipAddress, name: theplayerName, permCode: thepermVerifCode)
        
    }

    
}

    
    
    
    
    

