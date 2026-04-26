package com.example.services;

import com.example.entities.Employee;
import com.example.entities.PayrollProcessing;
import com.example.entities.Salary;
import com.example.repositories.EmployeeRepository;
import com.example.repositories.PayrollProcessingRepository;
import com.example.repositories.SalaryRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.YearMonth;
import java.util.ArrayList;
import java.util.List;

@Service
public class PayrollService {

    private final EmployeeRepository employeeRepo;
    private final PayrollProcessingRepository payrollRepo;
    private final AttendanceService attendanceService;
    private final LeaveRequestService leaveService;
    private final SalaryRepository salaryRepo; // ✅ যোগ করুন

    public PayrollService(EmployeeRepository employeeRepo,
                          PayrollProcessingRepository payrollRepo,
                          AttendanceService attendanceService,
                          LeaveRequestService leaveService,
                          SalaryRepository salaryRepo) { // ✅ যোগ করুন
        this.employeeRepo = employeeRepo;
        this.payrollRepo = payrollRepo;
        this.attendanceService = attendanceService;
        this.leaveService = leaveService;
        this.salaryRepo = salaryRepo; // ✅ যোগ করুন
    }

    @Transactional
    public List<PayrollProcessing> processAllEmployees(YearMonth month) {
        String monthStr = month.toString();

        List<Employee> employees = employeeRepo.findAll();

        for (Employee emp : employees) {
            String empCode = String.valueOf(emp.getId());

            Salary salaryData = salaryRepo.findByEmployeeId(emp.getId()).orElse(null);
            if (salaryData == null) {
                System.out.println("⚠️ Salary not found for employee: " + empCode);
                continue;
            }

            payrollRepo.deleteByEmployeeCodeAndMonth(empCode, monthStr);
            payrollRepo.flush();

            int totalAbsent = attendanceService.countAbsentOnly(empCode, month);
            int approvedLeave = leaveService.countApprovedLeaveDays(empCode, month);
            int finalAbsent = totalAbsent;

            double grossSalary = salaryData.getGrossSalary();
            double dailySalary = grossSalary / month.lengthOfMonth();
            double deduction = Math.round(dailySalary * finalAbsent * 100.0) / 100.0;
            double netSalary = Math.round((grossSalary - deduction) * 100.0) / 100.0;

            PayrollProcessing payroll = new PayrollProcessing();
            payroll.setEmployeeCode(empCode);
            payroll.setEmployeeName(emp.getFullName());
            payroll.setMonth(monthStr);
            payroll.setBasicSalary(salaryData.getBasicSalary());
            payroll.setGrossSalary(grossSalary);
            payroll.setAbsentDays(totalAbsent);
            payroll.setApprovedLeaveDays(approvedLeave);
            payroll.setDeduction(deduction);
            payroll.setNetSalary(netSalary);

            payrollRepo.save(payroll);
        }

        // ✅ সব save শেষে fresh data return করুন
        return payrollRepo.findByMonth(monthStr);
    }

    public List<PayrollProcessing> getAll() {
        return payrollRepo.findAll();
    }

    public PayrollProcessing getById(Long id) {
        return payrollRepo.findById(id)
                .orElseThrow(() -> new RuntimeException("Payroll not found"));
    }

    public void delete(Long id) {
        payrollRepo.deleteById(id);
    }
}
