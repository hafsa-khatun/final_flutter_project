package com.example.entities;

import jakarta.persistence.*;
import java.time.YearMonth;

@Entity
@Table(name = "payroll_processing")
public class PayrollProcessing {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String employeeCode;    // frontend থেকে select
    private String employeeName;    // backend auto set

    private Double basicSalary;     // backend fetch
    private Double grossSalary;
    private String month;

    private int absentDays;
    private int approvedLeaveDays;
    private Double deduction;
    private Double netSalary;

    public String getMonth() {
        return month;
    }

    public void setMonth(String month) {
        this.month = month;
    }
    // ===== Getters & Setters =====

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getEmployeeCode() { return employeeCode; }
    public void setEmployeeCode(String employeeCode) { this.employeeCode = employeeCode; }

    public String getEmployeeName() { return employeeName; }
    public void setEmployeeName(String employeeName) { this.employeeName = employeeName; }

    public Double getBasicSalary() { return basicSalary; }
    public void setBasicSalary(Double basicSalary) { this.basicSalary = basicSalary; }

    public Double getGrossSalary() { return grossSalary; }
    public void setGrossSalary(Double grossSalary) { this.grossSalary = grossSalary; }



    public int getAbsentDays() { return absentDays; }
    public void setAbsentDays(int absentDays) { this.absentDays = absentDays; }

    public int getApprovedLeaveDays() { return approvedLeaveDays; }
    public void setApprovedLeaveDays(int approvedLeaveDays) { this.approvedLeaveDays = approvedLeaveDays; }

    public Double getDeduction() { return deduction; }
    public void setDeduction(Double deduction) { this.deduction = deduction; }

    public Double getNetSalary() { return netSalary; }
    public void setNetSalary(Double netSalary) { this.netSalary = netSalary; }
}
