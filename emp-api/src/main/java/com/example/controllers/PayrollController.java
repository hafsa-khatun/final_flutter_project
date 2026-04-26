package com.example.controllers;

import com.example.entities.PayrollProcessing;
import com.example.services.PayrollService;
import org.springframework.web.bind.annotation.*;

import java.time.YearMonth;
import java.util.List;

@RestController
@RequestMapping("/api/payroll")
public class PayrollController {

    private final PayrollService service;

    public PayrollController(PayrollService service) {
        this.service = service;
    }

    // 🔹 Process payroll for a month for all employees
    @PostMapping("/process-payroll")
    public List<PayrollProcessing> processPayroll(@RequestParam String month) {
        YearMonth ym = YearMonth.parse(month);
        return service.processAllEmployees(ym);
    }


    @GetMapping
    public List<PayrollProcessing> getAll() {
        return service.getAll();
    }

    @GetMapping("/{id}")
    public PayrollProcessing getById(@PathVariable Long id) {
        return service.getById(id);
    }

    @DeleteMapping("/{id}")
    public void delete(@PathVariable Long id) {
        service.delete(id);
    }
}
