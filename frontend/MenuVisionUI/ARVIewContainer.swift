import SwiftUI
import RealityKit
import ARKit
import AVFoundation
import Vision

struct PresentModel{
    var model: ModelEntity
    var anchor: AnchorEntity
    var mealID: Int;
    var labelled: Bool;
    var atRest: Bool;
}

var presentModels: [PresentModel] = [];

private var grounded: Bool = false;

var modelIndex: Int = 0;

var freestyleMode : Bool = false;

var modelPlaced: Bool = false;

var viewer: ARView!;

private var modelMap: [Int: (String, String)] = [:]

func resetScene(){
    modelPlaced = false;
    viewer.scene.anchors.removeAll();
    presentModels.removeAll();
}

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

//for some reason the mod can go negative here so I added the count again to ensure its positive
func decModel(){
    modelIndex = (modelIndex - 1 + modelMap.count) % modelMap.count;
}

func incModel(){
    modelIndex = (modelIndex + 1 + modelMap.count) % modelMap.count;
}

class ARViewManager: ObservableObject {
    
    func changeModel(index: Int) {
        modelIndex = index;
        
        if (!freestyleMode){
            swapModel();
        }
    }
    
    func decrementModel() {
        decModel();
        
        if (!freestyleMode){
            swapModel();
        }
    }
    
    func incrementModel() {
        incModel();
        
        if (!freestyleMode){
            swapModel();
        }
    }
    
    func currentIndex() -> Int {
        
        return modelIndex;
    }
    
    func getCurrentModelID() -> String {
        if let model = modelMap[modelIndex] {
            let modelName = model.0;
            return modelName;
        }
        else{
            return "";
        }
    }
    
    func getCurrentModelName() -> String {
        if let model = modelMap[modelIndex] {
            let modelName = model.1;
            return modelName;
        }
        else{
            return "";
        }
    }
    
    func getModelMap() -> [Int: (String, String)] {
        return modelMap;
    }
    
    func modeSwitch() {
        freestyleMode.toggle();
        
        resetScene();
    }
    
    func reset(){
        resetScene();
    }
    
}


struct ARViewContainer: UIViewRepresentable {
    
    @ObservedObject var viewManager: ARViewManager
    
    @EnvironmentObject var dishMapping: DishMapping
    
    //@Binding var setUpComplete: Bool
    
