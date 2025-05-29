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


//VISTAS
struct ContentView: View {
@StateObject private var movimientosStore = MovimientosStore()
@Environment(\.managedObjectContext) private var viewContext
@State private var estaLogueado = false
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
                Label("Ingresos/Gastos", systemImage: "plus")
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
            Image("1024")
                .resizable()
                .scaledToFit()
                .offset(y:-20)
            TextField("Usuario", text: $username)
                .textFieldStyle(.roundedBorder)
                .autocapitalization(.none)
                .autocorrectionDisabled()
                .offset(y:-100)
            SecureField("Contraseña", text: $password)
                .textFieldStyle(.roundedBorder)
                .autocapitalization(.none)
                .autocorrectionDisabled()
                .offset(y:-100)
            
            Button("Iniciar sesión"){
                iniciarSesion()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
            .offset(y:-100)
            
            if !mensajeError.isEmpty{
                Text(mensajeError).foregroundColor(.red)
            }
            NavigationLink("Crear cuenta", isActive: $mostrarRegistro){
                RegistroView()
            }
            .padding(.top)
            .offset(y:-100)
        }
        .padding()
        .navigationTitle("Iniciar sesión")
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
        Image("1024")
            .resizable()
            .scaledToFit()
            .offset(y:-20)
        TextField("Usuario", text: $username)
            .textFieldStyle(.roundedBorder)
            .autocapitalization(.none)
            .autocorrectionDisabled()
            .offset(y:-100)
        SecureField("Contraseña", text: $password)
            .textFieldStyle(.roundedBorder)
            .autocapitalization(.none)
            .autocorrectionDisabled()
            .offset(y:-100)
        SecureField("Confirmar Contraseña", text: $confirmarPassword)
            .textFieldStyle(.roundedBorder)
            .autocapitalization(.none)
            .autocorrectionDisabled()
            .offset(y:-100)
        
        Button("Crear cuenta"){
            crearCuenta()
        }
        .padding()
        .background(Color.green)
        .foregroundColor(.white)
        .cornerRadius(8)
        .offset(y:-100)
        
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
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.blue)
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
        .offset(y: 40)
        
        
        .padding()
        .navigationBarHidden(true)
    }
}
}

struct IngresosGastosView: View{
@EnvironmentObject var movimientosStore: MovimientosStore
@Environment(\.dismiss) var dismiss

@State private var monto: String = ""
@State private var referencia: String = ""
@State private var tipo: String = "Ingreso"

let categorias = ["Ingreso", "Deudas", "Entretenimiento", "Comida", "Transporte"]

@State private var errorMensaje: String = ""

var body: some View{
    NavigationView{
        Form{
            Section(header: Text("Monto")){
                TextField("Ejemplo: 1500", text: $monto)
                    .keyboardType(.decimalPad)
            }
            Section(header: Text("Referencia")){
                TextField("Ejemplo: Salario", text: $referencia)
                    .keyboardType(.decimalPad)
            }
            Section(header: Text("Categoria")){
                Picker("Selecciona categoria", selection: $tipo){
                    ForEach(categorias, id: \.self){categoria in
                        Text(categoria)
                    }
                }
                .pickerStyle(.segmented)
            }
            if !errorMensaje.isEmpty{
                Text(errorMensaje)
                    .foregroundColor(.red)
            }
            
            Button("Guardar"){
                guardarMovimiento()
            }
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .navigationTitle("Agregar movimiento")
        .toolbar{
            ToolbarItem(placement: .cancellationAction){
                Button("Cancelar"){
                    dismiss()
                }
            }
        }
    }
}
func guardarMovimiento(){
    guard let montoDouble =  Double(monto), montoDouble != 0 else{
        errorMensaje = "Ingrese un monto valido"
        return
    }
    let montoFinal = tipo == "Ingreso" ? abs(montoDouble) : -abs(montoDouble)
    
    let nuevoMovimiento = Movimiento(
        tipo: tipo,
        monto: montoFinal,
        referencia: referencia,
        fecha: Date()
    )
    movimientosStore.agregarMovimiento(nuevoMovimiento)
    dismiss()
}
}

struct ReportesView: View {
@EnvironmentObject var movimientosStore: MovimientosStore
@State private var datosDePrueba = generarDatosDePrueba()
@State private var intervaloSeleccionado: IntervaloTiempo = .dia


var movimientosFiltrados: [Movimiento] {
    filtrarMovimientosPorIntervalo(movimientosStore.movimientos, intervalo: intervaloSeleccionado)
}

var barras: [Barra] {
    barrasParaMovimientos(movimientosFiltrados, intervalo: intervaloSeleccionado)
}

enum IntervaloTiempo: String, CaseIterable, Identifiable {
    case dia = "Día"
    case mes = "Mes"
    case año = "Año"
    
