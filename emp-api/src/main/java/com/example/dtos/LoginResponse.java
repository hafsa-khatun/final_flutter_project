package com.example.dtos;

public class LoginResponse {
    private Long id;
    private String username;
    private String role;
    private String token;
    private String fullName;
    private Long employeeId;

    public LoginResponse(Long id, String username, String role, String token, String fullName, Long employeeId) {
        this.id = id;
        this.username = username;
        this.role = role;
        this.token = token;
        this.fullName = fullName;
        this.employeeId = employeeId;
    }

    public Long getId() { return id; }
    public String getUsername() { return username; }
    public String getRole() { return role; }
    public String getToken() { return token; }
    public String getFullName() { return fullName; }
    public Long getEmployeeId() { return employeeId; }
}
