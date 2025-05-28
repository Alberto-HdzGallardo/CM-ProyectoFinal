//
//  ContentView.swift
//  appFinanzas
//
//  Created by Alumno on 19/05/25.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var estaLogueado = true
    @AppStorage("usuarioLogueado") var usuarioLogueado: String = ""

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>

    var body: some View {
        if estaLogueado{
            MainTabView(estaLogueado: $estaLogueado)
        }else{
            LoginView(estaLogueado: $estaLogueado)
        }
        
    }
}

struct MainTabView: View{
    @Binding var estaLogueado: Bool
    
    var body: some View{
        TabView{
            HomeView()
                .tabItem{
                    Label("Home", systemImage: "house")
                }
            IngresosGastosView()
                .tabItem{
                    Label("Ingresos/Gastos", systemImage: "chart.bar.fill")
                }
            ReportesView()
                .tabItem{
                    Label("Reportes", systemImage: "chart.bar.fill")
                }
            MarketExchangeView()
                .tabItem{
                    Label("Market Exchange", systemImage: "chart.xyaxis.line")
                }
        }
        .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
        //.environmentObject(SessionManager(estaLogueado: $estaLogueado))
    }
}

struct LoginView: View{
    @Environment(\.managedObjectContext) private var viewContext
    @AppStorage("usuarioLogueado") var usuarioLogueado: String = ""
    
    @State private var username = ""
    @State private var password = ""
    @State private var mostrarRegistro = false
    @State private var mensajeError = ""
    
    @Binding var estaLogueado: Bool
    
    var body: some View{
        NavigationView{
            VStack(spacing: 20){
                TextField("Usuario", text: $username)
                    .textFieldStyle(.roundedBorder)
                    .autocapitalization(.none)
                    .autocorrectionDisabled()
                SecureField("Contraseña", text: $password)
                    .textFieldStyle(.roundedBorder)
                    .autocapitalization(.none)
                    .autocorrectionDisabled()
                
                Button("Iniciar sesión"){
                    iniciarSesion()
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
                
                if !mensajeError.isEmpty{
                    Text(mensajeError).foregroundColor(.red)
                }
                NavigationLink("Crear cuenta", isActive: $mostrarRegistro){
                    RegistroView()
                }
                .padding(.top)
            }
            .padding()
            .navigationTitle("Login")
        }
    }
    func iniciarSesion(){
        let fetchRequest: NSFetchRequest<Usuario> = Usuario.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "username == %@ AND password == %@", username, password)
        do{
            let resultados = try viewContext.fetch(fetchRequest)
            if let usuario = resultados.first{
                mensajeError = ""
                usuarioLogueado = usuario.username ?? ""
                estaLogueado = true
                print("Usuario autenticado")
            }else{
                mensajeError = "Usuario o contraseña incorrectos"
            }
        }catch{
            mensajeError = "Error al verificar usuario"
        }
    }
}

struct RegistroView: View{
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    
    @State private var username = ""
    @State private var password = ""
    @State private var confirmarPassword = ""
    @State private var mensajeError = ""
    
    var body: some View{
        VStack(spacing: 20){
            TextField("Usuario", text: $username)
                .textFieldStyle(.roundedBorder)
                .autocapitalization(.none)
                .autocorrectionDisabled()
            SecureField("Contraseña", text: $password)
                .textFieldStyle(.roundedBorder)
                .autocapitalization(.none)
                .autocorrectionDisabled()
            SecureField("Confirmar Contraseña", text: $confirmarPassword)
                .textFieldStyle(.roundedBorder)
                .autocapitalization(.none)
                .autocorrectionDisabled()
            
            Button("Crear cuenta"){
                crearCuenta()
            }
            .padding()
            .background(Color.green)
            .foregroundColor(.white)
            .cornerRadius(8)
            
            if !mensajeError.isEmpty{
                Text(mensajeError).foregroundColor(.red)
            }
        }
        .padding()
        .navigationTitle("Registro")
    }
    func crearCuenta(){
        guard !username.isEmpty, !password.isEmpty else{
            mensajeError = "Rellena todos los campos"
            return
        }
        guard password == confirmarPassword else{
            mensajeError = "Las contraseñas no coinciden"
            return
        }
        
        //Validar si el usuario ya existe
        let fetchRequest: NSFetchRequest<Usuario> = Usuario.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "username == %@",username)
        
        do{
            let resultados = try viewContext.fetch(fetchRequest)
            if resultados.count > 0{
                mensajeError = "El usuario ya existe"
                return
            }
            
            //Crear nuevo ususario
            let nuevoUsuario = Usuario(context: viewContext)
            nuevoUsuario.username = username
            nuevoUsuario.password = password
            
            try viewContext.save()
            mensajeError = ""
            presentationMode.wrappedValue.dismiss()
        }catch{
            mensajeError = "Error al crear ususario"
        }
    }
}

struct HomeView: View{
    @AppStorage("usuarioLogueado") var usuarioLogueado: String = "Usuario"
    
    var body: some View{
        NavigationView{
            HStack(alignment: .top){
                NavigationLink(destination: ReportesView()){
                    Circle()
                        .fill(Color.purple.opacity(0.3))
                        .frame(width: 80, height: 80)
                        .overlay(
                            Image(systemName: "person.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 40)
                                .foregroundColor(.purple)
                        )
                        .padding(.leading)
                }
                VStack(alignment: .leading){
                    Text("Bienvenido")
                        .font(.title3)
                    Text(usuarioLogueado)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                    Spacer()
                }
                
            }
            .padding()
            .navigationBarHidden(true)
        }
    }
}

struct IngresosGastosView: View{
    var body: some View{
        Text("Ingresos/Gastos").font(.largeTitle)
    }
}

struct ReportesView: View{
    var body: some View{
        Text("Reportes").font(.largeTitle)
    }
}

struct MarketExchangeView: View{
    @StateObject private var stocksVM: StocksViewModel = StocksViewModel()
       
       @State private var isShowingStockSearchSheet: Bool = false
       
       var body: some View {
           
           VStack {
               
               HeaderView(showSheet: $isShowingStockSearchSheet)
               
               PortfolioCard(stocksVM: stocksVM)
               
               WatchlistView(stocksVM: stocksVM)
               
               
               
               Spacer()
           }
           .padding()
           .edgesIgnoringSafeArea(.bottom)
           .sheet(isPresented: $isShowingStockSearchSheet) {
               SearchStockView()
           }
        

           
           
       }
   }




#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
