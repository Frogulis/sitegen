#lang racket

(require markdown)
(require struct-update)
(require (only-in xml display-xml/content xexpr->xml xexpr?))
(require "shared.rkt")
(require "templates.rkt")

(define-struct-updaters page)

(define (parse-markdown-file file-name)
  (parse-markdown (file->string file-name)))

(define (populate-content p)
  (cond
    [(not (page? p)) (optional #f "Not a valid page")]
    [(string? (page-content p))
     (optional #t (page-content-set p (parse-markdown-file (page-content p))))]
    [else (optional #t p)]))

(define (build-page p)
  (cons (page-key p) (chain-bind-opt p populate-content default-template)))

(define output-path "output/")

(define (write-generated-page p)
  (define out
    (open-output-file (string-append output-path (car p) ".html") #:exists 'truncate/replace))
  (display (xexpr->string (optional-result (cdr p))) out)
  (close-output-port out))

(define (copy-page file-path)
  (copy-file file-path (string-append output-path file-path) #t))

(define (create-required-directories page-definitions)
  (define (but-last xs)
    (reverse (cdr (reverse xs))))
  (define (get-path p)
    (define page-type (hash-ref p 'type))
    (cond
      [(equal? page-type 'gen) (optional #t (page-key (apply page (hash-ref p 'config))))]
      [(equal? page-type 'copy) (optional #t (hash-ref p 'path))]
      [else (optional #f "Unsupported page type")]))
  (define (get-output-dir-paths path)
    (define (get-output-dir-paths-iter segments i paths)
      (if (> i (length segments))
          paths
          (get-output-dir-paths-iter
           segments
           (+ i 1)
           (cons (string-join (take segments i) "/" #:before-first output-path) paths))))
    (get-output-dir-paths-iter (but-last (string-split path "/" #:trim? #t)) 1 '()))

  (define path-responses (filter (lambda (r) (optional-success? r)) (map get-path page-definitions)))
  (define output-paths
    (list->set (append-map (lambda (r) (get-output-dir-paths (optional-result r))) path-responses)))
  (define output-paths-sorted
    (sort (set->list output-paths)
          (lambda (a b) (< (string-length a) (string-length b)))
          #:cache-keys? #t))

  (when (not (directory-exists? output-path))
    (make-directory output-path))
  (for-each (lambda (p)
              (when (not (directory-exists? p))
                (make-directory p)))
            output-paths-sorted))

; main
(define page-definitions (dynamic-require "definitions.rkt" 'page-definitions))

(create-required-directories page-definitions)

(define copy-page-definitions
  (filter (lambda (p) (equal? 'copy (hash-ref p 'type))) page-definitions))

(define gen-page-definitions (filter (lambda (p) (equal? 'gen (hash-ref p 'type))) page-definitions))
(define gen-pages (map (lambda (p) (apply page (hash-ref p 'config))) gen-page-definitions))
(define page-pairs (map build-page gen-pages))
(define success-pages (filter (lambda (page-pair) (optional-success? (cdr page-pair))) page-pairs))
(define failed-pages
  (filter (lambda (page-pair) (not (optional-success? (cdr page-pair)))) page-pairs))

(for-each (lambda (p)
            (begin
              (displayln (string-append "Writing generated page with key: " (car p)))
              (write-generated-page p)))
          success-pages)

(for-each (lambda (p)
            (begin
              (displayln (string-append "Copying: " (hash-ref p 'path)))
              (copy-page (hash-ref p 'path))))
          copy-page-definitions)

(when (not (empty? failed-pages))
  (begin
    (displayln "\nError messages:")
    (for-each (lambda (failed-page) (displayln (optional-result failed-page))) failed-pages)))
