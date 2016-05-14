//
//  ANTableViewFetchedResultsDisplayer.swift
//  Processus
//
//  Created by Anton Novoselov on 12/05/16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

import Foundation
import UIKit



protocol ANTableViewFetchedResultsDisplayer {
    func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath)
}



