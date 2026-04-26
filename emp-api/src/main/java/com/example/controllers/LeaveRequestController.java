package com.example.controllers;

import com.example.entities.LeaveRequest;
import com.example.services.LeaveRequestService;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/leave")

public class LeaveRequestController {

    private final LeaveRequestService service;

    public LeaveRequestController(LeaveRequestService service) {
        this.service = service;
    }

    @PostMapping
    public LeaveRequest create(@RequestBody LeaveRequest leave) {
        return service.applyLeave(leave);
    }

    @GetMapping
    public List<LeaveRequest> getAll() {
        return service.getAll();
    }

    @GetMapping("/{id}")
    public LeaveRequest getById(@PathVariable Long id) {
        return service.getById(id);
    }

    @PutMapping("/{id}")
    public LeaveRequest update(@PathVariable Long id,
                               @RequestBody LeaveRequest leave) {
        return service.update(id, leave);
    }

    @DeleteMapping("/{id}")
    public void delete(@PathVariable Long id) {
        service.delete(id);
    }

    @PutMapping("/approve/{id}")
    public LeaveRequest approve(@PathVariable Long id) {
        return service.approve(id);
    }

    @PutMapping("/reject/{id}")
    public LeaveRequest reject(@PathVariable Long id) {
        return service.reject(id);
    }

}
