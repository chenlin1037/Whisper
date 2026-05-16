import SwiftUI

struct SoundGridView: View {
    let sounds: [Sound]
    @EnvironmentObject var vm: PlayerViewModel

    private enum Layout {
        static let gridSpacing: CGFloat = 14

        static let columns: [GridItem] = [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible()),
        ]
    }

    var body: some View {
        LazyVGrid(columns: Layout.columns, spacing: Layout.gridSpacing) {
            ForEach(sounds) { sound in
                SoundCardView(sound: sound)
            }
        }
    }
}
