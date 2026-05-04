package com.uniquindio.quindioflix.controller;

import com.uniquindio.quindioflix.model.dto.ApiResponse;
import com.uniquindio.quindioflix.model.dto.UsuarioDTO;
import com.uniquindio.quindioflix.service.UsuarioService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Date;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/usuarios")
public class UsuarioController {

    @Autowired
    private UsuarioService usuarioService;

    @GetMapping
    public ResponseEntity<ApiResponse<List<UsuarioDTO>>> findAll() {
        List<UsuarioDTO> usuarios = usuarioService.findAll();
        return ResponseEntity.ok(ApiResponse.success(usuarios, "Usuarios obtenidos"));
    }

    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<UsuarioDTO>> findById(@PathVariable Integer id) {
        UsuarioDTO usuario = usuarioService.findById(id);
        if (usuario == null) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(ApiResponse.error("Usuario no encontrado"));
        }
        return ResponseEntity.ok(ApiResponse.success(usuario, "Usuario encontrado"));
    }

    @PostMapping
    public ResponseEntity<ApiResponse<UsuarioDTO>> save(@RequestBody UsuarioDTO usuario) {
        usuario.setFechaRegistro(new Date());
        usuario.setEstadoCuenta("PENDIENTE");
        usuario = usuarioService.save(usuario);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success(usuario, "Usuario creado"));
    }

    @PutMapping("/{id}")
    public ResponseEntity<ApiResponse<UsuarioDTO>> update(@PathVariable Integer id,
                                                         @RequestBody UsuarioDTO usuario) {
        usuario.setId(id);
        usuario = usuarioService.update(usuario);
        return ResponseEntity.ok(ApiResponse.success(usuario, "Usuario actualizado"));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<ApiResponse<Void>> delete(@PathVariable Integer id) {
        boolean deleted = usuarioService.delete(id);
        if (!deleted) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(ApiResponse.error("Usuario no encontrado"));
        }
        return ResponseEntity.ok(ApiResponse.success(null, "Usuario eliminado"));
    }

    @PostMapping("/registrar")
    public ResponseEntity<ApiResponse<Map>> registrar(
            @RequestParam String nombre,
            @RequestParam String email,
            @RequestParam String telefono,
            @RequestParam Date fechaNacimiento,
            @RequestParam String ciudad,
            @RequestParam Integer idPlan,
            @RequestParam(required = false) Integer idReferidor) {
        
        Map<String, Object> result = usuarioService.registrarUsuario(
                nombre, email, telefono, fechaNacimiento, ciudad, idPlan, idReferidor);
        
        Integer resultado = (Integer) result.get("P_RESULTADO");
        String mensaje = (String) result.get("P_MENSAJE");
        
        if (resultado != null && resultado > 0) {
            return ResponseEntity.status(HttpStatus.CREATED)
                    .body(ApiResponse.success(result, mensaje));
        } else {
            return ResponseEntity.status(HttpStatus.CONFLICT)
                    .body(ApiResponse.success(result, mensaje));
        }
    }

    @PutMapping("/{id}/plan")
    public ResponseEntity<ApiResponse<Map>> cambiarPlan(@PathVariable Integer id,
                                                     @RequestParam Integer idPlanNuevo) {
        Map<String, Object> result = usuarioService.cambiarPlan(id, idPlanNuevo);
        
        Integer resultado = (Integer) result.get("P_RESULTADO");
        String mensaje = (String) result.get("P_MENSAJE");
        
        if (resultado != null && resultado > 0) {
            return ResponseEntity.ok(ApiResponse.success(result, mensaje));
        } else {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(ApiResponse.success(result, mensaje));
        }
    }
}