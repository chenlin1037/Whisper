import SwiftUI

// MARK: - 轻量值类型，替代在 closure 里捕获 Mixsound 托管对象

struct MixSnapshot {
    let id: UUID
    let name: String
    let itemCount: Int
    let items: [(soundID: String, volume: Float)]
}

struct MixLibraryView: View {
    @EnvironmentObject var vm: PlayerViewModel
    @EnvironmentObject var mixLibraryStore: MixLibraryStore

    @State private var renameMixsound: Mixsound?
    @State private var renameText = ""
    @State private var deleteMixsound: Mixsound?

    // 在视图层将托管对象转换为值类型
    // 只在 mixsounds 变化时重新计算，不在每次 body 求值时访问 SwiftData
    private var snapshots: [MixSnapshot] {
        mixLibraryStore.mixsounds.map { mixsound in
            MixSnapshot(
                id: mixsound.id,
                name: mixsound.name,
                itemCount: mixsound.items.count,
                // 在这里一次性读取 items，避免 closure 持有托管对象
                items: mixsound.items.map { (soundID: $0.soundID, volume: $0.volume) }
            )
        }
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(spacing: 0) {
                    if mixLibraryStore.mixsounds.isEmpty {
                        emptyState
                            .frame(maxWidth: .infinity)
                            .padding(.top, 80)
                    } else {
                        LazyVStack(spacing: 6) {
                            ForEach(snapshots, id: \.id) { snapshot in
                                MixsoundRow(
                                    snapshot: snapshot,
                                    onPlay: {
                                        vm.applyMix(snapshot: snapshot, replaceCurrent: true)
                                    },
                                    onRename: {
                                        renameMixsound = mixLibraryStore.mixsounds.first { $0.id == snapshot.id }
                                        renameText = snapshot.name
                                    },
                                    onDelete: {
                                        deleteMixsound = mixLibraryStore.mixsounds.first { $0.id == snapshot.id }
                                    }
                                )
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 20)
                .padding(.bottom, vm.anyActive ? 130 : 36) // 统一在这里处理底部间距
            }
            .scrollIndicators(.hidden)
            // alert 挂在 ScrollView 上
            .alert("Rename", isPresented: renamePresented) {
                TextField("Name", text: $renameText)
                Button("Cancel", role: .cancel) { renameMixsound = nil }
                Button("Save") {
                    guard let mixsound = renameMixsound else { return }
                    mixLibraryStore.rename(id: mixsound.id, new_name: renameText)
                    renameMixsound = nil
                }
            } message: {
                Text("Changes will be applied to the mix name immediately.")
            }
            .alert("Delete this mix?", isPresented: deletePresented, presenting: deleteMixsound) { mixsound in
                Button("Cancel", role: .cancel) { deleteMixsound = nil }
                Button("Delete", role: .destructive) {
                    mixLibraryStore.delete(id: mixsound.id)
                    deleteMixsound = nil
                }
            } message: { mixsound in
                Text("\"\(mixsound.name)\" will be removed from your library.")
            }

            if vm.anyActive {
                ControlBarView(vm: vm)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 8)
                    .ignoresSafeArea(edges: .bottom)
            }
        }
    }

    private var mixsoundSection: some View {
        // snapshots 是值类型数组，ForEach 不会持有任何 SwiftData 托管对象
        ForEach(snapshots, id: \.id) { snapshot in
            MixsoundRow(
                snapshot: snapshot,

                onPlay: {
                    vm.applyMix(snapshot: snapshot, replaceCurrent: true)
                },

                onRename: {
                    // alert 需要操作托管对象，这里按 id 查找——查找是懒惰的，只在用户触发时执行
                    renameMixsound = mixLibraryStore.mixsounds.first { $0.id == snapshot.id }
                    renameText = snapshot.name
                },

                onDelete: {
                    deleteMixsound = mixLibraryStore.mixsounds.first { $0.id == snapshot.id }
                }
            )
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets(top: 3, leading: 0, bottom: 3, trailing: 0))
        }
    }

    // emptyState、renamePresented、deletePresented 不变，省略
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "bookmark.circle")
                .font(.system(size: 52, weight: .regular))
                .foregroundStyle(Color.selectedColor.opacity(0.75))
            VStack(spacing: 6) {
                Text("No Saved Mixes Yet")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.ink)

                Text("Save a mix from the sound settings screen. Your saved mixes will appear here.")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(Color.ink.opacity(0.56))
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
                    .padding(.horizontal, 30)
            }
        }
        .padding(.vertical, 32)
        .background(RoundedRectangle(cornerRadius: 24, style: .continuous).fill(Color.panel))
        .overlay(RoundedRectangle(cornerRadius: 24, style: .continuous).stroke(Color.white.opacity(0.75), lineWidth: 1))
    }

    private var renamePresented: Binding<Bool> {
        Binding(get: { renameMixsound != nil }, set: { if !$0 { renameMixsound = nil } })
    }

    private var deletePresented: Binding<Bool> {
        Binding(get: { deleteMixsound != nil }, set: { if !$0 { deleteMixsound = nil } })
    }
}

// MARK: - Row 改为只接收值类型

private struct MixsoundRow: View {
    // 只接收 MixSnapshot，不持有任何 SwiftData @Model 对象
    let snapshot: MixSnapshot
    let onPlay: () -> Void
    let onRename: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 0) {
            Button(action: onPlay) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(snapshot.name)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color.white)
                    Text("\(snapshot.itemCount) 种声音")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(Color.ink.opacity(0.5))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 20)
                .padding(.vertical, 14)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            Menu {
                Button { onRename() } label: {
                    Label("Rename", systemImage: "pencil")
                }

                Divider()

                Button(role: .destructive, action: onDelete) {
                    Label("Delete", systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis.circle.fill")
                    .font(.system(size: 22))
                    .foregroundStyle(Color.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
            }
        }
        .background(RoundedRectangle(cornerRadius: 20, style: .continuous).fill(Color.selectedColor.opacity(0.7)))
        .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).stroke(Color.white.opacity(0.9), lineWidth: 1))
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
    }
}
