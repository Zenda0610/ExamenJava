package com.mycompany.proyectojava;

import com.mycompany.proyectojava.common.Utils;
import com.mycompany.proyectojava.inventory.view.InventoryView;
import com.mycompany.proyectojava.inventory.controller.StockExpiryScheduler;
import com.mycompany.proyectojava.suppliers.view.SupplierView;
import com.mycompany.proyectojava.sales.view.SalesView;
import com.mycompany.proyectojava.logistics.view.LogisticsView;

public class ProyectoJava {

    public static void main(String[] args) {
        Utils.configurarConsola();
        try (var scheduler = StockExpiryScheduler.start()) {
            showMainMenu();
        }
    }

    private static void showMainMenu() {
        int opcion;

        do {
            Utils.imprimirTitulo("ERP FRESCURA TOTAL");
            System.out.println("1. Inventarios y calidad");
            System.out.println("2. Proveedores y compras");
            System.out.println("3. Ventas y facturación");
            System.out.println("4. Logística y entregas");
            System.out.println("0. Salir");

            opcion = Utils.leerEntero("Seleccione una opción: ");

            switch (opcion) {
                case 1:
                    new InventoryView().mostrarMenu();
                    break;
                case 2:
                    new SupplierView().mostrarMenu();
                    break;
                case 3:
                    new SalesView().mostrarMenu();
                    break;
                case 4:
                    new LogisticsView().mostrarMenu();
                    break;
                case 0:
                    System.out.println("Hasta pronto.");
                    break;
                default:
                    System.out.println("Opción no válida. Intente de nuevo.");
            }
        } while (opcion != 0);
    }
}
