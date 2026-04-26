package com.example.controllers;

import com.example.entities.Training;
import com.example.repositories.TrainingRepository;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/trainings")
public class TrainingController {
    private final TrainingRepository trainingRepo;

    public TrainingController(TrainingRepository trainingRepo) {
        this.trainingRepo= trainingRepo;
    }
    //  Create Training
    @PostMapping("create-training")
    public Training createTraining(@RequestBody Training training) {
        return trainingRepo.save(training);
    }

    //  Get All Trainings
    @GetMapping("")
    public List<Training> getAllTrainings() {
        return trainingRepo.findAll();
    }

    //  Get Training By
    @GetMapping("/{id}")
    public Training getTrainingById(@PathVariable Long id) {
        return trainingRepo.findById(id)
                .orElseThrow(() -> new RuntimeException("Training not found"));
    }

    //  Update Training
    @PutMapping("/{id}")
    public Training updateTraining(@PathVariable Long id,
                                   @RequestBody Training updatedTraining) {

        Training existing = trainingRepo.findById(id)
                .orElseThrow(() -> new RuntimeException("Training not found"));

        existing.setTrainingTitle(updatedTraining.getTrainingTitle());
        existing.setTrainerName(updatedTraining.getTrainerName());
        existing.setDescription(updatedTraining.getDescription());
        existing.setStartDate(updatedTraining.getStartDate());
        existing.setEndDate(updatedTraining.getEndDate());
        existing.setLocation(updatedTraining.getLocation());
        existing.setCertificateNumber(updatedTraining.getCertificateNumber());
        existing.setIssueDate(updatedTraining.getIssueDate());
        existing.setGrade(updatedTraining.getGrade());

        return trainingRepo.save(existing);
    }

    //  Delete Training
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteTraining(@PathVariable Long id) {
        trainingRepo.deleteById(id);
        return ResponseEntity.noContent().build();
    }

}
