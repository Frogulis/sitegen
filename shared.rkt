#lang racket

(provide (struct-out optional)
         bind-opt
         chain-bind-opt
         (struct-out page))

(struct page (key title css-paths content) #:transparent #:mutable)

(struct optional (success? result))

(define (bind-opt m f)
  (cond
    [(not (optional-success? m)) m]
    [else (f (optional-result m))]))

(define (chain-bind-opt m . fs)
  (define (chain-bind-opt-iter m fs)
    (cond
      [(not (optional-success? m)) m]
      [(empty? fs) m]
      [else (chain-bind-opt-iter ((first fs) (optional-result m)) (rest fs))]))
  (chain-bind-opt-iter (optional #t m) fs))

(define (f x)
  (cond
    [(= x 0) (optional #f "Divide by 0")]
    [else (optional #t (/ 10 x))]))

(define (g x)
  (cond
    [(= x 2) (optional #f "Addition to 2")]
    [else (optional #t (+ 2 x))]))

(define x (chain-bind-opt 7 f g))
(define y (bind-opt x f))
