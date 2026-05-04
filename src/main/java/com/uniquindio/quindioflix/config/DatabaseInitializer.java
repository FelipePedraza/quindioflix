package com.uniquindio.quindioflix.config;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.core.io.ClassPathResource;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Component;

import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.List;
import java.util.Set;
import java.util.HashSet;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

@Component
public class DatabaseInitializer implements CommandLineRunner {

    private static final Logger logger = LoggerFactory.getLogger(DatabaseInitializer.class);

    @Autowired
    private JdbcTemplate jdbcTemplate;

    private boolean initialized = false;
    private static final Set<String> CORE_TABLES = Set.of(
        "PLANES", "USUARIOS", "PERFILES", "CATEGORIAS", "GENEROS", 
        "CONTENIDO", "CONTENIDO_GENERO", "TEMPORADAS", "EPISODIOS",
        "DEPARTAMENTOS", "EMPLEADOS", "REPRODUCCIONES", "FAVORITOS",
        "CALIFICACIONES", "PAGOS", "REPORTES_CONTENIDO"
    );

    @Override
    public void run(String... args) throws Exception {
        if (initialized) {
            logger.info("Base de datos ya inicializada anteriormente");
            return;
        }
        
        Set<String> existingTables = getExistingTables();
        
        if (existingTables.contains("CONTENIDO")) {
            logger.info("Las tablas ya existen en la base de datos. Omitiendo inicializacion.");
            initialized = true;
            return;
        }
        
        logger.info("========================================");
        logger.info("INICIANDO INICIALIZACION DE BASE DE DATOS");
        logger.info("========================================");
        
        String[] scripts = {
            "sql/01_DDL_tablas.sql",
            "sql/02_DML_datos_prueba.sql",
            "sql/03_NT1_consultas_avanzadas.sql",
            "sql/04_NT2_cursores_sp_funciones.sql",
            "sql/05_NT2_excepciones_triggers.sql",
            "sql/06_NT3_transacciones.sql",
            "sql/07_NT4_indices.sql",
            "sql/08_NT5_usuarios_roles.sql"
        };

        for (String script : scripts) {
            try {
                logger.info(">>> Ejecutando: {}", script);
                int result = executeScript(script);
                logger.info("<<< Completado: {} (statements ejecutados: {})", script, result);
            } catch (Exception e) {
                logger.error("ERROR ejecutando {}: {}", script, e.getMessage());
            }
        }
        
        logger.info("========================================");
        logger.info("BASE DE DATOS INICIALIZADA");
        logger.info("========================================");
        
        initialized = true;
    }

    private Set<String> getExistingTables() {
        Set<String> tables = new HashSet<>();
        try {
            List<String> result = jdbcTemplate.query(
                "SELECT table_name FROM user_tables",
                (rs, rowNum) -> rs.getString("table_name")
            );
            tables.addAll(result);
            logger.info("Tablas existentes: {}", tables);
        } catch (Exception e) {
            logger.warn("No se pudo verificar tablas existentes: {}", e.getMessage());
        }
        return tables;
    }

    private int executeScript(String scriptPath) {
        ClassPathResource resource = new ClassPathResource(scriptPath);
        
        if (!resource.exists()) {
            logger.warn("Script no encontrado: {}", scriptPath);
            return 0;
        }
        
        int count = 0;
        
        try (InputStream is = resource.getInputStream();
             BufferedReader reader = new BufferedReader(new InputStreamReader(is))) {
            
            StringBuilder scriptBuilder = new StringBuilder();
            String line;
            while ((line = reader.readLine()) != null) {
                scriptBuilder.append(line).append("\n");
            }
            
            String scriptContent = scriptBuilder.toString();
            
            List<String> statements = parseOracleScript(scriptContent);
            
            for (String stmt : statements) {
                String trimmed = stmt.trim();
                
                if (isCommentOrEmpty(trimmed)) {
                    continue;
                }
                
                if (trimmed.startsWith("SET")) {
                    continue;
                }
                
                try {
                    jdbcTemplate.execute(trimmed);
                    count++;
                } catch (Exception e) {
                    String msg = e.getMessage();
                    if (!isIgnorableError(msg)) {
                        String preview = trimmed.length() > 60 ? trimmed.substring(0, 60) + "..." : trimmed;
                        logger.debug("Statement: {} -> Error: {}", preview, msg);
                    }
                }
            }
            
        } catch (Exception e) {
            logger.error("Error leyendo script {}: {}", scriptPath, e.getMessage());
        }
        
        return count;
    }

