package com.uniquindio.quindioflix.service;

import com.uniquindio.quindioflix.model.dto.UsuarioDTO;
import com.uniquindio.quindioflix.repository.UsuarioRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.SqlOutParameter;
import org.springframework.jdbc.core.SqlParameter;
import org.springframework.jdbc.core.simple.SimpleJdbcCall;
import org.springframework.stereotype.Service;

import java.sql.Types;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class UsuarioService {

    @Autowired
    private UsuarioRepository usuarioRepository;

    @Autowired
    private JdbcTemplate jdbcTemplate;

    public List<UsuarioDTO> findAll() {
        return usuarioRepository.findAll();
    }

    public UsuarioDTO findById(Integer id) {
        return usuarioRepository.findById(id);
    }

    public UsuarioDTO findByEmail(String email) {
        return usuarioRepository.findByEmail(email);
    }

    public UsuarioDTO save(UsuarioDTO usuario) {
        usuarioRepository.save(usuario);
        return findByEmail(usuario.getEmail());
    }

    public UsuarioDTO update(UsuarioDTO usuario) {
        usuarioRepository.update(usuario);
        return findById(usuario.getId());
    }

    public boolean delete(Integer id) {
        return usuarioRepository.delete(id) > 0;
    }

    public Map<String, Object> registrarUsuario(String nombre, String email, String telefono,
                                              java.util.Date fechaNacimiento, String ciudad,
                                              Integer idPlan, Integer idReferidor) {
        try {
            SimpleJdbcCall call = new SimpleJdbcCall(jdbcTemplate)
                    .withProcedureName("SP_REGISTRAR_USUARIO")
                    .declareParameters(
                            new SqlParameter("p_nombre", Types.VARCHAR),
                            new SqlParameter("p_email", Types.VARCHAR),
                            new SqlParameter("p_telefono", Types.VARCHAR),
                            new SqlParameter("p_fecha_nac", Types.DATE),
                            new SqlParameter("p_ciudad", Types.VARCHAR),
                            new SqlParameter("p_id_plan", Types.NUMERIC),
                            new SqlParameter("p_id_referidor", Types.NUMERIC),
                            new SqlOutParameter("p_resultado", Types.NUMERIC),
                            new SqlOutParameter("p_mensaje", Types.VARCHAR)
                    );

            Map<String, Object> params = new HashMap<>();
            params.put("p_nombre", nombre);
            params.put("p_email", email);
            params.put("p_telefono", telefono);
            params.put("p_fecha_nac", new java.sql.Date(fechaNacimiento.getTime()));
            params.put("p_ciudad", ciudad);
            params.put("p_id_plan", idPlan);
            params.put("p_id_referidor", idReferidor != null ? idReferidor : null);

            Map<String, Object> result = call.execute(params);
            return result;
        } catch (Exception e) {
            Map<String, Object> error = new HashMap<>();
            error.put("p_resultado", -1);
            error.put("p_mensaje", e.getMessage());
            return error;
        }
    }

    public Map<String, Object> cambiarPlan(Integer idUsuario, Integer idPlanNuevo) {
        try {
            SimpleJdbcCall call = new SimpleJdbcCall(jdbcTemplate)
                    .withProcedureName("SP_CAMBIAR_PLAN")
                    .declareParameters(
                            new SqlParameter("p_id_usuario", Types.NUMERIC),
                            new SqlParameter("p_id_plan_nuevo", Types.NUMERIC),
                            new SqlOutParameter("p_resultado", Types.NUMERIC),
                            new SqlOutParameter("p_mensaje", Types.VARCHAR)
                    );

            Map<String, Object> params = new HashMap<>();
            params.put("p_id_usuario", idUsuario);
            params.put("p_id_plan_nuevo", idPlanNuevo);

            Map<String, Object> result = call.execute(params);
            return result;
        } catch (Exception e) {
            Map<String, Object> error = new HashMap<>();
            error.put("p_resultado", -1);
            error.put("p_mensaje", e.getMessage());
            return error;
        }
    }
}