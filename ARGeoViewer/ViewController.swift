//
//  ViewController.swift
//  ARGeoViewer
//
//  Created by Andy Martushev on 9/14/19.
//  Copyright © 2019 Andy Martushev. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import CoreLocation

class ViewController: UIViewController, ARSCNViewDelegate, CLLocationManagerDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    let locationManager = CLLocationManager()
    var userLocation = CLLocation()
    
    var heading : Double! = 0.0
//    var distance : Float! = 0.0 {
//        didSet {
//            setStatusText()
//        }
//    }
    var status: String! {
        didSet {
            setStatusText()
        }
    }
    
//    var modelNode:SCNNode!
//    let rootNodeName = "shipMesh"
    
    var originalTransform:SCNMatrix4!
    
    func setStatusText() {
        var text = "Status: \(status!)\n"
        //text += "Distance: \(String(format: "%.2f meter aka %.2f feet", distance, distance * 3.28))"
        NSLog(text);
        //statusTextView.text = text
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        //let scene = SCNScene(named: "art.scnassets/ship.scn")!
        
        // Set the scene to the view
        //sceneView.scene = scene
        
        
        // Start location services
        locationManager.delegate = self
        locationManager.activityType = .fitness
        locationManager.distanceFilter = 1;
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.requestWhenInUseAuthorization()
        
        // Set the initial status
        status = "Getting user location..."
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.worldAlignment = .gravityAndHeading

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // Implementing this method is required
        print(error.localizedDescription)
    }

    func locationManager(_ manager: CLLocationManager,
                         didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            //locationManager.requestLocation()
            locationManager.startUpdatingLocation()
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            self.userLocation = location
            self.drawLocations();
        }
    }
    
    func drawLocations() {
        //Andy's House 39.4221591,-104.7810128
        let geo1 = GeoLocation(label: "6380 Sabino Way", latitude: 39.4221591, longitude: -104.7810128)
        let geo2 = GeoLocation(label: "Cobblestone Park", latitude: 39.4235731, longitude: -104.7821762)
        let geo3 = GeoLocation(label: "Pool at coblestone", latitude: 39.418479, longitude: -104.780100)
        
        let geo4 = GeoLocation(label: "1401 Wynkoop St", latitude: 39.750515, longitude: -105.003095)
        let geo5 = GeoLocation(label: "Pepsi Center", latitude: 39.74866, longitude: -105.00771)

        addLocations(locations: [geo1, geo2, geo3, geo4, geo5])
    }
    
    struct GeoLocation {
        let label: String
        let latitude: Double
        let longitude: Double
    }
    
    
    func addLocations(locations: [GeoLocation]){
        for node in sceneView.scene.rootNode.childNodes{
            node.removeFromParentNode();
        }
        
        for loc in locations{
            let location = CLLocation(latitude: loc.latitude, longitude: loc.longitude)
            let pinNode = makeBillboardNode("📍".image()!, width: 10, height: 10)
            let (minBox, maxBox) = pinNode.boundingBox
            pinNode.pivot = SCNMatrix4MakeTranslation(0, (maxBox.y - minBox.y)/2, 0)
            
            sceneView.scene.rootNode.addChildNode(pinNode)
            positionModel(modelNode: pinNode, location: location)
            
            let address = loc.label;
            let addressWidth = CGFloat(10 * address.count)
            let addressLabel = makeBillboardNode(address.image(backgroundColor: UIColor.white.withAlphaComponent(0.1))!, width: addressWidth, height: 20)
            
            // Position it on top of the pin
            addressLabel.position = SCNVector3Make(Float(addressWidth / 3.0), 16, 0)
            pinNode.addChildNode(addressLabel)
        }
    }
    
    func updatePositions(){
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 1.0
        
        // Position the model in the correct place
//        for model in sceneView.scene.rootNode{
//            positionModel(model: model, )
//        }
        //positionModel(location)
        
        // End animation
        SCNTransaction.commit()
        
        NSLog("Updating position...")
    }
    
    
//    func updateLocation(_ latitude : Double, _ longitude : Double) {
//        let location = CLLocation(latitude: latitude, longitude: longitude)
//
//        if self.modelNode == nil {
//            //let modelScene = SCNScene(named: "art.scnassets/ship.scn")!
//            //self.modelNode = modelScene.rootNode.childNode(withName: rootNodeName, recursively: true)!
//            let pin = makeBillboardNode("📍".image()!, width: 10, height: 10)
//
//            self.modelNode = pin;
//
//            let (minBox, maxBox) = self.modelNode.boundingBox
//            self.modelNode.pivot = SCNMatrix4MakeTranslation(0, (maxBox.y - minBox.y)/2, 0)
//
//            // Save original transform to calculate future rotations
//            self.originalTransform = self.modelNode.transform
//
//            // Position the model in the correct place
//            positionModel(location)
//
//            // Add the model to the scene
//            sceneView.scene.rootNode.addChildNode(self.modelNode)
//
//            let address = "6380 Sabino Way";
//            let addressWidth = CGFloat(10 * address.count)
//            let addressLabel = makeBillboardNode(address.image(backgroundColor: UIColor.white.withAlphaComponent(0.1))!, width: addressWidth, height: 20)
//
//            // Position it on top of the pin
//            addressLabel.position = SCNVector3Make(Float(addressWidth / 3.0), 16, 0)
//            self.modelNode.addChildNode(addressLabel)
//
//
//            //draw a line..
////            let startPos = SCNVector3(0, 0, 0);
////            let endPos = SCNVector3(10, 0, 0);
////
////            let line = lineBetweenNodes(positionA: startPos, positionB: endPos, inScene: sceneView.scene)
////            self.modelNode.addChildNode(line)
//        }else {
//            // Begin animation
//            SCNTransaction.begin()
//            SCNTransaction.animationDuration = 1.0
//
//            // Position the model in the correct place
//            positionModel(location)
//
//            // End animation
//            SCNTransaction.commit()
//
//            NSLog("Updating position...")
//        }
//    }
    
    func makeBillboardNode(_ image: UIImage, width: CGFloat = 10, height: CGFloat = 10) -> SCNNode {
        let plane = SCNPlane(width: width, height: height)
        plane.firstMaterial!.diffuse.contents = image
        let node = SCNNode(geometry: plane)
        node.constraints = [SCNBillboardConstraint()]
        return node
    }
    
    func positionModel(modelNode: SCNNode, location: CLLocation) {
        modelNode.position = translateNode(location)
        modelNode.scale = scaleNode(location);
    }
    
