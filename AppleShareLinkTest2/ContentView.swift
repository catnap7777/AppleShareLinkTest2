//
//  ContentView.swift
//  AppleShareLinkTest2
//
//  Created by Karen Mathes on 11/3/23.
//

import SwiftUI
import PDFKit

struct ContentView: View {
    @State private var model = Model()
    @State var pdfDisplayToggle = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 45) {
                Button {
                    model.buildPDF()
                    pdfDisplayToggle.toggle()
                } label: {
                    Label("View PDF", systemImage: "star")
                }
                .sheet(isPresented: $pdfDisplayToggle) {
                    PDFKitView(url: model.url)
                }
                
                //.. doesn't work correctly - share sheet "Markup" and "Print" buttons do NOT work
                ShareLink("Share? (not working correctly)", item: model.url, subject: Text("subject"), message: Text("message"), preview: SharePreview(Text("My Preview"), image: Image("myImage")))
                    .foregroundColor(.red)
                    
                //.. works correctly but no preview - "Markup" and "Print" buttons work as expected
                ShareLink("Share? (working/no preview)", item: model.url, subject: Text("subject"), message: Text("message"))
                    .foregroundColor(.green)
            }
            .onAppear{
                model.buildPDF()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
