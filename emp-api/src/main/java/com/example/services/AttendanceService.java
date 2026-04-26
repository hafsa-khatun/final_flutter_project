package com.example.services;

import com.example.entities.AttendanceReport;
import com.example.entities.AttendanceStatus;
import com.example.repositories.AttendanceReportRepository;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.YearMonth;
import java.util.List;

@Service
public class AttendanceService {

    private final AttendanceReportRepository repository;

    public AttendanceService(AttendanceReportRepository repository) {
        this.repository = repository;
    }

    // CREATE
    public AttendanceReport save(AttendanceReport report) {
        return repository.save(report);
    }

    // READ ALL
    public List<AttendanceReport> getAll() {
        return repository.findAll();
    }

    // READ BY ID
    public AttendanceReport getById(Long id) {
        return repository.findById(id).orElseThrow();
    }

    // UPDATE
    public AttendanceReport update(Long id, AttendanceReport updated) {
        AttendanceReport existing = repository.findById(id).orElseThrow();

        existing.setEmployeeCode(updated.getEmployeeCode());
        existing.setEmployeeName(updated.getEmployeeName());
        existing.setDate(updated.getDate());
        existing.setInTime(updated.getInTime());
        existing.setOutTime(updated.getOutTime());
        existing.setStatus(updated.getStatus());

        return repository.save(existing);
    }

    // DELETE
    public void delete(Long id) {
        repository.deleteById(id);
    }

    // Your Existing Logic (Keep)
    public int countEffectiveAbsent(String employeeCode, YearMonth month) {
        LocalDate startDate = month.atDay(1);
        LocalDate endDate = month.atEndOfMonth();

        List<AttendanceReport> list =
                repository.findByEmployeeCodeAndDateBetween(
                        employeeCode, startDate, endDate
                );

        long absent = list.stream()
                .filter(a -> a.getStatus() == AttendanceStatus.ABSENT)
                .count();

        long late = list.stream()
                .filter(a -> a.getStatus() == AttendanceStatus.LATE)
                .count();

        return (int) (absent + (late / 3));
    }
    //new add
    public int countAbsentOnly(String employeeCode, YearMonth month) {
        LocalDate start = month.atDay(1);
        LocalDate end = month.atEndOfMonth();

        return (int) repository.findByEmployeeCodeAndDateBetween(employeeCode, start, end)
                .stream()
                .filter(a -> a.getStatus() == AttendanceStatus.ABSENT)
                .count();
    }


}
