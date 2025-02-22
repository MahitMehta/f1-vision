//
//  RaceTrackView.swift
//  f1-vision
//
//  Created by Mahit Mehta on 2/21/25.
//

import SwiftUI
import RealityKit

func scaleModelToFit(_ modelEntity: ModelEntity, maxSize: Float = 1.0) -> Entity {
    let parent = Entity() // Create a parent entity
    parent.addChild(modelEntity) // Attach model to parent

    let bounds = modelEntity.visualBounds(relativeTo: nil)
    let maxDimension = max(bounds.extents.x, bounds.extents.y, bounds.extents.z)
    
    var scaleFactor = maxSize / maxDimension
    scaleFactor = max(scaleFactor, 0.01) // Prevent it from going too small

    parent.scale = SIMD3<Float>(scaleFactor, scaleFactor, scaleFactor)
    return parent
}

func placeModelOnTop(baseEntity: ModelEntity, topEntity: ModelEntity) {
    /*let baseBounds = baseEntity.visualBounds(relativeTo: nil)
    let topBounds = topEntity.visualBounds(relativeTo: nil)

    let baseTopY = baseBounds.center.y + (baseBounds.extents.y / 2)
    let topBottomY = topBounds.center.y - (topBounds.extents.y / 2)

    let newPosition = SIMD3<Float>(
        baseBounds.center.x,
        baseTopY - topBottomY,
        baseBounds.center.z
    )
    
    topEntity.position = newPosition*/
    baseEntity.addChild(topEntity) // Attach top entity to the base
}

/*func moveCarSmoothly(car: Entity, to targetEntity: Entity) {
    if let targetPosition = targetEntity.position(relativeTo: nil) {
        let newPosition = targetPosition + SIMD3<Float>(0, 0.5, 0) // Offset to sit above
        
        car.move(to: Transform(translation: newPosition), relativeTo: nil, duration: 1.5)
    }
}*/

struct RaceTrackView: View {
    var body: some View {
        
        
        
        // fetching from local
        // let url = Bundle.main.url(forResource: "scene", withExtension: "splineswift")!
        
        RealityView { content in
            /*let car = Model3D(
             named: "Mclaren") {model in
             model.resizable()
             .aspectRatio(contentMode: .fit)
             .scaleEffect(1)
             
             } placeholder: {
             ProgressView()
             }
             let track = Model3D(
             named: "RaceTrackModel") {model in
             model.resizable()
             .aspectRatio(contentMode: .fit)
             .scaleEffect(1)
             
             } placeholder: {
             ProgressView()
             }
             content.add(car)*/
            
            let car = try! await ModelEntity(named: "Mclaren")
            // optimal size is < 0.005
            car.transform.scale = .init(x: 5, y: 5, z: 5)
            car.position.y += 10
            car.position.z += 40
            car.transform.rotation = simd_quatf(angle: .pi / 2, axis: [0, 1, 0])
            //car.transform.translation.y += 0.01
            //car.transform.translation.x -= 0.1
            // let bounds_car = car.visualBounds(relativeTo: nil)
            //let maxDimension_car = max(bounds_car.extents.x, bounds_car.extents.y, bounds_car.extents.z)
            // let scaleFactor_car = 0.1 / maxDimension_car
            //car.scale = SIMD3<Float>(0.01, 0.01, 0.01)
            
            
            //let scaledEntity = scaleModelToFit(car, maxSize: 0.01)
            
            //car.components.set(CollisionComponent(shapes: [.generateBox(size:SIMD3<Float>(1,1,1))]))
            //scaledEntity.transform.translation.z = -0.2;
            
            //content.add(scaledEntity)
            
            
            
            
            
            let track = try! await ModelEntity(named: "RaceTrackModel")
            //track.transform.scale = .init(x: 0.2, y: 0.2, z: 0.2)
            let bounds = track.visualBounds(relativeTo: nil)
            let maxDimension = max(bounds.extents.x, bounds.extents.y, bounds.extents.z)
            let scaleFactor = 0.5 / maxDimension
            track.scale = SIMD3<Float>(scaleFactor, scaleFactor, scaleFactor)
            track.position = [0, 0, 0]
            
            // track.components.set(CollisionComponent(shapes: [.generateBox(size:SIMD3<Float>(1,1,1))]))
            //car.position += [0.5, 0, 0]
            
            track.addChild(car, preservingWorldTransform: false)
           // content.add(track)
            content.add(track)
            
            /*
            if let modelComponent = car.components[ModelComponent.self] {
                print("Car Mesh found: \(modelComponent.mesh)")
                let meshResource = modelComponent.mesh
                //let collisionShape = try! await ShapeResource.generateConvex(from: meshResource)
                let bounds = car.visualBounds(relativeTo: nil).extents
                let collisionShape = ShapeResource.generateBox(size: bounds)
                car.components.set(CollisionComponent(shapes: [collisionShape]))
            } else {
                print("No mesh found!")
            }
            
            
            if let modelComponent = track.components[ModelComponent.self] {
                print("Mesh found: \(modelComponent.mesh)")
                //let collisionShape = try! await ShapeResource.generateConvex(from: meshResource)
                let bounds = track.visualBounds(relativeTo: nil).extents
                let collisionShape = ShapeResource.generateBox(size: bounds)
                track.components.set(CollisionComponent(shapes: [collisionShape]))
            } else {
                print("No mesh found!")
            }
            
            
            // Enable physics
            car.components[PhysicsBodyComponent.self] = PhysicsBodyComponent(massProperties: .default, material: nil, mode: .dynamic)
            track.components[PhysicsBodyComponent.self] = PhysicsBodyComponent(massProperties: .default, material: nil, mode: .static)
            */
           // let targetPosition = track.position(relativeTo: nil)
            
            //let newPosition = targetPosition + SIMD3<Float>(0, -20, 0) // Offset to sit above
            
            //car.move(to: Transform(translation: newPosition), relativeTo: nil, duration: 5)
            
            
            //moveCarSmoothly(car: car, to: track)
            
        }
    }
}

#Preview {
    RaceTrackView()
}
