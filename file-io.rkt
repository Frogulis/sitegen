#lang racket

(require markdown)
(require "shared.rkt")

(provide output-path
         parse-markdown-file
         write-generated-page
         copy-page
         copy-dir
         create-required-directories)

(define output-path "output/")

(define (parse-markdown-file file-name)
  (parse-markdown (file->string file-name)))

(define (write-generated-page p)
  (define out
    (open-output-file (string-append output-path (car p) ".html") #:exists 'truncate/replace))
  (display (xexpr->string (optional-result (cdr p))) out)
  (close-output-port out))

(define (copy-dir dir-path)
  (define out-path (string-append output-path dir-path))
  (when (directory-exists? out-path)
    (delete-directory/files out-path))
  (copy-directory/files dir-path out-path))

(define (copy-page file-path)
  (copy-file file-path (string-append output-path file-path) #t))

(define (pnr x)
  (println x)
  x)

(define (create-required-directories page-definitions)
  (define path-responses (pnr (map (lambda (p) (hash-ref p 'path)) page-definitions)))
  (define output-paths
    (list->set (append-map (lambda (r) (get-output-dir-paths (pnr r))) path-responses)))
  (define output-paths-sorted ; sort output paths by length to ensure parent directories are created first
    (sort (set->list output-paths)
          (lambda (a b) (< (string-length a) (string-length b)))
          #:cache-keys? #t))
  (when (not (directory-exists? output-path))
    (make-directory output-path))
  (for-each (lambda (p)
              (when (not (directory-exists? p))
                (make-directory p)))
            output-paths-sorted))

; private

(define (but-last xs)
  (reverse (cdr (reverse xs))))

(define (get-output-dir-paths path)
  (define (get-output-dir-paths-iter segments i paths)
    (if (> i (length segments))
        paths
        (get-output-dir-paths-iter
         segments
         (+ i 1)
         (cons (string-join (take segments i) "/" #:before-first output-path) paths))))
  (get-output-dir-paths-iter (but-last (string-split path "/" #:trim? #t)) 1 '()))