    private List<String> parseOracleScript(String content) {
        List<String> statements = new ArrayList<>();
        StringBuilder currentStmt = new StringBuilder();
        boolean inPlSql = false;
        
        String[] lines = content.split("\n");
        
        for (String line : lines) {
            String trimmedLine = line.trim();
            
            if (trimmedLine.isEmpty()) {
                continue;
            }
            
            if (trimmedLine.startsWith("--")) {
                continue;
            }
            
            if (trimmedLine.equalsIgnoreCase("/")) {
                if (currentStmt.length() > 0) {
                    String stmt = currentStmt.toString().trim();
                    if (!stmt.isEmpty()) {
                        statements.add(stmt);
                    }
                    currentStmt.setLength(0);
                }
                inPlSql = false;
                continue;
            }
            
            if (isPlSqlStart(trimmedLine)) {
                inPlSql = true;
            }
            
            currentStmt.append(line).append("\n");
            
            if (inPlSql && trimmedLine.equalsIgnoreCase("END;")) {
                continue;
            }
            
            if (!inPlSql && trimmedLine.endsWith(";")) {
                String stmt = currentStmt.toString().trim();
                if (stmt.endsWith(";")) {
                    stmt = stmt.substring(0, stmt.length() - 1);
                }
                if (!stmt.isEmpty() && !isCommentOrEmpty(stmt)) {
                    statements.add(stmt);
                }
                currentStmt.setLength(0);
            }
        }
        
        if (currentStmt.length() > 0) {
            String stmt = currentStmt.toString().trim();
            if (stmt.endsWith(";")) {
                stmt = stmt.substring(0, stmt.length() - 1);
            }
            if (!stmt.isEmpty() && !isCommentOrEmpty(stmt)) {
                statements.add(stmt);
            }
        }
        
        return statements;
    }

    private boolean isPlSqlStart(String line) {
        String upper = line.toUpperCase();
        return upper.startsWith("CREATE OR REPLACE") ||
               upper.startsWith("CREATE PROCEDURE") ||
               upper.startsWith("CREATE FUNCTION") ||
               upper.startsWith("CREATE TRIGGER") ||
               upper.startsWith("DECLARE") ||
               upper.startsWith("BEGIN");
    }

    private boolean isCommentOrEmpty(String stmt) {
        if (stmt == null || stmt.trim().isEmpty()) {
            return true;
        }
        
        String trimmed = stmt.trim().toUpperCase();
        
        if (trimmed.startsWith("--")) {
            return true;
        }
        
        if (trimmed.startsWith("SET")) {
            return true;
        }
        
        if (trimmed.equals("DECLARE") || trimmed.equals("BEGIN") || trimmed.equals("END") || trimmed.equals("END;")) {
            return true;
        }
        
        return false;
    }

    private boolean isIgnorableError(String msg) {
        if (msg == null) {
            return true;
        }
        
        msg = msg.toUpperCase();
        
        if (msg.contains("ORA-00955") || msg.contains("NAME ALREADY USED") || msg.contains("UNIQUE CONSTRAINT")) {
            return true;
        }
        
        if (msg.contains("ORA-01418") || msg.contains("ALREADY EXISTS")) {
            return true;
        }
        
        if (msg.contains("ORA-02275") || msg.contains("REFERENCE CONSTRAINT")) {
            return true;
        }
        
        if (msg.contains("TABLE OR VIEW DOES NOT EXIST")) {
            return true;
        }
        
        return false;
    }
}