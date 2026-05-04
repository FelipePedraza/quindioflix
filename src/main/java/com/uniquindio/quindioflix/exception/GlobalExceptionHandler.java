package com.uniquindio.quindioflix.exception;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import com.uniquindio.quindioflix.model.dto.ApiResponse;

@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(Exception.class)
    public ResponseEntity<ApiResponse<Void>> handleException(Exception e) {
        return ResponseEntity
            .status(HttpStatus.INTERNAL_SERVER_ERROR)
            .body(ApiResponse.error("Error interno: " + e.getMessage()));
    }

    @ExceptionHandler(IllegalArgumentException.class)
    public ResponseEntity<ApiResponse<Void>> handleIllegalArgument(IllegalArgumentException e) {
        return ResponseEntity
            .status(HttpStatus.BAD_REQUEST)
            .body(ApiResponse.error(e.getMessage()));
    }

    @ExceptionHandler(NullPointerException.class)
    public ResponseEntity<ApiResponse<Void>> handleNullPointer(NullPointerException e) {
        return ResponseEntity
            .status(HttpStatus.NOT_FOUND)
            .body(ApiResponse.error("Recurso no encontrado"));
    }
}