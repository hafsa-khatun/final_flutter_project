package com.example.controllers;

import com.example.services.ReportService;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.HashMap;
import java.util.Map;
@RestController
@RequestMapping("/reports")
public class ReportController {
    private final ReportService reportService;

    public ReportController(ReportService reportService) {
        this.reportService = reportService;
    }

    @GetMapping("/employee-report")
    public ResponseEntity<byte[]> employeeCard(){
        Map<String, Object> params = new HashMap<>();

        try {
            byte[] pdf = reportService.generateReport("employees",params);

            return ResponseEntity.ok()
                    .header(HttpHeaders.CONTENT_DISPOSITION,"inline; filename=invoice.pdf")
                    .contentType(MediaType.APPLICATION_PDF)
                    .body(pdf);
        } catch (Exception e) {
            throw new RuntimeException(e);
        }

    }

    @GetMapping("/project-report")
    public ResponseEntity<byte[]> projectCard(@RequestParam Long pId){
        Map<String, Object> params = new HashMap<>();
        params.put("project_id",pId);
        try {
            byte[] pdf = reportService.generateReport("project_employee",params);

            return ResponseEntity.ok()
                    .header(HttpHeaders.CONTENT_DISPOSITION,"inline; filename=project.pdf")
                    .contentType(MediaType.APPLICATION_PDF)
                    .body(pdf);
        } catch (Exception e) {
            throw new RuntimeException(e);
        }

    }

    @GetMapping("/training-report")
    public ResponseEntity<byte[]> trainingCard(){
        Map<String, Object> params = new HashMap<>();

        try {
            byte[] pdf = reportService.generateReport("training",params);

            return ResponseEntity.ok()
                    .header(HttpHeaders.CONTENT_DISPOSITION,"inline; filename=Trainee.pdf")
                    .contentType(MediaType.APPLICATION_PDF)
                    .body(pdf);
        } catch (Exception e) {
            throw new RuntimeException(e);
        }

    }
    @GetMapping("/applicant-report")
    public ResponseEntity<byte[]> applicantCard(){
        Map<String, Object> params = new HashMap<>();

        try {
            byte[] pdf = reportService.generateReport("applicant",params);

            return ResponseEntity.ok()
                    .header(HttpHeaders.CONTENT_DISPOSITION,"inline; filename=Applicant.pdf")
                    .contentType(MediaType.APPLICATION_PDF)
                    .body(pdf);
        } catch (Exception e) {
            throw new RuntimeException(e);
        }

    }
    @GetMapping("/performance-report")
    public ResponseEntity<byte[]> performanceCard(){
        Map<String, Object> params = new HashMap<>();

        try {
            byte[] pdf = reportService.generateReport("performance",params);

            return ResponseEntity.ok()
                    .header(HttpHeaders.CONTENT_DISPOSITION,"inline; filename=Applicant.pdf")
                    .contentType(MediaType.APPLICATION_PDF)
                    .body(pdf);
        } catch (Exception e) {
            throw new RuntimeException(e);
        }

    }
    @GetMapping("/payroll-report")
    public ResponseEntity<byte[]> payrollCard(){
        Map<String, Object> params = new HashMap<>();

        try {
            byte[] pdf = reportService.generateReport("payroll",params);

            return ResponseEntity.ok()
                    .header(HttpHeaders.CONTENT_DISPOSITION,"inline; filename=Payroll.pdf")
                    .contentType(MediaType.APPLICATION_PDF)
                    .body(pdf);
        } catch (Exception e) {
            throw new RuntimeException(e);
        }

    }
}
