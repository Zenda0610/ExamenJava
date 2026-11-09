package com.mycompany.proyectojava.inventory.controller;

import java.util.Arrays;

public final class InspectorAccess {
    private InspectorAccess() {}

    public static boolean isRequired() {
        return System.getenv("ERP_INSPECTOR_USER") != null || System.getenv("ERP_INSPECTOR_PASSWORD") != null;
    }

    public static boolean authenticate(String user, char[] password) {
        String account = System.getenv("ERP_INSPECTOR_USER");
        String secret = System.getenv("ERP_INSPECTOR_PASSWORD");
        return account != null && !account.isBlank() && account.equals(user)
                && secret != null && !secret.isBlank() && Arrays.equals(secret.toCharArray(), password);
    }
}
