package com.mycompany.proyectojava.inventory.controller;

import com.mycompany.proyectojava.inventory.model.inventoryDAO;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;

public final class StockExpiryScheduler {
    private StockExpiryScheduler() {}

    public static ScheduledExecutorService start() {
        ScheduledExecutorService scheduler = Executors.newSingleThreadScheduledExecutor(task -> {
            Thread worker = new Thread(task, "stock-expiry-review");
            worker.setDaemon(true);
            return worker;
        });
        if (Boolean.parseBoolean(System.getProperty("erp.inventory.dailyReview", "true"))) {
            inventoryDAO dao = new inventoryDAO();
            scheduler.scheduleWithFixedDelay(() -> dao.actualizarEstadosVencimientoAutomatico(false),
                    0, 1, TimeUnit.DAYS);
        }
        return scheduler;
    }
}
