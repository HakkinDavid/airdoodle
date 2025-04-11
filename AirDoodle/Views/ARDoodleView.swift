import SwiftUI
import CoreData
import ARKit

struct ARDoodleView: UIViewRepresentable {
    @Binding var selectedTool: DrawingTool
    @Binding var lineWidth: CGFloat
    @Binding var selectedColor: UIColor
    @Binding var coordinator: Coordinator
    @Binding var arView: ARSCNView
    @Binding var sceneName: String
    
    func makeUIView(context: Context) -> ARSCNView {
        arView.delegate = context.coordinator
        arView.scene = SCNScene()
        
        let config = ARWorldTrackingConfiguration()
        arView.session.run(config)
        
        let panGesture = UIPanGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handlePan(_:)))
        arView.addGestureRecognizer(panGesture)
        
        NotificationCenter.default.addObserver(context.coordinator, selector: #selector(Coordinator.clearCanvas), name: NSNotification.Name("ClearCanvas"), object: nil)
        
        NotificationCenter.default.addObserver(
            context.coordinator,
            selector: #selector(Coordinator.screenshotCanvas),
            name: NSNotification.Name("ScreenshotCanvas"),
            object: arView
        )
        
        NotificationCenter.default.addObserver(
            context.coordinator,
            selector: #selector(Coordinator.loadScene),
            name: NSNotification.Name("LoadScene"),
            object: (sceneName, arView)
        )


        
        return arView
    }

    func updateUIView(_ uiView: ARSCNView, context: Context) {
        context.coordinator.selectedTool = selectedTool
        context.coordinator.lineWidth = lineWidth
        context.coordinator.selectedColor = selectedColor
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator: NSObject, ARSCNViewDelegate {
        var nodes: [SCNNode] = []
        var currentLine: SCNNode?
        var currentLinePositions: [SCNVector3] = []
        var selectedTool: DrawingTool = .pencil
        var lineWidth: CGFloat = 2.0
        var selectedColor: UIColor = .blue

        @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
            guard let sceneView = gesture.view as? ARSCNView else { return }
            let touchLocation = gesture.location(in: sceneView)
            
            let results = sceneView.hitTest(touchLocation, types: [.featurePoint, .estimatedHorizontalPlane])
            guard let result = results.first else { return }
            
            let position = SCNVector3(
                result.worldTransform.columns.3.x,
                result.worldTransform.columns.3.y,
                result.worldTransform.columns.3.z
            )
            
            switch selectedTool {
            case .pencil:
                if gesture.state == .began {
                    startNewLine(at: position, in: sceneView)
                } else if gesture.state == .changed {
                    addPointToCurrentLine(position, in: sceneView)
                }
            case .eraser:
                eraseAt(position, in: sceneView)
            case .circle:
                if gesture.state == .ended {
                    drawCircle(at: position, in: sceneView)
                }
            case .line:
                if gesture.state == .ended {
                    drawStraightLine(to: position, in: sceneView)
                }
            }
        }

        private func startNewLine(at position: SCNVector3, in sceneView: ARSCNView) {
            currentLinePositions = [position]
        }

        private func addPointToCurrentLine(_ position: SCNVector3, in sceneView: ARSCNView) {
            guard !currentLinePositions.isEmpty else { return }
            currentLinePositions.append(position)
            let newLineNode = createLineNode(from: currentLinePositions[currentLinePositions.count - 2], to: position, in: sceneView)
            sceneView.scene.rootNode.addChildNode(newLineNode)
            nodes.append(newLineNode)
        }

        private func createLineNode(from start: SCNVector3, to end: SCNVector3, in sceneView: ARSCNView) -> SCNNode {
    let distance = start.distance(to: end)
    let cylinder = SCNCylinder(radius: lineWidth / 200.0, height: CGFloat(distance))
    cylinder.firstMaterial?.diffuse.contents = selectedColor
    
    let node = SCNNode(geometry: cylinder)
    node.position = SCNVector3(
        (start.x + end.x) / 2,
        (start.y + end.y) / 2,
        (start.z + end.z) / 2
    )
    
            node.look(at: end, up: sceneView.scene.rootNode.worldUp, localFront: node.worldFront)
    
    return node
}

        private func eraseAt(_ position: SCNVector3, in sceneView: ARSCNView) {
            for node in nodes {
                if node.position.distance(to: position) < 0.02 {
                    node.removeFromParentNode()
                    nodes.removeAll { $0 == node }
                    break
                }
            }
        }

        private func drawCircle(at position: SCNVector3, in sceneView: ARSCNView) {
            let circle = SCNGeometry.circle(at: position, radius: 0.05)
            let node = SCNNode(geometry: circle)
            node.geometry?.firstMaterial?.diffuse.contents = selectedColor
            sceneView.scene.rootNode.addChildNode(node)
            nodes.append(node)
        }

        private func drawStraightLine(to position: SCNVector3, in sceneView: ARSCNView) {
            guard let firstPosition = currentLinePositions.first else { return }
            let lineNode = createLineNode(from: firstPosition, to: position, in: sceneView)
            sceneView.scene.rootNode.addChildNode(lineNode)
            nodes.append(lineNode)
        }
        
        @objc func saveScene(named name: String, in sceneView: ARSCNView) {
            nodes.forEach { sceneView.scene.rootNode.addChildNode($0.clone()) }

            let url = FileManager.default
                .urls(for: .documentDirectory, in: .userDomainMask)[0]
                .appendingPathComponent("\(name).scn")

            sceneView.scene.write(to: url, options: nil, delegate: nil)

            
            let context = PersistenceController.shared.container.viewContext
            let fetchRequest: NSFetchRequest<Doodle> = Doodle.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "name == %@", name)

            let doodle: Doodle
            if let existing = try? context.fetch(fetchRequest).first {
                doodle = existing
                doodle.date = Date()
                print("Actualizando entrada existente para \(name) con UUID \(String(describing: doodle.id))")
            } else {
                doodle = Doodle(context: context)
                doodle.id = UUID()
                doodle.name = name
                doodle.date = Date()
                print("Creando nueva entrada para \(name) con UUID \(String(describing: doodle.id))")
            }

            
            do {
                try context.save()
                print("Escena guardada como \(name).scn (\(url.path), \(doodle.id ?? UUID()))")
            } catch {
                print("Error al guardar la escena en Core Data: \(error.localizedDescription)")
            }
        }
        
        @objc func loadScene(from name: String, in sceneView: ARSCNView) {
            print("Intentando cargar escena...")
            let url = FileManager.default
                .urls(for: .documentDirectory, in: .userDomainMask)[0]
                .appendingPathComponent("\(name).scn")
            if let scene = try? SCNScene(url: url, options: nil) {
                sceneView.scene.rootNode.childNodes.forEach { $0.removeFromParentNode() }
                scene.rootNode.childNodes.forEach { sceneView.scene.rootNode.addChildNode($0) }
                print("Se ha cargado la escena \(name).scn")
            }
            else {
                print("No se encontró la escena \(name).scn")
            }
        }



        @objc func clearCanvas() {
            for node in nodes {
                node.removeFromParentNode()
            }
            nodes.removeAll()
        }
        
        @objc func screenshotCanvas(in sceneView: ARSCNView) {
            let screenshot = sceneView.snapshot()
            UIImageWriteToSavedPhotosAlbum(screenshot, nil , nil , nil)
        }
    }
}

enum DrawingTool {
    case pencil, eraser, line, circle
}

extension SCNGeometry {
    static func line(from vector1: SCNVector3, to vector2: SCNVector3, width: CGFloat) -> SCNGeometry {
        let vertices: [SCNVector3] = [vector1, vector2]
        let source = SCNGeometrySource(vertices: vertices)
        let indices: [Int32] = [0, 1]
        let element = SCNGeometryElement(indices: indices, primitiveType: .line)
        return SCNGeometry(sources: [source], elements: [element])
    }
    
    static func circle(at center: SCNVector3, radius: CGFloat) -> SCNGeometry {
        let path = UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: radius * 2, height: radius * 2))
        let shape = SCNShape(path: path, extrusionDepth: 0.01)
        return shape
    }
}

extension SCNVector3 {
    func distance(to vector: SCNVector3) -> Float {
        return sqrt(pow(vector.x - x, 2) + pow(vector.y - y, 2) + pow(vector.z - z, 2))
    }
}
