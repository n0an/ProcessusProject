//
//  ANPhotoAddingViewController.swift
//  Processus
//
//  Created by Anton Novoselov on 05/06/16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

import UIKit

protocol ANPhotoAddingVCDelegate: class {
    
    func photoSelectionDidEnd(photo: UIImage)
    
}

class ANPhotoAddingViewController: UIViewController, UINavigationControllerDelegate {
    
    // MARK: - OUTLETS
    
    @IBOutlet weak var photoPreviewImageView: UIImageView!
    
    @IBOutlet weak var hintLabel: UILabel!
    
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    // MARK: - ATTRIBUTES
    
    weak var delegate: ANPhotoAddingVCDelegate!
    
    var selectedPhoto: UIImage!
    
    // MARK: - viewDidLoad

    override func viewDidLoad() {
        super.viewDidLoad()
        
        hintLabel.hidden = false
        doneButton.enabled = false
        
        if !UIImagePickerController.isSourceTypeAvailable(.Camera) {
            cameraButton.enabled = false
            showAlertNoCameraDeviceFound()
        }

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        
    }
    

    // MARK: - HELPER METHODS
    
    func showAlertNoCameraDeviceFound() {
        
        let alertNoCamera = UIAlertController(title: "Error", message: "Device has no camera", preferredStyle: .Alert)
        
        let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        
        alertNoCamera.addAction(okAction)
        
        presentViewController(alertNoCamera, animated: true, completion: nil)
        
    }

    
    // MARK: - ACTIONS

    @IBAction func actionCameraButtonPressed(sender: UIBarButtonItem) {
        
        let cameraVC = UIImagePickerController()
        cameraVC.sourceType = .Camera
        
        cameraVC.delegate = self
        
        presentViewController(cameraVC, animated: true, completion: nil)
        
        
    }
    
    @IBAction func actionFolderButtonPressed(sender: UIBarButtonItem) {
        
        let photosVC = UIImagePickerController()
        photosVC.sourceType = .PhotoLibrary
        
        photosVC.delegate = self
        
        photosVC.allowsEditing = true
        
        presentViewController(photosVC, animated: true, completion: nil)
        
    }
    
    @IBAction func actionCancelPressed(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func actionDonePressed(sender: UIBarButtonItem) {
        
        delegate.photoSelectionDidEnd(selectedPhoto)
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    

}



extension ANPhotoAddingViewController: UIImagePickerControllerDelegate {
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        
        selectedPhoto = image
        
        photoPreviewImageView.image = image
        
        doneButton.enabled = true
        hintLabel.hidden = true
        
        dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    
}

























