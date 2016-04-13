//
//  PhotoBrowserCollectionViewController.swift
//  Photomania
//
//  Created by Essan Parto on 2014-08-20.
//  Copyright (c) 2014 Essan Parto. All rights reserved.
//

import UIKit
import Alamofire

class PhotoBrowserCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var photos = Array<PhotoInfo>()
    
    var isGettingPhotos:Bool = false
    
    var currentPage: Int = 1
    
  let refreshControl = UIRefreshControl()
  
  let PhotoBrowserCellIdentifier = "PhotoBrowserCell"
  let PhotoBrowserFooterViewIdentifier = "PhotoBrowserFooterView"
  
  // MARK: Life-cycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupView()
    
    
//    Alamofire.request(.GET, "https://api.500px.com/v1/photos", parameters: ["consumer_key":"c3EQxcUE9TnWtfXZ0sUru81OJtHmJBf0yAe8ups5"]).responseJSON { (response) in
//        if let json = response.result.value as? NSDictionary {
//            
//            var safephotos = json.valueForKey("photos") as! [NSDictionary]
//            
//            safephotos = safephotos.filter({ (photo) -> Bool in //过滤不可使用图片
//                photo.valueForKey("nsfw") as! Bool == false
//            })
//            
//            let photosInfo = safephotos.map({ (photo) -> PhotoInfo in
//                PhotoInfo(id: photo.valueForKey("id") as! Int, url: photo.valueForKey("image_url") as! String)
//            })
//            
//            self.photos = photosInfo
//            
//            self.collectionView!.reloadData()
//            
//        }
//    }
    
    self.getPopularPhotos()
  }
    
    func getPopularPhotos() {
        if !self.isGettingPhotos {
                    isGettingPhotos = true
            Alamofire.request(Five100px.Router.Popular(currentPage)).responseJSON(queue: dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), options: NSJSONReadingOptions.AllowFragments) { (response) in
                if let json = response.result.value as? NSDictionary {
                    var safephotos = json.valueForKey("photos") as! [NSDictionary]
                    
                    safephotos = safephotos.filter({ (photo) -> Bool in //过滤不可使用图片
                        photo.valueForKey("nsfw") as! Bool == false
                    })
                    
                    let photosInfo = safephotos.map({ (photo) -> PhotoInfo in
                        PhotoInfo(id: photo.valueForKey("id") as! Int, url: photo.valueForKey("image_url") as! String)
                    })
                    
                    let lastItem = self.photos.count
                    
                    self.photos += photosInfo
                    
                    let indexPath = (lastItem..<self.photos.count).map({ (index) -> NSIndexPath in
                        NSIndexPath(forItem: index, inSection: 0)
                    })
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        self.collectionView?.insertItemsAtIndexPaths(indexPath)
                    })
                    
                    self.currentPage += 1
                    self.isGettingPhotos = false
                }
            }

        }
    }
    
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  // MARK: CollectionView
  
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView.contentOffset.y + view.frame.height > scrollView.contentSize.height * 0.8 && scrollView.contentSize.height != 0.0 {
            getPopularPhotos()

        }

    }
    
  override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return photos.count
  }
  
  override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier(PhotoBrowserCellIdentifier, forIndexPath: indexPath) as! PhotoBrowserCollectionViewCell
    
    let photo = self.photos[indexPath.row]
    
    let imgUrl = photo.url
    
    Alamofire.request(.GET, imgUrl).response { (_, _, data, _) in
        if let img = data {
            cell.imageView.image = UIImage(data: img)
        }
    }
    
    return cell
  }
  
  override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
    return collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: PhotoBrowserFooterViewIdentifier, forIndexPath: indexPath) as UICollectionReusableView
  }
  
  override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    performSegueWithIdentifier("ShowPhoto", sender: self.photos[self.photos.startIndex.advancedBy(indexPath.item)].id)
  }
  
  // MARK: Helper
  
  func setupView() {
    navigationController?.setNavigationBarHidden(false, animated: true)
    
    guard let collectionView = self.collectionView else { return }
    let layout = UICollectionViewFlowLayout()
    let itemWidth = (view.bounds.size.width - 2) / 3
    layout.itemSize = CGSize(width: itemWidth, height: itemWidth)
    layout.minimumInteritemSpacing = 1.0
    layout.minimumLineSpacing = 1.0
    layout.footerReferenceSize = CGSize(width: collectionView.bounds.size.width, height: 100.0)
    
    collectionView.collectionViewLayout = layout
    
    let titleLabel = UILabel(frame: CGRect(x: 0.0, y: 0.0, width: 60.0, height: 30.0))
    titleLabel.text = "Photomania"
    titleLabel.textColor = UIColor.whiteColor()
    titleLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
    navigationItem.titleView = titleLabel
    
    collectionView.registerClass(PhotoBrowserCollectionViewCell.classForCoder(), forCellWithReuseIdentifier: PhotoBrowserCellIdentifier)
    collectionView.registerClass(PhotoBrowserCollectionViewLoadingCell.classForCoder(), forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: PhotoBrowserFooterViewIdentifier)
    
    refreshControl.tintColor = UIColor.whiteColor()
    refreshControl.addTarget(self, action: "handleRefresh", forControlEvents: .ValueChanged)
    collectionView.addSubview(refreshControl)
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "ShowPhoto" {
      (segue.destinationViewController as! PhotoViewerViewController).photoID = sender!.integerValue
      (segue.destinationViewController as! PhotoViewerViewController).hidesBottomBarWhenPushed = true
    }
  }
  
  func handleRefresh() {
    
  }
}

class PhotoBrowserCollectionViewCell: UICollectionViewCell {
  let imageView = UIImageView()
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    backgroundColor = UIColor(white: 0.1, alpha: 1.0)
    
    imageView.frame = bounds
    addSubview(imageView)
  }
}

class PhotoBrowserCollectionViewLoadingCell: UICollectionReusableView {
  let spinner = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    spinner.startAnimating()
    spinner.center = self.center
    addSubview(spinner)
  }
}
