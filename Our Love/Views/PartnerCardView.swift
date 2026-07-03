import SwiftUI

// MARK: - Partner Card View

struct PartnerCardView: View {
    let profile: PartnerProfile
    let onLike: () -> Void
    let onPass: () -> Void
    
    @State private var offset = CGSize.zero
    @State private var showDetails = false
    
    private let cardWidth = UIScreen.main.bounds.width - 48
    private let cardHeight: CGFloat = 480
    
    var body: some View {
        VStack(spacing: 0) {
            // Photo area
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [.pink.opacity(0.2), .purple.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(
                        LinearGradient(colors: [.pink, .purple], startPoint: .leading, endPoint: .trailing)
                    )
                
                // Like / Pass overlay
                if offset.width > 30 {
                    likeOverlay
                } else if offset.width < -30 {
                    passOverlay
                }
            }
            .frame(height: cardHeight * 0.65)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            
            // Info area
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(profile.displayName)
                        .font(.title2.weight(.bold))
                    
                    if let age = profile.age {
                        Text("\(age)")
                            .font(.title3)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    if let gender = profile.gender {
                        Image(systemName: gender == "female" ? "figure.dress.line.vertical.figure" : "figure.stand")
                            .foregroundColor(.pink)
                    }
                }
                
                if let city = profile.city, !city.isEmpty {
                    Label(city, systemImage: "mappin.circle.fill")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                if let bio = profile.bio, !bio.isEmpty {
                    Text(bio)
                        .font(.subheadline)
                        .foregroundColor(.primary)
                        .lineLimit(showDetails ? nil : 3)
                }
            }
            .padding()
            
            Spacer()
            
            // Action buttons
            HStack(spacing: 40) {
                Button {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                        offset = CGSize(width: -500, height: 0)
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        onPass()
                    }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 56))
                        .foregroundStyle(.red)
                        .shadow(color: .red.opacity(0.3), radius: 8)
                }
                
                Button {
                    showDetails.toggle()
                } label: {
                    Image(systemName: showDetails ? "chevron.up.circle.fill" : "info.circle.fill")
                        .font(.system(size: 32))
                        .foregroundStyle(.gray)
                }
                
                Button {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                        offset = CGSize(width: 500, height: 0)
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        onLike()
                    }
                } label: {
                    Image(systemName: "heart.circle.fill")
                        .font(.system(size: 56))
                        .foregroundStyle(
                            LinearGradient(colors: [.pink, .purple], startPoint: .leading, endPoint: .trailing)
                        )
                        .shadow(color: .pink.opacity(0.3), radius: 8)
                }
            }
            .padding(.bottom)
        }
        .frame(width: cardWidth, height: cardHeight)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: .black.opacity(0.1), radius: 15, y: 5)
        .offset(offset)
        .rotationEffect(.degrees(Double(offset.width / 20)))
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    offset = gesture.translation
                }
                .onEnded { gesture in
                    if gesture.translation.width > 120 {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                            offset = CGSize(width: 500, height: 0)
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            onLike()
                        }
                    } else if gesture.translation.width < -120 {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                            offset = CGSize(width: -500, height: 0)
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            onPass()
                        }
                    } else {
                        withAnimation(.spring) {
                            offset = .zero
                        }
                    }
                }
        )
    }
    
    private var likeOverlay: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.green.opacity(0.3))
            
            Text("ЛАЙК")
                .font(.largeTitle.weight(.bold))
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
                .background(Color.green)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .rotationEffect(.degrees(-15))
        }
    }
    
    private var passOverlay: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.red.opacity(0.3))
            
            Text("ПРОПУСК")
                .font(.largeTitle.weight(.bold))
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
                .background(Color.red)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .rotationEffect(.degrees(15))
        }
    }
}

#Preview {
    PartnerCardView(
        profile: PartnerProfile(
            id: "1",
            displayName: "Анна",
            bio: "Люблю путешествия, кофе и долгие прогулки по городу",
            city: "Москва",
            birthDate: "1998-05-15",
            age: 26,
            gender: "female",
            photo: nil,
            isActive: true,
            createdAt: nil,
            updatedAt: nil
        ),
        onLike: {},
        onPass: {}
    )
    .padding()
}
