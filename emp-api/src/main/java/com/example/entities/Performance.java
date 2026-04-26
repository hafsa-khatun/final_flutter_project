package com.example.entities;

import jakarta.persistence.*;

@Entity
@Table(name = "performance")
public class Performance {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "employee_id", nullable = false)
    private Long employeeId; // Employee table a change korben na

    @Column(name = "performance_ratting")
    private Double performanceRatting;

    @Column(name = "kpi_score")
    private Double kpiScore;

    @Column(name = "annual_review")
    private String annualReview;

    @Column(name = "promotion")
    private Boolean promotion;

    // Constructors
    public Performance() {}

    public Performance(Long employeeId, Double performanceRatting, Double kpiScore, String annualReview, Boolean promotion) {
        this.employeeId = employeeId;
        this.performanceRatting = performanceRatting;
        this.kpiScore = kpiScore;
        this.annualReview = annualReview;
        this.promotion = promotion;
    }

    // Getters and Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public Long getEmployeeId() { return employeeId; }
    public void setEmployeeId(Long employeeId) { this.employeeId = employeeId; }

    public Double getPerformanceRatting() { return performanceRatting; }
    public void setPerformanceRatting(Double performanceRatting) { this.performanceRatting = performanceRatting; }

    public Double getKpiScore() { return kpiScore; }
    public void setKpiScore(Double kpiScore) { this.kpiScore = kpiScore; }

    public String getAnnualReview() { return annualReview; }
    public void setAnnualReview(String annualReview) { this.annualReview = annualReview; }

    public Boolean getPromotion() { return promotion; }
    public void setPromotion(Boolean promotion) { this.promotion = promotion; }
}
