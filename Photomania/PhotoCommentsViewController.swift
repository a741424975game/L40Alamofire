//
//  PhotoCommentsViewController.swift
//  Photomania
//
//  Created by Essan Parto on 2014-08-25.
//  Copyright (c) 2014 Essan Parto. All rights reserved.
//

import UIKit
import Alamofire

class PhotoCommentsViewController: UITableViewController {
  var photoID: Int = 0
  var comments: [Comment]?
  
    @IBOutlet weak var spinner: UIActivityIndicatorView!
  // MARK: Life-Cycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    spinner.startAnimating()
    self.tableView.addSubview(spinner)
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.estimatedRowHeight = 50.0
    
    title = "Comments"
    navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .Done, target: self, action: #selector(PhotoCommentsViewController.dismiss))
        loadComment()
  }
    func loadComment() {
        Alamofire.request(Five100px.Router.Comment(photoID)).responseComment { (response) in
           self.comments = response.result.value!.map({ (comment) -> Comment in
            Comment(comment: comment)
           })
            self.spinner.stopAnimating()
            self.tableView.reloadData()
        }
    }
  
  func dismiss() {
    dismissViewControllerAnimated(true, completion: nil)
  }
  
  // MARK: - TableView
  
    
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return comments?.count ?? 0
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("CommentCell", forIndexPath: indexPath) as! PhotoCommentTableViewCell
    
    cell.spinner.startAnimating()
    Alamofire.request(.GET, comments![indexPath.row].userPictureURL).responseImage { (response) in
        if response.result.value != nil {
        cell.userImageView.image = response.result.value!
            cell.spinner.stopAnimating()
        }
    }
    cell.commentLabel.text = comments![indexPath.row].commentBody
    cell.userFullnameLabel.text = comments![indexPath.row].userFullname
    return cell
  }
}

class PhotoCommentTableViewCell: UITableViewCell {
  @IBOutlet weak var userImageView: UIImageView!
  @IBOutlet weak var commentLabel: UILabel!
  @IBOutlet weak var userFullnameLabel: UILabel!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
  override func awakeFromNib() {
    super.awakeFromNib()
    
    userImageView.layer.cornerRadius = 5.0
    userImageView.layer.masksToBounds = true
    
    commentLabel.numberOfLines = 0
  }
}