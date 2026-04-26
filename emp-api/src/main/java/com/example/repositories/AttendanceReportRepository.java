package com.example.repositories;

import com.example.entities.AttendanceReport;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.LocalDate;
import java.time.YearMonth;
import java.util.List;

public interface AttendanceReportRepository extends JpaRepository<AttendanceReport, Long> {
    List<AttendanceReport> findByEmployeeCodeAndDateBetween(
            String employeeCode,
            LocalDate startDate,
            LocalDate endDate
    );
}
