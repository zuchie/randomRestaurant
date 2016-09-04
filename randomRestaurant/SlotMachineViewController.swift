//
//  SlotMachineViewController.swift
//  randomRestaurant
//
//  Created by Zhe Cui on 7/31/16.
//  Copyright © 2016 Zhe Cui. All rights reserved.
//

import UIKit
import CoreLocation

class SlotMachineViewController: UIViewController {

    @IBOutlet weak var bizPicked: UILabel!
    @IBOutlet weak var pickedBizAddress: UILabel!
    
    private var nearbyBusinesses = GetNearbyBusinesses()
    
    private var ratingBar = 0.0
    
    private var bizName = ""
    private var bizPrice = ""
    private var bizRating = ""
    private var bizReviewCount = ""
    private var bizLocationObj: PickedBusinessLocation?
    private var bizAddress = ""
    private var bizCoordinate2D: CLLocationCoordinate2D?
    
    private let animationImages = [
        UIImage(named: "image0")!,
        UIImage(named: "image1")!,
        UIImage(named: "image2")!,
        UIImage(named: "image3")!,
        UIImage(named: "image4")!,
        UIImage(named: "image5")!,
        UIImage(named: "image6")!
    ]
    
    private var imageViews = [UIImageView]()
    
    var urlQueryParameters: UrlQueryParameters?
    
    private var imageViewFrameWidth: CGFloat = 0.0
    private var imageViewFrameHeight: CGFloat = 0.0
    private var imageViewFrameX: CGFloat = 0.0
    private var imageViewFrameY: CGFloat = 0.0
    
    private var imagesFrameY = [CGFloat]()
    
    func setUrlQueryParameters(urlParam: UrlQueryParameters) {
        urlQueryParameters = urlParam
        print("category: \(urlQueryParameters!.category), location: \(urlQueryParameters!.location), radius: \(urlQueryParameters!.radius), limit: \(urlQueryParameters!.limit), time: \(urlQueryParameters!.openAt)")
    }
    
    func getRatingBar(rating: Double) {
        ratingBar = rating
    }
 
    private func scrollImages(index: Int, imageView: UIImageView) {
        
        UIView.animateWithDuration(4.0, delay: 0.0, options: [.CurveEaseInOut], animations: {
 
            //print("image Y: \(imageView.frame.origin.y)")
            //imageView.image = self.animationImages[index]
            
            //self.view.addSubview(imageView)
            self.view.bringSubviewToFront(imageView)
            var frame = imageView.frame
            
            //print("frame origin y: \(frame.origin.y), frame height: \(frame.height)")
            //print("imageviews count: \(self.imageViews.count)")
            frame.origin.y += frame.height * CGFloat(self.imageViews.count - 1)
            print("1 index: \(index), frame Y: \(frame.origin.y)")
            imageView.frame = frame
            
        }, completion: { finished in
            if finished {
                //self.view.sendSubviewToBack(imageView)
                self.view.sendSubviewToBack(imageView)
                // Reuse this image view.
                //imageView.frame.origin.y = -(CGFloat(index) * self.imageViewFrameHeight)
                //self.imageViews[index] = imageView
                print("image \(index), Y: \(imageView.frame.origin.y)")
            } else {
                print("animation is still running...")
            }
        })
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("view did load")
        nearbyBusinesses.setRatingBar(ratingBar)
        
        imageViewFrameWidth = self.view.frame.width
        imageViewFrameHeight = self.view.frame.height
        imageViewFrameX = self.view.frame.origin.x
        imageViewFrameY = self.view.frame.origin.y
        
        // Init image views.
        for index in 0..<animationImages.count {
            let imageView = UIImageView()
            imageView.image = self.animationImages[index]
            imageView.frame = CGRect(x: imageViewFrameX, y: imageViewFrameY - CGFloat(index) * imageViewFrameHeight, width: imageViewFrameWidth, height: imageViewFrameHeight)
            
            imagesFrameY.append(imageView.frame.origin.y)

            self.view.addSubview(imageView)
            // Don't allow images block button.
            self.view.sendSubviewToBack(imageView)
            imageViews.append(imageView)
            
            print("image view x: \(imageView.frame.origin.x), y: \(imageView.frame.origin.y), height: \(imageView.frame.height), width: \(imageView.frame.width)")
        }
    }
    
