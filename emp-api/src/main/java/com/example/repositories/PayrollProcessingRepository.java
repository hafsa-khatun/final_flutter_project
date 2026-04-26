package com.example.repositories;

import com.example.entities.PayrollProcessing;
import jakarta.transaction.Transactional;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.YearMonth;
import java.util.List;

public interface PayrollProcessingRepository extends JpaRepository<PayrollProcessing, Long> {
    List<PayrollProcessing> findByEmployeeCode(String employeeCode);

    boolean existsByEmployeeCodeAndMonth(String employeeCode, String month);

    @Transactional


    void deleteByEmployeeCodeAndMonth(String employeeCode, String month);
    List<PayrollProcessing> findByMonth(String month);
}
