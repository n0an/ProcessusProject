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
    
    
    // MARK: - ATTRIBUTES

    var messageArray = [String]()
    var senderArray = [String]()
    
    var currentUserImage: UIImage?
    var recipientImage: UIImage?
    
    
    
    // MARK: - viewDidLoad

    override func viewDidLoad() {
        super.viewDidLoad()
        
        messageTextView.addSubview(promptLabel)
        self.title = recipientNickname
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ANChatViewController.keyboardDidShow(_:)), name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ANChatViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ANChatViewController.updateChat), name: "updateChatNow", object: nil)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ANChatViewController.didTapScrollView))
        tapGestureRecognizer.numberOfTapsRequired = 1
        
        chatScrollView.addGestureRecognizer(tapGestureRecognizer)
        
        
        
    }
    
    
    override func viewDidAppear(animated: Bool) {
        
        
        var userImageArray = [PFFile]()
        
        let queryForCurrentUser = PFQuery(className: "_User")
        
        queryForCurrentUser.whereKey("username", equalTo: currentUserName)
        
        queryForCurrentUser.findObjectsInBackgroundWithBlock { (objects: [PFObject]?, error: NSError?) in
            for object in objects! {
                userImageArray.append(object["image"] as! PFFile)
                userImageArray.first?.getDataInBackgroundWithBlock({ (imageData: NSData?, error: NSError?) in
                    if error == nil {
                        self.currentUserImage = UIImage(data: imageData!)
                        userImageArray.removeAll(keepCapacity: false)
                    }
                })
            }
            
            let queryForRecipientUser = PFQuery(className: "_User")
            
            queryForRecipientUser.whereKey("username", equalTo: recipientNickname)
            
            queryForRecipientUser.findObjectsInBackgroundWithBlock { (objects: [PFObject]?, error: NSError?) in
                for object in objects! {
                    userImageArray.append(object["image"] as! PFFile)
                    userImageArray.first?.getDataInBackgroundWithBlock({ (imageData: NSData?, error: NSError?) in
                        if error == nil {
                            self.recipientImage = UIImage(data: imageData!)
                            userImageArray.removeAll(keepCapacity: false)
                        }
                    })
                }
                
            }
            
            self.updateChat()
        }
        
    }
    
    
    
    
    // MARK: - NOTIFICATIONS
    
    func keyboardDidShow(notificaton: NSNotification) {
        
        let dict: NSDictionary = notificaton.userInfo!
        let keyboardSize: NSValue = dict.valueForKey(UIKeyboardFrameEndUserInfoKey) as! NSValue
        let frameKeyboardSize: CGRect = keyboardSize.CGRectValue()
        
        UIView.animateWithDuration(0.3, animations: {
            
            self.chatScrollView.frame.size.height -= frameKeyboardSize.height
            self.messageView.frame.origin.y -= frameKeyboardSize.height
            
            let scrollViewOffset: CGPoint = CGPointMake(0, self.chatScrollView.contentSize.height - self.chatScrollView.bounds.height)
            
            self.chatScrollView.setContentOffset(scrollViewOffset, animated: true)
            
            
        }) { (finished: Bool) in
            
        }
        
    }
    
    
    func keyboardWillHide(notificaton: NSNotification) {
        
        let dict: NSDictionary = notificaton.userInfo!
        let keyboardSize: NSValue = dict.valueForKey(UIKeyboardFrameEndUserInfoKey) as! NSValue
        let frameKeyboardSize: CGRect = keyboardSize.CGRectValue()
        
        UIView.animateWithDuration(0.3, animations: {
            
            self.chatScrollView.frame.size.height += frameKeyboardSize.height
            self.messageView.frame.origin.y += frameKeyboardSize.height
            
        }) { (finished: Bool) in
            
        }
        
    }
    
    
    
    // MARK: - HELPER METHODS
    
    func textViewDidChange(textView: UITextView) {
        self.promptLabel.hidden = messageTextView.hasText() ? true : false
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if self.messageTextView.hasText() {
            self.promptLabel.hidden = false
        }
    }
    
    
    
    func updateChat() {
        
        let messageMarginX: CGFloat = 45
        var messageMarginY: CGFloat = 27
        
        let bubbleMarginX: CGFloat = 40
        var bubbleMarginY: CGFloat = 21
        
        let imageMarginX: CGFloat = 15
        var imageMarginY: CGFloat = 5
        
        
        messageArray.removeAll(keepCapacity: false)
        senderArray.removeAll(keepCapacity: false)
        
        let predicate1 = NSPredicate(format: "sender = %@ AND recipient = %@", currentUserName, recipientNickname)
        
        let predicate2 = NSPredicate(format: "sender = %@ AND recipient = %@", recipientNickname, currentUserName)
        
        
        let query1 = PFQuery(className: "Message", predicate: predicate1)
        let query2 = PFQuery(className: "Message", predicate: predicate2)
        
        let resultQuery = PFQuery.orQueryWithSubqueries([query1, query2])
        resultQuery.addAscendingOrder("createdAt")
        
        resultQuery.findObjectsInBackgroundWithBlock { (objects: [PFObject]?, error: NSError?) in
            if error == nil {
                for object in objects! {
                    self.senderArray.append(object.objectForKey("sender") as! String)
                    self.messageArray.append(object.objectForKey("message") as! String)
                }
                
                for i in 0..<self.messageArray.count {
                    
                    if self.senderArray[i] == currentUserName {
                        
                        // !!!IMPORTANT!!!
                        // ** CREATING UILABEL MANUALLY
                        let messageLabel = UILabel()
                        messageLabel.text = self.messageArray[i]
                        messageLabel.frame = CGRectMake(0, 0, self.chatScrollView.frame.size.width - 90, CGFloat.max)
                        messageLabel.backgroundColor = UIColor(red: CGFloat(176 / 255), green: CGFloat(255 / 255), blue: CGFloat(215 / 255), alpha: 1.0)
                        
                        messageLabel.numberOfLines = 0
                        messageLabel.lineBreakMode = .ByWordWrapping
                        messageLabel.sizeToFit()
                        messageLabel.textAlignment = .Left
                        
                        messageLabel.font = UIFont(name: "Apple SD Gothic Neo", size: 16)
                        messageLabel.textColor = UIColor.blackColor()
                        
                        messageLabel.frame.origin.x = self.chatScrollView.frame.size.width - messageMarginX - messageLabel.frame.size.width
                        messageLabel.frame.origin.y = messageMarginY
                        
                        messageMarginY += messageLabel.frame.size.height + 30
                        
                        self.chatScrollView.addSubview(messageLabel)
                        
                        
                        let bubbleLabel = UILabel()
                        bubbleLabel.frame.size = CGSizeMake(messageLabel.frame.size.width + 10, messageLabel.frame.height + 10)
                        bubbleLabel.frame.origin.x = self.chatScrollView.frame.size.width - bubbleMarginX - bubbleLabel.frame.size.width
                        bubbleLabel.frame.origin.y = bubbleMarginY
                        bubbleMarginY +=  bubbleLabel.frame.size.height + 20
                        
                        bubbleLabel.layer.cornerRadius = 10
                        // !!!IMPORTANT!!!
                        bubbleLabel.clipsToBounds = true
                        bubbleLabel.backgroundColor = UIColor(red: CGFloat(176 / 255), green: CGFloat(255 / 255), blue: CGFloat(215 / 255), alpha: 1.0)
                        
                        self.chatScrollView.addSubview(bubbleLabel)
                        
                        
                        // !!!IMPORTANT
                        // ** SETTING SCROLLVIEW SIZE
                        let width = self.view.frame.size.width
                        self.chatScrollView.contentSize = CGSizeMake(width, messageMarginY)
                        
                        // !!!IMPORTANT
                        self.chatScrollView.bringSubviewToFront(messageLabel)
                        
                        let senderImage = UIImageView()
                        senderImage.image = self.currentUserImage
                        senderImage.frame.size = CGSize(width: 35, height: 35)
                        senderImage.frame.origin = CGPoint(x: self.chatScrollView.frame.size.width - senderImage.frame.size.width - imageMarginX, y: imageMarginY)
                        
                        senderImage.layer.cornerRadius = senderImage.frame.size.width / 2
                        senderImage.clipsToBounds = true
                        
                        self.chatScrollView.addSubview(senderImage)
                        
                        imageMarginY += bubbleLabel.frame.size.height + 20
                        
                        self.chatScrollView.bringSubviewToFront(senderImage)
                        
                    } else {
                        
                        let messageLabel = UILabel()
                        messageLabel.text = self.messageArray[i]
                        messageLabel.frame = CGRectMake(0, 0, self.chatScrollView.frame.size.width - 90, CGFloat.max)
                        messageLabel.backgroundColor = UIColor.whiteColor()
                        
                        messageLabel.numberOfLines = 0
                        messageLabel.lineBreakMode = .ByWordWrapping
                        messageLabel.sizeToFit()
                        messageLabel.textAlignment = .Left
                        
                        messageLabel.font = UIFont(name: "Apple SD Gothic Neo", size: 16)
                        messageLabel.textColor = UIColor.blackColor()
                        
                        messageLabel.frame.origin.x = messageMarginX
                        messageLabel.frame.origin.y = messageMarginY
                        messageMarginY += messageLabel.frame.size.height + 30
                        
                        self.chatScrollView.addSubview(messageLabel)
                        
                        let bubbleLabel = UILabel()
                        
                        bubbleLabel.frame = CGRectMake(bubbleMarginX, bubbleMarginY, messageLabel.frame.size.width + 10, messageLabel.frame.size.height + 10)
                        
                        bubbleMarginY += bubbleLabel.frame.size.height + 20
                        
                        bubbleLabel.layer.cornerRadius = 10
                        // !!!IMPORTANT!!!
                        bubbleLabel.clipsToBounds = true
                        bubbleLabel.backgroundColor = UIColor.whiteColor()
                        
                        self.chatScrollView.addSubview(bubbleLabel)
                        
                        
                        // !!!IMPORTANT
                        // ** SETTING SCROLLVIEW SIZE
                        let width = self.view.frame.size.width
                        self.chatScrollView.contentSize = CGSizeMake(width, messageMarginY)
                        
                        self.chatScrollView.bringSubviewToFront(messageLabel)
                        
                        
                        let senderImage = UIImageView()
                        senderImage.image = self.recipientImage
                        
                        senderImage.frame = CGRectMake(imageMarginX, imageMarginY, 35, 35)
                        senderImage.layer.cornerRadius = senderImage.frame.size.width / 2
                        senderImage.clipsToBounds = true
                        
                        self.chatScrollView.addSubview(senderImage)
                        
                        imageMarginY += bubbleLabel.frame.size.height + 20
                        
                        self.chatScrollView.bringSubviewToFront(senderImage)
                        
                    }
                    
                    let scrollViewOffset: CGPoint = CGPointMake(0, self.chatScrollView.contentSize.height - self.chatScrollView.bounds.height)
                    
                    self.chatScrollView.setContentOffset(scrollViewOffset, animated: true)
                    
                }
            }
        }
        
    }
    
    
    
    // MARK: - ACTIONS
    
    func didTapScrollView() {
        self.view.endEditing(true)
    }
    
    
    @IBAction func sendButtonPressed(sender: AnyObject) {
        
        didTapScrollView()
        
        if messageTextView.text.isEmpty {
            print("No text in the message")
        } else {
            let messageDB = PFObject(className: "Message")
            
            messageDB["sender"] = currentUserName
            messageDB["recipient"] = recipientNickname
            messageDB["message"] = self.messageTextView.text
            
            messageDB.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) in
                
                if success {
                    
                    let userQuery: PFQuery = PFUser.query()!
                    userQuery.whereKey("username", equalTo: recipientNickname)
                    
                    let pushQuery = PFInstallation.query()!
                    pushQuery.whereKey("user", matchesQuery: userQuery)
                    
                    let push: PFPush = PFPush()
                    push.setQuery(pushQuery)
                    push.setMessage("Processus: New message!")
                    
                    do {
                        try push.sendPush()
                        print("notification has sent")
                        
                    } catch let error as NSError {
                        print("notification error: \(error.localizedDescription)")
                    }
                    
                    print("message saved")
                    self.messageTextView.text = ""
                    self.promptLabel.hidden = false
                    self.updateChat()
                    
                } else {
                    print("Message not saved because of error: \(error?.localizedDescription)")
                }
                
            })
            
        }
        
    }
    
    
    
    
    
}
