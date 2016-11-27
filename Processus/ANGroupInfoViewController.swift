//
//  ANGroupInfoViewController.swift
//  Processus
//
//  Created by Anton Novoselov on 05/06/16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

import UIKit

class ANGroupInfoViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let backButton = UIBarButtonItem(title: "OK", style: .plain, target: self, action: #selector(ANGroupInfoViewController.backPressed(_:)))
        
        self.navigationItem.rightBarButtonItem = backButton
        
    }
    
    
    func backPressed(_ sender: UIBarButtonItem) {
        
        dismiss(animated: true, completion: nil)
        
    }

    

}
