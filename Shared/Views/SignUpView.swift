//
//  LoginView.swift
//  MemoReminder
//
//  Created by Seyed Parsa Neshaei and Гералд Бирген (https://github.com/gbrigens/SwiftUISignin.git) on 15.12.2020.
//

import SwiftUI
import ActivityIndicatorView

struct SignUpView: View {
    @Environment(\.colorScheme) var colorScheme
    var isDarkMode: Bool { colorScheme == .dark }
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter
    }()
    
    //MARK: - PROPERTIES
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
            
            VStack(alignment: .leading, spacing: 30){
                
                // LOGO & WELCOME
                VStack(alignment: .leading, spacing: 30){
                    //                    Image("logo-4")
                    //                        .resizable()
                    //                        .frame(width: 60, height: 60)
                    Text("Sign Up")
                        .modifier(CustomTextM(fontName: "MavenPro-Regular", fontSize: 23, fontColor: isDarkMode ? .black : .white))
                }
                .padding(.top,55)
                // FORM
                VStack {
                    
                    //                    HStack {
                    
                    VStack(alignment: .leading){
                        VStack(spacing: 20) {
                            SFInputComponent(inputTitle: "Name", username: $name, isSecure: false)
                            // Username
                            SFInputComponent(inputTitle: "Username", username: $username, isSecure: false)
                            // Password
                            SFInputComponent(inputTitle: "Password", username: $password, isSecure: true)
                            SFInputComponent(inputTitle: "Email", username: $email, isSecure: false)
                            DatePicker(selection: $birthDate, in: ...Date(), displayedComponents: .date) {
                                Text("Birthday")
                                    .modifier(CustomTextM(fontName: "MavenPro-Medium", fontSize: 16, fontColor: Color.gray))
                            }
                        }
                        .alert("The \(emptyFieldName) field is empty.", isPresented: $showingEmptyFieldAlert) {
                            Button("OK", role: .cancel) { }
                        }
                        
                        // Login btn
                        Button(action: {
                            signUp()
                        }){
                            Text("SIGN UP")
                                .modifier(CustomTextM(fontName: "MavenPro-Bold", fontSize: 14, fontColor: Color.black))
                                .modifier(SFButton())
                                .background(Color("yellow"))
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
                    
                    
                    //                    }
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
                // SIGN UP
                Button(action: { backToLogin() }) {
                    HStack{
                        Text("Already have an account?")
                        Text("Log in")
                            .modifier(CustomTextM(fontName: "MavenPro-Bold", fontSize: 18, fontColor: Color.primary))
                    }
                    .modifier(CustomTextM(fontName: "MavenPro-Regular", fontSize: 18, fontColor: Color.primary))
                    .foregroundColor(.primary)
                }
                .padding(.bottom, 30)
                
            }
            .offset(x:40)
            
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
    
    func signUp() {
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
            signUpStatus = await User.signUp(username: username, firstName: name, lastName: "L", birthday: dateFormatter.string(from: birthDate), password: password, phoneNumber: "09111111111", email: email)
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
    }
}
