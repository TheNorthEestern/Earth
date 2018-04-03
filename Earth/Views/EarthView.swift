//
//  EarthView.swift
//  Earth
//
//  Created by Kacy James on 3/29/18.
//  Copyright © 2018 Kacy James. All rights reserved.
//

import Foundation
import CoreLocation
import GLKit
import SceneKit

class EarthView : SCNView {
  
  // Generates a 3D quilting pin
  // similar to Apple's map pin
  // Unused
  lazy var pinNode: SCNNode = {
    let bodyHeight: CGFloat = 0.3
    let bodyRadius: CGFloat = 0.019
    let headRadius: CGFloat = 0.06
    
    let body = SCNCylinder(radius: bodyRadius, height: bodyHeight)
    let head = SCNSphere(radius: headRadius)
    
    let headMaterial = SCNMaterial()
    let bodyMaterial = SCNMaterial()
    
    headMaterial.diffuse.contents = UIColor.red
    headMaterial.emission.contents = UIColor(displayP3Red: 0.2, green: 0, blue: 0, alpha: 1.0)
    bodyMaterial.specular.contents = UIColor.white
    bodyMaterial.emission.contents = UIColor(displayP3Red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
    headMaterial.specular.contents = UIColor.white
    bodyMaterial.shininess = 100
    
    head.firstMaterial = headMaterial
    body.firstMaterial = bodyMaterial
    
    // Create and position the two nodes
    let bodyNode = SCNNode(geometry: body)
    bodyNode.position = SCNVector3(0, bodyHeight/2.0, 0)
    let headNode = SCNNode(geometry: head)
    headNode.position = SCNVector3(0, bodyHeight/2.0, 0)
    
    // Add them both to the pin
    let pinNode = SCNNode()
    pinNode.addChildNode(bodyNode)
    pinNode.addChildNode(headNode)
    
    self.earthNode?.addChildNode(pinNode)
    self.pinNode = pinNode
    
    return self.pinNode
  }()
  
  // Generates a geocoder for locating
  // the user's touches on a map
  // Unused
  lazy var geocoder: CLGeocoder = {
    var geocoder = CLGeocoder()
    return geocoder
  }()
  
  var earthNode: SCNNode?
  
  override func awakeFromNib() {
    let scene = SCNScene()
    self.scene = scene
    backgroundColor = UIColor(displayP3Red: 0.05, green: 0.05, blue: 0.05, alpha: 1.0)
    let camera = SCNCamera()
    let cameraNode = SCNNode()
    cameraNode.camera = camera
    cameraNode.position = SCNVector3(0, 0, 15)
    scene.rootNode.addChildNode(cameraNode)
    
    let earth = SCNSphere(radius: 3.0)
    let earthMaterial = SCNMaterial()
    
    earthMaterial.diffuse.contents = UIImage(named: "earth_diffuse_4k")!
    earthMaterial.specular.contents = UIImage(named: "earth_specular_1k")!
    earthMaterial.emission.contents = UIImage(named: "earth_lights_4k")!
    earthMaterial.normal.contents = UIImage(named:"earth_normal_4k")!
    earthMaterial.multiply.contents = UIColor(displayP3Red: 0.7, green: 0.7, blue: 0.7, alpha: 1.0)
    earthMaterial.shininess = 0.05
    earth.firstMaterial = earthMaterial
    
    let earthNode = SCNNode(geometry: earth)
    let axisNode = SCNNode()
    scene.rootNode.addChildNode(axisNode)
    axisNode.addChildNode(earthNode)
    axisNode.rotation = SCNVector4(1, 0, 0, CGFloat.pi / 6.0)
    self.earthNode = earthNode
    
    let clouds = SCNSphere(radius: 3.075)
    clouds.segmentCount = 144
    let cloudsMaterial = SCNMaterial()
    
    cloudsMaterial.diffuse.contents = UIColor.white
    cloudsMaterial.locksAmbientWithDiffuse = true
    cloudsMaterial.transparent.contents = UIImage(named: "clouds_transparent_2k")!
    cloudsMaterial.transparencyMode = .rgbZero
    cloudsMaterial.writesToDepthBuffer = false
    
    let url = Bundle.main.url(forResource: "AtmosphereHalo", withExtension: "glsl")
    guard let shaderSource = try? String(contentsOf: url!, encoding: .utf8) else {
      return
    }
    
    cloudsMaterial.shaderModifiers = [SCNShaderModifierEntryPoint.fragment: shaderSource]
    
    clouds.firstMaterial = cloudsMaterial
    let cloudNode = SCNNode(geometry: clouds)
    earthNode.addChildNode(cloudNode)
    
    earthNode.rotation = SCNVector4(0, 1, 0, 0)
    cloudNode.rotation = SCNVector4(0, 1, 0, 0)
    
    let rotate = CABasicAnimation(keyPath: "rotation.w")
    rotate.byValue = CGFloat.pi * 2.0
    rotate.duration = 50.0
    rotate.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
    rotate.repeatCount = Float.infinity
    
    earthNode.addAnimation(rotate, forKey: "rotate the earth")
    
    let rotateClouds = CABasicAnimation(keyPath: "rotation.w")
    rotateClouds.byValue = -CGFloat.pi * 2
    rotateClouds.duration = 150.0
    rotateClouds.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
    rotate.repeatCount = Float.infinity
    
    cloudNode.addAnimation(rotateClouds, forKey: "slowly move the clouds")
    
    let sun = SCNLight()
    sun.type = .spot
    
    sun.castsShadow = true
    sun.shadowRadius = 3.0
    sun.shadowColor = UIColor(displayP3Red: 0, green: 0, blue: 0, alpha: 0.75)
    sun.zNear = 10
    sun.zFar = 40
    
    let sunNode = SCNNode()
    sunNode.light = sun
    
    sunNode.position = SCNVector3(x: -15, y: 0, z: 12)
    sunNode.constraints = [SCNLookAtConstraint(target: earthNode)]
    scene.rootNode.addChildNode(sunNode)
  }
  
  // Converts a CGPoint taken from a user's touch
  // and converts it to a location on the globe
  // Unused
  func coordinateFrom(point: CGPoint) -> CLLocation {
    let u = point.x
    let v = point.y
    
    let lat = CLLocationDegrees((0.5 - v) * 180.0)
    let lon = CLLocationDegrees((u - 0.5) * 360.0)
    
    return CLLocation(latitude: lat, longitude: lon)
  }
  
}
