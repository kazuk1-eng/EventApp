import SwiftUI
import Combine

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @State private var isShowingLoginSheet = false
    
    var body: some View {
        VStack {
            if viewModel.isLoggedIn {
                VStack(spacing: 20) {
                    VStack(spacing: 10) {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(ContentView.primaryColor)
                        
                        Text(viewModel.user?.username ?? "ユーザー")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text(viewModel.user?.email ?? "")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding()
                    
                    List {
                        Section(header: Text("アカウント設定")) {
                            Button(action: {
                            }) {
                                HStack {
                                    Image(systemName: "person")
                                    Text("プロフィール編集")
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.gray)
                                }
                            }
                            
                            Button(action: {
                            }) {
                                HStack {
                                    Image(systemName: "bell")
                                    Text("通知設定")
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        
                        Section(header: Text("イベント")) {
                            NavigationLink(destination: ScheduleView()) {
                                HStack {
                                    Image(systemName: "calendar")
                                    Text("スケジュール")
                                }
                            }
                            
                            NavigationLink(destination: FavoritesView()) {
                                HStack {
                                    Image(systemName: "heart")
                                    Text("お気に入り")
                                }
                            }
                        }
                        
                        Section(header: Text("アプリ情報")) {
                            Button(action: {
                            }) {
                                HStack {
                                    Image(systemName: "info.circle")
                                    Text("このアプリについて")
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.gray)
                                }
                            }
                            
                            Button(action: {
                            }) {
                                HStack {
                                    Image(systemName: "questionmark.circle")
                                    Text("ヘルプ")
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        
                        Section {
                            Button(action: {
                                viewModel.logout()
                            }) {
                                HStack {
                                    Spacer()
                                    Text("ログアウト")
                                        .foregroundColor(.red)
                                    Spacer()
                                }
                            }
                        }
                    }
                    .listStyle(InsetGroupedListStyle())
                }
            } else {
                VStack(spacing: 20) {
                    Spacer()
                    
                    Image(systemName: "person.crop.circle.badge.questionmark")
                        .font(.system(size: 80))
                        .foregroundColor(.gray)
                    
                    Text("ログインしていません")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("ログインするとイベントのお気に入り登録やスケジュール管理ができます")
                        .font(.body)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Button(action: {
                        isShowingLoginSheet = true
                    }) {
                        Text("ログイン / 新規登録")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(ContentView.primaryColor)
                            .cornerRadius(10)
                            .padding(.horizontal)
                    }
                    
                    Spacer()
                }
                .padding()
                .sheet(isPresented: $isShowingLoginSheet) {
                    LoginView(isPresented: $isShowingLoginSheet)
                }
            }
        }
        .navigationTitle("プロフィール")
        .onAppear {
            viewModel.checkLoginStatus()
        }
    }
}

struct ScheduleView: View {
    @StateObject private var viewModel = ScheduleViewModel()
    
    var body: some View {
        VStack {
            if viewModel.isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(1.5)
                    .padding()
            } else if viewModel.scheduledEvents.isEmpty {
                VStack {
                    Image(systemName: "calendar.badge.exclamationmark")
                        .font(.system(size: 50))
                        .foregroundColor(.gray)
                        .padding()
                    
                    Text("スケジュールが空です")
                        .font(.headline)
                    
                    Text("イベントをスケジュールに追加すると、ここに表示されます")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Button(action: {
                    }) {
                        Text("イベントを探す")
                            .padding()
                            .background(ContentView.primaryColor)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding()
                }
                .padding()
            } else {
                List {
                    ForEach(viewModel.scheduledEvents) { event in
                        NavigationLink(destination: EventDetailView(eventId: event.id)) {
                            EventRowView(event: event)
                        }
                    }
                }
                .listStyle(PlainListStyle())
            }
        }
        .navigationTitle("スケジュール")
        .onAppear {
            viewModel.loadScheduledEvents()
        }
    }
}

struct LoginView: View {
    @Binding var isPresented: Bool
    @StateObject private var viewModel = LoginViewModel()
    @State private var isShowingRegistration = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "calendar.badge.clock")
                    .font(.system(size: 70))
                    .foregroundColor(ContentView.primaryColor)
                    .padding(.top, 50)
                
                Text("東京週末イベント")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("ログインして全ての機能を利用しましょう")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.bottom, 30)
                
                VStack(spacing: 15) {
                    TextField("メールアドレス", text: $viewModel.email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                        .padding(.horizontal)
                    
                    SecureField("パスワード", text: $viewModel.password)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                        .padding(.horizontal)
                    
                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                            .padding(.horizontal)
                    }
                    
                    Button(action: {
                        viewModel.login()
                    }) {
                        Text("ログイン")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(ContentView.primaryColor)
                            .cornerRadius(10)
                            .padding(.horizontal)
                    }
                    .disabled(viewModel.isLoading)
                    .opacity(viewModel.isLoading ? 0.5 : 1)
                    .overlay(
                        Group {
                            if viewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                                    .foregroundColor(.white)
                            }
                        }
                    )
                }
                
                Divider()
                    .padding(.vertical)
                
                Button(action: {
                    isShowingRegistration = true
                }) {
                    Text("アカウントをお持ちでない方は新規登録")
                        .foregroundColor(ContentView.primaryColor)
                }
                
                Spacer()
            }
            .padding()
            .navigationBarItems(trailing: Button("閉じる") {
                isPresented = false
            })
            .sheet(isPresented: $isShowingRegistration) {
                RegisterView(isPresented: $isShowingRegistration)
            }
            .onChange(of: viewModel.isLoggedIn) { isLoggedIn in
                if isLoggedIn {
                    isPresented = false
                }
            }
        }
    }
}

