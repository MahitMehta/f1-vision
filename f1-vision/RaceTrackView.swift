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

struct DriverPosition : Codable, Identifiable {
    let id: Int
    let positions: [[Float]]
}

func loadJSON<T: Decodable>(_ filename: String) -> T? {
    guard let url = Bundle.main.url(forResource: filename, withExtension: "json") else {
        print("❌ File \(filename).json not found in bundle")
        return nil
    }

    do {
        let data = try Data(contentsOf: url)
        let decodedData = try JSONDecoder().decode(T.self, from: data)
        return decodedData
    } catch {
        print("❌ Error loading \(filename).json: \(error.localizedDescription)")
        return nil
    }
}

func getTransformationRotation(currentX: Double, currentZ: Double, prevX: Double, prevZ: Double) -> simd_quatf {
    let deltaX = currentX - prevX
    let deltaZ = currentZ - prevZ
    let rotationAngleY = atan2(deltaZ, deltaX) + .pi/2 + (1 * .pi) / 180
    let transformationRotation = simd_quatf(angle: Float(rotationAngleY), axis: [0, -1, 0])
    
    return transformationRotation
}

let teamToCar: [String: String] = [
    "Ferrari": "Ferarri",
    "Kick Sauber Ferrari": "F1Sauber",
    "Haas Ferrari": "Haas",
    "Alpine Renault": "Alpine",
    "Williams Mercedes": "Williams",
    "Mercedes": "Mercedes",
    "McLaren Mercedes": "McLaren",
    "RB Honda RBPT": "Bull_Racing",
    "Red Bull Racing Honda RBPT": "Rb20",
    "Aston Martin Aramco Mercedes": "Aston"
]

let driverIdToTeamMap: [Int : String] = [
        1: "Red Bull Racing Honda RBPT",
        11: "Red Bull Racing Honda RBPT",
        
        14: "Aston Martin Aramco Mercedes",
        18: "Aston Martin Aramco Mercedes",
        
        81: "McLaren Mercedes",
        4: "McLaren Mercedes",

        16: "Ferrari",
        55: "Ferrari",
        
        63: "Mercedes",
        44: "Mercedes",
        
        20: "Haas Ferrari",
        27: "Haas Ferrari",
        
        22: "RB Honda RBPT",
        3: "RB Honda RBPT",
        
        77: "Kick Sauber Ferrari",
        24: "Kick Sauber Ferrari",
        
        10: "Alpine Renault",
        31: "Alpine Renault",
        
        23: "Williams Mercedes",
        2: "Williams Mercedes"
]

let teamHexcode: [String: String] = [
    "Red Bull Racing Honda RBPT": "#3671C6",
    "Ferrari": "#E8002D",
    "Mercedes": "#27F4D2",
    "Aston Martin Aramco Mercedes": "#229971",
    "McLaren Mercedes": "#FF8000",
    "Haas Ferrari": "#B6BABD",
    "RB Honda RBPT": "#FFFFFF",
    "Williams Mercedes": "#FFFFFF",
    "Kick Sauber Ferrari": "#52E252",
    "Alpine Renault": "#FF87BC"
]

func loadCarModel(driverId: Int) async -> (Int, ModelEntity)? {
    guard let teamName = driverIdToTeamMap[driverId] else {
        return nil
    }
    
    guard let carModelsFileName = teamToCar[teamName] else {
        return nil
    }
    
    print("Loading: \(carModelsFileName)")
    if let car = try? await ModelEntity(named: carModelsFileName) {
        return (driverId, car)
    }
    
    print("Failed to load car mode: \(carModelsFileName)")
    return nil
}

struct RaceTrackView: View {
    let items: [DriverPosition] = loadJSON("bahrain_positions") ?? []

