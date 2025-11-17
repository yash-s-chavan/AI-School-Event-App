package com.example.backend.repository;

import org.springframework.data.mongodb.repository.MongoRepository;
import com.example.backend.model.Post;

public interface PostRepository extends MongoRepository<Post, String> {}
