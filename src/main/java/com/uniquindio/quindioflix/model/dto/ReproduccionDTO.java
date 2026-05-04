package com.uniquindio.quindioflix.model.dto;

import java.util.Date;

public class ReproduccionDTO {
    private Integer id;
    private Integer idPerfil;
    private Integer idContenido;
    private Integer idEpisodio;
    private Date fechaHoraInicio;
    private Date fechaHoraFin;
    private String dispositivo;
    private Double porcentajeAvance;

    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }
    public Integer getIdPerfil() { return idPerfil; }
    public void setIdPerfil(Integer idPerfil) { this.idPerfil = idPerfil; }
    public Integer getIdContenido() { return idContenido; }
    public void setIdContenido(Integer idContenido) { this.idContenido = idContenido; }
    public Integer getIdEpisodio() { return idEpisodio; }
    public void setIdEpisodio(Integer idEpisodio) { this.idEpisodio = idEpisodio; }
    public Date getFechaHoraInicio() { return fechaHoraInicio; }
    public void setFechaHoraInicio(Date fechaHoraInicio) { this.fechaHoraInicio = fechaHoraInicio; }
    public Date getFechaHoraFin() { return fechaHoraFin; }
    public void setFechaHoraFin(Date fechaHoraFin) { this.fechaHoraFin = fechaHoraFin; }
    public String getDispositivo() { return dispositivo; }
    public void setDispositivo(String dispositivo) { this.dispositivo = dispositivo; }
    public Double getPorcentajeAvance() { return porcentajeAvance; }
    public void setPorcentajeAvance(Double porcentajeAvance) { this.porcentajeAvance = porcentajeAvance; }
}