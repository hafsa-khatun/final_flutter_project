package com.example.controllers;

import com.example.entities.Applicant;
import com.example.repositories.ApplicantRepository;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/applicants")
public class ApplicantController {

    private final ApplicantRepository applicantRepo;

    public ApplicantController(ApplicantRepository applicantRepo) {
        this.applicantRepo = applicantRepo;
    }

    //  Create Applicant
    @PostMapping("/create-applicant")
    public Applicant createApplicant(@RequestBody Applicant applicant) {
        applicant.setStatus(Applicant.ApplicationStatus.APPLIED);
        return applicantRepo.save(applicant);
    }

    // Get All Applicants
    @GetMapping
    public List<Applicant> getAllApplicants() {
        return applicantRepo.findAll();
    }

    // Get Applicant By Id
    @GetMapping("/{id}")
    public Applicant getApplicantById(@PathVariable Long id) {
        return applicantRepo.findById(id).orElse(null);
    }

    //  Update Status
    @PutMapping("/{id}/status")
    public Applicant updateStatus(@PathVariable Long id,
                                  @RequestParam Applicant.ApplicationStatus status) {

        Applicant applicant = applicantRepo.findById(id).orElse(null);

        if (applicant != null) {
            applicant.setStatus(status);
            return applicantRepo.save(applicant);
        }

        return null;
    }

    //  Delete Applicant
    @DeleteMapping("/{id}")
    public String deleteApplicant(@PathVariable Long id) {
        applicantRepo.deleteById(id);
        return "Applicant deleted successfully";
    }
}
