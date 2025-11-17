package com.example.backend.controller;

import com.example.backend.model.Post;
import com.example.backend.model.UnderReview;
import com.example.backend.repository.PostRepository;
import com.example.backend.repository.UnderReviewRepository;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/posts")
@CrossOrigin(origins = "*")
public class PostController {

    private final PostRepository postRepository;
    private final UnderReviewRepository underReviewRepository;

    public PostController(PostRepository postRepository, UnderReviewRepository underReviewRepository) {
        this.postRepository = postRepository;
        this.underReviewRepository = underReviewRepository;
    }

    // Submit a post
    @PostMapping
    public ResponseEntity<String> submitPost(@RequestBody UnderReview post) {
        underReviewRepository.save(post);
        return ResponseEntity.ok("submitted_for_review");
    }

    // Add under-review post
    @PostMapping("/underReview")
    public UnderReview addUnderReview(@RequestBody UnderReview review) {
        review.setTimestamp(LocalDateTime.now().toString());
        return underReviewRepository.save(review);
    }

    // Get all under-review posts (Admin view)
    @GetMapping("/admin/under-review")
    public List<UnderReview> getUnderReview() {
        return underReviewRepository.findAll();
    }

    // Approve under-review post, and move to main posts
    @PostMapping("/admin/approve/{id}")
    public ResponseEntity<String> approvePost(@PathVariable String id) {
        Optional<UnderReview> pending = underReviewRepository.findById(id);
        if (pending.isEmpty()) return ResponseEntity.notFound().build();

        UnderReview review = pending.get();

        Post approved = new Post(
                null,
                review.getUsername(),
                review.getCategory(),
                review.getQuestion(),
                review.getAiResponse(),
                review.getLikes(),
                review.getDislikes(),
                review.getComments(),
                review.getTimestamp()
        );

        postRepository.save(approved);
        underReviewRepository.deleteById(id);

        return ResponseEntity.ok("approved");
    }

    // Reject under-review post (delete it)
    @DeleteMapping("/admin/reject/{id}")
    public ResponseEntity<String> rejectPost(@PathVariable String id) {
        underReviewRepository.deleteById(id);
        return ResponseEntity.ok("rejected");
    }

    // Get main public feed posts
    @GetMapping
    public List<Post> getAllPosts() {
        return postRepository.findAll();
    }

    // Get count of under-review posts
    @GetMapping("/underreview/count")
    public long getUnderReviewCount() {
        return underReviewRepository.count();
    }

    // Like / Dislike
    @PostMapping("/{id}/reaction")
    public ResponseEntity<String> updateReaction(
            @PathVariable String id,
            @RequestBody Map<String, String> body
    ) {
        Optional<Post> optional = postRepository.findById(id);
        if (optional.isEmpty()) return ResponseEntity.notFound().build();

        Post post = optional.get();
        String type = body.get("type");

        if ("like".equals(type)) {
            post.setLikes(post.getLikes() + 1);
        } else if ("dislike".equals(type)) {
            post.setDislikes(post.getDislikes() + 1);
        }

        postRepository.save(post);
        return ResponseEntity.ok("updated");
    }

    // Add Comment
    @PostMapping("/{id}/comment")
    public ResponseEntity<String> addComment(
            @PathVariable String id,
            @RequestBody Map<String, String> body
    ) {
        Optional<Post> optional = postRepository.findById(id);
        if (optional.isEmpty()) return ResponseEntity.notFound().build();

        Post post = optional.get();
        String comment = body.get("comment");

        if (comment != null && !comment.isBlank()) {
            post.getComments().add(comment);
            postRepository.save(post);
        }

        return ResponseEntity.ok("comment_added");
    }
}
