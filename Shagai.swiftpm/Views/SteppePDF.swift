import SwiftUI
import PDFKit

struct SteppePDF: View {
    let pdfName: String
    var alignment: Alignment = .bottom
    @State private var image: UIImage?

    var body: some View {
        GeometryReader { geometry in
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: geometry.size.height, alignment: alignment)
                    .clipped()
            } else {
                Color.black
            }
        }
        .ignoresSafeArea()
        .onAppear { image = renderPage() }
    }

    private func renderPage() -> UIImage? {
        guard let url = Bundle.main.url(forResource: pdfName, withExtension: "pdf"),
              let doc = PDFDocument(url: url),
              let page = doc.page(at: 0) else { return nil }

        let rect = page.bounds(for: .cropBox)
        let fmt = UIGraphicsImageRendererFormat()
        fmt.scale = UIScreen.main.scale
        let renderer = UIGraphicsImageRenderer(size: rect.size, format: fmt)
        return renderer.image { ctx in
            ctx.cgContext.translateBy(x: 0, y: rect.height)
            ctx.cgContext.scaleBy(x: 1, y: -1)
            page.draw(with: .cropBox, to: ctx.cgContext)
        }
    }
}
