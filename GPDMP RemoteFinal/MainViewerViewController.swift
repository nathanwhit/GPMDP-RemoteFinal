import CoreFoundation
import Foundation
import Starscream
import SwiftyJSON
import UIKit

class MainViewController: UIViewController, UITextFieldDelegate, WebSocketDelegate {
    var currentSong : String = ""
    var currentArtist : String = ""
    var currentVolume : Float = 0
    var currentVolumeInt = 0
    var currentTime: Int?
    var totalTime: Int?
    
    var timer: Timer?
    
    var docpath = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    
    var ipAddress: String?
    var socket: WebSocket?
    var thePlayer: player?
    
    //MARK: Properties
    @IBOutlet weak var songInfo: UILabel!
    
    @IBOutlet weak var albumArt: UIImageView!
    
    @IBOutlet weak var playButton: UIButton!
    
    @IBOutlet weak var codeEntry: UITextField!
    
    @IBOutlet weak var volumeSlider: UISlider!
    
    @IBOutlet weak var shuffleButton: UIButton!
    
    @IBOutlet weak var songProg: UISlider!
    
    @IBOutlet weak var currTime: UILabel!
    
    @IBOutlet weak var endTime: UILabel!
    
    @IBOutlet weak var repeatButton: UIButton!
    
    @IBOutlet weak var disconnectButton: UIButton!
    
    //MARK: Actions
    
    
    @IBAction func playButton(_ sender: UIButton) {
        let json = JSON(["namespace":"playback", "method":"playPause"])
        //socket?.write(string: "{\"namespace\": \"playback\",\"method\":\"playPause\"}")
        socket?.write(string: stringify(jsonData: json))
        playButton.showsTouchWhenHighlighted = true
    }
    
    @IBAction func previousButton(_ sender: UIButton) {
        prevTrack()
    }
    
    @IBAction func nextButton(_ sender: UIButton) {
        skipTrack()
    }
    
    @IBAction func shuffleButton(_ sender: UIButton) {
        let json = JSON(["namespace": "playback", "method": "toggleShuffle"])
        //socket?.write(string: "{\"namespace\": \"playback\",\"method\":\"toggleShuffle\"}")
        socket?.write(string: stringify(jsonData: json))
    }
    @IBAction func repeatButton(_ sender: UIButton) {
        let json = JSON(["namespace":"playback","method":"toggleRepeat"])
        //socket?.write(string: "{\"namespace\": \"playback\",\"method\":\"toggleRepeat\"}")
        socket?.write(string: stringify(jsonData: json))
    }
    
    @IBAction func disconnect(_ sender: UIButton) {
        
        codeEntry.isHidden = true
        codeEntry.isEnabled = false
        if socket?.isConnected == true {
            socket?.disconnect()
        }
        else {
            socket?.connect()
        }
    }
    @IBAction func volumeSlider(_ sender: UISlider) {
        let currVol = Int(volumeSlider.value)
        let json = JSON(["namespace":"volume","method":"setVolume","arguments":"[\(currVol)]"])
        socket?.write(string: stringify(jsonData: json))
        print("{\"namespace\": \"volume\",\"method\":\"setVolume\",\"arguments\":\"[\(currVol)]\"}")
        socket?.write(string: "{\"namespace\": \"volume\",\"method\":\"setVolume\",\"arguments\": [\(currVol)]}")
    }
    
    @IBAction func songSeek(_ sender: UISlider) {
        currentTime = Int(sender.value)
        let json = JSON(["namespace":"playback","method":"setCurrentTime","arguments":[(currentTime)]])
        socket?.write(string: stringify(jsonData: json))
    }
    
