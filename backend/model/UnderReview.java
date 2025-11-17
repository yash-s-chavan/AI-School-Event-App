package com.example.backend.model;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Document(collection = "under_review")
public class UnderReview {
    @Id
    private String id;
    private String username;
    private String category;
    private String question;
    private String aiResponse;
    private int likes;
    private int dislikes;
    private List<String> comments;
    private String timestamp;
}
