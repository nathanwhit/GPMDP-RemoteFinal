//
//  UIViewController.swift
//  GPMDP RemoteFinal
//
//  Created by Nathan Whitaker on 3/14/17.
//  Copyright © 2017 Nathan Whitaker. All rights reserved.
//

import UIKit
import Foundation
import os.log
import Starscream
import SwiftyJSON

class editPlayer: UIViewController, UITextFieldDelegate, WebSocketDelegate {
    
    var isPerma: Bool?
    var thePlayer: player?
    var playIP: String?
    var playName: String?
    var theVerifCode: String?
    var sock: WebSocket?
    
    @IBOutlet weak var verifLabel: UILabel!
    @IBOutlet weak var codeEntryField: UITextField!
    
    @IBOutlet weak var editPlayerName: UITextField!
    
    @IBOutlet weak var connectButtonItem: UIBarButtonItem!
    
    @IBOutlet weak var editIPAddress: UITextField!
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    
    //MARK: Actions
    
    @IBAction func connectToIP(_ sender: UITextField) {
        updateSaveButtonState()
        guard editIPAddress != nil || editIPAddress.text != "" || containsOnlyNums(input: editIPAddress.text!) else {updateSaveButtonState(); return}
        sock = WebSocket(url: URL(string: "ws://" + editIPAddress.text! + ":5672/")!)
        sock?.delegate = self
        sock?.connect()
        
    }
    
   
    
    
    
    
    
    @IBAction func sendCode(_ sender: UITextField) {
        guard editIPAddress.text != nil || editIPAddress.text != "" || codeEntryField.text != "" || isPerma == false else {return}
        let code = codeEntryField.text
        let connectCom = "{\"namespace\":\"connect\", \"method\":\"connect\",\"arguments\":[\"iPhone / GPMDP Remote IOS\",\"\(code!)\"]}"
        print("sent message: " + connectCom)
        sock?.write(string: connectCom)
        isPerma = false
        
    }
    
    @IBAction func connectButton(_ sender: UIBarButtonItem) {
        if editIPAddress.text == nil || editIPAddress.text == "" || containsOnlyNums(input: editIPAddress.text!) == false {
            connectButtonItem.isEnabled = false
            print("please enter an IP")
        }
        else {
            print("ip is: " + editIPAddress.text!)
            let connectCom = "{\"namespace\":\"connect\", \"method\":\"connect\",\"arguments\":[\"iPhone / GPMDP Remote IOS\"]}"
            print("sent message: " + connectCom)
            sock?.write(string: connectCom)
        }
        
        updateSaveButtonState()
    }
    
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        let isPresentingInAddMealMode = presentingViewController is UINavigationController
        if isPresentingInAddMealMode {
            dismiss(animated: true, completion: nil)
        }
        
        else {
            thePlayer = player(ipAdd: playIP!, name: playName!)
            dismiss(animated: true, completion: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let ip = editIPAddress.text?.replacingOccurrences(of: " ", with: "")
        super.prepare(for: segue, sender: sender)
        if isPerma == true {
        let name = editPlayerName.text
        thePlayer = player(ipAdd: ip!, name: name!, permCode: theVerifCode!)
        }
        else {
            let name = editPlayerName.text
            thePlayer = player(ipAdd: ip!, name: name!)
        }
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        editPlayerName.delegate = self
        editIPAddress.delegate = self
        codeEntryField.delegate = self
        
        updateSaveButtonState()
        isPerma = false

        // Do any additional setup after loading the view.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    private func updateSaveButtonState() {
        // Disable the Save button if the text field is empty.
        if isPerma == false {
            saveButton.isEnabled = false
        }
        if editIPAddress.text == "" || editPlayerName.text == "" || containsOnlyNums(input: editIPAddress.text!) == false {
        connectButtonItem.isEnabled = false
        saveButton.isEnabled = false
        }
        
        else {
            saveButton.isEnabled = true
            connectButtonItem.isEnabled = true
        }
    }
    
    func stringify(jsonData: JSON) -> String {
        return jsonData.rawString(.utf8)!
        
    }
    
    func websocketDidReceiveMessage(socket: WebSocket, text: String) {
        print(text)
        var textData: JSON = JSON.null
        if let dataFromString = text.data(using: .utf8, allowLossyConversion: false) {
            let json = JSON(data: dataFromString)
            textData = json
        }
        else {
            print("ERROR")
        }
        guard isPerma == false else{return}
        if textData["channel"].stringValue == "connect" {
            
            theVerifCode = textData["payload"].stringValue
            guard theVerifCode != "CODE_REQUIRED" else {return}
            let comm = "{\"namespace\":\"connect\", \"method\":\"connect\",\"arguments\":[\"iPhone / GPMDP Remote IOS\",\"\(theVerifCode!)\"]}"
            sock?.write(string: comm)
            isPerma = true
            }
            
        }
    
    func setVerifCode(jsonData: JSON) {
        theVerifCode = jsonData["payload"].string
    }
    
    func websocketDidConnect(socket: WebSocket) {
        print("connected successfully")
    }
    
    func websocketDidDisconnect(socket: WebSocket, error: NSError?) {
        print("oops disconnected")
    }
    
    func websocketDidReceiveData(socket: WebSocket, data: Data) {
        print(data)
    }
    
    func containsOnlyNums(input: String) -> Bool {
        for chr: Character in input.characters {
            if chr == "0" || chr == "1" || chr == "2" || chr == "3" || chr == "4" || chr == "5" || chr == "6" || chr == "7" || chr == "8" || chr == "9" || chr == "." {
            
                continue
            }
            else {
                return false
            }
        }
        return true
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
