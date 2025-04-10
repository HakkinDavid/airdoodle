import SwiftUI
import ARKit

struct DoodleUIView: View {
    @State private var selectedTool: DrawingTool = .pencil
    @State private var lineWidth: CGFloat = 2.0
    @State private var selectedColor: Color = .blue
    @State private var coordinator = ARDoodleView.Coordinator()
    @State private var arView = ARSCNView()
    @State private var sceneName = "art_scene_" + String(Date().timeIntervalSince1970)
    
    private var selectedUIColor: UIColor {
        UIColor(selectedColor)
    }
    
    var body: some View {
        ZStack {
            ARDoodleView(selectedTool: $selectedTool, lineWidth: $lineWidth, selectedColor: .constant(selectedUIColor), coordinator: $coordinator, arView: $arView, sceneName: $sceneName)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                HStack {
                    TextField("Nombre de la escena", text: $sceneName)
                    Picker("Herramienta", selection: $selectedTool) {
                        Text("Lápiz").tag(DrawingTool.pencil)
                        Text("Borrador").tag(DrawingTool.eraser)
                        Text("Línea").tag(DrawingTool.line)
                        Text("Círculo").tag(DrawingTool.circle)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()
                }
                
                Slider(value: $lineWidth, in: 1...10, step: 0.5) {
                    Text("Grosor")
                }
                .padding()
                
                ColorPicker("Color", selection: $selectedColor)
                    .padding()
                
                Button(action: {
                    NotificationCenter.default.post(name: NSNotification.Name("ClearCanvas"), object: nil)
                }) {
                    Text("Borrar Dibujo")
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                }
                .padding()
                
                Button(action: {
                    $coordinator.wrappedValue.screenshotCanvas(in: $arView.wrappedValue)
                }) {
                    Text("Tomar Foto")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                }
                .padding()
                
                Button(action: {
                    $coordinator.wrappedValue.saveScene(named: $sceneName.wrappedValue, in: $arView.wrappedValue)
                }) {
                    Text("Guardar escena")
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                }
                .padding()
                
                Button(action: {
                    $coordinator.wrappedValue.loadScene(from: $sceneName.wrappedValue, in: $arView.wrappedValue)
                }) {
                    Text("Cargar escena")
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                }
                .padding()
            }
            .background(Color.white.opacity(0.0))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea(.all)
        }
    }
}
