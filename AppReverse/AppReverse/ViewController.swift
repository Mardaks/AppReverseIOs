//
//  ViewController.swift
//  AppReverse
//
//  Created by DISEÑO on 14/12/24.
//

import UIKit
import CoreData

class ViewController: UIViewController {

    //componentes
    @IBOutlet weak var txtUsername: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //bloquea la visualizacion del txtPassword
        txtPassword.isSecureTextEntry = true
    }
    
    //conecta a la bd
    func connectBD() -> NSManagedObjectContext {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        return delegate.persistentContainer.viewContext
    }
    
    //funcion para iniciar sesion
    func validateLogin() {
        let context = connectBD() //conectamos con la bd
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "username == %@ AND password == %@", txtUsername.text ?? "", txtPassword.text ?? "") //validamos el username y password con la bd
        
        do {
            let user = try context.fetch(fetchRequest)
            if let user = user.first {
                (UIApplication.shared.delegate as! AppDelegate).loggedInUser = user //almacenamos el usuario que inicia sesion
                print("Inicio de sesion exitoso")
                goToMenu() // cambia de ventan al menu
            } else {
                showAlert(message: "Usuario o contrasenia incorrecta")
                print("Credenciales invalidas")
            }
        }catch {
            print("Error al validar login: \(error)")
        }
    }
    
    //funcion para las alertas
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
    
    //funcion para ir al registrar usuario
    func goToRegisterUser(){
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let viewcontroller = storyboard.instantiateViewController(withIdentifier: "RegisterViewController") as? RegisterViewController
        self.navigationController?.pushViewController(viewcontroller ?? ViewController(), animated: true)
    }
    
    //boton login
    @IBAction func btnLogin(_ sender: Any) {
        validateLogin()
    }
    
    //boton registrar
    @IBAction func btnRegister(_ sender: Any) {
        goToRegisterUser()
    }
}
