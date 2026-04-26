package com.example.controllers;

import com.example.entities.Performance;
import com.example.repositories.PerformanceRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/performances")
public class PerformanceController {
    final
    PerformanceRepository performanceRepo;

    public PerformanceController(PerformanceRepository performanceRepo) {
        this.performanceRepo = performanceRepo;
    }
    @GetMapping
    public List<Performance> getAllPerformances() {
        return performanceRepo.findAll();
    }

    // Specific employee er performance
    @GetMapping("/employee/{employeeId}")
    public List<Performance> getByEmployee(@PathVariable Long employeeId) {
        return performanceRepo.findByEmployeeId(employeeId);
    }

    // Add new performance
    @PostMapping
    public Performance createPerformance(@RequestBody Performance performance) {
        return performanceRepo.save(performance);
    }

    // Update performance
    @PutMapping("/{id}")
    public Performance updatePerformance(@PathVariable Long id, @RequestBody Performance updatedPerformance) {
        Optional<Performance> optionalPerformance = performanceRepo.findById(id);
        if(optionalPerformance.isPresent()) {
            Performance perf = optionalPerformance.get();
            perf.setEmployeeId(updatedPerformance.getEmployeeId());
            perf.setPerformanceRatting(updatedPerformance.getPerformanceRatting());
            perf.setKpiScore(updatedPerformance.getKpiScore());
            perf.setAnnualReview(updatedPerformance.getAnnualReview());
            perf.setPromotion(updatedPerformance.getPromotion());
            return performanceRepo.save(perf);
        }
        throw new RuntimeException("Performance not found with id " + id);
    }

    // Delete performance
    @DeleteMapping("/{id}")
    public ResponseEntity<?> deletePerformance(@PathVariable Long id) {
        if (!performanceRepo.existsById(id)) {
            return ResponseEntity.notFound().build();
        }

        performanceRepo.deleteById(id);


        return ResponseEntity.ok().body(Map.of("message", "Performance record deleted successfully with id: " + id));
    }
}