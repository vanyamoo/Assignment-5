//
//  EmojiArtDocumentView.swift
//  EmojiArtJuly24
//
//  Created by Vanya Mutafchieva on 04/07/2024.
//

import SwiftUI

struct EmojiArtDocumentView: View {
    typealias Emoji = EmojiArt.Emoji
    
    //private let emojis = "👻🍎😃🤪☹️🤯🐶🐭🦁🐵🦆🐝🐢🐄🐖🌲🌴🌵🍄🌞🌎🔥🌈🌧️🌨️☁️⛄️⛳️🚗🚙🚓🚲🛺🏍️🚘✈️🛩️🚀🚁🏰🏠❤️💤⛵️"
    private let paletteEmojiSize: CGFloat = 40
    
    @ObservedObject var document: EmojiArtDocument
    
    var body: some View {
        VStack(spacing: 0) {
            documentBody
            PaletteChooser()
                .font(.system(size: paletteEmojiSize))
                .padding(.horizontal)
                .scrollIndicators(.hidden)
        }
    }
    
    private var documentBody: some View {
        GeometryReader { geometry in
            ZStack {
                Color.white
                documentContents(in: geometry)
                    .scaleEffect(selectedEmojis.isEmpty ? zoom * gestureZoom : zoom)
                    .offset(pan + gesturePan)
                    
            }
            .gesture(panGesture.simultaneously(with: zoomGesture)) // this tells the system that we want both these gestures to be recognised at the same time
            .dropDestination(for: Sturldata.self) { sturldatas, location in // When we say .self to a type, that means the type itself
                return drop(sturldatas, at: location, in: geometry)
            }
        }
        
    }
    
    @State private var zoom: CGFloat = 1
    @State private var pan: CGOffset = .zero
    @GestureState private var gestureZoom: CGFloat = 1
    @GestureState private var gesturePan: CGOffset = .zero // we could have made this be the struct that has all the information in there, but we don't need it all, we just need the translation
    
    private var zoomGesture: some Gesture {
        MagnificationGesture()
            .updating($gestureZoom) { inMotionPinchScale, gestureZoom, _ in
                gestureZoom = inMotionPinchScale
            }
            .onEnded { endingPinchScale in
                // in .onEnded we update our @State
                if selectedEmojis.isEmpty {
                    zoom *= endingPinchScale
                } else {
                    // update Model
                    selectedEmojis.forEach( { emojiId in document.resize(emojiWithId: emojiId, by: endingPinchScale) } )
                    
                }
            }
    }
    
    private var panGesture: some Gesture {
        DragGesture()
            .updating($gesturePan) { value, gesturePan, _ in
                gesturePan = value.translation
            }
            .onEnded { value in
                pan += value.translation // translation is how far the finger has moved since we started
            }
    }
    
    @State private var selectedEmojis = Set<Emoji.ID>()
    
    
    private func isSelected(_ emoji: Emoji) -> Bool {
        selectedEmojis.contains(emoji.id)
    }
    
    private func toggleSelection(_ emoji: Emoji) {
        _ = isSelected(emoji) ? selectedEmojis.remove(emoji.id) : selectedEmojis.update(with: emoji.id)
    }
    
    @State private var move: CGOffset = .zero
    @GestureState private var gestureMove: CGOffset = .zero
    
    private var moveEmojisGesture: some Gesture {
        DragGesture()
            .updating($gestureMove) { value, gestureMove, _ in
                gestureMove = value.translation
            }
            .onEnded { value in
                //move += value.translation
                selectedEmojis.forEach( { emojiId in document.move(emojiWithId: emojiId, by: value.translation) } )
            }
    }
    
    private var deleteGesture: some Gesture {
        LongPressGesture()
            .onEnded { finished in
                selectedEmojis.forEach( { emojiID in document.delete(emojiWithId: emojiID) } )
            }
    }
    
    private func selectGesture(_ emoji: Emoji) -> some Gesture {
        TapGesture()
            .onEnded {
                toggleSelection(emoji)
            }
    }
    
    
    @ViewBuilder
    private func documentContents(in geometry: GeometryProxy) -> some View {
        AsyncImage(url: document.background) { phase in // handle errors L12 ~29:30
            if let image = phase.image {
                image
            } else if let url = document.background {
                if phase.error != nil {
                    Text("\(url)")
                } else {
                    ProgressView()
                }
            }
        }
        .onTapGesture {
            selectedEmojis.removeAll()
        }
        .position(Emoji.Position.zero.in(geometry))
        ForEach(document.emojis) { emoji in
            Text(emoji.string)
                .font(emoji.font)
                .scaleEffect(isSelected(emoji) ? zoom * gestureZoom : zoom)
                .offset(isSelected(emoji) ? gestureMove : .zero)
                .gesture(selectGesture(emoji)).simultaneousGesture(deleteGesture)
                .gesture(moveEmojisGesture)
                //.border(isSelected(emoji) && gestureMove == .zero ? .blue : .clear)
                .border(isSelected(emoji) && gestureZoom == 1 ? .blue : .clear)   // fix this!! - either this or the above work, make so both work
                .position(emoji.position.in(geometry))
        }
    }
    
    
    private func drop(_ sturldatas: [Sturldata], at location: CGPoint, in geometry: GeometryProxy) -> Bool {
        for sturldata in sturldatas {
            switch sturldata {
            case .url(let url):
                document.setBackground(url)
                return true
            case .string(let emoji):
                document.addEmoji(emoji, at: emojiPosition(at: location, in: geometry), size: paletteEmojiSize / zoom)
                return true
            default: // if it's the raw data image, we'll do nothing for now
                break
            }
        }
        return false
    }
    
    private func emojiPosition(at location: CGPoint, in geometry: GeometryProxy) -> Emoji.Position {
        let center = geometry.frame(in: .local).center
        return Emoji.Position(x: Int((location.x - center.x - pan.width) / zoom),
                              y: Int(-(location.y - center.y - pan.height) / zoom))
    }
}

#Preview {
    EmojiArtDocumentView(document: EmojiArtDocument())
            .environmentObject(PaletteStore(named: "Preview"))
}
