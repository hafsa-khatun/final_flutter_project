package com.example.controllers;

import com.example.entities.Project;
import com.example.repositories.ProjectRepository;

import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/projects")
public class ProjectController {
  final
  ProjectRepository projectRepo;

    public ProjectController(ProjectRepository projectRepo) {
        this.projectRepo = projectRepo;
    }
    //  Create Project
    @PostMapping
    public Project createProject(@RequestBody Project project) {
        return projectRepo.save(project);
    }

    //  Get All Projects
    @GetMapping
    public List<Project> getAllProjects() {
        return projectRepo.findAll();
    }

    // Get Project By Id
    @GetMapping("/{id}")
    public Project getProjectById(@PathVariable Long id) {
        return projectRepo.findById(id)
                .orElseThrow(() -> new RuntimeException("Project Not Found"));
    }

    //  Update Project
    @PutMapping("/{id}")
    public Project updateProject(@PathVariable Long id, @RequestBody Project projectDetails) {

        Project project = projectRepo.findById(id)
                .orElseThrow(() -> new RuntimeException("Project Not Found"));

        project.setProjectName(projectDetails.getProjectName());
        project.setProjectCode(projectDetails.getProjectCode());
        project.setDescription(projectDetails.getDescription());
        project.setStartDate(projectDetails.getStartDate());
        project.setEndDate(projectDetails.getEndDate());
        project.setBudget(projectDetails.getBudget());
        project.setStatus(projectDetails.getStatus());
        project.setClientName(projectDetails.getClientName());
        project.setPriority(projectDetails.getPriority());
        return projectRepo.save(project);
    }

    // Delete Project
    @DeleteMapping("/{id}")
    public void deleteProject(@PathVariable Long id) {
        projectRepo.deleteById(id);
    }
}
