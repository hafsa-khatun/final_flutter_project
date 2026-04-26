package com.example.controllers;

import com.example.entities.Leave;
import com.example.repositories.LeaveRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/leaves")
public class LeaveController {
    final
    LeaveRepository leaveRepo;

    public LeaveController(LeaveRepository leaveRepo) {
        this.leaveRepo = leaveRepo;
    }
    @PostMapping
    public Leave createLeave(@RequestBody Leave leave) {
        return leaveRepo.save(leave);
    }

    // Get all leaves
    @GetMapping
    public List<Leave> getAllLeaves() {
        return leaveRepo.findAll();
    }

    // Get leaves by registration id
    @GetMapping("/registration/{registrationId}")
    public List<Leave> getLeavesByRegistration(@PathVariable Long registrationId) {
        return leaveRepo.findByRegistrationId(registrationId);
    }

    //  Update leave
    @PutMapping("/{id}")
    public Leave updateLeave(@PathVariable Long id, @RequestBody Leave leave) {
        Leave existing = leaveRepo.findById(id)
                .orElseThrow(() -> new RuntimeException("Leave not found"));

        existing.setLeaveType(leave.getLeaveType());
        existing.setStartDate(leave.getStartDate());
        existing.setEndDate(leave.getEndDate());
        existing.setStatus(leave.getStatus());
        existing.setRegistration(leave.getRegistration());

        return leaveRepo.save(existing);
    }

    //  Delete leave
    @DeleteMapping("/{id}")
    public void deleteLeave(@PathVariable Long id) {
        leaveRepo.deleteById(id);
    }

}

