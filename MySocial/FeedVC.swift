//
//  FeedVCViewController.swift
//  MySocial
//
//  Created by Fabian Menn on 8/25/17.
//  Copyright © 2017 Fabian Menn. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper
import Firebase

class FeedVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var captionField: FancyField!
    @IBOutlet weak var imageAdd: CircleView!

    
    var posts = [Post]()
    
    var userProfileImgUrl: String = ""

    var imagePicker: UIImagePickerController!
    static var imageCache: NSCache<NSString, UIImage> = NSCache()
    var imageSelected = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        
        DataService.ds.REF_POSTS.observe(.value, with: { (snapshot) in
            print("snapvalue: \(snapshot.children.allObjects)")
            
            self.posts = []
            
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                for snap in snapshot {
                    print("snaap: \(snap.value)")
                    
                    if let postDict = snap.value as? Dictionary<String, Any> {
                        let postId = snap.key
                        let post = Post(postId: postId, postData: postDict)
                        self.posts.append(post)
                    }
                }
            }
            self.getUserInfos()
                        //self.tableView.reloadData()
        })
        
        
        
        

        
    }
    
    func getUserInfos() {
        DataService.ds.REF_USERS.observe(.value, with: { (snapshot) in
            
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                for snap in snapshot {
                    //print("FABIAN snaap: \(snap)")
                    if let postDict = snap.value as? Dictionary<String, Any> {
                        //print("FABIAN: value \(snap.key)")
                        for post in self.posts {
                            if post.userId == snap.key {
                                post.username = postDict["username"] as! String
                                //print("FABIAN: \(postDict["username"])")
                                post.userImgUrl = postDict["imageUrl"] as! String
                                //print("test: \(post.username)")
                            }
                            
                        }
                    }
                }
                for post in self.posts {
                    print("huhu: name \(post.username)")
                    print("huhu: id \(post.userId)")
                    print("newcaption \(post.caption)")
                }
            }
            
            self.tableView.reloadData()
        })
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("count: \(posts.count)")
        return posts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let post = posts[indexPath.row]
        
        print("test count: \(posts.count)")
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as? PostCellTableViewCell {
            
            //getUsersInfos(post: post)
            var userImageCache: UIImage? = nil
            
            if let userImg = ProfileConfigVC.imageCache.object(forKey: post.userImgUrl as NSString) {
                userImageCache = userImg
            }
            
            //if let userImg = ProfileConfigVC.imageCache.object(forKey: post.userImgUrl as NSString) {
                //print("FABIAN: profile image url \(post.userImgUrl)")
                if let img = FeedVC.imageCache.object(forKey: post.imageUrl as NSString) {
                    cell.configureCell(post: post, postPic: img, profilePic: userImageCache)
                //}
            } else {
                cell.configureCell(post: post)
            }
            return cell
        }
        
        return UITableViewCell()
    }
    
    // solution by me
//    func getUsersInfos(post: Post) {
//         
//        // get username from user id
//        DataService.ds.REF_USERS.observe(.value, with: { (snapshot) in
//            
//            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
//                for snap in snapshot {
//                    //print("FABIAN snaap: \(snap)")
//                    if let postDict = snap.value as? Dictionary<String, Any> {
//                        //print("FABIAN: value \(snap.key)")
//                        if post.userId == snap.key {
//                            //print("FABIAN: \(postDict["username"])")
//                            self.userProfileImgUrl = postDict["imageUrl"] as! String
//                        }
//                        
//                    }
//                }
//            }
//        })
//
//    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            imageAdd.image = image
            imageSelected = true
        } else {
            print("FABIAN: No valid image selected")
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addImageTapped(_ sender: Any) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func postBtnTapped(_ sender: Any) {
        guard let caption = captionField.text, caption != "" else {
            print("FABIAN: Caption must be entered")
            let alert = UIAlertController(title: "Incorrect Post", message: "Caption must be entered", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Try again", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        guard let img = imageAdd.image, imageSelected == true else {
            let alert = UIAlertController(title: "Incorrect Post", message: "No image selected", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Try again", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            print("FABIAN: An image must be selected")
            return
        }
        
        if let imgData = UIImageJPEGRepresentation(img, 0.2) {
            
            let imageUid = NSUUID().uuidString
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            
            DataService.ds.REF_POST_IMAGES.child(imageUid).putData(imgData, metadata: metadata) { (metadata, error) in
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
    
    func postToFirebase(imgUrl: String) {
        let post: Dictionary<String, Any> = ["caption": captionField.text, "userId": KeychainWrapper.standard.string(forKey: KEY_UID), "imageUrl": imgUrl, "likes":0]
        
        let firebasePost = DataService.ds.REF_POSTS.childByAutoId()
        firebasePost.setValue(post)
        
        captionField.text = ""
        imageSelected = false
        imageAdd.image = UIImage(named: "add-image")
        tableView.reloadData()
    }
    
    @IBAction func signOutPressed(_ sender: Any) {
        let keychainResult = KeychainWrapper.standard.remove(key: KEY_UID)
        print("FABIAN: ID removed from keychain \(keychainResult)")
        try! Auth.auth().signOut()
        performSegue(withIdentifier: "toSignInVC", sender: nil)
    }
}
