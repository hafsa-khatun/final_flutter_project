package com.example.controllers;

import com.example.entities.Registration;
import com.example.repositories.RegistrationRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/registrations")
public class RegistrationController {
final
RegistrationRepository registrationRepo;

    public RegistrationController(RegistrationRepository registrationRepo) {
        this.registrationRepo = registrationRepo;
    }

    @PostMapping
    public Registration createRegistration(@RequestBody Registration registration) {
        return registrationRepo.save(registration);
    }

    // Get all registrations
    @GetMapping
    public List<Registration> getAllRegistrations() {
        return registrationRepo.findAll();
    }

    // Get registration by id
    @GetMapping("/{id}")
    public Registration getRegistrationById(@PathVariable Long id) {
        return registrationRepo.findById(id).orElse(null);
    }

    // ✅ Update
    @PutMapping("/{id}")
    public Registration updateRegistration(@PathVariable Long id,
                                           @RequestBody Registration registration) {

        Registration existing = registrationRepo.findById(id)
                .orElseThrow(() -> new RuntimeException("Registration not found"));

        existing.setName(registration.getName());
        existing.setPhone(registration.getPhone());
        existing.setReason(registration.getReason());

        return registrationRepo.save(existing);
    }

    // ✅ Delete
    @DeleteMapping("/{id}")
    public void deleteRegistration(@PathVariable Long id) {
        registrationRepo.deleteById(id);
    }
}


