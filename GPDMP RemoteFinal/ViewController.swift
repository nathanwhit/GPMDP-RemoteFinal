//
//  ViewController.swift
//  GPDMP RemoteFinal
//
//  Created by Nathan Whitaker on 3/13/17.
//  Copyright © 2017 Nathan Whitaker. All rights reserved.
//

import UIKit
import Foundation
import CoreFoundation
import Starscream
import AVFoundation
import MediaPlayer

class ViewController: UIViewController  {
    var asdf: String?
    
    let docpath = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard segue.identifier == "doneSegue" && asdf != nil else {return}
        let viewc = segue.destination as! MainView
        viewc.ipAddress = asdf
        viewc.socket = WebSocket(url: URL(string: "ws://" + asdf! + ":5672/")!)
            let lastIP = asdf!
            let path = docpath.appendingPathComponent("lastIP").appendingPathExtension("txt")
            do {
                try lastIP.write(to: path, atomically: true, encoding: String.Encoding.utf8)
            }
            catch let error as NSError {
                print("Failed writing to: \(path), Error: " + error.localizedDescription)
            }
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    }
    
    
    
    




