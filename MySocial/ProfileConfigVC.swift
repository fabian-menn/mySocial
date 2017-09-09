//
//  profileConfigVC.swift
//  MySocial
//
//  Created by Fabian Menn on 9/9/17.
//  Copyright © 2017 Fabian Menn. All rights reserved.
//

import UIKit
import Firebase

class ProfileConfigVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var nameField: UITextField!
    
    var usernameRef: DatabaseReference!
    var imageUrlRef: DatabaseReference!
    
    var imagePicker: UIImagePickerController!
    static var imageCache: NSCache<NSString, UIImage> = NSCache()
    var imageSelected = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBAction func nextBtnIsPressed(_ sender: Any) {
        performSegue(withIdentifier: "toFeedVCNew", sender: nil)
        
        guard let username = nameField.text, username != "" else {
            print("FABIAN: Caption must be entered")
            let alert = UIAlertController(title: "Incorrect Post", message: "Caption must be entered", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Try again", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        guard let img = profileImg.image, imageSelected == true else {
            let alert = UIAlertController(title: "Incorrect Sign Up", message: "No image selected", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Try again", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            print("FABIAN: An image must be selected")
            return
        }
        
        if let imgData = UIImageJPEGRepresentation(img, 0.2) {
            
            let imageUid = NSUUID().uuidString
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            
            DataService.ds.REF_USER_IMAGES.child(imageUid).putData(imgData, metadata: metadata) { (metadata, error) in
                if error != nil {
                    print("FABIAN: Unable to upload image to Firebase storage")
                } else {
                    print("FABIAN: Successfully uploaded image to Firebase storage")
                    let downloadURL = metadata?.downloadURL()?.absoluteString
                    if let url = downloadURL {
                        self.postToFirebase(imgUrl: url)
                    }
                    
                }
            }
            
        }
        
    }
    
    @IBAction func profilePicAddPressed(_ sender: Any) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    func postToFirebase(imgUrl: String) {
        let user: Dictionary<String, Any> = ["username": nameField.text, "imageUrl": imgUrl]
        
        let firebasePost = DataService.ds.REF_USER.child()
        firebasePost.setValue(user)
      sd  imageSelected = false
        
dsfdsfdfusernameRef = DataService.ds.REF_USER_CURRENT.child("username")
        self.usernameRef.setValue(nameField.text!)
        
        usernameRef = DataService.ds.REF_USER_CURRENT.child("username")
        self.usernameRef.setValue(nameField.text!)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            profileImg.image = image
            imageSelected = true
        } else {
            print("FABIAN: No valid image selected (ProfileConfigVC")
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }

    
}
