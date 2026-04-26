package com.example.controllers;

import com.example.entities.Department;
import com.example.repositories.DepartmentRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Date;
import java.util.List;

@RestController
@RequestMapping("/api/departments")
public class departmentController {
    @Autowired
    private DepartmentRepository departmentRepo;

    // Get all departments
    @GetMapping
    public List<Department> getAllDepartments() {

        return departmentRepo.findAll();
    }

    // Get department by ID
    @GetMapping("/{id}")
    public Department getDepartmentById(@PathVariable Long id) {

        return departmentRepo.findById(id).orElse(null);
    }

    // Create new department
    @PostMapping
    public ResponseEntity<?> createDepartment(@RequestBody Department department) {
        try {
            if (department.getName() == null || department.getName().trim().isEmpty()) {
                return ResponseEntity.badRequest().body("Department name is required.");
            }

            department.setCreatedDate(new Date());
            Department saved = departmentRepo.save(department);
            return ResponseEntity.ok(saved);
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Error saving department: " + e.getMessage());
        }
    }

    // Update department
    @PutMapping("/{id}")
    public Department updateDepartment(@PathVariable Long id, @RequestBody Department updatedDept) {
        return departmentRepo.findById(id).map(dept -> {
            dept.setName(updatedDept.getName());
            return departmentRepo.save(dept);
        }).orElse(null);
    }

    // Delete department
    @DeleteMapping("/{id}")
    public void deleteDepartment(@PathVariable Long id) {

        departmentRepo.deleteById(id);
    }
}