    func makeUIView(context: Context) -> ARView {
        
        //fill the model map
        
        Task{
            
            dishMapping.setStartedLoading();
            
            modelMap.removeAll()
                    
            for (index, dish) in dishMapping.getModels()
                .sorted(by: {
                    ($0.value.max(by: { $0.model_rating < $1.model_rating })?.model_rating ?? 0) >
                    ($1.value.max(by: { $0.model_rating < $1.model_rating })?.model_rating ?? 0)
                }).enumerated()
            {
                if let bestModel = dish.value.max(by: { $0.model_rating < $1.model_rating }) {
                    modelMap[index] = (bestModel.model_id, bestModel.dish_name)
                    
                    if bestModel.model_id == dishMapping.goToID {
                        modelIndex = index
                    }
                    
                    print("Making model map: ", bestModel.dish_name);
                }
                            
            }

            dishMapping.setFinishedLoading();
        }
        
                        
        let arView = ARView(frame: .zero);
        
        viewer = arView;
        
        // Setup AR session with occlusion
        let config = ARWorldTrackingConfiguration();
        config.planeDetection = .horizontal;
        
        if ARWorldTrackingConfiguration.supportsFrameSemantics(.personSegmentationWithDepth) {
            config.frameSemantics.insert(.personSegmentationWithDepth);
        }
        
        if ARWorldTrackingConfiguration.supportsFrameSemantics(.sceneDepth) {
            config.frameSemantics.insert(.sceneDepth)
        }
        
        config.maximumNumberOfTrackedImages = 10;
        
        arView.session.run(config);
        
        arView.addCoaching();

        // Add tap gesture for placing objects
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)));
        
        // add long press gesture for removing objects
        let longPressGesture = UILongPressGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleLongPress(_:)));
        
        arView.addGestureRecognizer(tapGesture);
        arView.addGestureRecognizer(longPressGesture);
        
        context.coordinator.arView = arView; // Assign ARView to Coordinator
        
        arView.session.delegate = context.coordinator;
        

        
        return arView;
    }
    
    static func dismantleUIView(_ uiView: ARView, coordinator: Coordinator) {
        print("Ending AR");
        uiView.session.pause()
    }

    func updateUIView(_ uiView: ARView, context: Context) {
        //context.coordinator.sz = sz;
        
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self);
    }
    

    class Coordinator: NSObject, ARSessionDelegate {
        var parent: ARViewContainer;
        weak var arView: ARView?;
        
        private var handPose = VNDetectHumanHandPoseRequest();

        init(_ parent: ARViewContainer) {
            self.parent = parent;
        }
        
        //callback called every frame
        func session(_ session: ARSession, didUpdate frame: ARFrame) {
            //let frameCapture = frame.capturedImage;
            //trackHand(in: frameCapture);
            
            //for each frame go through the presentModels if they have a label update its position
            presentModels.enumerated().forEach { i, pm in
               if (pm.labelled == true){
                   for childEntity in pm.anchor.children{
                       if (childEntity.name == "label"){
                           childEntity.position = pm.model.position;
                       }
                   }
               }
                
                //check if model is now at rest and should be reoriented
                
                if (!pm.atRest){
                    guard let motion = pm.model.components[PhysicsMotionComponent.self] as? PhysicsMotionComponent else { return }
                    
                    let velocity = motion.linearVelocity;
                    let velocityThreshold: Float = 0.0001;

                    if abs(velocity.x) < velocityThreshold && abs(velocity.y) < velocityThreshold && abs(velocity.z) < velocityThreshold {
                        
                        let targetOrientation = simd_quatf(angle: 0, axis: [1, 0, 0]);
                        
                        var transform = pm.model.transform;
                        transform.rotation = targetOrientation;
                        
                        // Use a transform animation to gradually apply the rotation
                        pm.model.move(to: transform, relativeTo: pm.model.parent, duration: 0.5, timingFunction: .easeInOut);
                        
                        presentModels[i].atRest = true;
                    }
                }
           }
        }
        
        //take in a frame capture and use computer vision to seek out hand positions and gestures
        func trackHand(in frameCapture: CVPixelBuffer) {
            let handler = VNImageRequestHandler(cvPixelBuffer: frameCapture, options: [:]);
            do {
                try handler.perform([handPose])
                if let observationResults = handPose.results?.first {
                    
                    let thumbPoints = try observationResults.recognizedPoints(.thumb);
                    let indexFingerPoints = try observationResults.recognizedPoints(.indexFinger);
                    
                    //search for tip points of each finger
                    guard let thumbTipPoint = thumbPoints[.thumbTip], let indexTipPoint = indexFingerPoints[.indexTip] else {
                        return;
                    }
                    
                    // Ignore low confidence points.
                    guard thumbTipPoint.confidence > 0.3 && indexTipPoint.confidence > 0.3 else {
                        return;
                    }
                    // Convert points from Vision coordinates to AVFoundation coordinates.
                    let thumbTipLocation = CGPoint(x: thumbTipPoint.location.x, y: 1 - thumbTipPoint.location.y);
                    let indexTipLocation = CGPoint(x: indexTipPoint.location.x, y: 1 - indexTipPoint.location.y);
                    
                    let fingerDistance = hypot(thumbTipPoint.location.x - indexTipPoint.location.x,
                                               thumbTipPoint.location.y - indexTipPoint.location.y);
                    
                    if (fingerDistance < 0.015){
                        print("PINCH DETECTED");
                        incModel();
                    }
                }
            } catch {
                print("Hand tracking failed: \(error)")
            }
        }
        
        @objc func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
            
            //toggle models upon swipe
            
            
            
        }

        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            guard let arView = arView else { return }
            
            //only do this if in freestyle mode after the first time
            
            if (!freestyleMode && modelPlaced){
                return;
            }
            
            //function takes in a tap and figures out what to do
            print("Tapped at:", gesture.location(in: arView));

            //retrieve the location where the user tapped
            let location = gesture.location(in: arView);
            
            var found = false;
            
            //first check if there is already a model here
            if let tappedModel = arView.entity(at: location){
                
                if (tappedModel.name != ""){
                    
                    presentModels.enumerated().forEach { i, pm in
                        if (pm.model.position == tappedModel.position){
                            
                            //if already labelled then remove the label
                            
                            found = true;
                            
                            if (pm.labelled == true){
                                for childEntity in pm.model.children{
                                    if (childEntity.name == "label"){
                                        childEntity.removeFromParent();
                                        presentModels[i].labelled = false;
                                        break;
                                    }
                                }
                            }
                            else {
                                //in this case we will add the label text
                                if let meal = modelMap[pm.mealID]{
                                    
                                    let mealName = meal.1;
                                    
                                    //print(modelMap[pm.mealID]);
                                    
                                    //if we want to change label color in the future use this format
                                    //let textColor = SimpleMaterial.Color(red: 0.98, green: 0.67, blue: 0.48, alpha: 0.95);
                                    
                                    
                                    let textMaterials = SimpleMaterial(color: .cyan, roughness: 0, isMetallic: false);
                                    
                                    let textDepth: Float = 0.01;
                                    let textFont = UIFont.systemFont(ofSize: 0.05);
                                    let textContainerFrame = CGRect(x: -0.15, y: -0.15, width: 0.3, height: 0.3);
                                    let textAlignment: CTTextAlignment = .center;
                                    let textLineBreak : CTLineBreakMode = .byWordWrapping;
                                    
                                    let textMeshResource : MeshResource = .generateText(mealName,
                                                                                        extrusionDepth: textDepth,
                                                                                        font: textFont,
                                                                                        containerFrame: textContainerFrame,
                                                                                        alignment: textAlignment,
                                                                                        lineBreakMode: textLineBreak
                                    );
                                    
                                    let textEntity = ModelEntity(mesh: textMeshResource, materials: [textMaterials]);
                                    
                                    //let xPos = pm.model.position.x;
                                    
                                    //let yPos = pm.model.position.y;
                                    
                                    //let zPos = pm.model.position.z;
                                    
                                    let modelBounds = pm.model.visualBounds(relativeTo: nil)
                                    let offset = modelBounds.max.y - modelBounds.min.y
                                    //textEntity.position = SIMD3<Float>(pm.model.position., topWorldY, 0);
                                                                                                        
                                                                        //fix orientation to only shift along y axis
                                    
                                    textEntity.position += SIMD3<Float>(0, offset, 0);
                                                                        
                                    textEntity.name = "label";
                                    
                                    //print("Text Entity Position: \(textEntity.position)")
                                    
                                    pm.model.addChild(textEntity);
                                    
                                    
                                    presentModels[i].labelled = true;
                                    
                                    //print("Anchor Entities: \(arView.scene.anchors)")
                                }
                            }
                            
                        }
                    }
                                    
                }
                
            }
            
            //if no model already there then go ahead and place a model
            if (!found){
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
                    
                    modelPlaced = true;
                } else {
                    print("No surface detected");
                }
            }
            
        }
        
        @objc func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
            guard let arView = arView else { return }
            
            //function takes in a tap and figures out what to do
            print("Long press at:", gesture.location(in: arView));

            //retrieve the location where the user tapped
            let location = gesture.location(in: arView);
                        
            //first check if there is already a model here
            if let tappedModel = arView.entity(at: location){
                
                if (tappedModel.name != ""){
                    
                    presentModels.enumerated().forEach { i, pm in
                        if (pm.model.position == tappedModel.position){
                            
                            if (!freestyleMode){
                                //when its not freestyle mode i'll just let this be like a do over mode in case theres a bug with where the anchor was placed or something
                                resetScene()
                                return;
                            }
                            
                            //if already labelled then remove the label
                                                        
                            print("Deleting model", pm.model.name);
                            
                            let oldPosition = pm.model.position;
                            let oldAnchorPosition = pm.anchor.position;
                            
                            pm.anchor.removeFromParent()
                            
                            presentModels.remove(at:i);
                            
                            //add smoke then remove it once its done
                            /*var smoke = ParticleEmitterComponent()
                            smoke.emitterShape = .sphere
                            smoke.emitterShapeSize = [1,1,1] * 0.005

                            smoke.mainEmitter.birthRate = 2000 //amount of particles spawned per frame
                            smoke.mainEmitter.size = 0.1 //size of each particle
                            smoke.mainEmitter.lifeSpan = 0.6 //how long each particle will stay active before disappearing
                            
                            smoke.mainEmitter.color = .evolving(start: .single(.lightGray),
                                                                end: .single(.darkGray));
                            
                            var emissionDuration = 0.3;
                                
                            //how long the particles will be emitted
                            smoke.timing = .once(warmUp: 0.01, emit: ParticleEmitterComponent.Timing.VariableDuration(duration:emissionDuration));
                            
                            let particleEntity = Entity()
                            particleEntity.components.set(smoke);
                            
                            particleEntity.position = oldPosition;

                            let smokeAnchor = AnchorEntity();
                            
                            smokeAnchor.position = oldAnchorPosition;
                            
                            smokeAnchor.addChild(particleEntity);
                            
                            arView.scene.addAnchor(smokeAnchor);
                            
                            //remove after smoke is done
                            DispatchQueue.main.asyncAfter(deadline: .now() + emissionDuration + smoke.mainEmitter.lifeSpan) { [weak self] in
                                arView.scene.removeAnchor(smokeAnchor)
                            }*/

                                                                
                        }
                    }
                                    
                }
                
            }
           
        }
        
        func placeModel(from raycastResult: ARRaycastResult, in arView: ARView) {
            do {
                //set up light
                if (!modelPlaced){
                    let light = DirectionalLight();
                    light.light.intensity = 1000;
                    light.isEnabled = true;
                    
                    let lightAnch = AnchorEntity(world: SIMD3(0.0, 0.0, 0.0));
                    lightAnch.addChild(light);
                    arView.scene.addAnchor(lightAnch);
                }
                                
                var model = createModel();
                
                //take in raycast result to set anchor and attach the model to this anchor then add anchor to scene
                #if !XCODE_RUNNING_FOR_PREVIEWS
                let anchor = AnchorEntity(world: raycastResult.worldTransform)
                #else
                let anchor = AnchorEntity(raycastResult: raycastResult)
                #endif
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
                
                var particles = ParticleEmitterComponent()
                particles.emitterShape = .sphere
                particles.emitterShapeSize = [1,1,1] * 0.005

                particles.mainEmitter.birthRate = 700 //amount of particles spawned per frame
                particles.mainEmitter.size = 0.013 //size of each particle
                particles.mainEmitter.lifeSpan = 0.8 //how long each particle will stay active before disappearing
                
                particles.mainEmitter.color = .constant(.random(a: .cyan, b: .red)); //color of each particle set to either cyan or red (Random)
                    
                //how long the particles will be emitted
                particles.timing = .once(warmUp: 0.01, emit: ParticleEmitterComponent.Timing.VariableDuration(duration:0.5));

                model.components.set(particles);
                
                arView.scene.addAnchor(anchor);
                
                arView.installGestures(.translation, for: model);
                
                //add this new models information to the list of present models to refer back to later
                
                presentModels.append(PresentModel(model:model, anchor:anchor, mealID:modelIndex, labelled: false, atRest: false));
                                

            } catch {
                print("Error loading model: \(error)");
            }
        }

    }
}

