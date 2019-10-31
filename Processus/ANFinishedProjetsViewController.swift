//
//  ANFinishedProjetsViewController.swift
//  Processus
//
//  Created by Anton Novoselov on 07/06/16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

import UIKit
import CoreData


class ANFinishedProjetsViewController: UIViewController, ANTableViewFetchedResultsDisplayer {
    
    // MARK: - OUTLETS
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - ATTRIBUTES
    
    fileprivate var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>?
    
    fileprivate var fetchedResultsDelegate: NSFetchedResultsControllerDelegate?
    
    
    // MARK: - viewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        tableView.estimatedRowHeight = 80
        tableView.rowHeight = 80
        
        
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Project")
        
        let finishedStatusDescriptor = NSSortDescriptor(key: "finishedStatus", ascending: false)
        
        fetchRequest.sortDescriptors = [finishedStatusDescriptor]
        
        let predicate = NSPredicate(format: "finished == true")
        
        fetchRequest.predicate = predicate
        
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: ANDataManager.sharedManager.context, sectionNameKeyPath: "finishedStatus", cacheName: nil)
        
        fetchedResultsDelegate = ANTableViewFetchedResultsDelegate(tableView: tableView, displayer: self)
        
        fetchedResultsController?.delegate = fetchedResultsDelegate
        
        do {
            try fetchedResultsController?.performFetch()
            
        } catch {
            print("There was a problem fetching.")
        }
        
    }
    
    
    // MARK: - HELPER METHODS
    
    func configureCell(_ cell: UITableViewCell, atIndexPath indexPath: IndexPath) {
        
        guard let cell = cell as? ANPersonProjectCell else {return}
        
        guard let project = fetchedResultsController?.object(at: indexPath) as? Project else {return}
        
        cell.customerNameLabel.text = project.customer
        cell.projectNameLabel.text = project.name
        cell.projectDueDateLabel.text = ANConfigurator.sharedConfigurator.dateFormatter.string(from: project.dueDate! as Date)
        
        let cellColor: UIColor
        
        if project.finishedStatus == ProjectFinishedStatus.Success.rawValue {
            cellColor = UIColor(red: 143/255, green: 255/255, blue: 146/255, alpha: 0.3)
        } else {
            cellColor = UIColor(red: 255/255, green: 82/255, blue: 52/255, alpha: 0.3)
        }
        
        cell.backgroundColor = cellColor
    }
    
    
    // MARK: - ACTIONS
    
    
    
    
}




// MARK: - UITableViewDataSource
extension ANFinishedProjetsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController?.sections?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard let sections = fetchedResultsController?.sections else {return 0}
        
        let currentSection = sections[section]
        
        return currentSection.numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellId = "personProjectsCell"
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        
        configureCell(cell, atIndexPath: indexPath)
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        
        if let sectionInfo = fetchedResultsController?.sections?[section] {
            
            let displayedTitle: String
            
            if sectionInfo.name == ProjectFinishedStatus.Success.rawValue {
                displayedTitle = NSLocalizedString("PROJECT_FINISH_STATUS_SUCCESS", comment: "")
            } else {
                displayedTitle = NSLocalizedString("PROJECT_FINISH_STATUS_FAILURE", comment: "")
            }
            
            return displayedTitle
        }
        
        return nil
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        
        let view = UIView()
        view.backgroundColor = UIColor.clear
        let paddingView = UIView()
        
        view.addSubview(paddingView)
        
        paddingView.translatesAutoresizingMaskIntoConstraints = false
        
        let statusLabel = UILabel()
        paddingView.addSubview(statusLabel)
        
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let constraints:[NSLayoutConstraint] = [
            
            paddingView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            paddingView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            statusLabel.centerXAnchor.constraint(equalTo: paddingView.centerXAnchor),
            statusLabel.centerYAnchor.constraint(equalTo: paddingView.centerYAnchor),
            
            paddingView.heightAnchor.constraint(equalTo: statusLabel.heightAnchor, constant: 5),
            paddingView.widthAnchor.constraint(equalTo: statusLabel.widthAnchor, constant: 10),
            
            view.heightAnchor.constraint(equalTo: paddingView.heightAnchor)
            
        ]
        
        NSLayoutConstraint.activate(constraints)
        
        guard let sectionInfo = fetchedResultsController?.sections?[section] else {return nil}

        
        let displayedTitle: String
        
        if sectionInfo.name == ProjectFinishedStatus.Success.rawValue {
            displayedTitle = NSLocalizedString("PROJECT_FINISH_STATUS_SUCCESS", comment: "")
        } else {
            displayedTitle = NSLocalizedString("PROJECT_FINISH_STATUS_FAILURE", comment: "")
        }

        
        
        statusLabel.text = displayedTitle
        
        paddingView.layer.cornerRadius = 10
        paddingView.layer.masksToBounds = true
        
        
        
        let paddingViewBGColor: UIColor
        
        if sectionInfo.name == ProjectFinishedStatus.Success.rawValue {
            paddingViewBGColor = UIColor(red: 143/255, green: 255/255, blue: 146/255, alpha: 0.6)
        } else {
            paddingViewBGColor = UIColor(red: 255/255, green: 82/255, blue: 52/255, alpha: 0.6)

        }
        
        
        paddingView.backgroundColor = paddingViewBGColor

        
        return view
        
    }
    
}


// MARK: - UITableViewDelegate

extension ANFinishedProjetsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        guard let project = fetchedResultsController?.object(at: indexPath) as? Project else {return}
        
        if editingStyle == .delete {
            let context = ANDataManager.sharedManager.context
            context.delete(project)
            
            ANDataManager.sharedManager.saveContext()
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    
    
    // MARK: - NAVIGATION
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showProjectDetails" {
            
            
            let destinationVC = segue.destination as! ANProjectDetailsViewController
            
            destinationVC.delegate = self
            
            guard let indexPath = tableView.indexPathForSelectedRow else {return}
            
            guard let project = fetchedResultsController?.object(at: indexPath) as? Project else {return}
            
            destinationVC.project = project
            
        }
        
    }
    
}



// MARK: - ANProjectDetailsVCDelegate

extension ANFinishedProjetsViewController: ANProjectDetailsVCDelegate {
    func projectEditingDidEndForProject(_ project: Project) {
        
    }
}










