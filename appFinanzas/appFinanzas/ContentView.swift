//
//  ContentView.swift
//  appFinanzas
//
//  Created by Alumno on 19/05/25.
//

import SwiftUI
import CoreData
import Combine
import Charts

struct Movimiento: Identifiable{
    let id = UUID()
    let tipo: String
    let monto: Double
    let referencia: String
    let fecha: Date
}

struct CategoriaGasto: Identifiable{
    let id = UUID()
    let nombre: String
    let monto: Double
    let color: Color
}

func calcularPorcentajePorCadaCategoria(movimientos: [Movimiento]) -> [CategoriaGasto]{
    //Filtra solo gastos
    let gastos = movimientos.filter{$0.monto < 0}
    
    //Agrupa y suma por categoria
    let sumaCategorias = Dictionary(grouping: gastos, by: {$0.tipo})
        .mapValues{$0.reduce(0){$0 + $1.monto}}
    let totalGastos = sumaCategorias.values.reduce(0) {$0 + abs($1)}
    let colores: [Color] = [.red, .orange, .blue, .green, .purple, .pink, .yellow]
    var categoriasGasto: [CategoriaGasto] = []
    
    for (index, (nombre, monto)) in sumaCategorias.enumerated(){
        let color = colores[index % colores.count]
        categoriasGasto.append(
            CategoriaGasto(
                nombre: nombre ?? "Sin categoria",
                monto: monto,
                color: color
            )
        )
    }
    return categoriasGasto
}

struct DonutChartView: View {
    var categorias: [CategoriaGasto]
    var total: Double{
        categorias.reduce(0){$0 + abs($1.monto)}
    }
    var body: some View {
        HStack{
            Spacer()
            Spacer()
            Spacer()
            Spacer()
            Spacer()
            Spacer()
            Spacer()
            Spacer()
            Spacer()
            Chart{
                ForEach(categorias){categoria in
                    SectorMark(
                        angle: .value("Monto", abs(categoria.monto)),
                        innerRadius: .ratio(0.45),
                        angularInset: 1.0
                    )
                    .foregroundStyle(categoria.color)
                    .annotation(position: .overlay){
                        let porcentaje = abs(categoria.monto)/total * 100
                        Text("\(Int(porcentaje))%")
                            .font(.caption2)
                            .foregroundColor(.white)
                            .bold()
                    }
                }
            }
            .frame(width: 150, height: 200)
            Spacer()
            Spacer()
            Spacer()
            Spacer()
            VStack(alignment: .leading, spacing: 12){
                ForEach(categorias) { categoria in
                    HStack{
                        RoundedRectangle(cornerRadius: 4)
                            .fill(categoria.color)
                            .frame(width: 20, height: 10)
                        Spacer()
                        Text(categoria.nombre)
                            .font(.headline)
                            .foregroundColor(.black)
                            .onAppear{print("Categoria: \(categoria.nombre)")}
                    }
                }
            }
        }
        
    }
}


class MovimientosStore: ObservableObject{
    @Published var movimientos : [Movimiento] = [
        Movimiento(tipo: "Comida", monto: -150, referencia: "McDonalds", fecha: Date()),
        Movimiento(tipo: "Comida", monto: -150, referencia: "McDonalds", fecha: Date()),
        Movimiento(tipo: "Entretenimiento", monto: -200, referencia: "Cine", fecha: Date()),
        Movimiento(tipo: "Transporte", monto: -200, referencia: "Cine", fecha: Date()),
        Movimiento(tipo: "Transporte", monto: -200, referencia: "Cine", fecha: Date()),
        Movimiento(tipo: "Ingreso", monto: 1500, referencia: "Salario", fecha: Date())
    ]
    func agregarMovimiento(_ movimiento: Movimiento){
        movimientos.append(movimiento)
    }
    func eliminarMovimiento(id: UUID){
        movimientos.removeAll{$0.id == id}
    }
}

struct ContentView: View {
    @StateObject private var movimientosStore = MovimientosStore()
    @Environment(\.managedObjectContext) private var viewContext
    @State private var estaLogueado = true
    @AppStorage("usuarioLogueado") var usuarioLogueado: String = ""
    
    var body: some View {
        if estaLogueado{
            MainTabView(estaLogueado: $estaLogueado)
                .environmentObject(MovimientosStore())
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
        .environmentObject(SessionManager(estaLogueado: $estaLogueado))
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
    @EnvironmentObject var movimientosStore: MovimientosStore
    
    var saldoTotal: Double {
        movimientosStore.movimientos.reduce(0) {$0 + $1.monto}
    }
    
    var movimientosOrdenados: [Movimiento]{
        movimientosStore.movimientos.sorted{$0.fecha > $1.fecha}
    }
    
    var categoriasGasto: [CategoriaGasto]{
        calcularPorcentajePorCadaCategoria(movimientos: movimientosStore.movimientos)
    }
    
    
    var body: some View{
        NavigationView{
            VStack(alignment: .leading){
                HStack(alignment: .top){
                    NavigationLink(destination: ConfiguracionUsuarioView()){
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
                        
                    }
                    
                }
                Text("Saldo total: \(saldoTotal, format: .currency(code: "MXN"))")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding()
                    
                List(movimientosOrdenados){mov in
                    HStack{
                        VStack(alignment: .leading){
                            Text(mov.tipo)
                                .font(.headline)
                            Text(mov.referencia)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        Text(mov.monto, format: .currency(code: "MXN"))
                            .foregroundColor(mov.monto < 0 ? .red : .green)
                    }
                        
                }
                .frame(height: 250)
                Text("Gasto mensual actual")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
                DonutChartView(categorias: categoriasGasto)
                    .frame(width: 150, height: 250)
            
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
}
   struct ConfiguracionUsuarioView: View {
    @AppStorage("usuarioLogueado") var usuarioLogueado: String = ""
    @EnvironmentObject var session: SessionManager
    
    var body: some View {
        VStack(spacing: 40){
            Text("Configuración de usuario")
                .font(.title)
                .padding()
            Spacer()
            
            Button(role: .destructive){
                cerrarSesion()
            } label: {
                Text("Cerrar sesión")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .cornerRadius(10)
                    .padding(.horizontal)
            }
            Spacer()
        }
    }
    func cerrarSesion(){
        usuarioLogueado = ""
        session.estaLogueado = false
    }
}

class SessionManager: ObservableObject{
    @Binding var estaLogueado: Bool
    
    init(estaLogueado: Binding<Bool>){
        self._estaLogueado = estaLogueado
    }
}




#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        .environmentObject(MovimientosStore())
}