//    func positionModel(_ location: CLLocation) {
//        // Rotate node
//        //self.modelNode.transform = rotateNode(Float(-1 * (self.heading - 180).toRadians()), self.originalTransform)
//
//        // Translate node
//        self.modelNode.position = translateNode(location)
//
//        // Scale node
//        let scale = scaleNode(location);
//        self.modelNode.scale = scale;
//    }
    
    func rotateNode(_ angleInRadians: Float, _ transform: SCNMatrix4) -> SCNMatrix4 {
        let rotation = SCNMatrix4MakeRotation(angleInRadians, 0, 1, 0)
        return SCNMatrix4Mult(transform, rotation)
    }
    
    func scaleNode (_ location: CLLocation) -> SCNVector3 {
        let distance = Float(location.distance(from: self.userLocation))
        let scale: Float = min(0.25,  max(625 / distance, 0.05));
        return SCNVector3(x: scale, y: scale, z: scale)
    }
    
    func translateNode (_ location: CLLocation) -> SCNVector3 {
        let locationTransform = transformMatrix(matrix_identity_float4x4, userLocation, location)
        return positionFromTransform(locationTransform)
    }
    
    func positionFromTransform(_ transform: simd_float4x4) -> SCNVector3 {
        return SCNVector3Make(
            transform.columns.3.x, transform.columns.3.y, transform.columns.3.z
        )
    }
    
    func transformMatrix(_ matrix: simd_float4x4, _ originLocation: CLLocation, _ driverLocation: CLLocation) -> simd_float4x4 {
        let bearing = bearingBetweenLocations(userLocation, driverLocation)
        let rotationMatrix = rotateAroundY(matrix_identity_float4x4, Float(bearing))
        
        let distance = Float(driverLocation.distance(from: self.userLocation))
        let position = vector_float4(0.0, 0.0, -distance, 0.0)
        let translationMatrix = getTranslationMatrix(matrix_identity_float4x4, position)
        
        let transformMatrix = simd_mul(rotationMatrix, translationMatrix)
        
        return simd_mul(matrix, transformMatrix)
    }
    
    func getTranslationMatrix(_ matrix: simd_float4x4, _ translation : vector_float4) -> simd_float4x4 {
        var matrix = matrix
        matrix.columns.3 = translation
        return matrix
    }
    
    func rotateAroundY(_ matrix: simd_float4x4, _ degrees: Float) -> simd_float4x4 {
        var matrix = matrix
        
        matrix.columns.0.x = cos(degrees)
        matrix.columns.0.z = -sin(degrees)
        
        matrix.columns.2.x = sin(degrees)
        matrix.columns.2.z = cos(degrees)
        return matrix.inverse
    }
    
    func bearingBetweenLocations(_ originLocation: CLLocation, _ driverLocation: CLLocation) -> Double {
        let lat1 = originLocation.coordinate.latitude.toRadians()
        let lon1 = originLocation.coordinate.longitude.toRadians()
        
        let lat2 = driverLocation.coordinate.latitude.toRadians()
        let lon2 = driverLocation.coordinate.longitude.toRadians()
        
        let longitudeDiff = lon2 - lon1
        
        let y = sin(longitudeDiff) * cos(lat2);
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(longitudeDiff);
        
        return atan2(y, x)
    }
    
    
    func lineBetweenNodes(positionA: SCNVector3, positionB: SCNVector3, inScene: SCNScene) -> SCNNode {
        let vector = SCNVector3(positionA.x - positionB.x, positionA.y - positionB.y, positionA.z - positionB.z)
        let distance = sqrt(vector.x * vector.x + vector.y * vector.y + vector.z * vector.z)
        let midPosition = SCNVector3 (x:(positionA.x + positionB.x) / 2, y:(positionA.y + positionB.y) / 2, z:(positionA.z + positionB.z) / 2)
        
        let lineGeometry = SCNCylinder()
        lineGeometry.radius = 0.25
        lineGeometry.height = CGFloat(distance)
        lineGeometry.radialSegmentCount = 5
        lineGeometry.firstMaterial!.diffuse.contents = UIColor.green
        
        let lineNode = SCNNode(geometry: lineGeometry)
        lineNode.position = midPosition
        lineNode.look (at: positionB, up: inScene.rootNode.worldUp, localFront: lineNode.worldUp)
        return lineNode
    }
    
    
    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}