    var body: some View {
        var cars: [Int: ModelEntity] = [:]
        
        RealityView { content in
            // Load Track
            
            let track = try! await ModelEntity(named: "track")
            let bounds = track.visualBounds(relativeTo: nil)
            let maxDimension = max(bounds.extents.x, bounds.extents.y, bounds.extents.z)
            let scaleFactor = 0.5 / maxDimension
            track.scale = SIMD3<Float>(scaleFactor, scaleFactor, scaleFactor)
            track.position = [0, 0, 0]
            
            // Load Cars
            
            let carScaleFactor = 0.075;
            
            let targetCarWidth = 2.0 * carScaleFactor
            let targetCarLength = 5.0 * carScaleFactor
            let targetCarHeight = 2.0 * carScaleFactor
            
            await withTaskGroup(of: (Int, ModelEntity)?.self) { group in
                for driverId in driverIdToTeamMap.keys {
                    group.addTask {
                        await loadCarModel(driverId: driverId)
                    }
                }
                
                for await response in group {
                    guard let (driverId, car) = response else {
                        continue
                    }
                    
                    if let modelBounds = car.model?.mesh.bounds {
                        let modelSize = modelBounds.extents  // Get current model size
                        let scaleX = Float(targetCarWidth) / modelSize.x
                        let scaleZ = Float(targetCarLength) / modelSize.z
                        let scaleY =  Float(targetCarHeight) / modelSize.x
                        
                        car.transform.scale = SIMD3<Float>(scaleX, scaleY, scaleZ)
                    }
                    
                    car.position.y += 3.1
                    car.position.z += 4.0
                    
                    car.transform.rotation = simd_quatf(angle: .pi / 2, axis: [0, -1, 0])
                    
                    let lightEntity = Entity()
                    var pointLight = PointLightComponent()
                    pointLight.intensity = 10
                    
                    // Adjust spread
                    pointLight.attenuationRadius = 2.0
                    
                    if let teamName = driverIdToTeamMap[driverId] {
                        if let hexCodeColor = teamHexcode[teamName] {
                            pointLight.color = UIColor(hex: hexCodeColor)
                          
                            lightEntity.components.set(pointLight)
                            lightEntity.position = [0, 2, 0]

                            car.addChild(lightEntity, preservingWorldTransform: false)
                        } else {
                            print("Error finding hex code color.")
                        }
                    } else {
                        print("Error finding team name.")
                    }
                   
                    cars[driverId] = car
                    track.addChild(car, preservingWorldTransform: false)
                }
            }
    
            content.add(track)
            
            Task {
                var prevTime = 0.0;
                
                for positionIndex in 0..<items[0].positions.count {
                    var delta = 0.0;
                    
                    for driverId in driverIdToTeamMap.keys {
                        if let car = cars[driverId] {
                            
                            let driverIdPositionIndex = items.firstIndex(where: { $0.id == driverId }) ?? -1
                            
                            if driverIdPositionIndex == -1 {
                                continue
                            }
                            
                            let pos = items[driverIdPositionIndex].positions[positionIndex]
                            
                           
                            // Same for all cars, used for calculating delta
                            if delta == 0 {
                                delta = Double(pos[3]) - prevTime
    
                                prevTime = Double(pos[3])
                            }
                            
                            let currentX = Double(pos[1])
                            let currentZ = Double(pos[0])
                            
                            var prevX = 0.0;
                            var prevZ = 0.0;
                            
                            if positionIndex > 0 {
                                prevX = Double(items[driverIdPositionIndex].positions[positionIndex - 1][1])
                                prevZ = Double(items[driverIdPositionIndex].positions[positionIndex - 1][0])
                            }
                            
                            let transformationRotation = getTransformationRotation(
                                currentX: currentX,
                                currentZ: currentZ,
                                prevX: prevX,
                                prevZ: prevZ
                            )
                            
                            let newX = -Double(pos[1] * 0.00070) + 2.2
                            let newZ = -Double(pos[0] * 0.00120) + 3.65
                            
                            let targetTransform = Transform(
                                scale: car.transform.scale,
                                rotation: transformationRotation,
                                
                                translation: SIMD3(
                                    Float(newX),
                                    car.transform.translation.y,
                                    Float(newZ)
                                )
                            )
                            
                            let deltaCopy = delta
                            
                            DispatchQueue.main.async {
                                car.move(to: targetTransform, relativeTo: track, duration: deltaCopy, timingFunction: .linear)
                            }
                        }
                    }
                    
                    try? await Task.sleep(nanoseconds: UInt64(delta * 1_000_000_000))
                }
            }
        }
    }
}

#Preview {
    RaceTrackView()
}