    @IBAction func start() {
        
        //imageView.startAnimating()
        
        // Start animation.
        for (index, imageView) in imageViews.enumerate() {
            
            print("0 index: \(index), Y: \(imageView.frame.origin.y)")
            
            //imageViews.removeAtIndex(index)
            //self.view.addSubview(imageView)
            // Don't allow images block button.
            //self.view.sendSubviewToBack(imageView)
            
            // Reset Y.
            imageView.frame.origin.y = imagesFrameY[index]
            
            scrollImages(index, imageView: imageView)
        }
        
        //scrollImages(0, image: imageView.animationImages!.first!)
        
        let access_token = "XxrwsnAP8YyUtmYdSrC0RCHA6sgn8ggZILNUhNZQqkP8zBTNjondbANeyBLWw7V8LGX-cAb_H4jM2OMu_mnJpwVik5IU0g_S6ZOEJZTaU"
        
        //bizPicked.text = nil // Reset for following queries
        
        // Get businesses from Yelp API v3.
        nearbyBusinesses.getUrlParameters(urlQueryParameters?.location, categories: urlQueryParameters?.category, radius: urlQueryParameters?.radius, limit: urlQueryParameters?.limit, open_at: urlQueryParameters?.openAt)
        
        nearbyBusinesses.makeBusinessesSearchUrl("https://api.yelp.com/v3/businesses/search?")
        
        nearbyBusinesses.makeUrlRequest(access_token) { totalBiz, randomNo in
            
            //print("total biz: \(totalBiz), random no.: \(randomNo)")
            if let returnedBusiness = self.nearbyBusinesses.result {
                //print("business picked: \(returnedBusiness)")
                
                self.bizName = self.nearbyBusinesses.getReturnedBusiness(returnedBusiness, key: "name")
                self.bizPrice = self.nearbyBusinesses.getReturnedBusiness(returnedBusiness, key: "price")
                self.bizRating = self.nearbyBusinesses.getReturnedBusiness(returnedBusiness, key: "rating")
                self.bizReviewCount = self.nearbyBusinesses.getReturnedBusiness(returnedBusiness, key: "review_count")
                
                // Get picked business location object and convert to address string.
                if let pickedBizLocationObj = returnedBusiness["location"] as? NSDictionary {
                        self.bizLocationObj = PickedBusinessLocation(businessObj: pickedBizLocationObj)
                    
                        self.bizAddress = self.bizLocationObj!.getBizAddressString()
                        print("biz location: \(self.bizAddress)")
                } else {
                    print("No location information of picked business")
                }
                
                if let pickedBusinessCoordinatesObj = returnedBusiness["coordinates"] as? NSDictionary {
                    self.bizCoordinate2D = CLLocationCoordinate2DMake((pickedBusinessCoordinatesObj["latitude"] as? CLLocationDegrees)!, (pickedBusinessCoordinatesObj["longitude"] as? CLLocationDegrees)!)
                    print("biz latitude: \(self.bizCoordinate2D!.latitude), longitude: \(self.bizCoordinate2D!.longitude)")
                }
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.bizPicked.text = "\(self.bizName)\nprice: \(self.bizPrice), rating: \(self.bizRating), review count: \(self.bizReviewCount)\ntotal found: \(totalBiz), picked no.: \(randomNo)"
                    self.pickedBizAddress.text = "\(self.bizAddress)"
                })
            } else {
                dispatch_async(dispatch_get_main_queue(), {
                    self.bizPicked.text = "No restaurant found"
                })
            }
            
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    private func alert() {
        
        // Create the alert.
        let alert = UIAlertController(title: "Alert", message: "Please push \"Start\" button.", preferredStyle: UIAlertControllerStyle.Alert)
        
        // Add an action(button).
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { action in
            
        }))
        
        // Show the alert.
        self.presentViewController(alert, animated: true, completion: nil)
    }

    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        let destinationVC = segue.destinationViewController
        
        if bizAddress.isEmpty || bizCoordinate2D == nil {
            
            alert()
            
        } else {
            if let mapVC = destinationVC as? GoogleMapViewController {
                if let id = segue.identifier {
                    if id == "googleMap" {
                        mapVC.setBizLocation(bizAddress)
                        mapVC.setBizCoordinate2D(bizCoordinate2D!)
                        mapVC.setBizName(bizName)
                        mapVC.setDepartureTime(urlQueryParameters!.openAt)
                    }
                }
            }
        }
    }
    
}
