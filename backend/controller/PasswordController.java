package com.example.backend.controller;

import com.example.backend.model.Password;
import com.example.backend.repository.PasswordRepository;
import org.springframework.web.bind.annotation.*;

import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/passwords")
@CrossOrigin(origins = "*")
public class PasswordController {

    private final PasswordRepository passwordRepository;

    public PasswordController(PasswordRepository passwordRepository) {
        this.passwordRepository = passwordRepository;
    }

    @PostMapping("/login")
    public String login(@RequestBody Map<String, String> body) {
        String password = body.get("password");
        Optional<Password> match = passwordRepository.findByPassword(password);
        return match.isPresent() ? "success" : "failure";
    }

}
