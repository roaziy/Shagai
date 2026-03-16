import SwiftUI
import RealityKit
import ARKit
import Vision

enum GameState: String {
    case searching = "Searching..."
    case holding = "Holding (Ready to Throw)"
    case throwing = "Thrown! (Wait for Result...)"
    case result = "Result"
}

struct ThrowResult: Equatable {
    var horse: Int = 0
    var camel: Int = 0
    var sheep: Int = 0
    var goat: Int = 0
}

class ARGameViewModel: ObservableObject {
    @Published var gameState: GameState = .searching
    @Published var debugText: String = "Ready"
    @Published var lastThrowResult: ThrowResult?
    @Published var isInputEnabled: Bool = true
    var isStoryMode: Bool = false
    
    func resetForNextThrow() {
        gameState = .searching
        lastThrowResult = nil
        debugText = "Your turn!"
        isInputEnabled = true
    }
}

class HandOverlayView: UIView {
    var points: [CGPoint] = [] {
        didSet {
            DispatchQueue.main.async { self.setNeedsDisplay() }
        }
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.setFillColor(UIColor.red.cgColor)
        for point in points {
            context.fillEllipse(in: CGRect(x: point.x - 2, y: point.y - 2, width: 4, height: 4))
        }
    }
    
    init() {
        super.init(frame: .zero)
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = false
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

struct ARGameView: UIViewRepresentable {
    @ObservedObject var viewModel: ARGameViewModel
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal]
        config.environmentTexturing = .automatic
        if let ultraWide = ARWorldTrackingConfiguration.supportedVideoFormats.first(where: { $0.captureDeviceType == .builtInUltraWideCamera }) {
            config.videoFormat = ultraWide
        }
        arView.session.run(config)
        
        let overlay = HandOverlayView()
        overlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        overlay.frame = arView.bounds
        arView.addSubview(overlay)
        context.coordinator.overlay = overlay
        
        arView.debugOptions = []
        
        context.coordinator.setup(arView: arView)
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(viewModel: viewModel)
    }
    
    @MainActor
    class Coordinator: NSObject, ARSessionDelegate {
        var viewModel: ARGameViewModel
        weak var arView: ARView?
        weak var overlay: HandOverlayView?
        private var planeAnchors: [UUID: AnchorEntity] = [:]
        
        private var frameCounter = 0
        private var isProcessingFrame = false
        private var handDebugMarker: ModelEntity?
        
        private var shagaiCubes: [ModelEntity] = []
        
        private var lastHandState: String = "UNKNOWN"
        private var stateStableCount = 0
        private var handPositionHistory: [(time: TimeInterval, pos: SIMD3<Float>)] = []
        private var recentVelocities: [SIMD3<Float>] = []
        
        private var stabilityFrameCount = 0
        
        private var framesSinceLastHand = 0
        private var smoothedHandPos: SIMD3<Float>?
        
        private var currentOrientation: UIInterfaceOrientation = .portrait
        
        private var fallbackFloor: ModelEntity?
        
        init(viewModel: ARGameViewModel) {
            self.viewModel = viewModel
            super.init()
        }
        
        func setup(arView: ARView) {
            self.arView = arView
            arView.session.delegate = self
            
            if let windowScene = arView.window?.windowScene {
                currentOrientation = windowScene.interfaceOrientation
            }
            
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(orientationDidChange),
                name: UIDevice.orientationDidChangeNotification,
                object: nil
            )
            
            let markerMesh = MeshResource.generateSphere(radius: 0.005)
            let markerMat = SimpleMaterial(color: .green, isMetallic: false)
            let marker = ModelEntity(mesh: markerMesh, materials: [markerMat])
            marker.isEnabled = false
            marker.components[CollisionComponent.self] = nil
            
            let anchor = AnchorEntity(world: .zero)
            anchor.addChild(marker)
            arView.scene.addAnchor(anchor)
            self.handDebugMarker = marker
            
