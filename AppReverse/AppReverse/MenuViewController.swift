import UIKit
import CoreData

class MenuViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    //Componentes
    @IBOutlet weak var txtRoom: UITextField! //txt para mostrar el nro de salon
    @IBOutlet weak var datePiker: UIDatePicker! //Selector de fecha y hora para la reserva
    
    //Variables
    let pickerView = UIPickerView() //PickerView para seleccionar el numero del salon
    let rooms = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15"] //array de los numeros de salones
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true //quitamos el boton back del navigation
        
        //Configuracion del DatePicker
        datePiker.datePickerMode = .dateAndTime
        datePiker.minimumDate = Date() //La fecha minima es la actual
        datePiker.addTarget(self, action: #selector(datePickerChanged), for: .valueChanged)
        
        //configuramos el UIPickerView
        pickerView.delegate = self
        pickerView.dataSource = self
        txtRoom.inputView = pickerView
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
    }
    
    //Conecta a la bd
    func connectBD() -> NSManagedObjectContext {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        return delegate.persistentContainer.viewContext
    }
    
    //Funcion para limpiar el txt
    func clearTxt() {
        txtRoom.text = ""
    }
    
    //funcion para mostrar alertas
    func showAlert(title: String, message: String, completion: ((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        let okAction = UIAlertAction(
            title: "OK",
            style: .default,
            handler: completion
        )
        alert.addAction(okAction)
        present(alert, animated: true)
    }
    
    //Funcion para verificar si ya hay una reserva en una fecha especifica
    func checkExistingReservation(room: Int32, date: Date) -> Bool {
        let context = connectBD()
        let fetchRequest : NSFetchRequest<Reverse> = Reverse.fetchRequest()
        
        //Configuracion para el rango de fecha para la validacion (todo el dia)
        let calendar = Calendar.current
        let dateFrom = calendar.startOfDay(for: date)
        let dateTo = calendar.date(byAdding: .day, value: 1, to: dateFrom)!
        
        //Crear el predicado para buscar las reservas registradas
        let predicate = NSPredicate(format: "room == %d AND date >= %@ AND date < %@", room, dateFrom as NSDate, dateTo as NSDate)
        
        fetchRequest.predicate = predicate
        
        do{
            let count = try context.count(for: fetchRequest)
            return count > 0
        } catch {
            print("Error al verificar reservas existentes: \(error.localizedDescription)")
            return false
        }
    }
    
    //Funcion para validar el numero de la sala
    func isValidRoomNumber(_ room: Int32) -> Bool {
        return room > 0 && room <= 15
    }
    
    //Funcion para registrar una reserva
    func saveReverse() {
        //Validacion del numero de salon
        guard let roomText = txtRoom.text, let roomNumber = Int32(roomText) else { //Conversion segura del texto a numero
            showAlert(title: "Error", message: "Por favor selecciona un salon valido")
            return
        }
        
        guard isValidRoomNumber(roomNumber) else { //Validar que el numero sea desde el 1 al 15
            showAlert(title: "Error", message: "El numero de salon debe ser desde 1 al 15")
            return
        }
        
        let selectedDate = datePiker.date //Obtener fecha del datePicker
        
        // Verificar si ya existe una reserva disponible
        if checkExistingReservation(room: roomNumber, date: selectedDate) {
            showAlert(
                title: "Reserva No Disponible",
                message: "La habitación \(roomNumber) ya está reservada para esta fecha"
            )
            return
        }
        
        //Registro de la reserva
        let context = connectBD()
        let reservation = Reverse(context: context)
        reservation.room = roomNumber
        reservation.date = selectedDate
        reservation.user = (UIApplication.shared.delegate as! AppDelegate).loggedInUser //Unimos la reserva con el usuario que esta logeado
        
        do {
            try context.save()
            showAlert(
                title: "Éxito",
                message: "Reserva registrada correctamente"
            ) { [weak self] _ in
                self?.goToList()
            }
        } catch let error as NSError {
            print("Error al guardar datos: \(error.localizedDescription)")
            showAlert(title: "Error", message: "No se pudo guardar la reserva")
        }
    }
    
    //Funcion para navegar a la vista del Listado de Reservas
    func goToList() {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let viewcontroller = storyboard.instantiateViewController(withIdentifier: "ListadoViewController") as? ListadoViewController
        self.navigationController?.pushViewController(viewcontroller ?? MenuViewController(), animated: true)
    }
    
    //Funcion para la configuracion del datePicker
    @objc func datePickerChanged() {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
    }
    
    //Boton registrar
    @IBAction func btnRegister(_ sender: Any) {
        saveReverse()
        clearTxt()
    }
    
    //Boton ver listado
    @IBAction func btnViewList(_ sender: Any) {
        goToList()
        clearTxt()
    }
    
    //Boton para cerrar sesion
    @IBAction func btnLogOut(_ sender: Any) {
        let alerController = UIAlertController(title: "Cerrar sesion", message: "Esta seguro que desear cerrar sesion?", preferredStyle: .alert) //Mostramos una alerta antes de cerrar sesion
        
        let cancelaAction = UIAlertAction(title: "Cancelar", style: .cancel)
        
        let confirmAction = UIAlertAction(title: "Confirmar", style: .destructive) { [weak self] _ in
            
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                appDelegate.loggedInUser = nil //Limpiamos la informacion del usuario actual
            }
            
            //Regresamos a la pantalla de inicio de sesion
            if let loginVC = self?.storyboard?.instantiateViewController(withIdentifier: "ViewController") {
                let navigationController = UINavigationController(rootViewController: loginVC)
                navigationController.modalPresentationStyle = .fullScreen
                        
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let window = windowScene.windows.first {
                    window.rootViewController = navigationController
                    window.makeKeyAndVisible()
                }
            }
        }
        alerController.addAction(cancelaAction)
        alerController.addAction(confirmAction)
        present(alerController, animated: true)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return rooms.count
    }
    
    //Funcion para mostrar texto en las filas del pickerView
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return rooms[row]
    }
    
    //Funcion para manejar la seleccion del pickerView
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        txtRoom.text = rooms[row] //Actualizamos el texto con el salon seleccionado
        txtRoom.resignFirstResponder() //Cierra el picker
    }
}
