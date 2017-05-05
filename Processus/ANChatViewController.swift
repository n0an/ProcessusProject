//
//  ANChatViewController.swift
//  Processus
//
//  Created by Anton Novoselov on 04/06/16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

import UIKit
import Parse

var recipientEmail = ""
var recipientNickname = ""

class ANChatViewController: UIViewController, UITextViewDelegate {
    
    
    // MARK: - OUTLETS
    
    @IBOutlet weak var chatScrollView: UIScrollView!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var promptLabel: UILabel!
    
    @IBOutlet weak var messageView: UIView!
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    // MARK: - ATTRIBUTES

    var messageArray = [String]()
    var senderArray = [String]()
    
    var currentUserImage: UIImage?
    var recipientImage: UIImage?
    
    var timer: Timer!
    
    // MARK: - viewDidLoad

    override func viewDidLoad() {
        super.viewDidLoad()
        
        messageTextView.addSubview(promptLabel)
        self.title = recipientNickname
        
        NotificationCenter.default.addObserver(self, selector: #selector(ANChatViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ANChatViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)

        
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ANChatViewController.updateChat), name: "updateChatNow", object: nil)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ANChatViewController.didTapScrollView))
        tapGestureRecognizer.numberOfTapsRequired = 1
        
        chatScrollView.addGestureRecognizer(tapGestureRecognizer)
        
        timer = Timer.scheduledTimer(timeInterval: 20, target: self, selector: #selector(ANChatViewController.updateViaTimer), userInfo: nil, repeats: true)
        
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        
        var userImageArray = [PFFile]()
        
        let queryForCurrentUser = PFQuery(className: "_User")
        
        queryForCurrentUser.whereKey("username", equalTo: currentUserName)
        
        queryForCurrentUser.findObjectsInBackground { (objects: [PFObject]?, error: NSError?) in
            for object in objects! {
                userImageArray.append(object["image"] as! PFFile)
                userImageArray.first?.getDataInBackground(block: { (imageData: Data?, error: NSError?) in
                    if error == nil {
                        self.currentUserImage = UIImage(data: imageData!)
                        userImageArray.removeAll(keepingCapacity: false)
                    }
                })
            }
            
            let queryForRecipientUser = PFQuery(className: "_User")
            
            queryForRecipientUser.whereKey("username", equalTo: recipientNickname)
            
            queryForRecipientUser.findObjectsInBackground { (objects: [PFObject]?, error: NSError?) in
                for object in objects! {
                    userImageArray.append(object["image"] as! PFFile)
                    userImageArray.first?.getDataInBackground(block: { (imageData: Data?, error: NSError?) in
                        if error == nil {
                            self.recipientImage = UIImage(data: imageData!)
                            userImageArray.removeAll(keepingCapacity: false)
                        }
                    })
                }
                
            }
            
            self.updateChat()
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        timer.invalidate()
    }
    
    
    // MARK: - NOTIFICATIONS
    
    
    func keyboardWillShow(_ notification: Notification) {
        updateBottomConstraint(notification, showing: true)
     
        
    }
    
    func keyboardWillHide(_ notification: Notification) {
        updateBottomConstraint(notification, showing: false)
    }

    
    
    
    
    // MARK: - HELPER METHODS
    
    func updateBottomConstraint(_ notification: Notification, showing: Bool) {
        
        
        if let
            userInfo = notification.userInfo,
            let frame = (userInfo[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue,
            let animationDuration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue {
            
            let newFrame = view.convert(frame, from: (UIApplication.shared.delegate?.window)!)
            
            let diff = showing ? 49 : 0
            
            bottomConstraint.constant = view.frame.height - newFrame.origin.y - CGFloat(diff)
            
            UIView.animate(withDuration: animationDuration, animations: {
                self.view.layoutIfNeeded()
                
                if showing {
                    let scrollViewOffset: CGPoint = CGPoint(x: 0, y: self.chatScrollView.contentSize.height - self.chatScrollView.bounds.height)
                    
                    self.chatScrollView.setContentOffset(scrollViewOffset, animated: true)
                }
                
                
            })
            
           
        }
        
    }
    
    
    
    func textViewDidChange(_ textView: UITextView) {
        self.promptLabel.isHidden = messageTextView.hasText ? true : false
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if self.messageTextView.hasText {
            self.promptLabel.isHidden = false
        }
    }
    
    
    func updateViaTimer() {
        
        updateChat()
    }
    
    
    func updateChat() {
        
        let messageMarginX: CGFloat = 45
        var messageMarginY: CGFloat = 27
        
        let bubbleMarginX: CGFloat = 40
        var bubbleMarginY: CGFloat = 21
        
        let imageMarginX: CGFloat = 15
        var imageMarginY: CGFloat = 5
        
        
        messageArray.removeAll(keepingCapacity: false)
        senderArray.removeAll(keepingCapacity: false)
        
        let predicate1 = NSPredicate(format: "sender = %@ AND recipient = %@", currentUserName, recipientNickname)
        
        let predicate2 = NSPredicate(format: "sender = %@ AND recipient = %@", recipientNickname, currentUserName)
        
        
        let query1 = PFQuery(className: "Message", predicate: predicate1)
        let query2 = PFQuery(className: "Message", predicate: predicate2)
        
        let resultQuery = PFQuery.orQuery(withSubqueries: [query1, query2])
        resultQuery.addAscendingOrder("createdAt")
        
        resultQuery.findObjectsInBackground { (objects: [PFObject]?, error: NSError?) in
            if error == nil {
                for object in objects! {
                    self.senderArray.append(object.object(forKey: "sender") as! String)
                    self.messageArray.append(object.object(forKey: "message") as! String)
                }
                
                for i in 0..<self.messageArray.count {
                    
                    if self.senderArray[i] == currentUserName {
                        
                        let messageLabel = UILabel()
                        messageLabel.text = self.messageArray[i]
                        messageLabel.frame = CGRect(x: 0, y: 0, width: self.chatScrollView.frame.size.width - 90, height: CGFloat.greatestFiniteMagnitude)
                        messageLabel.backgroundColor = UIColor(red: CGFloat(176 / 255), green: CGFloat(255 / 255), blue: CGFloat(215 / 255), alpha: 1.0)
                        
                        messageLabel.numberOfLines = 0
                        messageLabel.lineBreakMode = .byWordWrapping
                        messageLabel.sizeToFit()
                        messageLabel.textAlignment = .left
                        
                        messageLabel.font = UIFont(name: "Apple SD Gothic Neo", size: 16)
                        messageLabel.textColor = UIColor.black
                        
                        messageLabel.frame.origin.x = self.chatScrollView.frame.size.width - messageMarginX - messageLabel.frame.size.width
                        messageLabel.frame.origin.y = messageMarginY
                        
                        messageMarginY += messageLabel.frame.size.height + 30
                        
                        self.chatScrollView.addSubview(messageLabel)
                        
                        let bubbleLabel = UILabel()
                        bubbleLabel.frame.size = CGSize(width: messageLabel.frame.size.width + 10, height: messageLabel.frame.height + 10)
                        bubbleLabel.frame.origin.x = self.chatScrollView.frame.size.width - bubbleMarginX - bubbleLabel.frame.size.width
                        bubbleLabel.frame.origin.y = bubbleMarginY
                        bubbleMarginY +=  bubbleLabel.frame.size.height + 20
                        
                        bubbleLabel.layer.cornerRadius = 10
                        
                        bubbleLabel.clipsToBounds = true
                        bubbleLabel.backgroundColor = UIColor(red: CGFloat(176 / 255), green: CGFloat(255 / 255), blue: CGFloat(215 / 255), alpha: 1.0)
                        
                        self.chatScrollView.addSubview(bubbleLabel)
                        
                        // ** SETTING SCROLLVIEW SIZE
                        let width = self.view.frame.size.width
                        self.chatScrollView.contentSize = CGSize(width: width, height: messageMarginY)
                        
                        self.chatScrollView.bringSubview(toFront: messageLabel)
                        
                        let senderImage = UIImageView()
                        senderImage.image = self.currentUserImage
                        senderImage.frame.size = CGSize(width: 35, height: 35)
                        senderImage.frame.origin = CGPoint(x: self.chatScrollView.frame.size.width - senderImage.frame.size.width - imageMarginX, y: imageMarginY)
                        
                        senderImage.layer.cornerRadius = senderImage.frame.size.width / 2
                        senderImage.clipsToBounds = true
                        
                        self.chatScrollView.addSubview(senderImage)
                        
                        imageMarginY += bubbleLabel.frame.size.height + 20
                        
                        self.chatScrollView.bringSubview(toFront: senderImage)
                        
                    } else {
                        
                        let messageLabel = UILabel()
                        messageLabel.text = self.messageArray[i]
                        messageLabel.frame = CGRect(x: 0, y: 0, width: self.chatScrollView.frame.size.width - 90, height: CGFloat.greatestFiniteMagnitude)
                        messageLabel.backgroundColor = UIColor.white
                        
                        messageLabel.numberOfLines = 0
                        messageLabel.lineBreakMode = .byWordWrapping
                        messageLabel.sizeToFit()
                        messageLabel.textAlignment = .left
                        
                        messageLabel.font = UIFont(name: "Apple SD Gothic Neo", size: 16)
                        messageLabel.textColor = UIColor.black
                        
                        messageLabel.frame.origin.x = messageMarginX
                        messageLabel.frame.origin.y = messageMarginY
                        messageMarginY += messageLabel.frame.size.height + 30
                        
                        self.chatScrollView.addSubview(messageLabel)
                        
                        let bubbleLabel = UILabel()
                        
                        bubbleLabel.frame = CGRect(x: bubbleMarginX, y: bubbleMarginY, width: messageLabel.frame.size.width + 10, height: messageLabel.frame.size.height + 10)
                        
                        bubbleMarginY += bubbleLabel.frame.size.height + 20
                        
                        bubbleLabel.layer.cornerRadius = 10
                        
                        bubbleLabel.clipsToBounds = true
                        bubbleLabel.backgroundColor = UIColor.white
                        
                        self.chatScrollView.addSubview(bubbleLabel)
                        
                        
                        // ** SETTING SCROLLVIEW SIZE
                        let width = self.view.frame.size.width
                        self.chatScrollView.contentSize = CGSize(width: width, height: messageMarginY)
                        
                        self.chatScrollView.bringSubview(toFront: messageLabel)
                        
                        
                        let senderImage = UIImageView()
                        senderImage.image = self.recipientImage
                        
                        senderImage.frame = CGRect(x: imageMarginX, y: imageMarginY, width: 35, height: 35)
                        senderImage.layer.cornerRadius = senderImage.frame.size.width / 2
                        senderImage.clipsToBounds = true
                        
                        self.chatScrollView.addSubview(senderImage)
                        
                        imageMarginY += bubbleLabel.frame.size.height + 20
                        
                        self.chatScrollView.bringSubview(toFront: senderImage)
                        
                    }
                    
                    let scrollViewOffset: CGPoint = CGPoint(x: 0, y: self.chatScrollView.contentSize.height - self.chatScrollView.bounds.height)
                    
                    self.chatScrollView.setContentOffset(scrollViewOffset, animated: true)
                    
                }
            }
        }
        
    }
    
    
    
    // MARK: - ACTIONS
    
    func didTapScrollView() {
        self.view.endEditing(true)
    }
    
    
    @IBAction func sendButtonPressed(_ sender: AnyObject) {
        
        didTapScrollView()
        
        if messageTextView.text.isEmpty {
            
        } else {
            let messageDB = PFObject(className: "Message")
            
            messageDB["sender"] = currentUserName
            messageDB["recipient"] = recipientNickname
            messageDB["message"] = self.messageTextView.text
            
            messageDB.saveInBackground(block: { (success: Bool, error: NSError?) in
                
                if success {
                    
       
                    self.messageTextView.text = ""
                    self.promptLabel.isHidden = false
                    
                    self.updateChat()
                    
                } else {
                    print("Message not saved because of error: \(error?.localizedDescription)")
                }
                
            })
            
        }
        
    }
    
    
    
    
    
}
