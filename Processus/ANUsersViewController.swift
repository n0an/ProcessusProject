//
//  ANUsersViewController.swift
//  Processus
//
//  Created by Anton Novoselov on 04/06/16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

import UIKit
import Parse

var currentUserName = ""
var currentGroup = ""

class ANUsersViewController: UIViewController {

    // MARK: - OUTLETS
    @IBOutlet weak var tableView: UITableView!

    // MARK: - ATTRIBUTES
    
    var userEmailsArray = [String]()
    var nicknamesArray = [String]()
    var imageFileArray = [PFFile]()
    
    
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentUserName = PFUser.currentUser()!.username!
        currentGroup = PFUser.currentUser()?.objectForKey("group") as! String
        
        print("currentUserName = \(currentUserName)")
        print("currentGroup = \(currentGroup)")
        
        let predicate = NSPredicate(format: "username != %@ AND group == %@", currentUserName, currentGroup)
        
        let query = PFQuery(className: "_User", predicate: predicate)
        
        query.findObjectsInBackgroundWithBlock { (objects: [PFObject]?, error: NSError?) in
            let users = objects as! [PFUser]
            
            for user in users {
                self.userEmailsArray.append(user.email!)
                self.nicknamesArray.append(user.username!)
                self.imageFileArray.append(user["image"] as! PFFile)
                
                self.tableView.reloadData()
            }
        }


    }

    
    override func viewWillAppear(animated: Bool) {
        
        self.navigationItem.hidesBackButton = true
    }
    
    // MARK: - ACTIONS
    @IBAction func logoutButtonPressed(sender: AnyObject) {
        
        PFUser.logOut()
        
        self.navigationController?.popToRootViewControllerAnimated(true)
    }

}






extension ANUsersViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nicknamesArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cellId = "ANPersonCell"

        let cell = tableView.dequeueReusableCellWithIdentifier(cellId, forIndexPath: indexPath) as! ANPersonCell
        
        cell.fullNameLabel.text = nicknamesArray[indexPath.row]
        
        imageFileArray[indexPath.row].getDataInBackgroundWithBlock { (imageData: NSData?, error: NSError?) in
            if error == nil {
                let image = UIImage(data: imageData!)
                cell.avatarImageView.image = image
            }
        }
        
        
        return cell
        
    }
    
    
}

extension ANUsersViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! ANPersonCell
        
        recipientNickname = cell.fullNameLabel.text!

        self.performSegueWithIdentifier("toChatSegue", sender: self)

    }

    
}


















