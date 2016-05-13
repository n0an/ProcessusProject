//
//  ANPersonDetailsViewController.swift
//  Processus
//
//  Created by Anton Novoselov on 13/05/16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

import UIKit

class ANPersonDetailsViewController: UITableViewController {
    
    var person: Person!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("incoming person = \(person.firstName) \(person.lastName)")
        
        title = "\(person.firstName!) \(person.lastName!)"
        
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
        case 0:
            return 3
        case 1:
            return 1
        case 2:
            return 3
        default:
            break
        }
        
        return 0
    }
    
    

}



