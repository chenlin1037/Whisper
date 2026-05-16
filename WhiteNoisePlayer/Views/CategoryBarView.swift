import SwiftUI

struct CategoryBarView: View {
    private enum Layout {
        static let categoryHeight: CGFloat = 58
        static let horizontalPadding: CGFloat = 16
    }

    @State private var categories: [String] = []
    @Binding var selectedCategoryIndex: Int

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(Array(categories.enumerated()), id: \.offset) { index, category in
                        CategoryChip(
                            title: category,
                            isSeleted: selectedCategoryIndex == index,
                            onTap: {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    selectedCategoryIndex = index
                                }
                            }
                        )
                        .id(index)
                    }
                }
                .padding(.horizontal, Layout.horizontalPadding)
                .padding(.vertical, 10)
            }
            .frame(height: Layout.categoryHeight)
            .background(Color.clear)
            .onChange(of: selectedCategoryIndex) { _, newIndex in
                // 自动滚动到选中的分类
                withAnimation(.easeInOut(duration: 0.3)) {
                    proxy.scrollTo(newIndex, anchor: .center)
                }
            }
            .onAppear {
                if categories.isEmpty {
                    categories = SoundDataManager.shared.getAllCategories()
                }
            }
        }
    }
}