            addFallbackFloor(arView: arView)
            setupShagaiCubes(arView: arView)
        }
        
        private func addFallbackFloor(arView: ARView) {
            let floor = ModelEntity()
            let shape = ShapeResource.generateBox(width: 10, height: 0.01, depth: 10)
            floor.collision = CollisionComponent(shapes: [shape])
            floor.physicsBody = PhysicsBodyComponent(mode: .static)
            floor.physicsBody?.material = .generate(friction: 1.0, restitution: 0.0)
            floor.position = [0, -0.5, 0]
            
            let anchor = AnchorEntity(world: .zero)
            anchor.addChild(floor)
            arView.scene.addAnchor(anchor)
            self.fallbackFloor = floor
        }
        
        @objc private func orientationDidChange() {
            if let windowScene = arView?.window?.windowScene {
                currentOrientation = windowScene.interfaceOrientation
            }
            
            self.smoothedHandPos = nil
            self.handPositionHistory.removeAll()
            self.recentVelocities.removeAll()
        }
        
        deinit {
            NotificationCenter.default.removeObserver(self)
        }
        
        private func setupShagaiCubes(arView: ARView) {
            var baseEntity: Entity?
            
            if let entity = try? Entity.load(named: "3DModel.usdc") {
                baseEntity = entity
            } else if let entity = try? Entity.load(named: "assets/3DModel.usdc") {
                baseEntity = entity
            }
            
            var customMaterial: RealityKit.Material?
            var texture: TextureResource?
            var texStatus = "Tex: FAIL"
            
            if let t = try? TextureResource.load(named: "3DModel") {
                texture = t
                texStatus = "Tex: OK"
            }
            
            DispatchQueue.main.async {
                self.viewModel.debugText = texStatus
            }
            
            if let tex = texture {
                var mat = UnlitMaterial()
                mat.color = .init(texture: .init(tex))
                customMaterial = mat
            }
            
            if let model = baseEntity, let mat = customMaterial {
                applyMaterialRecursively(entity: model, material: mat)
            }
            
            let fallbackMesh = MeshResource.generateBox(size: 0.018)
            let fallbackMat = SimpleMaterial(color: .cyan, isMetallic: false)
            let fallbackEntity = ModelEntity(mesh: fallbackMesh, materials: [fallbackMat])
            
            for _ in 0..<4 {
                let entity: Entity
                
                if let base = baseEntity?.clone(recursive: true) {
                    entity = base
                    
                    let bounds = entity.visualBounds(relativeTo: nil)
                    let size = bounds.extents
                    let maxDim = max(size.x, max(size.y, size.z))
                    
                    if maxDim > 0 {
                        let targetSize: Float = 0.03
                        let scaleFactor = targetSize / maxDim
                        entity.setScale([scaleFactor, scaleFactor, scaleFactor], relativeTo: nil)
                    }
                } else {
                    entity = fallbackEntity.clone(recursive: true)
                }
                
                var physicsEntity: Entity = entity
                
                let boneMat = PhysicsMaterialResource.generate(friction: 1.0, restitution: 0.0)
                
                var massProps = PhysicsMassProperties.default
                massProps.mass = 0.15
                
                if let modelEnt = entity as? ModelEntity {
                    modelEnt.physicsBody = PhysicsBodyComponent(
                        massProperties: massProps,
                        material: boneMat,
                        mode: .kinematic
                    )
                    modelEnt.generateCollisionShapes(recursive: true)
                } else {
                    let wrapper = ModelEntity()
                    wrapper.addChild(entity)
                    
                    let shape = ShapeResource.generateBox(size: [0.032, 0.032, 0.032])
                    wrapper.collision = CollisionComponent(shapes: [shape])
                    wrapper.physicsBody = PhysicsBodyComponent(
                        massProperties: massProps,
                        material: boneMat,
                        mode: .kinematic
                    )
                    physicsEntity = wrapper
                }
                
                let anchor = AnchorEntity(world: .zero)
                anchor.addChild(physicsEntity)
                arView.scene.addAnchor(anchor)
                
                physicsEntity.setPosition([0, -10, 0], relativeTo: nil)
                
                if let res = physicsEntity as? ModelEntity {
                    shagaiCubes.append(res)
                }
            }
        }
        