func swapModel(){
    
    //can only be done after a model has been placed in the past and an anchor exists
    if (!modelPlaced){
        return;
    }
    
    let oldModel = presentModels[0].model;
    
    presentModels[0].anchor.removeChild(presentModels[0].model);
    
    var model = createModel();
    
    model.position = oldModel.position;
    
    //add smoke
    var smoke = ParticleEmitterComponent()
    smoke.emitterShape = .sphere
    smoke.emitterShapeSize = [1,1,1] * 0.005

    smoke.mainEmitter.birthRate = 2000 //amount of particles spawned per frame
    smoke.mainEmitter.size = 0.1 //size of each particle
    smoke.mainEmitter.lifeSpan = 0.6 //how long each particle will stay active before disappearing
    
    smoke.mainEmitter.color = .evolving(start: .single(.lightGray),
                                        end: .single(.white));
        
    //how long the particles will be emitted
    smoke.timing = .once(warmUp: 0.01, emit: ParticleEmitterComponent.Timing.VariableDuration(duration:0.3));

    model.components.set(smoke);
    
    presentModels[0].anchor.addChild(model);
    
    presentModels[0].model = model;
    
    viewer.installGestures(.translation, for: model);
    
}

func createModel() -> ModelEntity{
    
    do{
        
        guard let mod = modelMap[modelIndex] else {
            print("Error: model name is not to be found!");
            return ModelEntity();
        }
        
        var fileName = mod.0;
        
        var model : ModelEntity = ModelEntity();
        
        //set up a model entity by loading in the usdz file and setting position to be slightly above ground
        
        let fileManager = FileManager.default
        if let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            do {
                model = try ModelEntity.loadModel(contentsOf: documentsURL.appendingPathComponent(fileName + ".usdz"));
            } catch {
                print("Failed to load model: \(error.localizedDescription)")
            }
        }
                
        model.position = SIMD3(0.0, 0.7, 0.0);
        
        model.scale = [1.0, 1.0, 1.0];
                        
        //set up rigid body and collision components
        
        let mealPhysicsMaterial = PhysicsMaterialResource.generate(friction: 0.5, restitution: 0.5); //make material with low resitution so it doesnt bounce around
        
        let rigidBody: PhysicsBodyComponent = .init(massProperties: .default, material: mealPhysicsMaterial, mode: .dynamic );
        
        model.generateCollisionShapes(recursive: true); //generate a convex hull collision component for the model
                        
        model.components.set(rigidBody);
        
        model.physicsMotion = .init();
        
        return model;
        
    } catch {
        print("Error loading model: \(error)");
    }
    
    return ModelEntity();
    
}
