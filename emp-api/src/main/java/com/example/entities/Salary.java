package com.example.entities;

import jakarta.persistence.*;

@Entity
@Table(name = "salary_sheet")
public class Salary {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int id;
    private Integer employeeId;
    private String salaryCode;
    private String name;
    private String phone;

    private double basicSalary;
    private double houseRent;
    private double medical;
    private double transport;

    private double overTimeRate;
    private double overTimeHour;

    private double grossSalary;

    private String bankName;

    // ================= Calculation =================

    private void calculateSalary() {
        this.houseRent = basicSalary * 0.20;
        this.medical = basicSalary * 0.10;
        this.transport = basicSalary * 0.15;

        double overtimeAmount = overTimeRate * overTimeHour;

        this.grossSalary = basicSalary
                + houseRent
                + medical
                + transport
                + overtimeAmount;
    }

    // ================= Getter & Setter =================
    public Integer getEmployeeId() {
        return employeeId;
    }

    public void setEmployeeId(Integer employeeId) {
        this.employeeId = employeeId;
    }
    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getSalaryCode() {
        return salaryCode;
    }

    public void setSalaryCode(String salaryCode) {
        this.salaryCode = salaryCode;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public double getBasicSalary() {
        return basicSalary;
    }

    public void setBasicSalary(double basicSalary) {
        this.basicSalary = basicSalary;
        calculateSalary();
    }

    public double getHouseRent() {
        return houseRent;
    }

    public double getMedical() {
        return medical;
    }

    public double getTransport() {
        return transport;
    }

    public double getOverTimeRate() {
        return overTimeRate;
    }

    public void setOverTimeRate(double overTimeRate) {
        this.overTimeRate = overTimeRate;
        calculateSalary();
    }

    public double getOverTimeHour() {
        return overTimeHour;
    }

    public void setOverTimeHour(double overTimeHour) {
        this.overTimeHour = overTimeHour;
        calculateSalary();
    }

    public double getGrossSalary() {
        return grossSalary;
    }

    public String getBankName() {
        return bankName;
    }

    public void setBankName(String bankName) {
        this.bankName = bankName;
    }
}

