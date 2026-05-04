package com.uniquindio.quindioflix.repository;

import com.uniquindio.quindioflix.model.dto.ContenidoDTO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Repository;

import java.sql.ResultSet;
import java.util.List;

@Repository
public class ContenidoRepository {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    private static final RowMapper<ContenidoDTO> CONTENIDO_ROW_MAPPER = (rs, rowNum) -> {
        ContenidoDTO dto = new ContenidoDTO();
        dto.setId(rs.getInt("id_contenido"));
        dto.setTitulo(rs.getString("titulo"));
        dto.setAnioLanzamiento(rs.getInt("anio_lanzamiento"));
        dto.setDuracionMin(rs.getInt("duracion_min"));
        dto.setSinopsis(rs.getString("sinopsis"));
        dto.setClasificacionEdad(rs.getString("clasificacion_edad"));
        dto.setFechaCatalogo(rs.getDate("fecha_catalogo"));
        dto.setEsOriginal(rs.getString("es_original"));
        dto.setIdCategoria(rs.getInt("id_categoria"));
        dto.setIdEmpleadoResponsable(rs.getInt("id_empleado_responsable"));
        dto.setPopularidad(rs.getInt("popularidad"));
        return dto;
    };

    public List<ContenidoDTO> findAll() {
        String sql = "SELECT * FROM CONTENIDO ORDER BY id_contenido";
        return jdbcTemplate.query(sql, CONTENIDO_ROW_MAPPER);
    }

    public ContenidoDTO findById(Integer id) {
        String sql = "SELECT * FROM CONTENIDO WHERE id_contenido = ?";
        return jdbcTemplate.query(sql, CONTENIDO_ROW_MAPPER, id).stream().findFirst().orElse(null);
    }

    public List<ContenidoDTO> findByCategoria(Integer idCategoria) {
        String sql = "SELECT * FROM CONTENIDO WHERE id_categoria = ? ORDER BY titulo";
        return jdbcTemplate.query(sql, CONTENIDO_ROW_MAPPER, idCategoria);
    }

    public List<ContenidoDTO> findByGenero(Integer idGenero) {
        String sql = "SELECT c.* FROM CONTENIDO c " +
                "JOIN CONTENIDO_GENERO cg ON c.id_contenido = cg.id_contenido " +
                "WHERE cg.id_genero = ? ORDER BY c.popularidad DESC";
        return jdbcTemplate.query(sql, CONTENIDO_ROW_MAPPER, idGenero);
    }

    public List<ContenidoDTO> buscar(String filtro) {
        String sql = "SELECT * FROM CONTENIDO WHERE titulo LIKE ? ORDER BY titulo";
        return jdbcTemplate.query(sql, CONTENIDO_ROW_MAPPER, "%" + filtro + "%");
    }

    public int save(ContenidoDTO contenido) {
        String sql = "INSERT INTO CONTENIDO (titulo, anio_lanzamiento, duracion_min, " +
                "sinopsis, clasificacion_edad, fecha_catalogo, es_original, id_categoria, " +
                "id_empleado_responsable, popularidad) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        return jdbcTemplate.update(sql,
                contenido.getTitulo(),
                contenido.getAnioLanzamiento(),
                contenido.getDuracionMin(),
                contenido.getSinopsis(),
                contenido.getClasificacionEdad(),
                contenido.getFechaCatalogo(),
                contenido.getEsOriginal(),
                contenido.getIdCategoria(),
                contenido.getIdEmpleadoResponsable(),
                contenido.getPopularidad() != null ? contenido.getPopularidad() : 0
        );
    }

    public int update(ContenidoDTO contenido) {
        String sql = "UPDATE CONTENIDO SET titulo = ?, anio_lanzamiento = ?, duracion_min = ?, " +
                "sinopsis = ?, clasificacion_edad = ?, es_original = ?, id_categoria = ?, " +
                "id_empleado_responsable = ?, popularidad = ? WHERE id_contenido = ?";
        return jdbcTemplate.update(sql,
                contenido.getTitulo(),
                contenido.getAnioLanzamiento(),
                contenido.getDuracionMin(),
                contenido.getSinopsis(),
                contenido.getClasificacionEdad(),
                contenido.getEsOriginal(),
                contenido.getIdCategoria(),
                contenido.getIdEmpleadoResponsable(),
                contenido.getPopularidad(),
                contenido.getId()
        );
    }

    public int delete(Integer id) {
        String sql = "DELETE FROM CONTENIDO WHERE id_contenido = ?";
        return jdbcTemplate.update(sql, id);
    }
}