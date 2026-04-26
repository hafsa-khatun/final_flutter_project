package com.example.controllers;

import com.example.dtos.DocumentDTO;
import com.example.entities.Documents;
import com.example.entities.Employee;
import com.example.repositories.DocumentRepository;
import com.example.repositories.EmployeeRepository;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/documents")
public class DocumentController {

    private final DocumentRepository documentRepo;
    private final EmployeeRepository employeeRepo;

    public DocumentController(DocumentRepository documentRepo,
                              EmployeeRepository employeeRepo) {
        this.documentRepo = documentRepo;
        this.employeeRepo = employeeRepo;
    }

    //  Upload File
    @PostMapping("/upload/{employeeId}")
    public ResponseEntity<?> uploadFile(
            @PathVariable Long employeeId,
            @RequestParam("file") MultipartFile file,
            @RequestParam("documentType") String documentType
    ) throws IOException {

        Employee employee = employeeRepo.findById(employeeId)
                .orElseThrow(() -> new RuntimeException("Employee not found"));

        Documents document = new Documents();
        document.setFileName(file.getOriginalFilename());
        document.setFileType(file.getContentType());
        document.setData(file.getBytes());
        document.setDocumentType(documentType);
        document.setEmployee(employee);

        documentRepo.save(document);

        return ResponseEntity.ok(
                Map.of("message", "File Uploaded Successfully")
        );
    }



    //  Download File
    @GetMapping("/download/{id}")
    public ResponseEntity<byte[]> downloadFile(@PathVariable Long id) {
        Documents document = documentRepo.findById(id)
                .orElseThrow(() -> new RuntimeException("File not found"));
        return ResponseEntity.ok()
                .header("Content-Disposition",
                        "attachment; filename=\"" + document.getFileName() + "\"")
                .body(document.getData());
    }

    //  Get Documents By Employee
    @GetMapping("/employee/{employeeId}")
    public List<DocumentDTO> getByEmployee(@PathVariable Long employeeId) {
        if(employeeId == null) throw new RuntimeException("Employee ID missing");
        return documentRepo.findByEmployee_Id(employeeId)
                .stream()
                .map(d -> new DocumentDTO(d.getId(), d.getFileName(), d.getDocumentType()))
                .collect(Collectors.toList());
    }



    //  Delete Document
    @DeleteMapping("/{id}")
    public ResponseEntity<String> deleteDocument(@PathVariable Long id) {
        documentRepo.deleteById(id);
        return ResponseEntity.ok("Document Deleted Successfully");
    }
}
