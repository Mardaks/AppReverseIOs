import UIKit
import CoreData

class RegisterViewController: UIViewController {

    //componentes
    @IBOutlet weak var txtUsername: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var txtConfirmPassword: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        txtPassword.isSecureTextEntry = true //bloqueamos la vista del txtPassword
        txtConfirmPassword.isSecureTextEntry = true //bloqueamos la vista del txtConfirmPassword
    }
    
    //funcion para conectar a la bd
    func connectBD() -> NSManagedObjectContext {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        return delegate.persistentContainer.viewContext
    }
    
    //funcion para mostar alerta
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Aviso", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    //funcion para ir al menu
    func goToMenu() {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let viewcontroller = storyboard.instantiateViewController(withIdentifier: "MenuViewController") as? MenuViewController
        self.navigationController?.pushViewController(viewcontroller ?? ViewController(), animated: true)
    }
    
    //funcion para ir al menu
    func goToLogin() {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let viewcontroller = storyboard.instantiateViewController(withIdentifier: "ViewController") as? ViewController
        self.navigationController?.pushViewController(viewcontroller ?? ViewController(), animated: true)
    }
    
    //funcion para registrar un usuario
    func registerUser(username: String, password: String) {
        let context = connectBD() //conectamos a la bd
        let user = User(context: context)
        user.username = username
        user.password = password
        
        do {
            try context .save()
            print("Usuario registrado exitosamente")
            (UIApplication.shared.delegate as! AppDelegate).loggedInUser = user //almacenamos el usuario que se registro
            goToMenu() //cambimos de vista al menu
        } catch {
            print("Error al guardar: \(error.localizedDescription)")
            showAlert(message: "Error al registrar usuario")
        }
    }
    
    //funcion para validar si el usuario ya esta registrado
    func checkUserExists(username: String) -> Bool {
        let context = connectBD()
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "username == %@", username) //comparamos el username en la bd
        
        do {
            let count = try context.count(for: fetchRequest)
            return count > 0 //si no hay ningun registro del usernama en la bd pasa la validacion
        } catch {
            print("Error verificando usuario: \(error.localizedDescription)")
            return false
        }
    }
    
    @IBAction func btnRegister(_ sender: Any) {
        //validamos que tenga los campos completos
        guard let username = txtUsername.text, !username.isEmpty,
              let password = txtPassword.text, !password.isEmpty,
              let confirmPassword = txtConfirmPassword.text, !confirmPassword.isEmpty else {
            showAlert(message: "Todos los campos son requeridos")
            return
        }
        
        //validamos que el confirmPassword sea igual al password
        guard password == confirmPassword else {
            showAlert(message: "Las contrasenias no coinciden")
            return
        }
        
        //validamos si el usuario ya esta registrado
        if checkUserExists(username: username) {
            showAlert(message: "El usuario ya existe")
            return
        }
        
        registerUser(username: username, password: password) //registramos al usuario
    }
    
    @IBAction func btnBack(_ sender: Any) {
        goToLogin()
    }
}
