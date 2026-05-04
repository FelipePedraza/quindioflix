package com.uniquindio.quindioflix.model.dto;

public class HealthResponse {
    private String status;
    private String db;

    public HealthResponse() {
    }

    public HealthResponse(String status, String db) {
        this.status = status;
        this.db = db;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getDb() {
        return db;
    }

    public void setDb(String db) {
        this.db = db;
    }
}