import SwiftUI
import RealityKit
import ARKit

/*private func generateShadow() -> ModelEntity {
    
    
    
}*/

extension simd_float4x4 {
    func toTranslation() -> SIMD3<Float> {
        return SIMD3<Float>(columns.3.x, columns.3.y, columns.3.z);
    }
}

struct ARViewContainer: UIViewRepresentable {
    @Binding var sz: Float; // Bind state to update the model

    func makeUIView(context: Context) -> ARView {
        
        let arView = ARView(frame: .zero);

        // Setup AR session with occlusion
        let config = ARWorldTrackingConfiguration();
        config.planeDetection = .horizontal;
        config.frameSemantics.insert(.personSegmentationWithDepth);
        arView.session.run(config);

        // Add tap gesture for placing objects
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)));
        
        arView.addGestureRecognizer(tapGesture);

        context.coordinator.arView = arView; // Assign ARView to Coordinator

        return arView;
    }

    func updateUIView(_ uiView: ARView, context: Context) {
        context.coordinator.sz = sz;
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self);
    }

    class Coordinator: NSObject {
        var parent: ARViewContainer;
        weak var arView: ARView?;
        var sz: Float;

        init(_ parent: ARViewContainer) {
            self.parent = parent;
            self.sz = parent.sz;
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
                //set up a model entity by loading in the usdz file and setting position to be slightly above ground
                let model = try ModelEntity.loadModel(named: "latte");
                model.position = SIMD3(0.0, 0.05, 0.0);
                model.scale = [sz, sz, sz];

                //take in raycast result to set anchor and attach the model to this anchor then add anchor to scene
//                let anchor = AnchorEntity(raycastResult: raycastResult);
                let anchor = AnchorEntity(world: raycastResult.worldTransform.toTranslation())


                anchor.addChild(model);
                arView.scene.addAnchor(anchor);

            } catch {
                print("Error loading model: \(error)");
            }
        }
    }
}