    var id: String { self.rawValue }
}

// Función de filtrado
func filtrarMovimientosPorIntervalo(_ movimientos: [Movimiento], intervalo: IntervaloTiempo) -> [Movimiento] {
    let calendar = Calendar.current
    let ahora = Date()
    
    return movimientos.filter { mov in
        switch intervalo {
        case .dia:
            return calendar.isDate(mov.fecha, inSameDayAs: ahora)
        case .mes:
            return calendar.isDate(mov.fecha, equalTo: ahora, toGranularity: .month)
        case .año:
            return calendar.isDate(mov.fecha, equalTo: ahora, toGranularity: .year)
        }
    }
}

// Estructura Barra para grafica
struct Barra: Identifiable, Equatable {
    var id = UUID()
    var label: String
    var valor: Double
    var fecha: Date? // Para ordenamiento preciso
}


func barrasParaMovimientos(_ movimientos: [Movimiento], intervalo: IntervaloTiempo) -> [Barra] {
    let calendar = Calendar.current
    let dateFormatter = DateFormatter()
    
    switch intervalo {
    case .dia:
        // Agrupar por hora del día
        dateFormatter.dateFormat = "HH"
        let agrupados = Dictionary(grouping: movimientos) { mov -> String in
            dateFormatter.string(from: mov.fecha)
        }
        
        return agrupados.map { (hora, movs) in
            let total = movs.reduce(0) { $0 + $1.monto }
            return Barra(label: "\(hora):00", valor: total, fecha: movs.first?.fecha)
        }.sorted { $0.label < $1.label }
        
    case .mes:
        // Agrupar por día del mes con formato de fecha completo
        dateFormatter.dateFormat = "dd MMM"
        let agrupados = Dictionary(grouping: movimientos) { mov -> String in
            dateFormatter.string(from: mov.fecha)
        }
        
        return agrupados.map { (dia, movs) in
            let total = movs.reduce(0) { $0 + $1.monto }
            return Barra(label: dia, valor: total, fecha: movs.first?.fecha)
        }.sorted { $0.fecha ?? Date() < $1.fecha ?? Date() }
        
    case .año:
        // Agrupar por mes con nombre completo
        dateFormatter.dateFormat = "MMMM"
        let agrupados = Dictionary(grouping: movimientos) { mov -> String in
            dateFormatter.string(from: mov.fecha)
        }
        
        return agrupados.map { (mes, movs) in
            let total = movs.reduce(0) { $0 + $1.monto }
            return Barra(label: mes, valor: total, fecha: movs.first?.fecha)
        }.sorted { $0.fecha ?? Date() < $1.fecha ?? Date() }
    }
}

var body: some View {
    VStack {
        HeaderReportes()
        
        Picker("Intervalo de tiempo", selection: $intervaloSeleccionado) {
            ForEach(IntervaloTiempo.allCases) { intervalo in
                Text(intervalo.rawValue).tag(intervalo)
            }
        }
        .pickerStyle(.segmented)
        .padding()
        
        Spacer()
        
        // Gráfica con colores y animación
        Chart(barras) { barra in
            BarMark(
                x: .value("Periodo", barra.label),
                y: .value("Monto", barra.valor)
            )
            .foregroundStyle(barra.valor < 0 ? .red : .green)
            .annotation(position: .top) {
                Text(barra.valor, format: .currency(code: "MXN"))
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading)
        }
        .frame(height: 200)
        .padding()
        .animation(.easeInOut, value: barras)
        
        // Lista de movimientos con secciones según el intervalo
        List {
            ForEach(groupedMovimientos, id: \.0) { section, items in
                Section(header: Text(section).font(.headline)) {
                    var sortedItems: [Movimiento]{items.sorted{$0.fecha > $1.fecha}}
                    ForEach(sortedItems) { mov in
                        HStack {
                            Text(mov.tipo)
                            Spacer()
                            Text(mov.monto, format: .currency(code: "MXN"))
                                .foregroundColor(mov.monto < 0 ? .red : .green)
                        }
                    }
                }
            }
        }
        .listStyle(.plain)
    }
    .padding()
}

// Agrupa movimientos para mostrarlos en secciones
private var groupedMovimientos: [(String, [Movimiento])] {
    let calendar = Calendar.current
    let dateFormatter = DateFormatter()
    
    switch intervaloSeleccionado {
    case .dia:
        dateFormatter.dateFormat = "HH:00"
        let grouped = Dictionary(grouping: movimientosFiltrados) { mov -> String in
            dateFormatter.string(from: mov.fecha)
        }
        return grouped.map { ($0.key, $0.value) }.sorted { $0.0 > $1.0 }
        
    case .mes:
        dateFormatter.dateFormat = "dd MMMM"
        let grouped = Dictionary(grouping: movimientosFiltrados) { mov -> String in
            dateFormatter.string(from: mov.fecha)
        }
        return grouped.map { ($0.key, $0.value) }.sorted {
            calendar.date(from: calendar.dateComponents([.day], from: dateFormatter.date(from: $0.0) ?? Date())) ?? Date() >
            calendar.date(from: calendar.dateComponents([.day], from: dateFormatter.date(from: $1.0) ?? Date())) ?? Date()
        }
        
    case .año:
        dateFormatter.dateFormat = "MMMM"
        let grouped = Dictionary(grouping: movimientosFiltrados) { mov -> String in
            dateFormatter.string(from: mov.fecha)
        }
        return grouped.map { ($0.key, $0.value) }.sorted {
            calendar.date(from: calendar.dateComponents([.month], from: dateFormatter.date(from: $0.0) ?? Date())) ?? Date() >
            calendar.date(from: calendar.dateComponents([.month], from: dateFormatter.date(from: $1.0) ?? Date())) ?? Date()
        }
    }
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

struct DonutChartView: View {
var categorias: [CategoriaGasto]
var total: Double{
    categorias.reduce(0){$0 + abs($1.monto)}
}
var body: some View {
    HStack(alignment: .center){
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
        
        VStack(alignment: .leading, spacing: 5){
            ForEach(categorias) { categoria in
                HStack(alignment: .center){
                    RoundedRectangle(cornerRadius: 4)
                        .fill(categoria.color)
                        .frame(width: 20, height: 10)
                    Text(categoria.nombre)
                        .font(.headline)
                        .foregroundColor(.black)
                        .onAppear{print("Categoria: \(categoria.nombre)")}
                }
                
                
            }
        }
        .frame(width: 200)
    }
    .offset(x: 100, y: -50)
    
    
}
}

struct Movimiento: Identifiable{
let id = UUID()
let tipo: String
let monto: Double
let referencia: String
let fecha: Date

init(tipo: String, monto: Double, referencia: String, fecha: Date) {
    self.tipo = tipo
    self.monto = monto
    self.referencia = referencia
    self.fecha = fecha
}

}

struct CategoriaGasto: Identifiable{
let id = UUID()
let nombre: String
let monto: Double
let color: Color
}

class MovimientosStore: ObservableObject{
@Published var movimientos : [Movimiento] = [
    Movimiento(tipo: "Comida", monto: -150, referencia: "McDonalds", fecha: Date()),
    Movimiento(tipo: "Comida", monto: -150, referencia: "Starbucks", fecha: Date()),
    Movimiento(tipo: "Entretenimiento", monto: -200, referencia: "Cine", fecha: Date()),
    Movimiento(tipo: "Transporte", monto: -200, referencia: "CU", fecha: Date()),
    Movimiento(tipo: "Transporte", monto: -200, referencia: "Novia", fecha: Date()),
    Movimiento(tipo: "Deuda", monto: -1500, referencia: "Elektra", fecha: Date()),
    Movimiento(tipo: "Ingreso", monto: 1500, referencia: "Tanda", fecha: Date()),
    Movimiento(tipo: "Ingreso", monto: 1500, referencia: "Utilidades", fecha: Date()),
    Movimiento(tipo: "Ingreso", monto: 1500, referencia: "Salario", fecha: DateFormatter.customDate(from: "2025-05-25")),
    Movimiento(tipo: "Entretenimiento", monto: -200, referencia: "HBO", fecha: DateFormatter.customDate(from: "2025-05-20")),
    Movimiento(tipo: "Comida", monto: -500, referencia: "KFC", fecha: DateFormatter.customDate(from: "2025-05-27")),
    Movimiento(tipo: "Deuda", monto: -3500, referencia: "Terreno", fecha: DateFormatter.customDate(from: "2025-05-05")),
    Movimiento(tipo: "Ingreso", monto: 1500, referencia: "Salario", fecha: DateFormatter.customDate(from: "2025-05-15")),
    Movimiento(tipo: "Entretenimiento", monto: -250, referencia: "Netflix", fecha: DateFormatter.customDate(from: "2025-04-25")),
    Movimiento(tipo: "Ingreso", monto: 1500, referencia: "Salario", fecha: DateFormatter.customDate(from: "2025-03-25"))
]
func agregarMovimiento(_ movimiento: Movimiento){
    movimientos.append(movimiento)
}
func eliminarMovimiento(id: UUID){
    movimientos.removeAll{$0.id == id}
}
}

class SessionManager: ObservableObject{
@Binding var estaLogueado: Bool

init(estaLogueado: Binding<Bool>){
    self._estaLogueado = estaLogueado
}
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

extension DateFormatter{
static func customDate(from string: String)->Date{
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter.date(from: string) ?? Date()
}

}




#Preview {
ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    .environmentObject(MovimientosStore())
}
