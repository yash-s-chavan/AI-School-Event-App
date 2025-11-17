package com.example.backend.repository;

import com.example.backend.model.Password;
import org.springframework.data.mongodb.repository.MongoRepository;

import java.util.Optional;

public interface PasswordRepository extends MongoRepository<Password, String> {
    Optional<Password> findByPassword(String password);
}
