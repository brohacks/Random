(define gui #f)
(define status-label #f)
(define toggling? #f)
(define elapsed 0.0)
(define logging-active #f)

;; Append data into CSV file
(define (append-gps-row lat lon ts)
  (let* ((path (string-append (system-directory) (system-pathseparator) "gps_log.csv"))
         (rows (if (file-exists? path)
                   (csv-read path)   
                   '(("Latitude" "Longitude" "Timestamp")))))
    (csv-write path
      (append rows
              (list (list (number->string lat)
                          (number->string lon)
                          (number->string ts)))))))

;;log GPS every 5 second
(define (toggle-label t)
  (when toggling?
    (set! elapsed (+ elapsed t))
    (when (> elapsed 5000.0) 
      (let ((lat (gps-latitude))
            (lon (gps-longitude))
            (ts  (current-seconds)))
        (append-gps-row lat lon ts)
      (set! elapsed 0.0))))


;; Button callback: log GPS once on click
(define (gps-button g w t x y)
  (let ((lat (gps-latitude))
        (lon (gps-longitude))
        (ts  (current-seconds)))
    (append-gps-row lat lon ts)
    (glgui-widget-set! gui status-label 'label
      (string-append "Appended GPS: " 
                     (number->string lat) ", "
                     (number->string lon) " @ "
                     (number->string ts)))))

;; Start/Stop logging toggle
(define (start-action g w t x y)
  (set! toggling? #t)
  (set! elapsed 0.0)
  (set! logging-active #t)
  (glgui-widget-set! gui status-label 'label "Logging started..."))

(define (stop-action g w t x y)
  (set! toggling? #f)
  (set! logging-active #f)
  (glgui-widget-set! gui status-label 'label "Logging stopped."))

;; MAIN
(main
 ;; INIT
 (lambda (w h)
   (make-window 320 480)
   (glgui-orientation-set! GUI_PORTRAIT)
   (set! gui (make-glgui))

   ;; Title
   (glgui-label gui 120 (- (glgui-height-get) 30) 200 30 "GPS Logger" ascii_18.fnt White)

   ;; Exit button
   (glgui-button-string gui 85 180 150 30 "Exit" ascii_18.fnt
     (lambda (g w t x y) (force-terminate)))

   ;; Start/Stop buttons
   (glgui-button-string gui 60 220 100 36 "Start" ascii_18.fnt start-action)
   (glgui-button-string gui 180 220 100 36 "Stop" ascii_18.fnt stop-action)

   ;; Status label
   (set! status-label (glgui-label gui 80 270 300 30 "Status: Ready!" ascii_18.fnt White))

   ;; Log GPS once button
   (glgui-button-string gui 85 130 150 30 "Log GPS" ascii_18.fnt gps-button)

   gui)

 ;; EVENT / FRAME
 (lambda (t x y)
   (glgui-event gui t x y)
   (when logging-active
     (toggle-label t)))

 ;; TERMINATE
 (lambda () #t)

 ;; SUSPEND
 (lambda () (glgui-suspend))

 ;; RESUME
 (lambda () (glgui-resume)))
