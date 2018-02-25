//
//  ChatViewController.swift
//  ParseChat
//
//  Created by Daniel Calderon on 2/24/18.
//  Copyright © 2018 Daniel Calderon. All rights reserved.
//

import UIKit
import Parse

class ChatViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {

    
 
    @IBOutlet weak var chatMessageField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var chatTableView: UITableView!
    
    var messages: [String] = []
    var usernames: [String] = []
    
    var alertController: UIAlertController!
    var refreshControl: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "Chat"
        chatTableView.separatorStyle = .none
        chatTableView.delegate = self
        chatTableView.dataSource = self
        
        chatTableView.rowHeight = UITableViewAutomaticDimension
        chatTableView.estimatedRowHeight = 120
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(ChatViewController.didPullToRefresh(_:)), for: .valueChanged)
        chatTableView.insertSubview(refreshControl, at: 0)
        
        sendButton.isEnabled = false
        alertController = UIAlertController(title: "", message: "Are you sure?", preferredStyle: .actionSheet)
        let logoutButton = UIAlertAction(title: "Logout", style: .destructive) { (action) in
            NotificationCenter.default.post(name: NSNotification.Name("didLogout"), object: nil)
        }
        
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            // Nothing
        }
        
        alertController.addAction(logoutButton)
        alertController.addAction(cancelButton)
        
        chatMessageField.addTarget(self, action: #selector(ChatViewController.textDidChange(_:)), for: .editingChanged)
        
        fetchMessages(nil)
        
        Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.fetchMessages(_:)), userInfo: nil, repeats: true)
    }
    @objc func didPullToRefresh(_ refreshControl: UIRefreshControl){
        fetchMessages(nil)
    }
    @objc func textDidChange(_ textField: UITextField){
        if(chatMessageField.text?.isEmpty)!{
            sendButton.isEnabled = false
        }
        else{
            sendButton.isEnabled = true
        }
    }
    @IBAction func onTapSend(_ sender: Any) {
        let user = PFUser.current()
        let chatMessage = PFObject(className: "Message")
        chatMessage["text"] = chatMessageField.text ?? ""
        chatMessage["user"] = user
        chatMessage.saveInBackground { (success, error) in
            if success {
                print("The message was saved!")
                self.chatMessageField.text = ""
                self.sendButton.isEnabled = false
            } else if let error = error {
                print("Problem saving message: \(error.localizedDescription)")
            }
        }
    }
    @objc func fetchMessages(_ sender:Any?){
        
        let df = DateFormatter()
        df.dateStyle = .short
        df.timeStyle = .short
        
        let query = PFQuery(className: "Message")
        query.includeKey("user")
        query.order(byDescending: "createdAt")
        query.findObjectsInBackground { (messages, error) in
            if(messages != nil){
                self.messages = []
                self.usernames = []
               
                for message in messages!{
                    self.messages.append(message["text"] as! String)
                    if(message["user"] != nil){
                        self.usernames.append((message["user"] as! PFUser).username!)
                    }
                    else{
                        self.usernames.append("🤖")
                    }
                }
                self.chatTableView.reloadData()
            }
            else{
                print("Info:! \(error?.localizedDescription)")
            }
        }
        self.refreshControl.endRefreshing()
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatCell", for: indexPath) as! ChatCell
        
        cell.messageLabel.text = self.messages[indexPath.row]
        cell.usernameLabel.text = self.usernames[indexPath.row]
        
        return cell
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    @IBAction func onLogOut(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginViewController = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
        self.present(loginViewController, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
