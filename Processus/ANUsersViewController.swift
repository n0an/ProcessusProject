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
        
        currentUserName = PFUser.current()!.username!
        currentGroup = PFUser.current()?.object(forKey: "group") as! String
        
        
        let predicate = NSPredicate(format: "username != %@ AND group == %@", currentUserName, currentGroup)
        
        let query = PFQuery(className: "_User", predicate: predicate)
        
        query.findObjectsInBackground { (objects: [PFObject]?, error: NSError?) in
            let users = objects as! [PFUser]
            
            for user in users {
                self.userEmailsArray.append(user.email!)
                self.nicknamesArray.append(user.username!)
                self.imageFileArray.append(user["image"] as! PFFile)
                
                self.tableView.reloadData()
            }
        }


    }

    
    override func viewWillAppear(_ animated: Bool) {
        
        self.navigationItem.hidesBackButton = true
    }
    
    // MARK: - ACTIONS
    @IBAction func logoutButtonPressed(_ sender: AnyObject) {
        
        PFUser.logOut()
        
        self.navigationController?.popToRootViewController(animated: true)
    }

}






extension ANUsersViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nicknamesArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellId = "ANPersonCell"

        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! ANPersonCell
        
        cell.fullNameLabel.text = nicknamesArray[indexPath.row]
        
        imageFileArray[indexPath.row].getDataInBackground { (imageData: Data?, error: NSError?) in
            if error == nil {
                let image = UIImage(data: imageData!)
                cell.avatarImageView.image = image
            }
        }
        
        
        return cell
        
    }
    
    
}

extension ANUsersViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath) as! ANPersonCell
        
        recipientNickname = cell.fullNameLabel.text!

        self.performSegue(withIdentifier: "toChatSegue", sender: self)

    }

    
}


















