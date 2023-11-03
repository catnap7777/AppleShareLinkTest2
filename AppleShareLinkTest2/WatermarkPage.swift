//
//  WatermarkPage.swift
//  AppleShareLinkTest2
//
//  Created by Karen Mathes on 11/3/23.
//

import SwiftUI
import PDFKit

class Model: ObservableObject {
    
    var url: URL = URL.documentsDirectory
    
    var document: PDFDocument?
    var myData: Data?
    
    init() {
        if let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let myAppDirectoryURL = documentsURL.appending(path: "myPDFs")
            
            do {
                try FileManager.default.createDirectory(at: myAppDirectoryURL, withIntermediateDirectories: true, attributes: nil)
                let fileURL = myAppDirectoryURL.appending(path: "kamTest1.pdf")
                url = fileURL
            } catch let error as NSError {
                print("Could not create subdirectory. \(error), \(error.userInfo)")
            }
        }
    }
    
    func buildPDF() {
        let creator = PdfCreator()
        let pdfData = creator.pdfData(title: "This is a title-1111", body: "This is a body-1111")
        clearPDFDir()
        document = PDFDocument(data: pdfData ?? Data())
        document?.write(to: url)
        myData = pdfData
    }
    
    //.. to remove random folders that appear to be generated when Markup is used
    func clearPDFDir() {
        var removed: Int = 0
        
        if let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            
            let myAppDirectoryURL = documentsURL.appending(path: "myPDFs")
            do {
                let docFiles = try FileManager.default.contentsOfDirectory(at: myAppDirectoryURL, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
                print("\(docFiles.count) doc files found")
                for url in docFiles {
                    removed += 1
                    try FileManager.default.removeItem(at: url)
                }
                print("\(removed) doc files removed")
            } catch {
                print(error)
                print("\(removed) doc files removed")
            }
        }
    }
    
    
}

struct PDFKitView: UIViewRepresentable {
    let url: URL
    
    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.document = PDFDocument(url: self.url)
        return pdfView
    }
    
    func updateUIView(_ uiView: PDFView, context: UIViewRepresentableContext<PDFKitView>) {
    }
}

class PdfCreator : NSObject {
    private var pageRect : CGRect
    private var renderer : UIGraphicsPDFRenderer?
    
    /**
     W: 8.5 inches * 72 DPI = 612 points
     H: 11 inches * 72 DPI = 792 points
     A4 = [W x H] 595 x 842 points
     */
    init(pageRect : CGRect =
         CGRect(x: 0, y: 0, width: (8.5 * 72.0), height: (11 * 72.0))) {
        
        let format = UIGraphicsPDFRendererFormat()
        let metaData = [kCGPDFContextTitle: "It's a PDF!"]
        
        format.documentInfo = metaData as [String: Any]
        self.pageRect = pageRect
        self.renderer = UIGraphicsPDFRenderer(bounds: self.pageRect,
                                              format: format)
        
        super.init()
    }
}

extension PdfCreator {
    private func addTitle ( title  : String ){
        let textRect = CGRect(x: 20, y: 20,
                              width: pageRect.width - 40 ,height: 40)
        title.draw(in: textRect,
                   withAttributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 30)])
    }
    
    private func addBody (body : String) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .justified
        
        let attributes = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20),
            NSAttributedString.Key.paragraphStyle: paragraphStyle,
            NSAttributedString.Key.foregroundColor : UIColor.gray
        ]
        
        let bodyRect = CGRect(x: 20, y: 70,
                              width: pageRect.width - 40 ,height: pageRect.height - 80)
        body.draw(in: bodyRect, withAttributes: attributes)
    }
}

extension PdfCreator {
    func pdfData( title : String, body: String ) -> Data? {
        if let renderer = self.renderer {
 
            let data = renderer.pdfData  { ctx in
                ctx.beginPage()
                addTitle(title: title)
                addBody(body: body)
            }
            return data
        }
        return nil
    }
 
}

