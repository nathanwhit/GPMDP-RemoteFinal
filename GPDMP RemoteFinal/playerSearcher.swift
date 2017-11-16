//
//  playerSearcher.swift
//  GPMDP RemoteFinal
//
//  Created by Nathan Whitaker on 3/31/17.
//  Copyright © 2017 Nathan Whitaker. All rights reserved.
//

import Foundation

class playerSearcher: NSObject, NetServiceBrowserDelegate {
    
    var browser: NetServiceBrowser?
    
    override init() {
        super.init()
        browser = NetServiceBrowser.init()
        browser?.delegate = self
        browser?.searchForBrowsableDomains()
    }
    
    func netServiceBrowserWillSearch(_ browser: NetServiceBrowser) {
    }
    
    func netServiceBrowserDidStopSearch(_ browser: NetServiceBrowser) {
        
    }
    
    func netServiceBrowser(_ browser: NetServiceBrowser, didNotSearch errorDict: [String : NSNumber]) {
    }
    
    func netServiceBrowser(_ browser: NetServiceBrowser, didFind service: NetService, moreComing: Bool) {
        
    }
    func netServiceBrowser(_ browser: NetServiceBrowser, didRemove service: NetService, moreComing: Bool) {
        
    }
    
    func netServiceBrowser(_ browser: NetServiceBrowser, didFindDomain domainString: String, moreComing: Bool) {
    }
    
    func netServiceBrowser(_ browser: NetServiceBrowser, didRemoveDomain domainString: String, moreComing: Bool) {
    }
}
