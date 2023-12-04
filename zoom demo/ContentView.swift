import SwiftUI

struct ContentView: View {
    @State private var scale: CGFloat = 1.0
    @State var angle: CGFloat = 0.0
    @StateObject private var imageStore = ImageStore()
    @State private var showSavedImage = false
    @State private var scrollView: UIScrollView?
    
    var body: some View {
        VStack(alignment: .center) {
            Spacer()
          ZoomableScrollView(scale: $scale, angle: $angle, scrollView: $scrollView, content: {
                Group {
                    Image("template")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                        .rotationEffect(Angle(degrees: angle))
                }
            })
            .frame(width: 300, height: 300)
            .border(Color.black)
//            .gesture(TapGesture(count: 2).onEnded {
//                scale = scale < maxAllowedScale / 2 ? maxAllowedScale : 1.0
//            })
            Spacer()
            Text("Change the scale")
            Slider(value: $scale, in: 1...maxAllowedScale + 0.5)
                .padding(.horizontal)
            Spacer()
            Button("Submit") {
              if let scrollView = self.scrollView {
                  imageStore.saveImage(from: scrollView)
                  showSavedImage = true
              }
              
            }
            .sheet(isPresented: $showSavedImage) {
                if let savedImage = imageStore.savedImage {
                    ImageViewer(savedImage: savedImage)
                } else {
                    Text("No image saved")
                }
            }
        }.background(Color.gray)
    }
}

struct ImageViewer: View {
    var savedImage: UIImage
    
    var body: some View {
        Image(uiImage: savedImage)
            .resizable()
            .scaledToFit()
    }
}
