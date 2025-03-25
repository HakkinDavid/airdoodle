import SwiftUI
import ARKit

struct ARDoodleView: UIViewRepresentable {
    func makeUIView(context: Context) -> ARSCNView {
        let arView = ARSCNView()
        arView.delegate = context.coordinator
        arView.scene = SCNScene()
        
        let config = ARWorldTrackingConfiguration()
        arView.session.run(config)
        
        let panGesture = UIPanGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handlePan(_:)))
        arView.addGestureRecognizer(panGesture)

        NotificationCenter.default.addObserver(context.coordinator, selector: #selector(Coordinator.clearCanvas), name: NSNotification.Name("ClearCanvas"), object: nil)
        
        return arView
    }

    func updateUIView(_ uiView: ARSCNView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator: NSObject, ARSCNViewDelegate {
        var nodes: [SCNNode] = []
        var currentLine: SCNNode?
        var currentLinePositions: [SCNVector3] = []

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
            
            if gesture.state == .began {
                startNewLine(at: position, in: sceneView)
            } else if gesture.state == .changed {
                addPointToCurrentLine(position, in: sceneView)
            }
        }

        private func startNewLine(at position: SCNVector3, in sceneView: ARSCNView) {
            currentLinePositions = [position]
            let lineNode = createLineNode(from: position, to: position)
            sceneView.scene.rootNode.addChildNode(lineNode)
            nodes.append(lineNode)
            currentLine = lineNode
        }

        private func addPointToCurrentLine(_ position: SCNVector3, in sceneView: ARSCNView) {
            guard let currentLine = currentLine else { return }
            currentLinePositions.append(position)
            let newLineNode = createLineNode(from: currentLinePositions[currentLinePositions.count - 2], to: position)
            sceneView.scene.rootNode.addChildNode(newLineNode)
            nodes.append(newLineNode)
        }

        private func createLineNode(from start: SCNVector3, to end: SCNVector3) -> SCNNode {
            let line = SCNGeometry.line(from: start, to: end)
            let node = SCNNode(geometry: line)
            node.geometry?.firstMaterial?.diffuse.contents = UIColor.systemBlue
            return node
        }

        @objc func clearCanvas() {
            for node in nodes {
                node.removeFromParentNode()
            }
            nodes.removeAll()
        }
    }
}

extension SCNGeometry {
    static func line(from vector1: SCNVector3, to vector2: SCNVector3) -> SCNGeometry {
        let vertices: [SCNVector3] = [vector1, vector2]
        let source = SCNGeometrySource(vertices: vertices)
        let indices: [Int32] = [0, 1]
        let element = SCNGeometryElement(indices: indices, primitiveType: .line)
        return SCNGeometry(sources: [source], elements: [element])
    }
}
