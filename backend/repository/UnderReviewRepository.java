package com.example.backend.repository;

import com.example.backend.model.UnderReview;
import org.springframework.data.mongodb.repository.MongoRepository;

public interface UnderReviewRepository extends MongoRepository<UnderReview, String> {
}
