package com.example.controllers;

import com.example.entities.Salary;
import com.example.repositories.SalaryRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/salary")
public class SalaryController {
    final
    SalaryRepository salaryRepository;

    public SalaryController(SalaryRepository salaryRepository) {
        this.salaryRepository = salaryRepository;
    }

    @PostMapping("/save")
    public Salary saveSalary(@RequestBody Salary salary) {
        return salaryRepository.save(salary);
    }
    @GetMapping("/all")
    public List<Salary> getAllSalary() {
        return salaryRepository.findAll();
    }
    @GetMapping("/{id}")
    public Salary getSalaryById(@PathVariable int id) {
        return salaryRepository.findById(id).orElse(null);
    }
    @PutMapping("/update/{id}")
    public Salary updateSalary(@PathVariable int id, @RequestBody Salary salaryDetails) {

        return salaryRepository.findById(id).map(salary -> {

            salary.setSalaryCode(salaryDetails.getSalaryCode());
            salary.setName(salaryDetails.getName());
            salary.setPhone(salaryDetails.getPhone());
            salary.setBasicSalary(salaryDetails.getBasicSalary());
            salary.setOverTimeRate(salaryDetails.getOverTimeRate());
            salary.setOverTimeHour(salaryDetails.getOverTimeHour());
            salary.setBankName(salaryDetails.getBankName());

            return salaryRepository.save(salary);

        }).orElseThrow(() -> new RuntimeException("Salary not found with id " + id));
    }

    @DeleteMapping("/delete/{id}")
    public void deleteSalary(@PathVariable int id) {
        salaryRepository.deleteById(id);
    }
}