struct RegisterView: View {
    @Binding var isPresented: Bool
    @StateObject private var viewModel = RegisterViewModel()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "person.badge.plus")
                    .font(.system(size: 70))
                    .foregroundColor(ContentView.primaryColor)
                    .padding(.top, 50)
                
                Text("新規アカウント登録")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("アカウントを作成して全ての機能を利用しましょう")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.bottom, 30)
                
                VStack(spacing: 15) {
                    TextField("ユーザー名", text: $viewModel.username)
                        .autocapitalization(.none)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                        .padding(.horizontal)
                    
                    TextField("メールアドレス", text: $viewModel.email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                        .padding(.horizontal)
                    
                    SecureField("パスワード", text: $viewModel.password)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                        .padding(.horizontal)
                    
                    SecureField("パスワード（確認）", text: $viewModel.confirmPassword)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                        .padding(.horizontal)
                    
                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                            .padding(.horizontal)
                    }
                    
                    Button(action: {
                        viewModel.register()
                    }) {
                        Text("登録")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(ContentView.primaryColor)
                            .cornerRadius(10)
                            .padding(.horizontal)
                    }
                    .disabled(viewModel.isLoading)
                    .opacity(viewModel.isLoading ? 0.5 : 1)
                    .overlay(
                        Group {
                            if viewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                                    .foregroundColor(.white)
                            }
                        }
                    )
                }
                
                Spacer()
            }
            .padding()
            .navigationBarItems(trailing: Button("閉じる") {
                isPresented = false
            })
            .onChange(of: viewModel.isRegistered) { isRegistered in
                if isRegistered {
                    isPresented = false
                }
            }
        }
    }
}


class ProfileViewModel: ObservableObject {
    @Published var isLoggedIn = false
    @Published var user: User?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    
    func checkLoginStatus() {
        isLoading = true
        
        APIService.shared.getCurrentUser()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                
                if case .failure(let error) = completion {
                    self?.isLoggedIn = false
                    self?.user = nil
                    
                    if error != .unauthorized {
                        self?.errorMessage = error.localizedDescription
                    }
                }
            }, receiveValue: { [weak self] user in
                self?.isLoggedIn = true
                self?.user = user
            })
            .store(in: &cancellables)
    }
    
    func logout() {
        isLoading = true
        
        APIService.shared.logout()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                self?.isLoggedIn = false
                self?.user = nil
                
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            }, receiveValue: { _ in })
            .store(in: &cancellables)
    }
}

class ScheduleViewModel: ObservableObject {
    @Published var scheduledEvents: [Event] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    
    func loadScheduledEvents() {
        isLoading = true
        errorMessage = nil
        
        APIService.shared.fetchSchedule()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            }, receiveValue: { [weak self] events in
                self?.scheduledEvents = events
            })
            .store(in: &cancellables)
    }
}

class LoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isLoggedIn = false
    
    private var cancellables = Set<AnyCancellable>()
    
    func login() {
        guard !email.isEmpty else {
            errorMessage = "メールアドレスを入力してください"
            return
        }
        
        guard !password.isEmpty else {
            errorMessage = "パスワードを入力してください"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        APIService.shared.login(email: email, password: password)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            }, receiveValue: { [weak self] _ in
                self?.isLoggedIn = true
            })
            .store(in: &cancellables)
    }
}

class RegisterViewModel: ObservableObject {
    @Published var username = ""
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isRegistered = false
    
    private var cancellables = Set<AnyCancellable>()
    
    func register() {
        guard !username.isEmpty else {
            errorMessage = "ユーザー名を入力してください"
            return
        }
        
        guard !email.isEmpty else {
            errorMessage = "メールアドレスを入力してください"
            return
        }
        
        guard !password.isEmpty else {
            errorMessage = "パスワードを入力してください"
            return
        }
        
        guard password == confirmPassword else {
            errorMessage = "パスワードが一致しません"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        APIService.shared.register(username: username, email: email, password: password)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            }, receiveValue: { [weak self] _ in
                self?.isRegistered = true
            })
            .store(in: &cancellables)
    }
}


struct User: Codable, Identifiable {
    let id: Int
    let username: String
    let email: String
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ProfileView()
        }
    }
}
