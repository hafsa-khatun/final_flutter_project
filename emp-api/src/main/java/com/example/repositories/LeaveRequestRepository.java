package com.example.repositories;

import com.example.entities.LeaveRequest;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDate;
import java.util.List;

public interface LeaveRequestRepository extends JpaRepository<LeaveRequest, Long> {

    @Query("SELECT l FROM LeaveRequest l " +
            "WHERE l.employeeCode = :employeeCode " +
            "AND l.status = com.example.entities.LeaveStatus.APPROVED " +
            "AND l.startDate <= :end AND l.endDate >= :start")
    List<LeaveRequest> findApprovedLeavesInMonth(
            @Param("employeeCode") String employeeCode,
            @Param("start") LocalDate start,
            @Param("end") LocalDate end);
}