    func isRepeatMessage(textArr: JSON) -> Bool{
        if textArr["channel"].stringValue == "repeat" {
            print("REPEAT THING RECEIVED")
            return true
        }
        return false
    }
    func isRepeat(textArr: JSON) {
        switch textArr["payload"].stringValue {
        case "LIST_REPEAT":
            repeatButton.setImage(#imageLiteral(resourceName: "repeatAll"), for: .normal)
        case "SINGLE_REPEAT":
            repeatButton.setImage(#imageLiteral(resourceName: "repeatAll-1"), for: .normal)
        case "NO_REPEAT":
            repeatButton.setImage(#imageLiteral(resourceName: "Repeat"), for: .normal)
        default:
            return
        }
    }
    
    
    func skipTrack() {
        let json = JSON(["namespace": "playback","method":"forward"])
        let json1 = JSON(["namespace": "playback","method":"getCurrentTrack","requestID":27])
        socket?.write(string: stringify(jsonData: json))
        socket?.write(string: stringify(jsonData: json1))
        //socket?.write(string: "{\"namespace\": \"playback\",\"method\":\"forward\"}")
        //socket?.write(string: "{\"namespace\": \"playback\",\"method\":\"getCurrentTrack\",\"requestID\":27}")
    }
    
    func prevTrack() {
        let json = JSON(["namespace": "playback","method":"rewind"])
        let json1 = JSON(["namespace": "playback","method":"getCurrentTrack","requestID":27])
        socket?.write(string: stringify(jsonData: json))
        socket?.write(string: stringify(jsonData: json))
        //socket?.write(string: "{\"namespace\": \"playback\",\"method\":\"rewind\"}")
        //socket?.write(string: "{\"namespace\": \"playback\",\"method\":\"getCurrentTrack\",\"requestID\":27}")
    }
    
    func isPermVerified() -> Bool {
       /* let doc = docpath.appendingPathComponent("permVerifCode").appendingPathExtension("txt")
        let fileExists = (try? doc.checkResourceIsReachable()) ?? false
        if fileExists {
            let perma = try! String(contentsOf: docpath.appendingPathComponent("permVerifCode").appendingPathExtension("txt"), encoding: String.Encoding.utf8)
        print("verif is : " + perma)
        if perma == "CODE_REQUIRED" {
            return false
        }
        else {
            return true
        }
        }
        else {
            return false
        }
 */
        return false
    }
    
    func isTimeMessage(textArr: JSON) -> Bool{
        if textArr["channel"].stringValue == "time" {
            return true
        }
        return false
    }
    
    func getCurrentTime(timeData: JSON) {
        currentTime = timeData["current"].intValue
        totalTime = timeData["total"].intValue
        songProg.maximumValue = Float(totalTime!)
        songProg.setValue(Float(currentTime!), animated: true)
        let currMins = "\((currentTime!/1000)/60)"
        let currSecs = (currentTime!/1000)
        let currSecsMid = currSecs%60
        var currSecsFin = "\(currSecsMid)"
        if currSecsMid < 10 {
            currSecsFin = "0" + currSecsFin
        }
        currTime.text = currMins + ":" + currSecsFin
        let endMins = "\((totalTime!/1000)/60)"
        let endSecs = (totalTime!/1000)
        let endSecsMid = endSecs%60
        var endSecsFin = "\(endSecsMid)"
        if endSecsMid < 10 {
            endSecsFin = "0" + endSecsFin
        }
        endTime.text = endMins + ":" + endSecsFin
        
    }
    
    func isVolumeResponse(textArr: JSON) -> Bool {
        if textArr["channel"].stringValue == "volume" {
            currentVolume = textArr["payload"].floatValue
            volumeSlider.value = currentVolume
            print("Current volume is \(currentVolume)")
            
            return true
        }
        else {
            return false
        }
    }
    
    func getCurrentTrack(textArr: JSON) {

        var textData: JSON = JSON.null
        if textArr["namespace"].stringValue == "result" && textArr["requestID"].intValue == 27
        {
            textData = textArr["value"]
            currentSong = textData["title"].stringValue
            currentArtist = textData["artist"].stringValue
            songInfo.text = currentSong + " - " + currentArtist
            let currentAlbumArtStr = textData["albumArt"].stringValue
            let currentAlbumArtURL: NSURL = NSURL(string: currentAlbumArtStr)!
            if let albumData: NSData = NSData(contentsOf: (currentAlbumArtURL) as URL) {
                albumArt.image = UIImage(data: albumData as Data)
                albumArt.updateFocusIfNeeded()
        }
            else {
            textData = textArr["payload"]
            currentSong = textData["title"].stringValue
            currentArtist = textData["artist"].stringValue
            songInfo.text = currentSong + " - " + currentArtist
            let currentAlbumArtStr = textData["albumArt"].stringValue
            let currentAlbumArtURL: NSURL = NSURL(string: currentAlbumArtStr)!
            if let albumData: NSData = NSData(contentsOf: (currentAlbumArtURL) as URL) {
                albumArt.image = UIImage(data: albumData as Data)
                albumArt.updateFocusIfNeeded()
        }
    }
        }
    }
    
    func isPlayingMessage(textArr: JSON) -> Bool {
        if textArr["channel"].stringValue == "playState" {
            return true
        }
        else {
            return false
        }
    }
    
    func isPlaying(textArr: JSON) -> Bool {
        if textArr["payload"].stringValue == "true" {
            return true
        }
        else {
            return false
        }
    }
    
    func isVerifiedMessage(textArr: JSON) -> Bool {
        if textArr["channel"].stringValue == "connect" {
            return true
        }
            
        else {
            return false
        }
    }
    
    func isShuffleMessage(textArr: JSON) -> Bool {
        if textArr["channel"].stringValue == "shuffle" {
            print("SHUFFLE THING RECEIVED")
            return true
        }
        return false
    }
    
    func isShuffled(textArr: JSON) -> Bool {
        
        if textArr["payload"].stringValue == "ALL_SHUFFLE" {
            print("YEAH IT'S SHUFFLED")
            return true
        }
        else {
            print("NAH NO SHUFFLES HERE")
            return false
        }
    }
    
    func sendGetTrack() {
        socket?.write(string: "{\"namespace\": \"playback\",\"method\":\"getCurrentTrack\",\"requestID\":27}")
    }
    
    func isVerified(textArr: JSON) {
        let path = docpath.appendingPathComponent("permVerifCode").appendingPathExtension("txt")
        let verifCode = textArr["payload"].stringValue
        if verifCode == "CODE_REQUIRED" {
            songInfo.text = "Try again please, code wrong"
            do {
                try verifCode.write(to: path, atomically: true, encoding: String.Encoding.utf8)
            }
            catch let error as NSError {
                print("Failed writing to: \(path), Error: " + error.localizedDescription)
            }
        }
        else{
            
            print("Verification string sent : " + verifCode)
            sendVerifcode(verifCode: verifCode)
            socket?.write(string: "{\"namespace\":\"playback\",\"method\":\"getCurrentTrack\",\"requestID\":\"23\"}")
            codeEntry.isHidden = true
            codeEntry.isEnabled = false
            codeEntry.isSelected = false
            do {
                try verifCode.write(to: path, atomically: true, encoding: String.Encoding.utf8)
            }
            catch let error as NSError {
                print("Failed writing to: \(path), Error: " + error.localizedDescription)
            }
        }
    }
    
    func sendVerifcode(verifCode: String) {
        socket?.write(string: "{\"namespace\": \"connect\",\"method\": \"connect\",\"arguments\": [\"Nathans Phone / GPMDP Remote\", \"\(verifCode)\"]}")
        socket?.write(string: "{\"namespace\":\"volume\",\"method\":\"getVolume\",\"requestID\":55}")
        socket?.write(string: "{\"namespace\": \"playback\",\"method\":\"getCurrentTrack\",\"requestID\":27}")

        
    }
    
    func websocketDidConnect(socket: WebSocket) {
        print("websocket is connected")
        disconnectButton.setTitle("Disconnect", for: .normal)
        sendVerifcode(verifCode: (thePlayer?.permVerifCode!)!)
        
    }
    
    func websocketDidDisconnect(socket: WebSocket, error: NSError?) {
        disconnectButton.setTitle("Connect", for: .normal
        )
        //codeEntry.isHidden = false
        //codeEntry.isEnabled = true
        //player1.isHidden = false
        //player2.isHidden = false
        //player1.isEnabled = true
        //player2.isEnabled = true
        
        if let e = error {
            print("websocket is disconnected: \(e.localizedDescription)")
        } else {
            print("websocket disconnected")
            let verifCode = "CODE_REQUIRED"
            let path = docpath.appendingPathComponent("permVerifCode").appendingPathExtension("txt")
            socket.disconnect()
            do {
                try verifCode.write(to: path, atomically: true, encoding: String.Encoding.utf8)
            }
            catch let error as NSError {
                print("Failed writing to: \(path), Error: " + error.localizedDescription)
            }
            
        }
        
    }
    
    func stringify(jsonData: JSON) -> String{
        return jsonData.rawString(.utf8)!
    }
    
    func websocketDidReceiveMessage(socket: WebSocket, text: String) {
        //print("Received text: \(text)")
        //socket.write("{")
        
        //SOON REPLACE STUPID CRAP BELOW WITH SWITCH STATEMENT
        
        
        var textData: JSON = JSON.null
        if let dataFromString = text.data(using: .utf8, allowLossyConversion: false) {
            let json = JSON(data: dataFromString)
            textData = json
        }
        else {
            print("ERROR")
        }
        
        print(text)
        if isPlayingMessage(textArr: textData) == true {
            if isPlaying(textArr: textData) == true {
                playButton.setImage(#imageLiteral(resourceName: "Pause"), for: .normal)
            }
            else {
                playButton.setImage(#imageLiteral(resourceName: "Play"), for: .normal)
            }
        }
            if isVerifiedMessage(textArr: textData) == true {
                isVerified(textArr: textData)
            }
        
        
        if isVolumeResponse(textArr: textData) == true {
            print("Gotten")
        }
        if textData["channel"].stringValue == "track" || (textData["namespace"].stringValue == "result" && textData["requestID"].intValue == 27) {
            getCurrentTrack(textArr: textData)
        }
        if isShuffleMessage(textArr: textData) {
            if isShuffled(textArr: textData) == true {
                shuffleButton.setImage(#imageLiteral(resourceName: "shuffleOn"), for: .normal)
            }
            else {
                shuffleButton.setImage(#imageLiteral(resourceName: "Shuffle"), for: .normal)
            }
        }
        if isTimeMessage(textArr: textData) == true {
            getCurrentTime(timeData: textData["payload"])
        }
        if isRepeatMessage(textArr: textData) == true {
            isRepeat(textArr: textData)
        }
        
    }
    
    func websocketDidReceiveData(socket: WebSocket, data: Data) {
        print("Received data: \(data.count)")
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        codeEntry.delegate = self
        socket?.delegate = self
        //socket = WebSocket(url: URL(string: "ws://" + ipAddress! + ":5672")!)
            codeEntry.isHidden = true
            codeEntry.isEnabled = false
        socket?.connect()
        timer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(MainViewController.sendGetTrack), userInfo: nil, repeats: true)
        songProg.setThumbImage(#imageLiteral(resourceName: "Thumb"), for: .normal)
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        socket?.connect()
        sendVerifcode(verifCode: (thePlayer?.permVerifCode)!)
        sendGetTrack()
    }
    
    
    override func applicationFinishedRestoringState() {
        socket?.connect()
        sendVerifcode(verifCode: (thePlayer?.permVerifCode)!)
    }
    
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        codeEntry.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let head = "{\"namespace\": \"connect\",\"method\": \"connect\",\"arguments\": [\"Nathans Phone / GPMDP Remote\", "
        let fourDigitCode =  textField.text
        socket?.write(string: head + "\"" + fourDigitCode! + "\"]}" )
        print("Sent string: " + head + "\"" + fourDigitCode! + "\"]}" )
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
}


