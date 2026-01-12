#lang racket

(require struct-update)
(require "shared.rkt")
(require "templates.rkt")
(require "file-io.rkt")
(require "atom.rkt")

(define (get-page-with-content p)
  (cond
    [(not (string? (hash-ref p 'path))) (optional #f "Not a valid page")]
    [else (optional #t (cons p (parse-markdown-file (string-append (hash-ref p 'path) ".md"))))]))

; cons the page to its content
(define (build-page p)
  (cons p (chain-bind-opt p get-page-with-content default-template)))

(define page-definitions (dynamic-require "definitions.rkt" 'page-definitions))

(create-required-directories page-definitions)

(define copy-page-definitions
  (filter (lambda (p) (or (equal? 'copy (hash-ref p 'type)) (equal? 'copy-dir (hash-ref p 'type))))
          page-definitions))

(define gen-page-definitions (filter (lambda (p) (equal? 'gen (hash-ref p 'type))) page-definitions))
(define page-pairs (map build-page gen-page-definitions))
(define success-pages (filter (lambda (page-pair) (optional-success? (cdr page-pair))) page-pairs))
(define failed-pages
  (filter (lambda (page-pair) (not (optional-success? (cdr page-pair)))) page-pairs))

(for-each (lambda (p)
            (begin
              (displayln (string-append "Writing generated page with key: " (hash-ref (car p) 'path)))
              (write-generated-page p)))
          success-pages)

(for-each (lambda (p)
            (begin
              (displayln (string-append "Copying: " (hash-ref p 'path)))
              (cond
                [(equal? (hash-ref p 'type) 'copy) (copy-page (hash-ref p 'path))]
                [(equal? (hash-ref p 'type) 'copy-dir) (copy-dir (hash-ref p 'path))])))
          copy-page-definitions)

(when (not (empty? failed-pages))
  (begin
    (displayln "\nError messages:")
    (for-each (lambda (failed-page) (displayln (optional-result (cdr failed-page)))) failed-pages)))

; atom feed generation
(define site-metadata (dynamic-require "definitions.rkt" 'metadata))

; fake pairs, we dont have crontent in scope right here
(define copy-page-pairs (map (lambda (p) (cons p #f)) copy-page-definitions))

(define feed-pages
  (filter (lambda (page-pair)
            (let ([the-page (car page-pair)])
              (and (hash-has-key? the-page 'feed-id)
                   (hash-has-key? the-page 'updated)
                   (hash-has-key? the-page 'title))))
          (append success-pages copy-page-pairs)))

(define feed-pages-with-combined-content
  (map (lambda (p)
         (if (cdr p)
             (hash-set (car p) 'content (generate-page-as-string (optional-result (cdr p))))
             (car p)))
       feed-pages))

(define sorted-feed-pages
  (sort feed-pages-with-combined-content
        (lambda (a b) (string<=? (hash-ref b 'updated) (hash-ref a 'updated)))))

(displayln (format "Generating feed with ~a entries" (length sorted-feed-pages)))
(write-string-to-file "feed.xml"
                      (render-feed (feed-outer site-metadata
                                               (map (lambda (p) (feed-entry site-metadata p))
                                                    sorted-feed-pages))))
