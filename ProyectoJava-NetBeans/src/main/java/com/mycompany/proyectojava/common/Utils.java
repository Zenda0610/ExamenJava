
package com.mycompany.proyectojava.common;

import java.io.Console;
import java.io.PrintStream;
import java.math.BigDecimal;
import java.nio.charset.Charset;
import java.nio.charset.StandardCharsets;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import java.util.Scanner;

public class Utils {
    private static final Scanner SCANNER = new Scanner(System.in, codificacionEntrada());
    private static final DateTimeFormatter DATE_FORMAT = DateTimeFormatter.ISO_LOCAL_DATE; 
    
    
    public static void configurarConsola() {
        if (!usaTerminal()) {
            System.setOut(new PrintStream(System.out, true, StandardCharsets.UTF_8));
            System.setErr(new PrintStream(System.err, true, StandardCharsets.UTF_8));
        }
    }

    private static boolean usaTerminal() {
        Console consola = System.console();
        return consola != null && consola.isTerminal();
    }

    private static Charset codificacionEntrada() {
        return usaTerminal()
                ? Charset.forName(System.getProperty("stdin.encoding", "UTF-8"))
                : StandardCharsets.UTF_8;
    }

    public static String leerPalabra(String palabra) {
        while (true) {
            System.out.print(palabra);
            String input = SCANNER.nextLine().trim();
            if (!input.isEmpty()) {
                return input;
            }
            System.out.println("Error: Este campo no puede estar vacío.");
        }
    }
    
    public static String leerPalabraOpcional(String palabra) {
        System.out.print(palabra);
        return SCANNER.nextLine().trim();
    }

    public static char[] readPassword(String prompt) {
        if (usaTerminal()) return System.console().readPassword("%s", prompt);
        System.out.print(prompt);
        return SCANNER.nextLine().toCharArray();
    }
    
    public static int leerEntero(String numero) {
        while (true) {
            System.out.print(numero);
            try {
                return Integer.parseInt(SCANNER.nextLine().trim());
            } catch (NumberFormatException e) {
                System.out.println("Error: Ingrese un número entero válido.");
            }
        }
    }
    
    public static BigDecimal leerDecimalExacto(String decimal) {
        while (true) {
            System.out.print(decimal);
            try {
                BigDecimal value = new BigDecimal(SCANNER.nextLine().trim());
                if (value.compareTo(BigDecimal.ZERO) > 0) {
                    if (value.stripTrailingZeros().scale() <= 2) return value;
                    System.out.println("Error: Ingrese un valor con máximo dos decimales.");
                    continue;
                }
                System.out.println("Error: El valor debe ser mayor que cero.");
            } catch (NumberFormatException e) {
                System.out.println("Error: Ingrese un valor numérico válido (ej. 150.50).");
            }
        }
    }
    
    public static LocalDate leerFecha(String fecha) {
        while (true) {
            System.out.print(fecha + " (formato AAAA-MM-DD): ");
            try {
                return LocalDate.parse(SCANNER.nextLine().trim(), DATE_FORMAT);
            } catch (DateTimeParseException e) {
                System.out.println("Error: Formato de fecha inválido. Ejemplo válido: 2026-12-31");
            }
        }
    }
    
    public static boolean leerBoolean(String b) {
        while (true) {
            System.out.print(b + " (S/N): ");
            String input = SCANNER.nextLine().trim().toUpperCase();
            if (input.equals("S") || input.equals("SI")) {
                return true;
            } else if (input.equals("N") || input.equals("NO")) {
                return false;
            }
            System.out.println("Error: Responda únicamente con 'S' para Sí o 'N' para No.");
        }
    }
    
    public static void pausa() {
        System.out.print("\nPresione ENTER para continuar...");
        SCANNER.nextLine();
    }
    
    public static void imprimirTitulo(String titulo) {
        System.out.println("\n=======================================================");
        System.out.println("   " + titulo.toUpperCase());
        System.out.println("=======================================================");
    }
}
