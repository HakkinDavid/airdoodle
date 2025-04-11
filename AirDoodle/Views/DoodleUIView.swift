import SwiftUI
import ARKit

struct DoodleUIView: View {
    @State private var selectedTool: DrawingTool = .pencil
    @State private var lineWidth: CGFloat = 2.0
    @State private var selectedColor: Color = .blue
    @State private var coordinator = ARDoodleView.Coordinator()
    @State private var arView = ARSCNView()
    @State private var sceneName = "art_scene_" + String(Date().timeIntervalSince1970)
    @State private var hideUI: Bool = false
    @State var loadingDoodleName: String? = nil
    
    private var selectedUIColor: UIColor {
        UIColor(selectedColor)
    }
    
    var body: some View {
        ZStack {
            ARDoodleView(selectedTool: $selectedTool, lineWidth: $lineWidth, selectedColor: .constant(selectedUIColor), coordinator: $coordinator, arView: $arView, sceneName: $sceneName)
                .onAppear {
                    if loadingDoodleName != nil {
                        $coordinator.wrappedValue.loadScene(from: loadingDoodleName!, in: $arView.wrappedValue)
                        sceneName = loadingDoodleName!
                    }
                }
                .edgesIgnoringSafeArea(.all)
            
            if !hideUI {
                VStack {
                    HStack {
                        TextField("Nombre de la escena", text: $sceneName)
                            .foregroundColor(.white)
                            .padding(10)
                            .frame(maxWidth: 300)
                            .background(Color.gray.opacity(0.5))
                            .cornerRadius(10)
                            .padding(.leading, 20)
                        
                        Spacer(minLength: 150)
                        Picker("Herramienta", selection: $selectedTool) {
                            Text("Lápiz").tag(DrawingTool.pencil)
                            Text("Borrador").tag(DrawingTool.eraser)
                            Text("Línea").tag(DrawingTool.line)
                            Text("Círculo").tag(DrawingTool.circle)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.trailing, 20)
                    }
                    .padding(.top, 90)
                    .padding(.bottom, 10)
                    
                    VStack(alignment: .trailing){
                        HStack {
                            Text("Grosor")
                                .foregroundColor(.white)
                                .shadow(radius: 3)
                                .padding(.leading, 20)
                            
                            Slider(value: $lineWidth, in: 1...10, step: 0.5)
                                .padding(.horizontal, 20)
                            
                            ColorPicker("Color", selection: $selectedColor)
                                .frame(maxWidth: 90)
                                .shadow(radius: 3)
                                .padding(.trailing, 20)
                        }
                    }
                    
                    Spacer()
                    
                    HStack {
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
                                .background(Color.purple)
                                .foregroundColor(.white)
                                .clipShape(Capsule())
                        }
                        .padding()
                    }
                    .padding(20)
                }
                .background(Color.white.opacity(0.0))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea(.all)
            }
        }
        .navigationBarItems(trailing: Button(action: {
            hideUI.toggle()
        }) {
            Text("Ocultar UI")
        })
    }
}
