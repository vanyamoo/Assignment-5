//
//  EmojiArtJuly24App.swift
//  EmojiArtJuly24
//
//  Created by Vanya Mutafchieva on 04/07/2024.
//

import SwiftUI

@main
struct EmojiArtJuly24App: App {
    @StateObject var defaultDocument = EmojiArtDocument()
    @StateObject var paletteStore = PaletteStore(named: "Main")
    
    var body: some Scene {
        WindowGroup {
            EmojiArtDocumentView(document: defaultDocument)
                .environmentObject(paletteStore)
        }
    }
}
