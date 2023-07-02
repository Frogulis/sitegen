#lang racket

(provide page-definitions)
(require "shared.rkt")

(define css-files (list "/styles/override.css" "/styles/pico.classless.min.css"))

(define page-definitions
  (list (page "writing/gentle-tyranny"
              "Thoughts on \"The Gentle Tyranny of Call/Return\""
              css-files
              "input/test.md")
        (page "writing/ladder" "Another test page" (list "idk.css") "input/test2.md")
        (page "index" "Jamie Hoffmann" css-files "input/index.md")))
