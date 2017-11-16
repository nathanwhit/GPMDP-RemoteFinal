import CoreFoundation
import Foundation
import Starscream
import SwiftyJSON
import UIKit
import Async
import AVFoundation
import Kingfisher

class MainView: UIViewController, UITextFieldDelegate, WebSocketDelegate {
    var currentSong : String?
    var currentArtist : String?
    var currentVolume : Float?
    var currentVolumeInt: Int?
    var currentTime: Int?
    var totalTime: Int?
    
    var currSysVol: Float?
    
    var timer: Timer?
    
    var docpath = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    
    var ipAddress: String?
    var socket: WebSocket?
    var thePlayer: player?
    let avPlayer = AVAudioSession.sharedInstance()
    
    //MARK: Properties
    @IBOutlet weak var songInfo: UILabel!
    
    @IBOutlet weak var artistInfo: UILabel!
    
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
        socket?.write(string: stringify(jsonData: json))
    }
    @IBAction func repeatButton(_ sender: UIButton) {
        let json = JSON(["namespace":"playback","method":"toggleRepeat"])
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
    
    func skipTrack() {
        let json = JSON(["namespace": "playback","method":"forward"])
        let json1 = JSON(["namespace": "playback","method":"getCurrentTrack","requestID":27])
        socket?.write(string: stringify(jsonData: json))
        socket?.write(string: stringify(jsonData: json1))
    }
    
    func prevTrack() {
        let json = JSON(["namespace": "playback","method":"rewind"])
        let json1 = JSON(["namespace": "playback","method":"getCurrentTrack","requestID":27])
        socket?.write(string: stringify(jsonData: json))
        socket?.write(string: stringify(jsonData: json))
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
    
    
    
    func sendGetTrack() {
        socket?.write(string: "{\"namespace\": \"playback\",\"method\":\"getCurrentTrack\",\"requestID\":27}")
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
        try? avPlayer.setActive(true)
        //addObserver(self, forKeyPath: #keyPath(avPlayer.outputVolume), options: [.old, .new], context: nil)
        currSysVol = avPlayer.outputVolume
        
    }
    
    func websocketDidDisconnect(socket: WebSocket, error: NSError?) {
        disconnectButton.setTitle("Connect", for: .normal
        )
        
        try? avPlayer.setActive(false)
        //removeObserver(self, forKeyPath: #keyPath(avPlayer.outputVolume))
        //currSysVol = avPlayer.outputVolume
        
        if let e = error {
            print("websocket is disconnected: \(e.localizedDescription)")
        } else {
            print("websocket disconnected")
            
        }
        
    }
    
    func stringify(jsonData: JSON) -> String{
        return jsonData.rawString(.utf8)!
    }
    
    func websocketDidReceiveMessage(socket: WebSocket, text: String) {
        //print("Received text: \(text)")
        //socket.write("{")
        
        let group = AsyncGroup()
        var textData: JSON = JSON.null
        if let dataFromString = text.data(using: .utf8, allowLossyConversion: false) {
            let json = JSON(data: dataFromString)
            textData = json
        }
        else {
            print("ERROR")
            }
        
        
        switch textData["channel"] {
            
            case "result":
                switch textData["requestID"].stringValue {
                case "27":
                    let trackData = textData["payload"]
                    group.main{     self.currentSong = trackData["title"].stringValue
                        self.currentArtist = trackData["artist"].stringValue
                        self.songInfo.text = self.currentSong!
                        self.artistInfo.text = self.currentArtist!}
                    let currentAlbumArtStr = trackData["albumArt"].stringValue
                    let currentAlbumArtURL = URL(string: currentAlbumArtStr)
                    let resource = ImageResource(downloadURL: currentAlbumArtURL!, cacheKey: textData["album"].stringValue)
                    albumArt.kf.setImage(with: resource)
                    default:
                    return
                    }
                    
            
            
            case "playState":
                if !textData["payload"].boolValue {
                    self.playButton.setImage(#imageLiteral(resourceName: "Play"), for: .normal)
            }
                else {
                    self.playButton.setImage(#imageLiteral(resourceName: "Pause"), for: .normal)
            }
            
            case "track":
                let trackData = textData["payload"]
                group.main {
            self.currentSong = trackData["title"].stringValue
            self.currentArtist = trackData["artist"].stringValue
                    self.songInfo.text = self.currentSong!
                self.artistInfo.text = self.currentArtist!}
            let currentAlbumArtStr = trackData["albumArt"].stringValue
                if currentAlbumArtStr == "" { return }
                else {
            let currentAlbumArtURL = URL(string: currentAlbumArtStr)!
            let resource = ImageResource(downloadURL: currentAlbumArtURL, cacheKey: trackData["album"].stringValue)
            albumArt.kf.setImage(with: resource)
            }
            
            case "time":
                let timeData = textData["payload"]
                self.currentTime = timeData["current"].intValue
                self.totalTime = timeData["total"].intValue
                self.songProg.maximumValue = Float(self.totalTime!)
                self.songProg.setValue(Float(self.currentTime!), animated: true)
                let currMins = "\((self.currentTime!/1000)/60)"
                let currSecs = (self.currentTime!/1000)
                let currSecsMid = currSecs%60
                var currSecsFin = "\(currSecsMid)"
                if currSecsMid < 10 {
                    currSecsFin = "0" + currSecsFin
                }
                self.currTime.text = currMins + ":" + currSecsFin

                let endMins = "\((self.totalTime!/1000)/60)"
                let endSecs = (self.totalTime!/1000)
                let endSecsMid = endSecs%60
                var endSecsFin = "\(endSecsMid)"
                if endSecsMid < 10 {
                    endSecsFin = "0" + endSecsFin
                }
                self.endTime.text = endMins + ":" + endSecsFin

            
            case "shuffle":
                switch textData["payload"] {
                    case "ALL_SHUFFLE":
                    self.shuffleButton.setImage(#imageLiteral(resourceName: "shuffleOn"), for: .normal)
                    default:
                    self.shuffleButton.setImage(#imageLiteral(resourceName: "Shuffle"), for: .normal)
            }
            
            case "repeat":
                switch textData["payload"] {
                    case "LIST_REPEAT":
                    self.repeatButton.setImage(#imageLiteral(resourceName: "repeatAll"), for: .normal)
                    case "SINGLE_REPEAT":
                    self.repeatButton.setImage(#imageLiteral(resourceName: "repeatAll-1"), for: .normal)
                    default:
                    self.repeatButton.setImage(#imageLiteral(resourceName: "Repeat"), for: .normal)
            }
            
            case "volume":
            self.currentVolume = textData["payload"].floatValue
            self.volumeSlider.value = self.currentVolume!
            print("Current volume is \(self.currentVolume)")
            
            
            case "queue":
            break
            
            case "search":
            break
            
            default:
            return
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
        timer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(MainView.sendGetTrack), userInfo: nil, repeats: true)
        
        songProg.setThumbImage(#imageLiteral(resourceName: "Thumb"), for: .normal)
        try? avPlayer.setActive(true)
        addObserver(self, forKeyPath: #keyPath(avPlayer.outputVolume), options: [.old, .new], context: nil)
        currSysVol = avPlayer.outputVolume
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier! {
        case "toQueue":
            let searchScreen = segue.destination as! queueViewTableViewController
            searchScreen.sock = socket!
            searchScreen.thePlayer = thePlayer!
        case "toSearch":
            let searchScreen = segue.destination as! SearchViewTableViewController
            searchScreen.sock = socket!
            searchScreen.thePlayer = thePlayer!
        default:
            return
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == #keyPath(avPlayer.outputVolume) {
            volumeSlider.value = 100 * avPlayer.outputVolume
            volumeSlider(volumeSlider)
        }
        else {
            return
        }
    }

    
    
    
    
}



