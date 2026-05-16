import SwiftUI

struct HomeView: View {
    @EnvironmentObject var vm: PlayerViewModel
    @State private var selectedCategoryIndex = 0
    // @State private var showMixLibrary = false

    var body: some View {
        ZStack(alignment: .bottom) {
            // backgroundLayer

            VStack(spacing: 0) {
                header
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 12)

                CategoryBarView(selectedCategoryIndex: $selectedCategoryIndex)

                SoundGridPagerView(selectedCategoryIndex: $selectedCategoryIndex)
            }

            if vm.anyActive {
                ControlBarView(vm: vm)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 8)
                    .ignoresSafeArea(edges: .bottom)
            }
        }
        // .preferredColorScheme(.light)
        // .sheet(isPresented: $showMixLibrary) {
        //     MixLibraryView(vm: vm)
        // }
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 8) {
                // Text("White Noise")
                //     .font(.system(size: 34, weight: .bold, design: .rounded))
                //     .foregroundStyle(Color.ink)

                Text(statusText)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(Color.ink.opacity(0.68))
            }

            Spacer(minLength: 16)

            // Button {
            //     showMixLibrary = true
            // } label: {
            //     VStack(alignment: .trailing, spacing: 6) {
            //         Image(systemName: "square.stack.3d.up")
            //             .font(.system(size: 20, weight: .semibold))
            //             .foregroundStyle(Color.selectedColor)
            //         Text("混合库")
            //             .font(.system(size: 11, weight: .semibold, design: .rounded))
            //             .foregroundStyle(Color.ink.opacity(0.60))
            //     }
            //     .padding(.horizontal, 16)
            //     .padding(.vertical, 12)
            //     .background(
            //         RoundedRectangle(cornerRadius: 20, style: .continuous)
            //             .fill(Color.panel)
            //     )
            //     .overlay(
            //         RoundedRectangle(cornerRadius: 20, style: .continuous)
            //             .stroke(Color.white.opacity(0.85), lineWidth: 1)
            //     )
            // }
            // .buttonStyle(.plain)

            // if vm.anyActive {
            //     VStack(alignment: .trailing, spacing: 6) {
            //         Text("\(vm.activeTracks.count)")
            //             .font(.system(size: 26, weight: .bold, design: .rounded))
            //             .foregroundStyle(Color.selectedColor)
            //         Text("正在混音")
            //             .font(.system(size: 11, weight: .semibold, design: .rounded))
            //             .foregroundStyle(Color.ink.opacity(0.55))
            //     }
            //     .padding(.horizontal, 16)
            //     .padding(.vertical, 12)
            //     .background(
            //         RoundedRectangle(cornerRadius: 20, style: .continuous)
            //             .fill(Color.panel)
            //     )
            //     .overlay(
            //         RoundedRectangle(cornerRadius: 20, style: .continuous)
            //             .stroke(Color.white.opacity(0.85), lineWidth: 1)
            //     )
            //     .shadow(color: Color.selectedColor.opacity(0.12), radius: 18, x: 0, y: 10)
            // }
        }
    }

    private var backgroundLayer: some View {
        ZStack {
            LinearGradient.appBackground
                .ignoresSafeArea()

            RadialGradient.heroGlow
                .ignoresSafeArea()

            Color.warmGlow
                .opacity(0.10)
                .frame(width: 240, height: 240)
                .clipShape(Circle())
                .offset(x: 110, y: 260)
                .ignoresSafeArea()

            Color.selectedColor
                .opacity(0.07)
                .frame(width: 280, height: 280)
                .clipShape(Circle())
                .offset(x: -120, y: -260)
                .ignoresSafeArea()
        }
    }

    private var statusText: String {
        if let error = vm.errorMessage, !error.isEmpty {
            return "Playback encountered an issue. Please try again later."
        }

        if !vm.sleepCountdown.isEmpty {
            return "Sleep timer active · \(vm.sleepCountdown) remaining"
        }

        if vm.isPlaying {
            return "Playing \(vm.activeTracks.count) Sounds"
        }

        if vm.anyActive {
            return "\(vm.activeTracks.count) Sounds Selected"
        }

        return "Create your perfect mix for focus, relaxation, or sleep."
    }
}
