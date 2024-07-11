# sitegen
This is the site generator I built for [https://frogulis.net](https://frogulis.net).

I wouldn't recommend it for anything important!

How to use:
1. Install Racket (duh)
2. Put a `definitions.rkt` in your source directory
3. Navigate to the directory with `definitions.rkt`
4. Run `racket [...]/sitegen.rkt`

The output will be put in `[working dir]/output/`.

Here's an example `definitions.rkt`:
```racket
#lang racket

; the important part - this will be imported by sitegen and used to build the site
(provide page-definitions)

; just a variable
(define css-files (list "/styles/my.css"))

; a list of directives
; gen (path, title, css-file-paths) -> generate HTML from [path].md
; copy-dir -> copy specified directory directly from source to output
; copy -> copy specified file from source to output
(define page-definitions
  (list (hash 'type 'gen 'config `("index" "Home" ,css-files))
        (hash 'type 'gen 'config `("writing/opinions" "I'm full of opinions!" ,css-files))
        (hash 'type 'copy-dir 'path "writing/images/")
        (hash 'type 'copy 'path "favicon.ico")
        (hash 'type 'copy-dir 'path "styles/")))
```