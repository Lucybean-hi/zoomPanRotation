import SwiftUI
import UIKit

let maxAllowedScale = 4.0

struct ZoomableScrollView<Content: View>: UIViewRepresentable {
    @Binding var scale: CGFloat
    @Binding var angle: CGFloat
    let content: Content
    @Binding var scrollView: UIScrollView?

    init(scale: Binding<CGFloat>, angle: Binding<CGFloat>, scrollView: Binding<UIScrollView?>, @ViewBuilder content: () -> Content) {
        self._scale = scale
        self._angle = angle
        self._scrollView = scrollView
        self.content = content()
    }

    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.delegate = context.coordinator
        scrollView.maximumZoomScale = maxAllowedScale
        scrollView.minimumZoomScale = 1
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.bouncesZoom = true

        let rotationGesture = UIRotationGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleRotation(_:)))
                scrollView.addGestureRecognizer(rotationGesture)
      
        let hostedView = UIHostingController(rootView: content).view
        hostedView?.translatesAutoresizingMaskIntoConstraints = true
        hostedView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        hostedView?.frame = scrollView.bounds
        scrollView.addSubview(hostedView ?? UIView())

//        context.coordinator.hostingController = UIHostingController(rootView: content)
        context.coordinator.imageView = hostedView?.subviews.first(where: { $0 is UIImageView }) as? UIImageView
        DispatchQueue.main.async {
            self.scrollView = scrollView
        }
        return scrollView
    }

    func updateUIView(_ uiView: UIScrollView, context: Context) {
      if uiView.zoomScale != scale {
          uiView.zoomScale = scale
      }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIScrollViewDelegate {
        var parent: ZoomableScrollView
        var hostingController: UIHostingController<Content>?
        weak var imageView: UIImageView?

        init(_ parent: ZoomableScrollView) {
            self.parent = parent
        }

//        func viewForZooming(in scrollView: UIScrollView) -> UIView? {
//            return hostingController?.view
//        }
        func viewForZooming(in scrollView: UIScrollView) -> UIView? {
            return scrollView.subviews.first
        }
        func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
            parent.scale = scale
        }
        @objc func handleRotation(_ gesture: UIRotationGestureRecognizer) {
            guard let imageView = self.imageView else { return }

            // 将旋转手势的变化应用到 imageView 上
            let rotation = gesture.rotation
            imageView.transform = imageView.transform.rotated(by: rotation)
            gesture.rotation = 0

            if gesture.state == .ended {
                // 更新 angle 状态以反映旋转的总角度
                let totalRotation = atan2(imageView.transform.b, imageView.transform.a)
                parent.angle = Double(totalRotation) * (180 / .pi)
            }
        }

    }
}
