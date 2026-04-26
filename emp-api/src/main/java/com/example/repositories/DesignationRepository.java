package com.example.repositories;

import com.example.entities.Designation;
import org.hibernate.boot.models.JpaAnnotations;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
@Repository
public interface DesignationRepository extends JpaRepository<Designation,Long> {
    List<Designation> findByDepartmentId(Long departmentId);
}
