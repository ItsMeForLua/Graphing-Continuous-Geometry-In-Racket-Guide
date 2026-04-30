#lang racket
(require plot)

;polar expects a function θ → r, not a sum of x/y terms — polar coords don't work directly for this equation
; Circle
#|
(plot (parametric
       (λ (t) (list (* 6 (cos t))
                    (* 6 (sin t))))
       0 (* 2 pi)))
|#

;Hyperbola
; To identify a conic section, it's usually easiest
; to group the x and y variables on the same side of the equals sign.

; The actual general range of hyperbolic functions is that of infinites, so we will restrict it
; arbitrarily to -3 and 3 as our start and end values.

#|
(plot (parametric
       (λ (t) (list (* 4 (cosh t))
                    (* 4 (sinh t))))
       -3
        3)) ; you provide the start and end values
|#