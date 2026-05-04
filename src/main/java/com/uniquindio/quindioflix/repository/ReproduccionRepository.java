package com.uniquindio.quindioflix.repository;

import com.uniquindio.quindioflix.model.dto.ReproduccionDTO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Repository;

import java.util.Date;
import java.util.List;

@Repository
public class ReproduccionRepository {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    private static final RowMapper<ReproduccionDTO> REPRO_ROW_MAPPER = (rs, rowNum) -> {
        ReproduccionDTO dto = new ReproduccionDTO();
        dto.setId(rs.getInt("id_reproduccion"));
        dto.setIdPerfil(rs.getInt("id_perfil"));
        dto.setIdContenido(rs.getInt("id_contenido"));
        Integer idEp = rs.getInt("id_episodio");
        if (rs.wasNull()) dto.setIdEpisodio(null); else dto.setIdEpisodio(idEp);
        dto.setFechaHoraInicio(rs.getTimestamp("fecha_hora_inicio"));
        dto.setFechaHoraFin(rs.getTimestamp("fecha_hora_fin"));
        dto.setDispositivo(rs.getString("dispositivo"));
        dto.setPorcentajeAvance(rs.getDouble("porcentaje_avance"));
        return dto;
    };

    public List<ReproduccionDTO> findByPerfil(Integer idPerfil) {
        String sql = "SELECT * FROM REPRODUCCIONES WHERE id_perfil = ? ORDER BY fecha_hora_inicio DESC";
        return jdbcTemplate.query(sql, REPRO_ROW_MAPPER, idPerfil);
    }

    public List<ReproduccionDTO> findByPerfilYFechas(Integer idPerfil, Date fechaInicio, Date fechaFin) {
        String sql = "SELECT * FROM REPRODUCCIONES WHERE id_perfil = ? " +
                "AND fecha_hora_inicio BETWEEN ? AND ? ORDER BY fecha_hora_inicio DESC";
        return jdbcTemplate.query(sql, REPRO_ROW_MAPPER, idPerfil, fechaInicio, fechaFin);
    }

    public int save(ReproduccionDTO reproduccion) {
        String sql = "INSERT INTO REPRODUCCIONES (id_perfil, id_contenido, id_episodio, " +
                "fecha_hora_inicio, fecha_hora_fin, dispositivo, porcentaje_avance) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?)";
        return jdbcTemplate.update(sql,
                reproduccion.getIdPerfil(),
                reproduccion.getIdContenido(),
                reproduccion.getIdEpisodio(),
                reproduccion.getFechaHoraInicio(),
                reproduccion.getFechaHoraFin(),
                reproduccion.getDispositivo(),
                reproduccion.getPorcentajeAvance()
        );
    }
}