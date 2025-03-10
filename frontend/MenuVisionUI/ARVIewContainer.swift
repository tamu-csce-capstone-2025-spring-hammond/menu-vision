import SwiftUI
import RealityKit
import ARKit

private var grounded: Bool = false;

var modelIndex: Int = 0;

private let modelMap: [Int: String] = [
    0: "apple_1",
    1: "avocado_1",
    2: "onion_1",
    3: "orange_1"
];

extension simd_float4x4 {
    func toTranslation() -> SIMD3<Float> {
        return SIMD3<Float>(columns.3.x, columns.3.y, columns.3.z);
    }
}

//add AR coaching implementation
//when user first starts up app (or AR render view) this will pop up directing the user to move their phone around
//along a surface until a flat surface for anchoring is discovered
extension ARView: ARCoachingOverlayViewDelegate {
    func addCoaching() {
        print("Model Index: ",modelIndex);
        let coacher = ARCoachingOverlayView(frame: self.bounds);
        
        coacher.session = self.session;
        
        coacher.autoresizingMask = [.flexibleWidth, .flexibleHeight];
        
        coacher.activatesAutomatically = true;
        
        coacher.goal = .horizontalPlane; //look for flat surfaces
        
        self.addSubview(coacher);
                
    }
}

class ARViewManager: ObservableObject {

    func changeModel() {
        modelIndex = (modelIndex + 1) % modelMap.count;
    }
    
    func getCurrentModelName() -> String {
        return modelMap[modelIndex] ?? "";
    }
}


struct ARViewContainer: UIViewRepresentable {
    
    @ObservedObject var viewManager: ARViewManager
    
    func makeUIView(context: Context) -> ARView {
        
        let arView = ARView(frame: .zero);
        
        // Setup AR session with occlusion
        let config = ARWorldTrackingConfiguration();
        config.planeDetection = .horizontal;
        config.frameSemantics.insert(.personSegmentationWithDepth);
        arView.session.run(config);
        
        arView.addCoaching();

        // Add tap gesture for placing objects
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)));
        
        arView.addGestureRecognizer(tapGesture);

        context.coordinator.arView = arView; // Assign ARView to Coordinator

        return arView;
    }

    func updateUIView(_ uiView: ARView, context: Context) {
        //context.coordinator.sz = sz;
        
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self);
    }

    class Coordinator: NSObject {
        var parent: ARViewContainer;
        weak var arView: ARView?;

        init(_ parent: ARViewContainer) {
            self.parent = parent;
        }

        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            guard let arView = arView else { return }
            
            //function takes in a tap and figures out what to do
            print("Tapped at:", gesture.location(in: arView));

            //retrieve the location where the user tapped
            let location = gesture.location(in: arView);
            
            //scan the scene looking for anchor options
            if let currentFrame = arView.session.currentFrame {
                let anchors = currentFrame.anchors;
                print("Detected anchors: \(anchors)");
            }
            
            //shoot out a ray from tap location to determine if selected position is a possible anchor point
            //if so then retrieve anchor point information
            if let result = arView.raycast(from: location, allowing: .existingPlaneGeometry, alignment: .horizontal).first {
                print("Hit detected at:", result.worldTransform.toTranslation())
                //render the model at the detected anchor point
                placeModel(from: result, in: arView);
            } else {
                print("No surface detected");
            }
        }
        func placeModel(from raycastResult: ARRaycastResult, in arView: ARView) {
            do {
                //set up light
                let light = DirectionalLight();
                light.light.intensity = 1000;
                light.isEnabled = true;
                
                let lightAnch = AnchorEntity(world: SIMD3(0.0, 0.0, 0.0));
                lightAnch.addChild(light);
                arView.scene.addAnchor(lightAnch);
                
                guard let modelName = modelMap[modelIndex] else {
                    print("Error: model name is not to be found!");
                    return;
                }
                
                //set up a model entity by loading in the usdz file and setting position to be slightly above ground
                let model = try ModelEntity.loadModel(named: modelName);
                model.position = SIMD3(0.0, 0.7, 0.0);
                model.scale = [1.0, 1.0, 1.0];
                                
                //set up rigid body and collision components
                
                let mealPhysicsMaterial = PhysicsMaterialResource.generate(friction: 0.5, restitution: 0.5); //make material with low resitution so it doesnt bounce around
                
                let rigidBody: PhysicsBodyComponent = .init(massProperties: .default, material: mealPhysicsMaterial, mode: .dynamic );
                
                model.generateCollisionShapes(recursive: true); //generate a convex hull collision component for the model
                                
                model.components.set(rigidBody);
                
                //take in raycast result to set anchor and attach the model to this anchor then add anchor to scene
                let anchor = AnchorEntity(raycastResult: raycastResult);
                anchor.addChild(model);
                
                //prevent creating multiple grounds and causing issues
                if (!grounded){
                    //set up ground entity
                    let ground = ModelEntity(mesh: .generatePlane(width: 0.01, depth: 0.01), materials: [SimpleMaterial(color: .clear, roughness: 0, isMetallic: false)]);
                    
                    //make ground collision component
                    
                    let groundCollisionComponent: CollisionComponent = .init(shapes: [.generateBox(size: [100, 0.01, 100])]);
                    
                    let groundphysicsBody: PhysicsBodyComponent = .init(mode: .static);
                                    
                    ground.components.set(groundCollisionComponent);
                    ground.components.set(groundphysicsBody);
                    
                    anchor.addChild(ground);
                    
                    //grounded = true;
                }
                
                arView.scene.addAnchor(anchor);

            } catch {
                print("Error loading model: \(error)");
            }
        }
    }
}

