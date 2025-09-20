(define gui #f)
(define status-label #f)

;; Append row with multiple columns: Score, Player, Timestamp
(define (append-score score player)
  (let* ((path (string-append (system-directory) (system-pathseparator) "scores.csv"))
         (rows (if (file-exists? path)
                   (csv-read path)        ;; read existing rows
                   '(("Score" "Player" "Timestamp"))))) ;; human-readable time
    ;; Write back with new row
    (csv-write path
      (append rows
              (list (list (number->string score) player))))))

;; Button callback (adds a row each click)
(define (button g w t x y)
  (append-score 100 "Player1")  ;; replace "Player1" with dynamic name if needed
  (glgui-widget-set! gui status-label 'label "Appended row to scores.csv"))

(main
 ;; INIT
 (lambda (w h)
   (make-window 320 480)
   (glgui-orientation-set! GUI_PORTRAIT)

   (set! gui (make-glgui))

   ;; Title
   (glgui-label gui 150 (- (glgui-height-get) 30) 200 30 "Scores" ascii_18.fnt White)

   ;; Exit button
   (glgui-button-string gui 85 180 150 30 "Exit" ascii_18.fnt
     (lambda (g w t x y) (force-terminate)))

   ;; Status label
   (set! status-label (glgui-label gui 80 270 300 30 "Status: Ready!" ascii_18.fnt White))

   ;; Add Score button
   (glgui-button-string gui 85 130 150 30 "Add Score" ascii_18.fnt button)

   gui)

 ;; EVENT / FRAME
 (lambda (t x y)
   (glgui-event gui t x y))

 ;; TERMINATE
 (lambda () #t)

 ;; SUSPEND
 (lambda () (glgui-suspend))

 ;; RESUME
 (lambda () (glgui-resume)))
