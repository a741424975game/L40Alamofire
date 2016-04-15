//
//  PhotoViewerViewController.swift
//  Photomania
//
//  Created by Essan Parto on 2014-08-24.
//  Copyright (c) 2014 Essan Parto. All rights reserved.
//

import UIKit
import QuartzCore
import Alamofire

class PhotoViewerViewController: UIViewController, UIScrollViewDelegate, UIPopoverPresentationControllerDelegate, UIActionSheetDelegate {
  var photoID: Int = 0
    var imageUrl: String = ""
    
  
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
//  let scrollView = UIScrollView()
//  let spinner = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
  
  var photoInfo: PhotoInfo?
  
  // MARK: Life-Cycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupView()
    
    
    if photoInfo != nil {
        photoID = (photoInfo?.id)!
        self.getHighDefinitionPhoto(self.photoID)
    }
  }
    
    func getHighDefinitionPhoto(photoID: Int) {
        //调用my500pxAPI 详见https://github.com/a741424975game/my500pxAPI ps:官方的高清图有水印 所以自己爬了个
        let url = "http://gzpweb.imwork.net/photo/\(photoID)"
        
        Alamofire.request(.GET, url).responseJSON { (response) in
            if let str = response.result.value?.valueForKey("imageUrl") {
                self.imageUrl = (str as? String)!
                Alamofire.request(.GET, self.imageUrl).responseImage(completionHandler: { (response) in
                    self.imageView.image = response.result.value!
                    self.addButtomBar()
                })
            }
        }
    }
  
  func setupView() {
    navigationController?.setNavigationBarHidden(false, animated: true)
    
    self.spinner.center = CGPoint(x: view.center.x, y: view.center.y - view.bounds.origin.y / 2.0)
    self.spinner.hidesWhenStopped = true
    self.spinner.startAnimating()
    
    self.view.addSubview(spinner)
    
//    self.scrollView.frame = view.bounds
    self.scrollView.delegate = self
    self.scrollView.minimumZoomScale = 1.0
    self.scrollView.maximumZoomScale = 3.0
    self.scrollView.zoomScale = 1.0
    
    self.view.addSubview(scrollView)
    

    self.scrollView.addSubview(imageView)
    
    let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(PhotoViewerViewController.handleDoubleTap(_:)))
    doubleTapRecognizer.numberOfTapsRequired = 2
    doubleTapRecognizer.numberOfTouchesRequired = 1
    scrollView.addGestureRecognizer(doubleTapRecognizer)
    
    let singleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(PhotoViewerViewController.handleSingleTap(_:)))
    singleTapRecognizer.numberOfTapsRequired = 1
    singleTapRecognizer.numberOfTouchesRequired = 1
    singleTapRecognizer.requireGestureRecognizerToFail(doubleTapRecognizer)
    self.scrollView.addGestureRecognizer(singleTapRecognizer)
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    if photoInfo != nil {
      navigationController?.setToolbarHidden(false, animated: true)
    }
  }
  
  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    navigationController?.setToolbarHidden(true, animated: true)
  }
  
  // MARK: Bottom Bar
  
  func addButtomBar() {
    var items = [UIBarButtonItem]()
    
    let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
    
    items.append(barButtonItemWithImageNamed("hamburger", title: nil, action: #selector(PhotoViewerViewController.showDetails)))
    
    if photoInfo?.commentsCount > 0 {
      items.append(barButtonItemWithImageNamed("bubble", title: "\(photoInfo?.commentsCount ?? 0)", action: #selector(PhotoViewerViewController.showComments)))
    }
    
    items.append(flexibleSpace)
    items.append(UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Action, target: self, action: #selector(PhotoViewerViewController.showActions)))
    items.append(flexibleSpace)
    
    items.append(barButtonItemWithImageNamed("like", title: "\(photoInfo?.votesCount ?? 0)"))
    items.append(barButtonItemWithImageNamed("heart", title: "\(photoInfo?.favoritesCount ?? 0)"))
    
    self.setToolbarItems(items, animated: true)
    navigationController?.setToolbarHidden(false, animated: true)
    
    navigationItem.rightBarButtonItem = UIBarButtonItem(customView: userInfoViewForPhotoInfo(photoInfo!))
  }
  
  func userInfoViewForPhotoInfo(photoInfo: PhotoInfo) -> UIView {
    let userProfileImageView = UIImageView(frame: CGRect(x: 0, y: 10.0, width: 30.0, height: 30.0))
    userProfileImageView.layer.cornerRadius = 3.0
    userProfileImageView.layer.masksToBounds = true
    
    return userProfileImageView
  }

  func showDetails() {
    let photoDetailsViewController = storyboard?.instantiateViewControllerWithIdentifier("PhotoDetails") as? PhotoDetailsViewController
    photoDetailsViewController?.modalPresentationStyle = .OverCurrentContext
    photoDetailsViewController?.modalTransitionStyle = .CoverVertical
    photoDetailsViewController?.photoInfo = photoInfo
    
    presentViewController(photoDetailsViewController!, animated: true, completion: nil)
  }
  
  func showComments() {
    let photoCommentsViewController = storyboard?.instantiateViewControllerWithIdentifier("PhotoComments") as? PhotoCommentsViewController
    photoCommentsViewController?.modalPresentationStyle = .Popover
    photoCommentsViewController?.modalTransitionStyle = .CoverVertical
    photoCommentsViewController?.photoID = photoID
    photoCommentsViewController?.popoverPresentationController?.delegate = self
    presentViewController(photoCommentsViewController!, animated: true, completion: nil)
  }
  
  func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
    return UIModalPresentationStyle.OverCurrentContext
  }
  
  func presentationController(controller: UIPresentationController, viewControllerForAdaptivePresentationStyle style: UIModalPresentationStyle) -> UIViewController? {
    let navController = UINavigationController(rootViewController: controller.presentedViewController)
    
    return navController
  }
  
  func barButtonItemWithImageNamed(imageName: String?, title: String?, action: Selector? = nil) -> UIBarButtonItem {
    let button = UIButton(type: .Custom)
    
    if let imageName = imageName {
        button.setImage(UIImage(named: imageName)!.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
    }
    
    if let title = title {
        button.setTitle(title, forState: .Normal)
        button.titleEdgeInsets = UIEdgeInsets(top: 0.0, left: 10.0, bottom: 0.0, right: 0.0)
        
        let font = UIFont.preferredFontForTextStyle(UIFontTextStyleFootnote)
        button.titleLabel?.font = font
    }
    
    let size = button.sizeThatFits(CGSize(width: 90.0, height: 30.0))
    button.frame.size = CGSize(width: min(size.width + 10.0, 60), height: size.height)
    
    if let action = action {
        button.addTarget(self, action: action, forControlEvents: .TouchUpInside)
    }
    
    let barButton = UIBarButtonItem(customView: button)
    
    return barButton
  }
  
  // MARK: Download Photo
  
  func showActions() {
//    let actionSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil, otherButtonTitles: "Download Photo")
//    
//    actionSheet.showFromToolbar(navigationController!.toolbar)
    let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
    let cancel = UIAlertAction(title: "cancel", style: UIAlertActionStyle.Cancel, handler: nil)
    let downloadPhoto = UIAlertAction(title: "download", style: UIAlertActionStyle.Default) { (action:UIAlertAction!) in
        print("download")
    }
    actionSheet.addAction(cancel)
    actionSheet.addAction(downloadPhoto)
    self.presentViewController(actionSheet, animated: true, completion: nil)
    
  }

  

    
  
  // MARK: Gesture Recognizers
  
  func handleDoubleTap(recognizer: UITapGestureRecognizer!) {
    let pointInView = recognizer.locationInView(self.imageView)
    self.zoomInZoomOut(pointInView)
  }
  
  func handleSingleTap(recognizer: UITapGestureRecognizer!) {
    let hidden = navigationController?.navigationBar.hidden ?? false
    navigationController?.setNavigationBarHidden(!hidden, animated: true)
    navigationController?.setToolbarHidden(!hidden, animated: true)
    navigationController?.prefersStatusBarHidden()
  }
  
  // MARK: ScrollView
  
  func centerFrameFromImage(image: UIImage?) -> CGRect {
    
    guard let image = image else { return CGRectZero }
    
    let scaleFactor = scrollView.frame.size.width / image.size.width
    let newHeight = image.size.height * scaleFactor
    
    var newImageSize = CGSize(width: scrollView.frame.size.width, height: newHeight)
    
    newImageSize.height = min(scrollView.frame.size.height, newImageSize.height)
    
    let centerFrame = CGRect(x: 0.0, y: scrollView.frame.size.height/2 - newImageSize.height/2, width: newImageSize.width, height: newImageSize.height)
    
    return centerFrame
  }
  
  func scrollViewDidZoom(scrollView: UIScrollView) {
    self.centerScrollViewContents()
  }
  
  func centerScrollViewContents() {
    let boundsSize = scrollView.frame
    var contentsFrame = self.imageView.frame
    
    if contentsFrame.size.width < boundsSize.width {
      contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0
    } else {
      contentsFrame.origin.x = 0.0
    }
    
    if contentsFrame.size.height < boundsSize.height {
      contentsFrame.origin.y = (boundsSize.height - scrollView.scrollIndicatorInsets.top - scrollView.scrollIndicatorInsets.bottom - contentsFrame.size.height) / 2.0
    } else {
      contentsFrame.origin.y = 0.0
    }
    
    self.imageView.frame = contentsFrame
  }
  
  func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
    return self.imageView
  }
  
  func zoomInZoomOut(point: CGPoint!) {
    let newZoomScale = self.scrollView.zoomScale > (self.scrollView.maximumZoomScale/2) ? self.scrollView.minimumZoomScale : self.scrollView.maximumZoomScale
    
    let scrollViewSize = self.scrollView.bounds.size
    
    let width = scrollViewSize.width / newZoomScale
    let height = scrollViewSize.height / newZoomScale
    let x = point.x - (width / 2.0)
    let y = point.y - (height / 2.0)
    
    let rectToZoom = CGRect(x: x, y: y, width: width, height: height)
    
    self.scrollView.zoomToRect(rectToZoom, animated: true)
  }
}
