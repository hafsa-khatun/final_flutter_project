package com.example.dtos;

public class DocumentDTO {
    private Long id;
    private String fileName;
    private String documentType;

    public DocumentDTO(Long id, String fileName, String documentType) {
        this.id = id;
        this.fileName = fileName;
        this.documentType = documentType;
    }

    // getters and setters
    public Long getId() { return id; }
    public String getFileName() { return fileName; }
    public String getDocumentType() { return documentType; }
    public void setId(Long id) { this.id = id; }
    public void setFileName(String fileName) { this.fileName = fileName; }
    public void setDocumentType(String documentType) { this.documentType = documentType; }
}
