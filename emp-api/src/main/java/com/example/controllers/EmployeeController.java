package com.example.controllers;

import com.example.entities.Department;
import com.example.entities.Designation;
import com.example.entities.Employee;
import com.example.repositories.DepartmentRepository;
import com.example.repositories.DesignationRepository;
import com.example.repositories.EmployeeRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;
@RestController
@RequestMapping("/api/employees")
public class EmployeeController {
    @Autowired
    private EmployeeRepository employeeRepo;

    @Autowired
    private DepartmentRepository departmentRepo;

    @Autowired
    private DesignationRepository designationRepo;

    // Get all employees
    @GetMapping
    public List<Employee> getAllEmployees() {
        return employeeRepo.findAll();
    }

    // Get employees by status (ACTIVE/INACTIVE)
    @GetMapping("/status/{status}")
    public List<Employee> getEmployeesByStatus(@PathVariable String status) {
        return employeeRepo.findByStatus(status.toUpperCase());
    }

    // Get employee by ID
    @GetMapping("/{id}")
    public Employee getEmployeeById(@PathVariable Long id) {
        return employeeRepo.findById(id).orElse(null);
    }

    // Create employee
    @PostMapping
    public Employee createEmployee(@RequestBody Employee employee) {
        if (employee.getDepartment() == null || employee.getDesignation() == null) {
            throw new RuntimeException("Department or Designation missing");
        }

        Department dept = departmentRepo.findById(employee.getDepartment().getId())
                .orElseThrow(() -> new RuntimeException("Invalid Department ID"));

        Designation desg = designationRepo.findById(employee.getDesignation().getId())
                .orElseThrow(() -> new RuntimeException("Invalid Designation ID"));

        employee.setDepartment(dept);
        employee.setDesignation(desg);

        if (employee.getStatus() == null) employee.setStatus("ACTIVE");
        else employee.setStatus(employee.getStatus().toUpperCase());

        return employeeRepo.save(employee);
    }

    // Update employee
    @PutMapping("/{id}")
    public Employee updateEmployee(@PathVariable Long id, @RequestBody Employee updatedEmp) {
        return employeeRepo.findById(id).map(emp -> {
            emp.setFullName(updatedEmp.getFullName());
            emp.setEmail(updatedEmp.getEmail());
            emp.setPhone(updatedEmp.getPhone());
            emp.setGender(updatedEmp.getGender());
            emp.setEmployeeType(updatedEmp.getEmployeeType());
            emp.setSalary(updatedEmp.getSalary());

            if (updatedEmp.getDepartment() != null && updatedEmp.getDepartment().getId() != null) {
                Department dept = departmentRepo.findById(updatedEmp.getDepartment().getId())
                        .orElseThrow(() -> new RuntimeException("Invalid Department ID"));
                emp.setDepartment(dept);
            }

            if (updatedEmp.getDesignation() != null && updatedEmp.getDesignation().getId() != null) {
                Designation desg = designationRepo.findById(updatedEmp.getDesignation().getId())
                        .orElseThrow(() -> new RuntimeException("Invalid Designation ID"));
                emp.setDesignation(desg);
            }

            // Update status if provided
            if (updatedEmp.getStatus() != null) {
                emp.setStatus(updatedEmp.getStatus().toUpperCase());
            }

            return employeeRepo.save(emp);
        }).orElseThrow(() -> new RuntimeException("Employee not found"));
    }

    // Delete employee


    @DeleteMapping("/{id}")
    public void deleteEmployee(@PathVariable Long id) {

        Employee emp = employeeRepo.findById(id)
                .orElseThrow(() -> new RuntimeException("Employee not found"));


        emp.setStatus("INACTIVE");


        employeeRepo.save(emp);
    }
}
