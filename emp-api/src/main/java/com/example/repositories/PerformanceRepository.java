package com.example.repositories;

import com.example.entities.Performance;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
@Repository
public interface PerformanceRepository extends JpaRepository<Performance,Long> {
    List<Performance> findByEmployeeId(Long employeeId);
}
