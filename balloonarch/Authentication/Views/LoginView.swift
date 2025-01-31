//
//  LoginView.swift
//  balloonarch
//
//  Created by Rose, Alex on 1/31/25.
//

import SwiftUI

struct LoginView: View {
    @StateObject var vm = LoginViewModel()
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            // Background Gradient
            LinearGradient(gradient: Gradient(colors: [Color(#colorLiteral(red: 0.8470588235, green: 0.9176470588, blue: 1, alpha: 1)), Color(#colorLiteral(red: 0.9764705882, green: 0.9176470588, blue: 1, alpha: 1))]),
                           startPoint: .topLeading, endPoint: .bottomTrailing)
            .ignoresSafeArea()
            
            // Floating Balloons
            ForEach(0..<6) { index in
                BalloonView(index: index)
                    .offset(y: isAnimating ? -UIScreen.main.bounds.height : 0)
            }
            
            // Content
            VStack(spacing: 30) {
                // Header
                VStack {
                    Image(systemName: "airballoon.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.white)
                        .shadow(radius: 5)
                    
                    Text("BalloonRecycle")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(radius: 5)
                }
                .padding(.top, 40)
                
                // Login Form
                VStack(spacing: 20) {
                    TextField("Email", text: $vm.email)
                        .modifier(ModernTextField())
                    
                    SecureField("Password", text: $vm.password)
                        .modifier(ModernTextField())
                    
                    Button("Log In") { Task { await vm.login() } }
                        .disabled(!vm.isValidForm).modifier(ModernButton())
                    
                    Button("Create Account") { Task { await vm.createAccount() } }
                        .disabled(!vm.isValidForm).modifier(ModernButton(backgroundColor: .purple))
                }
            }
            .padding(.horizontal, 30)
            
            Spacer()
        }
        
        // Bottom Wave
        WaveShape()
            .fill(Color.white.opacity(0.3))
            .frame(height: 150)
            .offset(y: UIScreen.main.bounds.height * 0.35)
    }
//        .onAppear {
//            withAnimation(Animation.easeInOut(duration: 8).repeatForever()) {
//                isAnimating = true
//            }
//        }
}


// Balloon Component
struct BalloonView: View {
    let index: Int
    let colors: [Color] = [.red, .blue, .green, .yellow, .purple, .orange]
    
    var body: some View {
        GeometryReader { geometry in
            let xPosition = CGFloat.random(in: 0...geometry.size.width)
            let delay = Double.random(in: 0...2)
            
            ZStack {
                // Balloon Body
                Circle()
                    .fill(colors[index % colors.count])
                    .frame(width: 60, height: 80)
                    .overlay(
                        Circle()
                            .stroke(Color.white, lineWidth: 2)
                    )
                
                // Balloon Tip
                Triangle()
                    .fill(colors[index % colors.count])
                    .frame(width: 10, height: 15)
                    .offset(y: 40)
                
                // String
                Path { path in
                    path.move(to: CGPoint(x: 30, y: 50))
                    path.addLine(to: CGPoint(x: 30, y: 70))
                }
                .stroke(Color.gray, lineWidth: 1)
            }
            .position(x: xPosition, y: geometry.size.height + 100)
            .animation(
                Animation.easeInOut(duration: 8)
                    .repeatForever()
                    .delay(delay),
                value: UUID()
            )
        }
    }
}

// Custom Shapes
struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

struct WaveShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: rect.midY))
        
        path.addQuadCurve(
            to: CGPoint(x: rect.width, y: rect.midY),
            control: CGPoint(x: rect.width * 0.5, y: rect.maxY)
        )
        
        path.addLine(to: CGPoint(x: rect.width, y: rect.height))
        path.addLine(to: CGPoint(x: 0, y: rect.height))
        path.closeSubpath()
        
        return path
    }
}

// View Modifiers
struct ModernTextField: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(15)
            .background(Color.white.opacity(0.9))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.purple.opacity(0.3), lineWidth: 2)
            )
            .font(.system(size: 16, weight: .medium, design: .rounded))
            .textInputAutocapitalization(.never)
    }
}

struct ModernButton: ViewModifier {
    var backgroundColor: Color = .blue
    
    func body(content: Content) -> some View {
        content
            .font(.system(size: 16, weight: .semibold, design: .rounded))
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(backgroundColor)
            .cornerRadius(12)
            .shadow(color: backgroundColor.opacity(0.3), radius: 5, x: 0, y: 5)
    }
}

//
//struct LoginView: View {
//    @StateObject var vm = LoginViewModel()
//    
//    var body: some View {
//        VStack(spacing: 20) {
//            TextField("Email", text: $vm.email)
//                .textContentType(.emailAddress)
//                .autocapitalization(.none)
//            
//            SecureField("Password", text: $vm.password)
//                .textContentType(.password)
//            
//            Button("Log In") { Task { await vm.login() } }
//                .disabled(!vm.isValidForm)
//            
//            Button("Create Account") { Task { await vm.createAccount() } }
//                .disabled(!vm.isValidForm)
//            
//            if vm.isLoading {
//                ProgressView()
//            }
//        }
//        .padding()
//        .alert("Authentication Error", isPresented: $vm.showError) {
//            Button("OK", role: .cancel) { }
//        } message: {
//            Text(vm.errorMessage)
//        }
//    }
//}
