package com.uniquindio.quindioflix.controller;

import com.uniquindio.quindioflix.model.dto.ApiResponse;
import com.uniquindio.quindioflix.model.dto.UsuarioDTO;
import com.uniquindio.quindioflix.service.UsuarioService;
import com.uniquindio.quindioflix.util.JwtService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

    @Autowired
    private UsuarioService usuarioService;

    @Autowired
    private JwtService jwtService;

    @PostMapping("/login")
    public ResponseEntity<ApiResponse<Map>> login(
            @RequestParam String email,
            @RequestParam String password) {
        
        UsuarioDTO usuario = usuarioService.findByEmail(email);
        
        if (usuario == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(ApiResponse.error("Credenciales inválidas"));
        }
        
        if (!"ACTIVO".equals(usuario.getEstadoCuenta())) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(ApiResponse.error("Cuenta no activa"));
        }
        
        String token = jwtService.generateToken(
                usuario.getEmail(),
                usuario.getId(),
                "USER"
        );
        
        Map<String, Object> response = new HashMap<>();
        response.put("token", token);
        response.put("usuarioId", usuario.getId());
        response.put("email", usuario.getEmail());
        response.put("nombre", usuario.getNombre());
        
        return ResponseEntity.ok(ApiResponse.success(response, "Login exitoso"));
    }

    @PostMapping("/logout")
    public ResponseEntity<ApiResponse<Void>> logout(@RequestHeader String authorization) {
        return ResponseEntity.ok(ApiResponse.success(null, "Logout exitoso"));
    }
}