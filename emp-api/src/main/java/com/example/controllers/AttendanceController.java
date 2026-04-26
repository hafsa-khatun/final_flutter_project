package com.example.controllers;

import com.example.entities.AttendanceReport;
import com.example.services.AttendanceService;
import org.springframework.web.bind.annotation.*;


import java.util.List;

@RestController
@RequestMapping("/attendance")
public class AttendanceController {

    private final AttendanceService service;

    public AttendanceController(AttendanceService service) {
        this.service = service;
    }

    @PostMapping
    public AttendanceReport create(@RequestBody AttendanceReport report) {
        return service.save(report);
    }

    @GetMapping
    public List<AttendanceReport> getAll() {
        return service.getAll();
    }

    @GetMapping("/{id}")
    public AttendanceReport getById(@PathVariable Long id) {
        return service.getById(id);
    }

    @PutMapping("/{id}")
    public AttendanceReport update(@PathVariable Long id,
                                   @RequestBody AttendanceReport report) {
        return service.update(id, report);
    }

    @DeleteMapping("/{id}")
    public void delete(@PathVariable Long id) {
        service.delete(id);
    }
}

