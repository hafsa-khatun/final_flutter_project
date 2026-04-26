package com.example.controllers;

import com.example.entities.Department;
import com.example.entities.Designation;
import com.example.repositories.DepartmentRepository;
import com.example.repositories.DesignationRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/designations")
public class designationController {
    @Autowired
    private DesignationRepository designationRepo;

    @Autowired
    private DepartmentRepository departmentRepo;

    // Get all designations
    @GetMapping
    public List<Designation> getAllDesignations() {

        return designationRepo.findAll();
    }

    // Get designation by ID
    @GetMapping("/{id}")
    public Designation getDesignationById(@PathVariable Long id) {

        return designationRepo.findById(id).orElse(null);
    }

    // Create designation
    @PostMapping
    public Designation createDesignation(@RequestBody Designation designation) {
        if (designation.getDepartment() == null || designation.getDepartment().getId() == null) {
            throw new RuntimeException("Invalid department");
        }
        Department dept = departmentRepo.findById(designation.getDepartment().getId())
                .orElseThrow(() -> new RuntimeException("Department not found"));
        designation.setDepartment(dept);
        return designationRepo.save(designation);
    }

    // Update designation
    @PutMapping("/{id}")
    public Designation updateDesignation(@PathVariable Long id, @RequestBody Designation updatedDesg) {
        return designationRepo.findById(id).map(designation -> {
            designation.setName(updatedDesg.getName());

            if (updatedDesg.getDepartment() != null) {
                Department dept = departmentRepo.findById(updatedDesg.getDepartment().getId()).orElse(null);
                if (dept != null) designation.setDepartment(dept);
            }
            return designationRepo.save(designation);
        }).orElse(null);
    }

    // Delete designation
    @DeleteMapping("/{id}")
    public void deleteDesignation(@PathVariable Long id) {

        designationRepo.deleteById(id);
    }

    // Get designations by department (for dependent dropdown)
    @GetMapping("/by-department/{deptId}")
    public List<Designation> getDesignationsByDepartment(@PathVariable Long deptId) {
        return designationRepo.findByDepartmentId(deptId);
    }
}
