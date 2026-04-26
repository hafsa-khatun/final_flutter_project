package com.example.controllers;

import com.example.dtos.LoginRequest;
import com.example.dtos.LoginResponse;
import com.example.entities.User;
import com.example.repositories.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Optional;
import java.util.UUID;

@RestController
@RequestMapping("/api/auth")
public class AuthController {
    @Autowired
    private UserRepository userRepository;

    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody LoginRequest loginRequest) {
        Optional<User> user = userRepository.findByUsername(loginRequest.getUsername());

        if (user.isEmpty()) {
            return ResponseEntity.status(401).body("Invalid username or password");
        }

        User foundUser = user.get();

        if (!foundUser.getPassword().equals(loginRequest.getPassword())) {
            return ResponseEntity.status(401).body("Invalid username or password");
        }

        String token = UUID.randomUUID().toString();

        LoginResponse response = new LoginResponse(
                foundUser.getId(),
                foundUser.getUsername(),
                foundUser.getRole().name(),

                token,
                foundUser.getFullName(),
                foundUser.getEmployeeId()
        );

        return ResponseEntity.ok(response);
    }
}
