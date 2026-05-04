package com.uniquindio.quindioflix.model.dto;

import java.util.Date;

public class UsuarioDTO {
    private Integer id;
    private String nombre;
    private String email;
    private String telefono;
    private Date fechaNacimiento;
    private String ciudad;
    private Date fechaRegistro;
    private String estadoCuenta;
    private Integer idPlan;
    private Integer idReferidor;

    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }
    public String getNombre() { return nombre; }
    public void setNombre(String nombre) { this.nombre = nombre; }
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    public String getTelefono() { return telefono; }
    public void setTelefono(String telefono) { this.telefono = telefono; }
    public Date getFechaNacimiento() { return fechaNacimiento; }
    public void setFechaNacimiento(Date fechaNacimiento) { this.fechaNacimiento = fechaNacimiento; }
    public String getCiudad() { return ciudad; }
    public void setCiudad(String ciudad) { this.ciudad = ciudad; }
    public Date getFechaRegistro() { return fechaRegistro; }
    public void setFechaRegistro(Date fechaRegistro) { this.fechaRegistro = fechaRegistro; }
    public String getEstadoCuenta() { return estadoCuenta; }
    public void setEstadoCuenta(String estadoCuenta) { this.estadoCuenta = estadoCuenta; }
    public Integer getIdPlan() { return idPlan; }
    public void setIdPlan(Integer idPlan) { this.idPlan = idPlan; }
    public Integer getIdReferidor() { return idReferidor; }
    public void setIdReferidor(Integer idReferidor) { this.idReferidor = idReferidor; }
}