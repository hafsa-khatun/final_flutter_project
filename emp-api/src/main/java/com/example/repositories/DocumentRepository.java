package com.example.repositories;

import com.example.entities.Documents;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface DocumentRepository extends JpaRepository<Documents, Long> {

    List<Documents> findByEmployee_Id(Long employeeId);



}
