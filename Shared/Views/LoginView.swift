//
//  LoginView.swift
//  MemoReminder
//
//  Created by Seyed Parsa Neshaei and Гералд Бирген (https://github.com/gbrigens/SwiftUISignin.git) on 15.12.2020.
//

import SwiftUI
import ActivityIndicatorView

struct LoginView: View {
    @Environment(\.colorScheme) var colorScheme
    var isDarkMode: Bool { colorScheme == .dark }
    
    @EnvironmentObject var globalData: GlobalData
    
    // MARK: - PROPERTIES
    @State var username = "";
    @State var password = "";
    @State var showingAlert = false
    @State var loginStatus: User.AuthenticationStatus = .failed
    @State var showActivityIndicatorView = false
    
    var alertTextMessage: String {
        switch loginStatus {
        case .failed:
            return "Login failed. Please double-check your username and password and then try again."
        case .invalidData:
            return "Invalid data provided. Please try again."
        default:
            return ""
        }
    }
    
    @EnvironmentObject var mainAppViewModel: MainAppViewModel
    
    var body: some View {
        ZStack{
            Image("login-4")
                .resizable()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 30){
                    VStack(alignment: .leading, spacing: 30){
                        Image("MemoReminderIcon")
                            .resizable()
                            .frame(width: 60, height: 60)
                        Text("Welcome to MemoReminder")
                            .modifier(CustomTextViewModifier(fontName: "MavenPro-Regular", fontSize: 23, fontColor: .black))
                    }
                    .padding(.top,55)
                    VStack {
                            VStack(alignment: .leading){
                                VStack(spacing: 20) {
                                    AuthenticationInputComponentView(inputTitle: "Username", username: $username, isSecure: false)
                                    VStack(spacing: 15){
                                        AuthenticationInputComponentView(inputTitle: "Password", username: $password, isSecure: true)
                                    }
                                }
                                Button(action: { login() }){
                                    Text("LOGIN")
                                        .modifier(CustomTextViewModifier(fontName: "MavenPro-Bold", fontSize: 14, fontColor: Color.black))
                                        .modifier(AuthenticationCustomButtonViewModifier())
                                        .background(isDarkMode ? Color(red: 231/255, green: 133/255, blue: 54/255) : Color(red: 247/255, green: 207/255, blue: 71/255))
                                        .cornerRadius(10)
                                }
                                .padding(.top,30)
                                .alert(alertTextMessage, isPresented: $showingAlert) {
                                    Button("OK", role: .cancel) { }
                                }
                                
                            }
                            .padding(.horizontal,30)
                            .padding(.vertical,40)
                    }
                    .background(Color("card"))
                    .cornerRadius(10)
                    .padding(.top,20)
                    .shadow(radius: 20.0)
                    .offset(x: -25.0, y: 0.0)
                     
                    Spacer()
                    Button(action: { goToSignUp() }) {
                        HStack{
                            Text("New?")
                            Text("Sign up")
                                .modifier(CustomTextViewModifier(fontName: "MavenPro-Bold", fontSize: 18, fontColor: Color.primary))
                            Text("for a new account.")
                        }
                        .modifier(CustomTextViewModifier(fontName: "MavenPro-Regular", fontSize: 18, fontColor: Color.primary))
                        .foregroundColor(.primary)
                    }
                    .padding(.bottom, 30)
                    .padding(.top, 30)
                    
                }
                .offset(x:40)
            }
            
            ActivityIndicatorView(isVisible: $showActivityIndicatorView, type: .equalizer)
                .frame(width: 100.0, height: 100.0)
                .foregroundColor(.orange)
        }.edgesIgnoringSafeArea(.all)
    }
    
    func login() {
        guard !showActivityIndicatorView else { return }
        showActivityIndicatorView = true
        async {
            loginStatus = await User.login(username: username, password: password, globalData: globalData)
            if loginStatus == .success {
                main {
                    showActivityIndicatorView = false
                    withAnimation {
                        mainAppViewModel.currentView = .mainTabView
                    }
                }
            } else {
                main {
                    showActivityIndicatorView = false
                    showingAlert = true
                }
            }
        }
    }
    
    func goToSignUp() {
        withAnimation {
            mainAppViewModel.currentView = .signUp
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .preferredColorScheme(.dark)
    }
}

struct AuthenticationInputComponentView: View {
    @State var inputTitle: String
    @Binding var username: String
    @State var isSecure: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8){
            Text(inputTitle)
                .modifier(CustomTextViewModifier(fontName: "MavenPro-Medium", fontSize: 16, fontColor: Color.gray))
            Group{
                if !isSecure {
                    TextField("", text: $username)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                } else {
                    SecureField("", text: $username)
                }
            }.padding(10)
            .font(Font.system(size: 15, weight: .medium, design: .serif))
            .foregroundColor(.primary)
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 0.5).frame(height: 45))
        }
    }
}

struct AuthenticationCustomButtonViewModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity)
            .frame(height: 56, alignment: .leading)
    }
}

struct CustomTextViewModifier: ViewModifier {
    let fontName: String
    let fontSize: CGFloat
    let fontColor: Color
    
    func body(content: Content) -> some View {
        content
            .font(.custom(fontName, size: fontSize))
            .foregroundColor(fontColor)
    }
}
