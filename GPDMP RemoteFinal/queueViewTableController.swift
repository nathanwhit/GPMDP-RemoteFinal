//
//  queueViewTableController.swift
//  GPMDP RemoteFinal
//
//  Created by Nathan Whitaker on 3/21/17.
//  Copyright © 2017 Nathan Whitaker. All rights reserved.
//

import UIKit
import Foundation
import Starscream
import SwiftyJSON
import Async
import Kingfisher

class queueViewTableViewController: UITableViewController, WebSocketDelegate {
    
    var sock: WebSocket?
    var thePlayer: player?
    var permVerif: String?
    var queue = [resultObject]()
    var theResult: resultObject?
    
    func websocketDidConnect(socket: WebSocket) {
        print("connected")
        let verf = thePlayer?.permVerifCode
        sock?.write(string: "{\"namespace\": \"connect\",\"method\": \"connect\",\"arguments\": [\"Nathans Phone / GPMDP Remote\", \"\(verf!)\"]}")
        let json = JSON(["namespace":"queue", "method":"getTracks"])
        sock?.write(string: stringify(jsonData: json))
    }
    func websocketDidDisconnect(socket: WebSocket, error: NSError?) {
        print("disconnected")
    }
    func websocketDidReceiveData(socket: WebSocket, data: Data) {
        print(data)
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
        
        switch textData["channel"].stringValue {
        case "queue":
            let theData = textData["payload"]
            for track in theData.arrayValue {
                self.queue.append(resultObject(name: track["title"].stringValue, artist: track["artist"].stringValue, album: track["album"].stringValue, picture: track["albumArt"].stringValue, track: track))
            }
            self.tableView.reloadData()
        default:
            return
            }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let viewc = segue.destination as! MainView
        viewc.thePlayer = thePlayer
        viewc.socket = sock
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sock?.delegate = self
        sock?.connect()
        
        definesPresentationContext = true
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let theTrack = queue[indexPath.row].Track
        let json = JSON(["namespace":"queue", "method":"playTrack", "arguments": [theTrack.rawValue], "requestID":89])
        sock?.write(string: stringify(jsonData: json))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return queue.count
    }
    
    
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "queueTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? queueTableViewCell  else {
            fatalError("The dequeued cell is not an instance of MealTableViewCell.")
        }
        
        // Fetches the appropriate meal for the data source layout.
        let result = queue[indexPath.row]
        
        cell.resultText.text = result.theName
        cell.resultSubtitle.text = result.theArtist
        let resource =  ImageResource(downloadURL: result.thePicture!, cacheKey: result.theAlbum)
        cell.resultPicture.kf.setImage(with: resource)
        
        return cell
    }
    
    func stringify(jsonData: JSON) -> String {
        return jsonData.rawString(.utf8)!
        
    }
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
     /*// Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
    queue.remove(at: indexPath.row)
     tableView.deleteRows(at: [indexPath], with: .fade)
        
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
 */
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        tableView.moveRow(at: fromIndexPath, to: to)
     }
    */
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
