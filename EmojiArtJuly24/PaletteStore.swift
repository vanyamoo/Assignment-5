//
//  PaletteStore.swift
//  EmojiArtJuly24
//
//  Created by Vanya Mutafchieva on 08/07/2024.
//

import SwiftUI

class PaletteStore: ObservableObject {
    let name: String
    @Published var palettes: [Palette] { // note this is not private
        didSet {
            if palettes.isEmpty, !oldValue.isEmpty {  // this prevents the user from deleting the last palette
                palettes = oldValue // setting your own var's value in its didSet – you want to be careful! It's easy to make an infinite loop here (we won't have infinite loop because we checked to make sure our oldvalue was not empty)
            }
        }
    }
    init(named name: String) {
        self.name = name
        palettes = Palette.builtins
        if palettes.isEmpty {
            palettes = [Palette(name: "Warning", emojis: "⚠️")]
        }
    }
    
    // the index of the palette we are currently showing (this will be very helpful to the View because we'll make sure it's never out of bounds)
    @Published private var _cursorIndex = 0
    
    var cursorIndex: Int {
        get { boundsCheckedPaletteIndex(_cursorIndex) }
        set {  _cursorIndex = boundsCheckedPaletteIndex(newValue)} // we could have aslo just said _cursorIndex = newValue (that's fine because every time someone gets it it'll get boundsChecked)
    }
    
    private func boundsCheckedPaletteIndex(_ index: Int) -> Int {
            var index = index % palettes.count
            if index < 0 {
                index += palettes.count
            }
            return index
        }
    
    // MARK: - Adding Palettes
            
            // these functions are the recommended way to add Palettes to the PaletteStore
            // since they try to avoid duplication of Identifiable-ly identical Palettes
            // by first removing/replacing any Palette with the same id that is already in palettes
            // it does not "remedy" existing duplication, it just does not "cause" new duplication
            
            func insert(_ palette: Palette, at insertionIndex: Int? = nil) { // "at" default is cursorIndex
                let insertionIndex = boundsCheckedPaletteIndex(insertionIndex ?? cursorIndex)
                if let index = palettes.firstIndex(where: { $0.id == palette.id }) {
                    palettes.move(fromOffsets: IndexSet([index]), toOffset: insertionIndex)
                    palettes.replaceSubrange(insertionIndex...insertionIndex, with: [palette])
                } else {
                    palettes.insert(palette, at: insertionIndex)
                }
            }
            
            func insert(name: String, emojis: String, at index: Int? = nil) {
                insert(Palette(name: name, emojis: emojis), at: index)
            }
            
            func append(_ palette: Palette) { // at end of palettes
                if let index = palettes.firstIndex(where: { $0.id == palette.id }) {
                    if palettes.count == 1 {
                        palettes = [palette]
                    } else {
                        palettes.remove(at: index)
                        palettes.append(palette)
                    }
                } else {
                    palettes.append(palette)
                }
            }
            
            func append(name: String, emojis: String) {
                append(Palette(name: name, emojis: emojis))
            }


}
