//
//  EmojiArt.swift
//  EmojiArtJuly24
//
//  Created by Vanya Mutafchieva on 04/07/2024.
//
//  L10 ~5:20 *1* EmojiArt structure will be the background and all the emojis, and where they are, and what size they are. That's the entirety of our Model so far.

import Foundation

struct EmojiArt {
    var background: URL?
    private(set) var emojis = [Emoji]()
    
    private var uniqueEmojiId = 0
    
    mutating func addEmoji(_ emoji: String, at position: Emoji.Position, size: Int) {
        uniqueEmojiId += 1
        emojis.append(Emoji(string: emoji, size: size, position: position, id: uniqueEmojiId))
    }
    
    mutating func delete(_ emoji: Emoji) {
        if let index = index(of: emoji.id) {
            emojis.remove(at: index)
        }
    }
    
    subscript(_ emojiId: Emoji.ID) -> Emoji? {
            if let index = index(of: emojiId) {
                return emojis[index]
            } else {
                return nil
            }
        }

    subscript(_ emoji: Emoji) -> Emoji {
        get {
            if let index = index(of: emoji.id) {
                return emojis[index]
            } else {
                return emoji // should probably throw error
            }
        }
        set {
            if let index = index(of: emoji.id) {
                emojis[index] = newValue
            }
        }
    }
    
    private func index(of emojiId: Emoji.ID) -> Int? {
        emojis.firstIndex(where: { $0.id == emojiId })
    }
    
    struct Emoji: Identifiable {
        let string: String
        var size: Int
        var position: Position
        var id: Int
        
        struct Position {
            var x: Int
            var y: Int
            
            static let zero = Self(x: 0, y: 0) // Self means the type your code is in. We could also say Position(x:0,y:0)
        }
    }
}
