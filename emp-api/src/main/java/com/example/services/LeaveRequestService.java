package com.example.services;

import com.example.entities.LeaveRequest;
import com.example.entities.LeaveStatus;
import com.example.repositories.LeaveRequestRepository;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.YearMonth;
import java.util.List;

@Service
public class LeaveRequestService {

    private final LeaveRequestRepository repository;

    public LeaveRequestService(LeaveRequestRepository repository) {
        this.repository = repository;
    }

    public LeaveRequest applyLeave(LeaveRequest leave) {
        leave.setStatus(LeaveStatus.PENDING);
        return repository.save(leave);
    }

    public List<LeaveRequest> getAll() {
        return repository.findAll();
    }

    public LeaveRequest getById(Long id) {
        return repository.findById(id).orElseThrow();
    }

    public LeaveRequest update(Long id, LeaveRequest updated) {
        LeaveRequest existing = repository.findById(id).orElseThrow();
        existing.setLeaveType(updated.getLeaveType());
        existing.setStartDate(updated.getStartDate());
        existing.setEndDate(updated.getEndDate());
        existing.setReason(updated.getReason());
        return repository.save(existing);
    }

    public void delete(Long id) {
        repository.deleteById(id);
    }

    public LeaveRequest approve(Long id) {
        LeaveRequest leave = repository.findById(id).orElseThrow();
        leave.setStatus(LeaveStatus.APPROVED);
        return repository.save(leave);
    }

    public LeaveRequest reject(Long id) {
        LeaveRequest leave = repository.findById(id).orElseThrow();
        leave.setStatus(LeaveStatus.REJECTED);
        return repository.save(leave);
    }


    public int countApprovedLeaveDays(String employeeCode, YearMonth month) {
        LocalDate start = month.atDay(1);
        LocalDate end = month.atEndOfMonth();

        List<LeaveRequest> leaves = repository.findApprovedLeavesInMonth(employeeCode, start, end);

        int totalDays = 0;
        for (LeaveRequest leave : leaves) {
            LocalDate leaveStart = leave.getStartDate().isBefore(start) ? start : leave.getStartDate();
            LocalDate leaveEnd = leave.getEndDate().isAfter(end) ? end : leave.getEndDate();
            totalDays += (int) (leaveEnd.toEpochDay() - leaveStart.toEpochDay() + 1);
        }

        System.out.println("Employee: " + employeeCode + " ApprovedLeaveDays: " + totalDays);
        return totalDays;
    }
}