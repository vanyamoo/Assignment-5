//
//  EmojiArtDocument.swift
//  EmojiArtJuly24
//
//  Created by Vanya Mutafchieva on 04/07/2024.
//
//  *2* To create our ViewModel, we'll always start with what is our model (1), and because it's fully private we need to provide these computed properties (2) that let you get at the emojis and the background. And we'll be setting these values so we'll of course have intents (3)

import SwiftUI

class EmojiArtDocument: ObservableObject {
    
    typealias Emoji = EmojiArt.Emoji
    
    // 1.
    @Published private var emojiArt = EmojiArt()
    
    init() {
        emojiArt.addEmoji("🐄", at: .init(x: -200, y: -150), size: 200) // we can say .init(x:, y:) instead of the full EmojiArt.Emoji.Position(x:, y:). saying .init lets Type Inference to infer the type it's expecting there
        emojiArt.addEmoji("🐖", at: .init(x: 250, y: 100), size: 80)
    }
    
    // 2.
    var background: URL? {
        emojiArt.background
    }
    
    var emojis: [Emoji] {
        emojiArt.emojis
    }
    
    // 3.
    // MARK: - Intents
    
    func setBackground(_ url: URL?) {
        emojiArt.background = url
    }
    
    func addEmoji(_ emoji: String, at position: Emoji.Position, size: CGFloat) {
        emojiArt.addEmoji(emoji, at: position, size: Int(size))
    }
    
    func delete(_ emoji: Emoji) {
        emojiArt.delete(emoji)
    }
    
    func delete(emojiWithId id: Emoji.ID) {
        if let emoji = emojiArt[id] {
            delete(emoji)
        }
    }
    
    func move(_ emoji: Emoji, by offset: CGOffset) {
        let existingPosition = emojiArt[emoji].position
        emojiArt[emoji].position = Emoji.Position(
            x: existingPosition.x + Int(offset.width),
            y: existingPosition.y - Int(offset.height)
        )
    }
        
    func move(emojiWithId id: Emoji.ID, by offset: CGOffset) {
        if let emoji = emojiArt[id] {
            move(emoji, by: offset)
        }
    }
    
    func resize(_ emoji: Emoji, by scale: CGFloat) {
        emojiArt[emoji].size = Int(CGFloat(emojiArt[emoji].size) * scale)
    }
    
    func resize(emojiWithId id: Emoji.ID, by scale: CGFloat) {
        if let emoji = emojiArt[id] {
            resize(emoji, by: scale)
        }
    }
}

extension EmojiArt.Emoji {
    var font: Font {
        Font.system(size: CGFloat(size))
    }
}

extension EmojiArt.Emoji.Position {
    func `in`(_ geometry: GeometryProxy) -> CGPoint {
        let center = geometry.frame(in: .local).center
        return CGPoint(x: center.x + CGFloat(x), y: center.y - CGFloat(y))
    }
}


