import SwiftUI

// MARK: - 抖音风格顶部 Tab 栏

// 用法：将 DiscoverView() 和 TrendingView() 替换成你自己的视图即可

struct ContentView: View {
    @EnvironmentObject var vm: PlayerViewModel
    @State private var selectedTab = 1 // 默认

    var body: some View {
        VStack(spacing: 0) {
            // 顶部 Tab
            TabBar(
                tabs: ["Favorites", "White Noise", "Mix Library"],

                selected: $selectedTab
            )
            // 可左右滑动的页面
            TabView(selection: $selectedTab) {
                CollectionView()
                    .tag(0)
                HomeView() // 替换成你的发现视图
                    .tag(1)

                if selectedTab == 2 {
                    MixLibraryView()
                        .tag(2)
                } else {
                    Color.clear.tag(2) // 占位，保持 tab 存在
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .ignoresSafeArea()
        }
    }
}

// MARK: - 顶部 Tab 栏组件

struct TabBar: View {
    let tabs: [String]
    @Binding var selected: Int
    @Namespace private var ns

    var body: some View {
        HStack(spacing: 32) {
            ForEach(tabs.indices, id: \.self) { i in
                Button {
                    withAnimation(.spring(response: 0.28, dampingFraction: 0.72)) {
                        selected = i
                    }
                } label: {
                    VStack(spacing: 5) {
                        Text(tabs[i])
                            .font(.system(size: selected == i ? 18 : 15,
                                          weight: selected == i ? .bold : .regular))
                            .foregroundColor(selected == i ? .primary : .primary.opacity(0.5))
                            .animation(.spring(response: 0.28), value: selected)

                        // 红色下划线
                        ZStack {
                            Capsule()
                                .fill(Color.clear)
                                .frame(width: 24, height: 3)
                            if selected == i {
                                Capsule()
                                    .fill(Color.red)
                                    .frame(width: 24, height: 3)
                                    .matchedGeometryEffect(id: "indicator", in: ns)
                            }
                        }
                    }

                    .padding(.vertical, 8)
                }
                .buttonStyle(.plain)
            }
        }
    }
}
