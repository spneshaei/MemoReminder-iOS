//
//  LoginView.swift
//  MemoReminder
//
//  Created by Seyed Parsa Neshaei and Гералд Бирген (https://github.com/gbrigens/SwiftUISignin.git) on 15.12.2020.
//

import SwiftUI
import ActivityIndicatorView

struct SignUpView: View {
    @EnvironmentObject var globalData: GlobalData
    
    @Environment(\.colorScheme) var colorScheme
    var isDarkMode: Bool { colorScheme == .dark }
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter
    }()
    
    @State var username = "";
    @State var password = "";
    @State var name = "";
    @State var email = "";
    @State var signUpStatus: User.AuthenticationStatus = .failed
    @State var showingAlert = false
    @State private var birthDate = Date(timeIntervalSince1970: 1183104000)
    @State private var emptyFieldName = ""
    @State private var showingEmptyFieldAlert = false
    @State var showingEmailWrongAlert = false
    @State var showActivityIndicatorView = false
    
    @EnvironmentObject var mainAppViewModel: MainAppViewModel
    
    var alertTextMessage: String {
        switch signUpStatus {
        case .failed:
            return "Sign up failed. Please try again."
        case .invalidData:
            return "Invalid data provided. Please try again."
        case .success:
            return "Sign up successful! Now you can login"
        }
    }
    
    var body: some View {
        ZStack {
            Image("login-4")
                .resizable()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 25){
                    VStack(alignment: .leading, spacing: 30){
                        Text("Sign Up")
                            .modifier(CustomTextViewModifier(fontName: "MavenPro-Regular", fontSize: 23, fontColor: .black))
                    }
                    .padding(.top,70)
                    VStack {
                        VStack(alignment: .leading){
                            VStack(spacing: 20) {
                                AuthenticationInputComponentView(inputTitle: "Name", username: $name, isSecure: false)
                                AuthenticationInputComponentView(inputTitle: "Username", username: $username, isSecure: false)
                                AuthenticationInputComponentView(inputTitle: "Password", username: $password, isSecure: true)
                                AuthenticationInputComponentView(inputTitle: "Email", username: $email, isSecure: false)
                                DatePicker(selection: $birthDate, in: ...Date(), displayedComponents: .date) {
                                    Text("Birthday")
                                        .modifier(CustomTextViewModifier(fontName: "MavenPro-Medium", fontSize: 16, fontColor: Color.gray))
                                }
                            }
                            .alert("The \(emptyFieldName) field is empty.", isPresented: $showingEmptyFieldAlert) {
                                Button("OK", role: .cancel) { }
                            }
                            Button(action: {
                                signUp(globalData: globalData)
                            }){
                                Text("SIGN UP")
                                    .modifier(CustomTextViewModifier(fontName: "MavenPro-Bold", fontSize: 14, fontColor: Color.black))
                                    .modifier(AuthenticationCustomButtonViewModifier())
                                    .background(isDarkMode ? Color(red: 231/255, green: 133/255, blue: 54/255) : Color(red: 247/255, green: 207/255, blue: 71/255))
                                    .cornerRadius(10)
                            }
                            .padding(.top,30)
                            .alert(alertTextMessage, isPresented: $showingAlert) {
                                Button("OK", role: .cancel) {
                                    if signUpStatus == .success {
                                        withAnimation {
                                            mainAppViewModel.currentView = .login
                                        }
                                    }
                                }
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
                    .alert("Your email address is provided in a wrong format. Maybe you've had a typo. Fix the email address and then try again", isPresented: $showingEmailWrongAlert) {
                        Button("OK", role: .cancel) { }
                    }
                    
                    Spacer()
                    Button(action: { backToLogin() }) {
                        HStack{
                            Text("Already have an account?")
                            Text("Log in")
                                .modifier(CustomTextViewModifier(fontName: "MavenPro-Bold", fontSize: 18, fontColor: Color.primary))
                        }
                        .modifier(CustomTextViewModifier(fontName: "MavenPro-Regular", fontSize: 18, fontColor: Color.primary))
                        .foregroundColor(.primary)
                    }
                    .padding(.bottom, 30)
                }
                .offset(x:40)
            }
            
            ActivityIndicatorView(isVisible: $showActivityIndicatorView, type: .equalizer)
                .frame(width: 100.0, height: 100.0)
                .foregroundColor(.orange)
        }.edgesIgnoringSafeArea(.all)
    }
    
    var areAllFieldsValid: Bool {
        guard !username.isEmpty else {
            emptyFieldName = "username"
            showingEmptyFieldAlert = true
            return false
        }
        guard !password.isEmpty else {
            emptyFieldName = "password"
            showingEmptyFieldAlert = true
            return false
        }
        guard !name.isEmpty else {
            emptyFieldName = "name"
            showingEmptyFieldAlert = true
            return false
        }
        guard !email.isEmpty else {
            emptyFieldName = "email"
            showingEmptyFieldAlert = true
            return false
        }
        return true
    }
    
    func signUp(globalData: GlobalData) {
        guard !showActivityIndicatorView else { return }
        guard areAllFieldsValid else { return }
        guard isValidEmailAddress(emailAddressString: email) else {
            showingEmailWrongAlert = true
            return
        }
        showActivityIndicatorView = true
        async {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "YYYY-MM-dd"
            signUpStatus = await User.signUp(username: username, firstName: name, lastName: "L", birthday: dateFormatter.string(from: birthDate), password: password, phoneNumber: "09111111111", email: email, globalData: globalData)
            main {
                showActivityIndicatorView = false
                showingAlert = true
            }
        }
    }
    
    func backToLogin() {
        withAnimation {
            mainAppViewModel.currentView = .login
        }
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
            .environmentObject(GlobalData.sample)
    }
}
