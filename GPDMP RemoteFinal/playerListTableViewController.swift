//
//  playerListTableViewController.swift
//  GPMDP RemoteFinal
//
//  Created by Nathan Whitaker on 3/14/17.
//  Copyright © 2017 Nathan Whitaker. All rights reserved.
//

import UIKit
import os.log
import Starscream

class playerListTableViewController: UITableViewController {
    var players = [player]()
    var thePlayer: player?
    
    
    
   @IBAction func unwindToPlayerList(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? editPlayer, let thePlayer = sourceViewController.thePlayer {
            let newIndexPath = IndexPath(row: players.count, section: 0)
            
            players.append(thePlayer)
            tableView.insertRows(at: [newIndexPath], with: .automatic)
            savePlayers()
    }
        else {
            return
    }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = editButtonItem
        
        if let savedPlayers = loadPlayers() {
            players += savedPlayers
        }
        else {
            players = [player]()
        }
        

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        //self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return players.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "playerTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? playerTableViewCell  else {
            fatalError("The dequeued cell is not an instance of MealTableViewCell.")
        }
        
        // Fetches the appropriate meal for the data source layout.
        thePlayer = players[indexPath.row]
        
        cell.titleLabel.text = thePlayer?.playerName
        cell.subtitleLabel.text = thePlayer?.ipAddress
        
        return cell
    }

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            players.remove(at: indexPath.row)
            savePlayers()
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    // MARK: - Navigation

    //In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        switch(segue.identifier ?? "") {
        case "AddPlayer":
            os_log("Adding a new player.", log: OSLog.default, type: .debug)
            
        case "showMainView":
        let playerDetailViewController = segue.destination as! MainView
        guard let selectedPlayerCell = sender as? playerTableViewCell else {
            fatalError("Unexpected sender: \(sender)")
        }
        
        guard let indexPath = tableView.indexPath(for: selectedPlayerCell) else {
            fatalError("The selected cell is not being displayed by the table")
        }
        
        let selectedPlayer = players[indexPath.row]
        playerDetailViewController.socket = WebSocket(url: URL(string: "ws://" + selectedPlayer.ipAddress + ":5672")!)
        playerDetailViewController.thePlayer = selectedPlayer
        default:
            os_log("Going to main with nothing.", log: OSLog.default, type: .debug)
        }

}
    
    private func savePlayers() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(players, toFile: player.ArchiveURL.path)
        if isSuccessfulSave {
            os_log("Players successfully saved.", log: OSLog.default, type: .debug)
        } else {
            os_log("Failed to save players...", log: OSLog.default, type: .error)
        }
    }
    private func loadPlayers() -> [player]? {
    return NSKeyedUnarchiver.unarchiveObject(withFile: player.ArchiveURL.path) as? [player]
        
    }
    
}
