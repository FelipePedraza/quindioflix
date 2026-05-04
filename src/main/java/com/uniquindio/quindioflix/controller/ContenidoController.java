package com.uniquindio.quindioflix.controller;

import com.uniquindio.quindioflix.model.dto.ApiResponse;
import com.uniquindio.quindioflix.model.dto.ContenidoDTO;
import com.uniquindio.quindioflix.service.ContenidoService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/contenido")
public class ContenidoController {

    @Autowired
    private ContenidoService contenidoService;

    @GetMapping
    public ResponseEntity<ApiResponse<List<ContenidoDTO>>> findAll() {
        List<ContenidoDTO> contenidos = contenidoService.findAll();
        return ResponseEntity.ok(ApiResponse.success(contenidos, "Contenido obtenido"));
    }

    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<ContenidoDTO>> findById(@PathVariable Integer id) {
        ContenidoDTO contenido = contenidoService.findById(id);
        if (contenido == null) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(ApiResponse.error("Contenido no encontrado"));
        }
        return ResponseEntity.ok(ApiResponse.success(contenido, "Contenido encontrado"));
    }

    @GetMapping("/categoria/{idCategoria}")
    public ResponseEntity<ApiResponse<List<ContenidoDTO>>> findByCategoria(@PathVariable Integer idCategoria) {
        List<ContenidoDTO> contenidos = contenidoService.findByCategoria(idCategoria);
        return ResponseEntity.ok(ApiResponse.success(contenidos, "Contenidos por categoría"));
    }

    @GetMapping("/genero/{idGenero}")
    public ResponseEntity<ApiResponse<List<ContenidoDTO>>> findByGenero(@PathVariable Integer idGenero) {
        List<ContenidoDTO> contenidos = contenidoService.findByGenero(idGenero);
        return ResponseEntity.ok(ApiResponse.success(contenidos, "Contenidos por género"));
    }

    @GetMapping("/buscar")
    public ResponseEntity<ApiResponse<List<ContenidoDTO>>> buscar(@RequestParam String q) {
        List<ContenidoDTO> contenidos = contenidoService.buscar(q);
        return ResponseEntity.ok(ApiResponse.success(contenidos, "Resultados de búsqueda"));
    }

    @PostMapping
    public ResponseEntity<ApiResponse<ContenidoDTO>> save(@RequestBody ContenidoDTO contenido) {
        contenido = contenidoService.save(contenido);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success(contenido, "Contenido creado"));
    }

    @PutMapping("/{id}")
    public ResponseEntity<ApiResponse<ContenidoDTO>> update(@PathVariable Integer id,
                                                       @RequestBody ContenidoDTO contenido) {
        contenido.setId(id);
        contenido = contenidoService.update(contenido);
        return ResponseEntity.ok(ApiResponse.success(contenido, "Contenido actualizado"));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<ApiResponse<Void>> delete(@PathVariable Integer id) {
        boolean deleted = contenidoService.delete(id);
        if (!deleted) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(ApiResponse.error("Contenido no encontrado"));
        }
        return ResponseEntity.ok(ApiResponse.success(null, "Contenido eliminado"));
    }
}