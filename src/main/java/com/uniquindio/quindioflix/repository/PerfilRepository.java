package com.uniquindio.quindioflix.repository;

import com.uniquindio.quindioflix.model.dto.PerfilDTO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public class PerfilRepository {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    private static final RowMapper<PerfilDTO> PERFIL_ROW_MAPPER = (rs, rowNum) -> {
        PerfilDTO dto = new PerfilDTO();
        dto.setId(rs.getInt("id_perfil"));
        dto.setIdUsuario(rs.getInt("id_usuario"));
        dto.setNombre(rs.getString("nombre"));
        dto.setTipo(rs.getString("tipo"));
        return dto;
    };

    public List<PerfilDTO> findByUsuario(Integer idUsuario) {
        String sql = "SELECT * FROM PERFILES WHERE id_usuario = ? ORDER BY id_perfil";
        return jdbcTemplate.query(sql, PERFIL_ROW_MAPPER, idUsuario);
    }

    public PerfilDTO findById(Integer id) {
        String sql = "SELECT * FROM PERFILES WHERE id_perfil = ?";
        return jdbcTemplate.query(sql, PERFIL_ROW_MAPPER, id).stream().findFirst().orElse(null);
    }

    public int save(PerfilDTO perfil) {
        String sql = "INSERT INTO PERFILES (id_usuario, nombre, tipo) VALUES (?, ?, ?)";
        return jdbcTemplate.update(sql, perfil.getIdUsuario(), perfil.getNombre(), perfil.getTipo());
    }

    public int delete(Integer id) {
        String sql = "DELETE FROM PERFILES WHERE id_perfil = ?";
        return jdbcTemplate.update(sql, id);
    }
}