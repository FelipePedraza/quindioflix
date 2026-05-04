package com.uniquindio.quindioflix.repository;

import com.uniquindio.quindioflix.model.dto.UsuarioDTO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Repository;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;

@Repository
public class UsuarioRepository {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    private static final RowMapper<UsuarioDTO> USUARIO_ROW_MAPPER = (rs, rowNum) -> {
        UsuarioDTO dto = new UsuarioDTO();
        dto.setId(rs.getInt("id_usuario"));
        dto.setNombre(rs.getString("nombre"));
        dto.setEmail(rs.getString("email"));
        dto.setTelefono(rs.getString("telefono"));
        dto.setFechaNacimiento(rs.getDate("fecha_nacimiento"));
        dto.setCiudad(rs.getString("ciudad"));
        dto.setFechaRegistro(rs.getDate("fecha_registro"));
        dto.setEstadoCuenta(rs.getString("estado_cuenta"));
        dto.setIdPlan(rs.getInt("id_plan"));
        String ref = rs.getString("id_referidor");
        dto.setIdReferidor(ref != null ? Integer.parseInt(ref) : null);
        return dto;
    };

    public List<UsuarioDTO> findAll() {
        String sql = "SELECT * FROM USUARIOS ORDER BY id_usuario";
        return jdbcTemplate.query(sql, USUARIO_ROW_MAPPER);
    }

    public UsuarioDTO findById(Integer id) {
        String sql = "SELECT * FROM USUARIOS WHERE id_usuario = ?";
        return jdbcTemplate.query(sql, USUARIO_ROW_MAPPER, id).stream().findFirst().orElse(null);
    }

    public UsuarioDTO findByEmail(String email) {
        String sql = "SELECT * FROM USUARIOS WHERE email = ?";
        return jdbcTemplate.query(sql, USUARIO_ROW_MAPPER, email).stream().findFirst().orElse(null);
    }

    public int save(UsuarioDTO usuario) {
        String sql = "INSERT INTO USUARIOS (nombre, email, telefono, fecha_nacimiento, ciudad, " +
                "fecha_registro, estado_cuenta, id_plan, id_referidor) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
        return jdbcTemplate.update(sql,
                usuario.getNombre(),
                usuario.getEmail(),
                usuario.getTelefono(),
                usuario.getFechaNacimiento(),
                usuario.getCiudad(),
                usuario.getFechaRegistro(),
                usuario.getEstadoCuenta(),
                usuario.getIdPlan(),
                usuario.getIdReferidor()
        );
    }

    public int update(UsuarioDTO usuario) {
        String sql = "UPDATE USUARIOS SET nombre = ?, email = ?, telefono = ?, " +
                "fecha_nacimiento = ?, ciudad = ?, estado_cuenta = ?, id_plan = ?, id_referidor = ? " +
                "WHERE id_usuario = ?";
        return jdbcTemplate.update(sql,
                usuario.getNombre(),
                usuario.getEmail(),
                usuario.getTelefono(),
                usuario.getFechaNacimiento(),
                usuario.getCiudad(),
                usuario.getEstadoCuenta(),
                usuario.getIdPlan(),
                usuario.getIdReferidor(),
                usuario.getId()
        );
    }

    public int updatePlan(Integer idUsuario, Integer idPlan) {
        String sql = "UPDATE USUARIOS SET id_plan = ? WHERE id_usuario = ?";
        return jdbcTemplate.update(sql, idPlan, idUsuario);
    }

    public int delete(Integer id) {
        String sql = "DELETE FROM USUARIOS WHERE id_usuario = ?";
        return jdbcTemplate.update(sql, id);
    }
}