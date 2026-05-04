package com.uniquindio.quindioflix.service;

import com.uniquindio.quindioflix.model.dto.ContenidoDTO;
import com.uniquindio.quindioflix.repository.ContenidoRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class ContenidoService {

    @Autowired
    private ContenidoRepository contenidoRepository;

    public List<ContenidoDTO> findAll() {
        return contenidoRepository.findAll();
    }

    public ContenidoDTO findById(Integer id) {
        return contenidoRepository.findById(id);
    }

    public List<ContenidoDTO> findByCategoria(Integer idCategoria) {
        return contenidoRepository.findByCategoria(idCategoria);
    }

    public List<ContenidoDTO> findByGenero(Integer idGenero) {
        return contenidoRepository.findByGenero(idGenero);
    }

    public List<ContenidoDTO> buscar(String filtro) {
        return contenidoRepository.buscar(filtro);
    }

    public ContenidoDTO save(ContenidoDTO contenido) {
        contenidoRepository.save(contenido);
        return findById(contenido.getId());
    }

    public ContenidoDTO update(ContenidoDTO contenido) {
        contenidoRepository.update(contenido);
        return findById(contenido.getId());
    }

    public boolean delete(Integer id) {
        return contenidoRepository.delete(id) > 0;
    }
}