        private func applyMaterialRecursively(entity: Entity, material: RealityKit.Material) {
                        if let modelEntity = entity as? ModelEntity {
                                modelEntity.model?.materials = [material]
                            }
                        for child in entity.children {
                                applyMaterialRecursively(entity: child, material: material)
                            }
                    }
                
        @objc(session:didUpdateFrame:)
                nonisolated func session(_ session: ARSession, didUpdate frame: ARFrame) {
                        Task { @MainActor in self.processFrame(frame) }
                    }
                
        @objc(session:didAddAnchors:)
                nonisolated func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
                        Task { @MainActor in self.addPlaneAnchors(anchors) }
                    }
                
        @objc(session:didUpdateAnchors:)
                nonisolated func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
                        Task { @MainActor in self.updatePlaneAnchors(anchors) }
                    }
                
        private func addPlaneAnchors(_ anchors: [ARAnchor]) {
            guard let arView = arView else { return }
            for anchor in anchors {
                if let planeAnchor = anchor as? ARPlaneAnchor {
                    let anchorEntity = AnchorEntity(anchor: planeAnchor)
                    
                    let width = planeAnchor.planeExtent.width
                    let depth = planeAnchor.planeExtent.height
                    
                    let model = ModelEntity()
                    
                    let visualModel = ModelEntity()
                    let mesh = MeshResource.generatePlane(width: width, depth: depth)
                    let material = SimpleMaterial(color: .cyan.withAlphaComponent(0.2), isMetallic: false)
                    visualModel.model = ModelComponent(mesh: mesh, materials: [material])
                    visualModel.position = [0, 0.501, 0]
                    model.addChild(visualModel)
                    
                    let shape = ShapeResource.generateBox(width: width, height: 1.0, depth: depth)
                    model.collision = CollisionComponent(shapes: [shape])
                    model.physicsBody = PhysicsBodyComponent(mode: .static)
                    model.physicsBody?.material = .generate(friction: 1.0, restitution: 0.0)
                    
                    model.position = SIMD3<Float>(planeAnchor.center.x, -0.5, planeAnchor.center.z)
                    anchorEntity.addChild(model)
                    arView.scene.addAnchor(anchorEntity)
                    self.planeAnchors[planeAnchor.identifier] = anchorEntity
                    
                    if let floor = self.fallbackFloor {
                        let planeWorldY = anchorEntity.position(relativeTo: nil).y
                        if planeWorldY < floor.position.y || floor.position.y == -0.5 {
                            floor.position.y = planeWorldY - 0.01
                        }
                    }
                }
            }
        }
        
        private func updatePlaneAnchors(_ anchors: [ARAnchor]) {
            for anchor in anchors {
                if let planeAnchor = anchor as? ARPlaneAnchor,
                   let anchorEntity = self.planeAnchors[planeAnchor.identifier],
                   let model = anchorEntity.children.first as? ModelEntity {
                    
                    let width = planeAnchor.planeExtent.width
                    let depth = planeAnchor.planeExtent.height
                    
                    let currentSize = model.collision?.shapes.first?.bounds.extents ?? .zero
                    let sizeDiff = abs(currentSize.x - width) + abs(currentSize.z - depth)
                    
                    if sizeDiff > 0.05 {
                        if let visual = model.children.first as? ModelEntity {
                            visual.model?.mesh = MeshResource.generatePlane(width: width, depth: depth)
                        }
                        
                        let shape = ShapeResource.generateBox(width: width, height: 1.0, depth: depth)
                        model.collision?.shapes = [shape]
                        model.position = SIMD3<Float>(planeAnchor.center.x, -0.5, planeAnchor.center.z)
                    }
                }
            }
        }
        
        private func processFrame(_ frame: ARFrame) {
            frameCounter += 1
            if frameCounter % 2 != 0 {
                return
            }
            
            if self.viewModel.gameState == .throwing {
                checkDiceState()
            }
            
            guard !isProcessingFrame else { return }
            isProcessingFrame = true
            let pixelBuffer = frame.capturedImage
            
            let intrinsics = frame.camera.intrinsics
            let resolution = frame.camera.imageResolution
            let focalLength = (intrinsics.columns.0.x + intrinsics.columns.1.y) / 2.0
            
            Task.detached(priority: .userInitiated) { [weak self] in
                guard let self = self else { return }
                
                let visionOrientation: CGImagePropertyOrientation = .up
                
                let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: visionOrientation)
                let request = VNDetectHumanHandPoseRequest()
                request.maximumHandCount = 1
                try? handler.perform([request])
                
                if let observation = request.results?.first {
                    let allPoints = try? observation.recognizedPoints(.all)
                    guard let points = allPoints else { await self.handleVisionEmpty(); return }
                    
                    let wrist = points[.wrist]
                    let middleMCP = points[.middleMCP]
                    
                    var rawHandState = "UNKNOWN"
                    var currentConf: Float = 0.0
                    
                    if let w = wrist, let m_mcp = middleMCP, w.confidence > 0.1 {
                        currentConf = Float(w.confidence)
                        
                        let handScale = hypot(w.location.x - m_mcp.location.x, w.location.y - m_mcp.location.y)
                        
                        if handScale > 0 {
                            var totalTipDist: CGFloat = 0
                            var tipCount: CGFloat = 0
                            
                            let tips: [VNHumanHandPoseObservation.JointName] = [.indexTip, .middleTip, .ringTip, .littleTip]
                            for tipName in tips {
                                if let tip = points[tipName], tip.confidence > 0.1 {
                                    let d = hypot(w.location.x - tip.location.x, w.location.y - tip.location.y)
                                    totalTipDist += d
                                    tipCount += 1
                                }
                            }
                            
                            if tipCount > 0 {
                                let avgDist = totalTipDist / tipCount
                                let ratio = avgDist / handScale
                                
                                if ratio < 1.1 { rawHandState = "FIST" }
                                else if ratio > 1.6 { rawHandState = "OPEN" }
                            }
                        }
                    }
                    
                    var estimatedDepth: Float = 0.4
                    
                    if let w = points[.wrist], let m_mcp = points[.middleMCP],
                       w.confidence > 0.3, m_mcp.confidence > 0.3 {
                        let distNorm = hypot(w.location.x - m_mcp.location.x, w.location.y - m_mcp.location.y)
                        let distPixels = Float(distNorm) * Float(resolution.width)
                        
                        if distPixels > 0 {
                            estimatedDepth = (focalLength * 0.15) / distPixels
                        }
                    }
                    
                    estimatedDepth = max(0.25, min(estimatedDepth, 0.8))
                    
                    var jointPoints: [CGPoint?] = []
                    let keys: [VNHumanHandPoseObservation.JointName] = [
                        .wrist, .thumbCMC, .thumbMP, .thumbIP, .thumbTip,
                        .indexMCP, .indexPIP, .indexDIP, .indexTip,
                        .middleMCP, .middlePIP, .middleDIP, .middleTip,
                        .ringMCP, .ringPIP, .ringDIP, .ringTip,
                        .littleMCP, .littlePIP, .littleDIP, .littleTip
                    ]
                    
                    for key in keys {
                        if let point = points[key], point.confidence > 0.1 {
                            jointPoints.append(CGPoint(x: point.location.x, y: point.location.y))
                        } else { jointPoints.append(nil) }
                    }
                    
                    var palmCenter: CGPoint? = nil
                    if let m_mcp = points[.middleMCP], m_mcp.confidence > 0.3 {
                        palmCenter = m_mcp.location
                    } else if let w = points[.wrist], w.confidence > 0.3 {
                        palmCenter = w.location
                    }
                    
                    await self.handleVisionResult(
                        palmCenter: palmCenter,
                        jointPoints: jointPoints,
                        rawHandState: rawHandState,
                        frame: frame,
                        estimatedDepth: estimatedDepth,
                        conf: currentConf
                    )
                } else {
                    await self.handleVisionEmpty()
                }
            }
        }
        
        private func handleVisionEmpty() {
            self.isProcessingFrame = false
            self.framesSinceLastHand += 1
            
            self.overlay?.points = []
            self.handDebugMarker?.isEnabled = false
            
            if self.viewModel.gameState == .holding {
                if framesSinceLastHand < 30 { return }
            }
            
            if self.viewModel.gameState != .throwing && self.viewModel.gameState != .result {
                self.updateState(.searching, info: "Lost Tracking")
            }
            
            self.handPositionHistory.removeAll()
            self.recentVelocities.removeAll()
            self.stateStableCount = 0
            self.smoothedHandPos = nil
        }
        
        private func handleVisionResult(palmCenter: CGPoint?, jointPoints: [CGPoint?], rawHandState: String, frame: ARFrame, estimatedDepth: Float, conf: Float) {
            defer { self.isProcessingFrame = false }
            guard let arView = arView else { return }
            
            self.framesSinceLastHand = 0
            
            var screenPoints: [CGPoint] = []
            let interfaceOrientation: UIInterfaceOrientation
            if let windowScene = arView.window?.windowScene {
                interfaceOrientation = windowScene.interfaceOrientation
            } else {
                interfaceOrientation = .portrait
            }
            
            let transform = frame.displayTransform(for: interfaceOrientation, viewportSize: arView.bounds.size)
            
            for point in jointPoints {
                if let p = point {
                    let pFlip = CGPoint(x: p.x, y: 1 - p.y)
                    let pScreenNorm = pFlip.applying(transform)
                    let pScreen = CGPoint(
                        x: pScreenNorm.x * arView.bounds.width,
                        y: pScreenNorm.y * arView.bounds.height
                    )
                    screenPoints.append(pScreen)
                }
            }
            self.overlay?.points = screenPoints
            
            guard let pCenter = palmCenter else { return }
            
            let cameraTransform = arView.cameraTransform
            
            let pFlip = CGPoint(x: pCenter.x, y: 1 - pCenter.y)
            let pScreenNorm = pFlip.applying(transform)
            let pScreen = CGPoint(
                x: pScreenNorm.x * arView.bounds.width,
                y: pScreenNorm.y * arView.bounds.height
            )
            
            let cameraPos = cameraTransform.translation
            let cameraForward = -normalize(SIMD3<Float>(
                cameraTransform.matrix.columns.2.x,
                cameraTransform.matrix.columns.2.y,
                cameraTransform.matrix.columns.2.z
            ))
            
            var handPos = cameraPos + (cameraForward * estimatedDepth)
            
            if let rayResult = arView.ray(through: pScreen) {
                let rayOrigin = rayResult.origin
                let rayDirection = normalize(rayResult.direction)
                handPos = rayOrigin + (rayDirection * estimatedDepth)
            }
            
            if let current = self.smoothedHandPos {
                let moveDist = distance(current, handPos)
                let smoothFactor: Float = moveDist > 0.05 ? 0.4 : 0.2
                self.smoothedHandPos = current * (1 - smoothFactor) + handPos * smoothFactor
            } else {
                self.smoothedHandPos = handPos
            }
            
            guard var finalHandPos = self.smoothedHandPos else { return }
            
            if let surfaceY = getNearestSurfaceBelow(handPos: finalHandPos) {
                let minHeight: Float = 0.12
                let currentHeight = finalHandPos.y - surfaceY
                
                if currentHeight < minHeight {
                    finalHandPos.y = surfaceY + minHeight
                }
            }
            
            self.handDebugMarker?.setPosition(finalHandPos, relativeTo: nil)
            self.handDebugMarker?.isEnabled = true
            
            let now = Date().timeIntervalSince1970
            var velocity = SIMD3<Float>(0, 0, 0)
            
            if let last = handPositionHistory.last {
                let dt = Float(now - last.time)
                if dt > 0.001 && dt < 0.5 {
                    let v = (finalHandPos - last.pos) / dt
                    
                    if length(v) < 3.0 {
                        velocity = v
                        self.recentVelocities.append(v)
                        if self.recentVelocities.count > 8 {
                            self.recentVelocities.removeFirst()
                        }
                    }
                }
            }
            
            handPositionHistory.append((now, finalHandPos))
            if handPositionHistory.count > 6 {
                handPositionHistory.removeFirst()
            }
            
            let effectiveState = (rawHandState == "UNKNOWN") ? lastHandState : rawHandState
            
            if effectiveState == lastHandState {
                stateStableCount += 1
            } else {
                stateStableCount = 0
                lastHandState = effectiveState
            }
            
            let posStr = String(format: "(%.2f, %.2f, %.2f)", finalHandPos.x, finalHandPos.y, finalHandPos.z)
            let info = String(format: "D:%.2f C:%.2f\nPos:%@", estimatedDepth, conf, posStr)
            
            let requiredStable = (effectiveState == "FIST") ? 6 : 2
            
            if stateStableCount >= requiredStable {
                if effectiveState == "FIST" && self.viewModel.isInputEnabled {
                    if self.viewModel.gameState == .searching ||
                        self.viewModel.gameState == .throwing ||
                        self.viewModel.gameState == .result {
                        self.updateState(.holding, info: info)
                        self.stabilityFrameCount = 0
                    } else {
                        self.updateState(.holding, info: info)
                    }
                    holdCubesInHand(handPos: finalHandPos)
                } else if effectiveState == "OPEN" {
                    if self.viewModel.gameState == .holding {
                        self.updateState(.throwing, info: info)
                        self.stabilityFrameCount = 0
                        self.throwFrameCount = 0
                        throwCubes(handPos: finalHandPos, lastVelocity: velocity)
                    } else {
                        if self.viewModel.gameState != .throwing &&
                            self.viewModel.gameState != .result {
                            self.updateState(.searching, info: info)
                        }
                    }
                }
            } else {
                if self.viewModel.gameState == .holding && self.viewModel.isInputEnabled {
                    holdCubesInHand(handPos: finalHandPos)
                    self.updateState(.holding, info: info)
                } else {
                    if self.viewModel.gameState != .result {
                        self.updateState(self.viewModel.gameState, info: info)
                    }
                }
            }
        }
        
        private var throwFrameCount = 0
        
        private func checkDiceState() {
            throwFrameCount += 1
            
            var allStopped = true
            for cube in shagaiCubes {
                let pos = cube.position(relativeTo: nil)
                if pos.y < -1.0 {
                    let rescueY = self.fallbackFloor?.position.y ?? -0.3
                    cube.physicsBody?.mode = .kinematic
                    cube.setPosition([
                        Float.random(in: -0.05...0.05),
                        rescueY + 0.15,
                        Float.random(in: -0.05...0.05)
                    ], relativeTo: nil)
                    cube.physicsBody?.mode = .dynamic
                    cube.components[PhysicsMotionComponent.self] = PhysicsMotionComponent(
                        linearVelocity: [0, -0.3, 0],
                        angularVelocity: .random(in: -1...1)
                    )
                    allStopped = false
                    continue
                }
                
                if let motion = cube.components[PhysicsMotionComponent.self] {
                    if length(motion.linearVelocity) > 0.01 ||
                        length(motion.angularVelocity) > 0.1 {
                        allStopped = false
                    }
                }
            }
            
            if allStopped {
                stabilityFrameCount += 1
            } else {
                stabilityFrameCount = 0
            }
            
            if stabilityFrameCount > 10 || throwFrameCount > 300 {
                throwFrameCount = 0
                determineResults()
            }
        }
        
        private func determineResults() {
            var horse = 0
            var camel = 0
            var sheep = 0
            var goat = 0
            
            for cube in shagaiCubes {
                let cubePos = cube.position(relativeTo: nil)
                if cubePos.y < -1.0 { continue }
                
                let rotation = cube.orientation(relativeTo: nil)
                let localY = rotation.act([0, 1, 0])
                let localZ = rotation.act([0, 0, 1])
                let worldUp = SIMD3<Float>(0, 1, 0)
                let dotY = dot(localY, worldUp)
                let dotZ = dot(localZ, worldUp)
                
                if dotY > 0.7 { horse += 1 }
                else if dotY < -0.7 { camel += 1 }
                else if dotZ > 0.7 { sheep += 1 }
                else if dotZ < -0.7 { goat += 1 }
            }
            
            let result = ThrowResult(horse: horse, camel: camel, sheep: sheep, goat: goat)
            let resultText = "H:\(horse) C:\(camel) S:\(sheep) G:\(goat)"
            DispatchQueue.main.async {
                self.viewModel.gameState = .result
                self.viewModel.debugText = "🎉 RESULT:\n\(resultText)"
                self.viewModel.lastThrowResult = result
            }
        }
        
        private func holdCubesInHand(handPos: SIMD3<Float>) {
            for cube in shagaiCubes {
                cube.physicsBody?.mode = .kinematic
                cube.setPosition([0, -10, 0], relativeTo: nil)
            }
        }
        
        private func throwCubes(handPos: SIMD3<Float>, lastVelocity: SIMD3<Float>) {
            self.viewModel.isInputEnabled = false
            
            let launchPos = handPos
            
            var throwVel = lastVelocity
            if !recentVelocities.isEmpty {
                if let maxV = recentVelocities.max(by: {
                    length_squared($0) < length_squared($1)
                }) {
                    if length(maxV) > length(lastVelocity) {
                        throwVel = maxV
                    }
                }
            }
            
            let velY = throwVel.y
            let velXZ = SIMD3<Float>(throwVel.x, 0, throwVel.z)
            
            var finalY = velY
            if finalY < 0 { finalY *= 1.5 }
            else { finalY *= 0.5 }
            
            if finalY > -0.3 { finalY -= 1.0 }
            
            finalY = max(finalY, -3.0)
            
            var finalXZ = velXZ * 0.2
            if length(finalXZ) > 0.15 {
                finalXZ = normalize(finalXZ) * 0.15
            }
            
            throwVel = finalXZ
            throwVel.y = finalY
            
            for (i, cube) in shagaiCubes.enumerated() {
                let row = Float(i / 2)
                let col = Float(i % 2)
                let jitter = SIMD3<Float>.random(in: -0.001...0.001)
                let offset = SIMD3<Float>(
                    (col - 0.5) * 0.005,
                    0.0,
                    (row - 0.5) * 0.005
                ) + jitter
                
                cube.setPosition(launchPos + offset, relativeTo: nil)
                
                let randomRotation: simd_quatf
                let angularVel: SIMD3<Float>
                
                if self.viewModel.isStoryMode && i < 2 {
                    randomRotation = simd_quatf(
                        angle: Float.random(in: 0...2 * .pi),
                        axis: [0, 1, 0]
                    )
                    angularVel = SIMD3<Float>.random(in: -0.3...0.3)
                } else {
                    randomRotation = simd_quatf(
                        angle: Float.random(in: 0...2 * .pi),
                        axis: normalize(SIMD3<Float>.random(in: -1...1))
                    )
                    angularVel = SIMD3<Float>.random(in: -1.5...1.5)
                }
                
                cube.setOrientation(randomRotation, relativeTo: nil)
                
                cube.physicsBody?.mode = .dynamic
                
                let randomV = SIMD3<Float>.random(in: -0.003...0.003)
                
                cube.components[PhysicsMotionComponent.self] = PhysicsMotionComponent(
                    linearVelocity: throwVel + randomV,
                    angularVelocity: angularVel
                )
            }
            
            recentVelocities.removeAll()
        }
        
        private func getNearestSurfaceBelow(handPos: SIMD3<Float>) -> Float? {
            guard !planeAnchors.isEmpty else { return nil }
            
            var nearestY: Float?
            var minDistance: Float = Float.infinity
            
            for anchor in planeAnchors.values {
                let planeY = anchor.position(relativeTo: nil).y
                
                if planeY < handPos.y {
                    let distance = handPos.y - planeY
                    if distance < minDistance {
                        minDistance = distance
                        nearestY = planeY
                    }
                }
            }
            
            return nearestY
        }
        
        private func updateState(_ state: GameState, info: String = "") {
            DispatchQueue.main.async {
                self.viewModel.gameState = state
                self.viewModel.debugText = "\(state.rawValue)\n\(info)"
            }
        }
    }
}

