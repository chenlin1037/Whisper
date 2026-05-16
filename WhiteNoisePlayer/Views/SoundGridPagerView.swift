import SwiftUI

struct SoundGridPagerView: View {
    @Binding var selectedCategoryIndex: Int
    @EnvironmentObject var vm: PlayerViewModel

    // 改为 @State，onAppear 时赋值一次，不随 body 重复计算
    @State private var groups: [(category: Sound.Category, sounds: [Sound])] = []
    @State private var allSounds: [Sound] = []
    @State private var categories: [String] = []

    private enum Layout {
        static let horizontalPadding: CGFloat = 16
        static let topPadding: CGFloat = 12
    }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 24) {
                    sectionHeader("All")
                        .id("All")
                    SoundGridView(sounds: allSounds)

                    ForEach(groups, id: \.category) { group in
                        sectionHeader(group.category.rawValue)
                            .id(group.category.rawValue)
                        SoundGridView(sounds: group.sounds)
                    }
                }
                .padding(.horizontal, Layout.horizontalPadding)
                .padding(.top, Layout.topPadding)
                .padding(.bottom, 130)
            }
            .scrollIndicators(.hidden)
            .onChange(of: selectedCategoryIndex) { _, newIndex in
                withAnimation(.easeInOut(duration: 0.3)) {
                    let id = categories[newIndex]
                    proxy.scrollTo(id, anchor: .top)
                }
            }
            .onAppear {
                // 只在首次出现时从 DataManager 加载，后续不再重复调用
                if allSounds.isEmpty {
                    let dm = SoundDataManager.shared
                    allSounds = dm.sounds
                    groups = dm.getSoundsGroupedByCategory()
                    categories = dm.getAllCategories()
                }
                if selectedCategoryIndex > 0 {
                    let id = categories[selectedCategoryIndex]
                    proxy.scrollTo(id, anchor: .top)
                }
            }
        }
    }

    private func sectionHeader(_ title: String) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(Color.ink)
            Spacer()
        }
        .padding(.horizontal, 4)
        .padding(.top, title == "All" ? 2 : 8)
    }
}
