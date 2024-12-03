#lang racket

(require threading)

(define (sum-muls s #:start [start-pos 0] #:end [end-pos #f])
  (~> s
      (regexp-match* #px"mul\\((\\d+)\\,(\\d+)\\)" _ start-pos end-pos #:match-select cdr)
      (map (lambda~> (map string->number _) (apply * _)) _)
      (apply + _)))

(define (active xs ys from)
  (match* (xs ys)
    [(_ '()) (list (cons from #f))]
    [((cons x xr) (cons y _)) #:when (< x y) (active xr ys from)]
    [(_ (cons y yr)) (cons (cons from y) (passive xs yr y))]))

(define (passive xs ys from)
  (match* (xs ys)
    [('() _) '()]
    [((cons x _) (cons y yr)) #:when (> x y) (passive xs yr from)]
    [((cons x xr) _) (active xr ys x)]))

(define (active-zones input)
  (let ([dos (map car (regexp-match-positions* #px"do\\(\\)" input))]
        [donts (map car (regexp-match-positions* #px"don't\\(\\)" input))])
    (active dos donts 0)))

(define part1 sum-muls)

(define (part2 input)
  (apply + (map (lambda (zone) (sum-muls input #:start (car zone) #:end (cdr zone)))
                (active-zones input))))

(define (solve file)
  (let* ([input (port->string (open-input-file file) #:close? #t)]
         [solution1 (part1 input)]
         [solution2 (part2 input)])
    (println solution1)
    (println solution2)))

; entry-point, run with:
; racket day3.rkt input.txt
(~> (current-command-line-arguments)
    (vector-ref 0)
    solve)