
import Foundation
import UIKit

class ImageStore: ObservableObject {
    @Published var savedImage: UIImage?

    func saveImage(from scrollView: UIScrollView) {
        // Calculate the zoomed rect
        let zoomedRect = CGRect(x: scrollView.contentOffset.x,
                                y: scrollView.contentOffset.y,
                                width: scrollView.frame.size.width,
                                height: scrollView.frame.size.height)

        // Make sure on the main thread when dealing with the UI
        DispatchQueue.main.async {
            // Create a context of the desired size to render the zoomed rect
            let renderer = UIGraphicsImageRenderer(size: zoomedRect.size)
            self.savedImage = renderer.image { ctx in
                ctx.cgContext.translateBy(x: -zoomedRect.origin.x, y: -zoomedRect.origin.y)
                scrollView.drawHierarchy(in: scrollView.bounds, afterScreenUpdates: true)
            }
        }
    }
}