struct ShagaiCameraEngineView: View {
    @StateObject private var viewModel = ARGameViewModel()
    
    var body: some View {
        ZStack {
            ARGameView(viewModel: viewModel)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Spacer()
                HStack {
                    VStack(alignment: .leading) {
                        Text(viewModel.debugText)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(colorForState(viewModel.gameState))
                            .shadow(radius: 2)
                            .multilineTextAlignment(.leading)
                    }
                    Spacer()
                }
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(16)
                .padding()
            }
        }
    }
    
    func colorForState(_ state: GameState) -> Color {
        switch state {
        case .searching: return .yellow
        case .holding: return .red
        case .throwing: return .green
        case .result: return .blue
        }
    }
}

struct ARThrowOverlay: View {
    @StateObject private var arViewModel = ARGameViewModel()
    @Binding var isPresented: Bool
    var isStoryMode: Bool = false
    var onResult: (ThrowResult) -> Void
    
    @State private var resultReceived = false
    @State private var resultText = ""
    
    var body: some View {
        ZStack {
            ARGameView(viewModel: arViewModel)
                .ignoresSafeArea()
            
            VStack {
                if resultReceived {
                    HStack {
                        Spacer()
                        Button { isPresented = false } label: {
                            ZStack {
                                Circle()
                                    .fill(.ultraThinMaterial)
                                    .frame(width: 44, height: 44)
                                Image(systemName: "xmark")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    .padding()
                }
                
                Spacer()
                
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(statusLabel)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(statusColor)
                            .shadow(color: .black, radius: 2)
                        
                        if !resultText.isEmpty {
                            Text(resultText)
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                                .shadow(color: .black, radius: 2)
                        }
                    }
                    Spacer()
                }
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(16)
                .padding()
            }
        }
        .onAppear {
            arViewModel.isStoryMode = isStoryMode
        }
        .onChange(of: arViewModel.lastThrowResult) { _, result in
            guard let result = result, !resultReceived else { return }
            resultReceived = true
            resultText = "Horse: \(result.horse)  Camel: \(result.camel)  Sheep: \(result.sheep)  Goat: \(result.goat)"
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                onResult(result)
                isPresented = false
            }
        }
    }
    
    private var statusLabel: String {
        switch arViewModel.gameState {
        case .searching: return "Show your hand..."
        case .holding: return "Holding — open to throw!"
        case .throwing: return "Thrown! Waiting..."
        case .result: return "Result!"
        }
    }
    
    private var statusColor: Color {
        switch arViewModel.gameState {
        case .searching: return .yellow
        case .holding: return .orange
        case .throwing: return .green
        case .result: return .cyan
        }
    }
}
