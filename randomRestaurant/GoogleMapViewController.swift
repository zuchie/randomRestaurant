//
//  GoogleMapViewController.swift
//  randomRestaurant
//
//  Created by Zhe Cui on 8/30/16.
//  Copyright © 2016 Zhe Cui. All rights reserved.
//

import UIKit
import GoogleMaps

class GoogleMapViewController: UIViewController {
    
    
    private var location: String?
    private var bizCoordinate2D: CLLocationCoordinate2D?
    private var bizName: String?
    private var departureTime: Int?
    private var drawRoute = GetDirection()
    private var mapView: GMSMapView!
    
    private var label = UILabel()
    
    
    func setBizLocation(location: String) {
        self.location = location
    }
    
    func setBizCoordinate2D(coordinate2D: CLLocationCoordinate2D) {
        self.bizCoordinate2D = coordinate2D
    }
    
    func setBizName(name: String) {
        self.bizName = name
    }

    func setDepartureTime(time: Int) {
        self.departureTime = time
    }
    
    // KVO - Key Value Observer, to observe changes of mapView.myLocation.
    override func viewWillAppear(animated: Bool) {
        view.addObserver(self, forKeyPath: "myLocation", options: NSKeyValueObservingOptions.New, context: nil)
    }
    
    // Deregister observer.
    override func viewWillDisappear(animated: Bool) {
        view.removeObserver(self, forKeyPath: "myLocation")
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        
        if keyPath == "myLocation" && (object?.isKindOfClass(GMSMapView))! {
            
            // Draw route.
            drawRoute.makeGoogleDirectionsUrl(
                "https://maps.googleapis.com/maps/api/directions/json?",
                origin: mapView.myLocation!.coordinate,
                dest: bizCoordinate2D!,
                depart: departureTime!,
                key: "AIzaSyA-vPWnAEHdO3V4TwUbedRuJO1mDEgIjr0"
            )
            
            drawRoute.makeUrlRequest() { routesPoints, distances, durationInTraffic, viewport in
                
                // Draw from returned polyline.
                for points in routesPoints {
                    //print("poly points: \(points)")
                    dispatch_async(dispatch_get_main_queue(), {
                        let path = GMSMutablePath(fromEncodedPath: points)
                        let polyline = GMSPolyline(path: path)
                        polyline.strokeWidth = 3
                        
                        polyline.map = self.mapView
                    })
                }
                
                print("distance: \(distances.first!), duration in traffic: \(durationInTraffic), viewport: \(viewport.northeast!), \(viewport.southwest!)")
                
                dispatch_async(dispatch_get_main_queue(), {
                    
                    // Update camera to new bounds.
                    let bounds = GMSCoordinateBounds(coordinate: viewport.northeast!, coordinate: viewport.southwest!)
                    let edges = UIEdgeInsetsMake(120, 40, 40, 40)
                    let camera = GMSCameraUpdate.fitBounds(bounds, withEdgeInsets: edges)
                    
                    self.mapView.animateWithCameraUpdate(camera)
                    
                    self.label.text = "\(distances.first!), \(durationInTraffic)"
                })
            }

        }
    }
    
    override func loadView() {
        // Create a GMSCameraPosition that tells the map to display the
        // business position at zoom level 12.
        let camera = GMSCameraPosition.cameraWithTarget(bizCoordinate2D!, zoom: 10.0)
        mapView = GMSMapView.mapWithFrame(CGRect.zero, camera: camera)
        
        //mapView = GMSMapView()

        mapView.myLocationEnabled = true
        mapView.settings.myLocationButton = true

        view = mapView
        
        // Creates a marker in the center of the map.
        let marker = GMSMarker()
        marker.position = bizCoordinate2D!
        marker.title = bizName
        marker.snippet = location
        marker.map = mapView
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add label.
        let labelWidth: CGFloat = 180.0
        let labelHeight: CGFloat = 20.0
        let screenBounds = UIScreen.mainScreen().bounds
        label.frame = CGRect(x: screenBounds.width / 2.0 - labelWidth / 2.0, y: screenBounds.height - labelHeight , width: labelWidth, height: labelHeight)
        label.backgroundColor = UIColor.lightGrayColor()
        label.textAlignment = .Center
        label.textColor = UIColor.whiteColor()
        label.adjustsFontSizeToFitWidth = true
        
        view.addSubview(label)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
