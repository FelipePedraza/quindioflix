package com.uniquindio.quindioflix.model.dto;

import java.util.Date;

public class ContenidoDTO {
    private Integer id;
    private String titulo;
    private Integer anioLanzamiento;
    private Integer duracionMin;
    private String sinopsis;
    private String clasificacionEdad;
    private Date fechaCatalogo;
    private String esOriginal;
    private Integer idCategoria;
    private Integer idEmpleadoResponsable;
    private Integer popularidad;

    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }
    public String getTitulo() { return titulo; }
    public void setTitulo(String titulo) { this.titulo = titulo; }
    public Integer getAnioLanzamiento() { return anioLanzamiento; }
    public void setAnioLanzamiento(Integer anioLanzamiento) { this.anioLanzamiento = anioLanzamiento; }
    public Integer getDuracionMin() { return duracionMin; }
    public void setDuracionMin(Integer duracionMin) { this.duracionMin = duracionMin; }
    public String getSinopsis() { return sinopsis; }
    public void setSinopsis(String sinopsis) { this.sinopsis = sinopsis; }
    public String getClasificacionEdad() { return clasificacionEdad; }
    public void setClasificacionEdad(String clasificacionEdad) { this.clasificacionEdad = clasificacionEdad; }
    public Date getFechaCatalogo() { return fechaCatalogo; }
    public void setFechaCatalogo(Date fechaCatalogo) { this.fechaCatalogo = fechaCatalogo; }
    public String getEsOriginal() { return esOriginal; }
    public void setEsOriginal(String esOriginal) { this.esOriginal = esOriginal; }
    public Integer getIdCategoria() { return idCategoria; }
    public void setIdCategoria(Integer idCategoria) { this.idCategoria = idCategoria; }
    public Integer getIdEmpleadoResponsable() { return idEmpleadoResponsable; }
    public void setIdEmpleadoResponsable(Integer idEmpleadoResponsable) { this.idEmpleadoResponsable = idEmpleadoResponsable; }
    public Integer getPopularidad() { return popularidad; }
    public void setPopularidad(Integer popularidad) { this.popularidad = popularidad; }
}