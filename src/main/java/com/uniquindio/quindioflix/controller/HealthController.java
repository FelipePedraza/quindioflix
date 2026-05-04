package com.uniquindio.quindioflix.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import com.uniquindio.quindioflix.model.dto.ApiResponse;
import com.uniquindio.quindioflix.model.dto.HealthResponse;
import javax.sql.DataSource;
import java.sql.Connection;

@RestController
@RequestMapping("/api")
public class HealthController {

    @Autowired
    private DataSource dataSource;

    @GetMapping("/health")
    public ResponseEntity<ApiResponse<HealthResponse>> health() {
        try (Connection conn = dataSource.getConnection()) {
            conn.prepareStatement("SELECT 1 FROM DUAL").execute();
            HealthResponse response = new HealthResponse("UP", "Oracle conectado");
            return ResponseEntity.ok(ApiResponse.success(response, "Health check exitoso"));
        } catch (Exception e) {
            return ResponseEntity.ok(ApiResponse.success(
                new HealthResponse("DOWN", "Oracle desconectado: " + e.getMessage()),
                "Health check fallido"
            ));
        }
    }
}