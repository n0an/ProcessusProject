//
//  ANPhotoAddingViewController.swift
//  Processus
//
//  Created by Anton Novoselov on 05/06/16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

import UIKit

protocol ANPhotoAddingVCDelegate: class {
    
    func photoSelectionDidEnd(_ photo: UIImage)
    
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
        
        hintLabel.isHidden = false
        doneButton.isEnabled = false
        
        if !UIImagePickerController.isSourceTypeAvailable(.camera) {
            cameraButton.isEnabled = false
            showAlertNoCameraDeviceFound()
        }

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
    }
    

    // MARK: - HELPER METHODS
    
    func showAlertNoCameraDeviceFound() {
        
        let alertNoCamera = UIAlertController(title: NSLocalizedString("CAMERA_ALERT_TITLE", comment: ""), message: NSLocalizedString("CAMERA_ALERT_MESSAGE", comment: ""), preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        alertNoCamera.addAction(okAction)
        
        present(alertNoCamera, animated: true, completion: nil)
        
    }

    
    // MARK: - ACTIONS

    @IBAction func actionCameraButtonPressed(_ sender: UIBarButtonItem) {
        
        let cameraVC = UIImagePickerController()
        cameraVC.sourceType = .camera
        
        cameraVC.delegate = self
        
        present(cameraVC, animated: true, completion: nil)
        
        
    }
    
    @IBAction func actionFolderButtonPressed(_ sender: UIBarButtonItem) {
        
        let photosVC = UIImagePickerController()
        photosVC.sourceType = .photoLibrary
        
        photosVC.delegate = self
        
        photosVC.allowsEditing = true
        
        present(photosVC, animated: true, completion: nil)
        
    }
    
    @IBAction func actionCancelPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func actionDonePressed(_ sender: UIBarButtonItem) {
        
        delegate.photoSelectionDidEnd(selectedPhoto)
        
        dismiss(animated: true, completion: nil)
    }
    

}



extension ANPhotoAddingViewController: UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        
        selectedPhoto = image
        
        photoPreviewImageView.image = image
        
        doneButton.isEnabled = true
        hintLabel.isHidden = true
        
        dismiss(animated: true, completion: nil)
        
    }
    
    
}

























