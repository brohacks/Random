(define gui #f)
(define status-label #f)

;; Append GPS row into csv file
(define (append-gps-row)
  (let* ((path (string-append (system-directory) (system-pathseparator) "gps_log.csv"))
         (rows (if (file-exists? path)
                   (csv-read path)   ;; already existing rows
                   '(("Latitude" "Longitude" "Timestamp")))) ;; header if new
         (lat (number->string (gps-latitude)))
         (lon (number->string (gps-longitude)))
         (ts  (number->string (current-seconds)))) ;; readable timestamp
    ;; Write back with new row
    (csv-write path
      (append rows
              (list (list lat lon ts))))))

;; Button callback
(define (gps-button g w t x y)
  (append-gps-row)
  (glgui-widget-set! gui status-label 'label "Appended GPS to gps_log.csv"))

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

   ;; Status label
   (set! status-label (glgui-label gui 80 270 300 30 "Status: Ready!" ascii_18.fnt White))

   ;; Add GPS button
   (glgui-button-string gui 85 130 150 30 "Log GPS" ascii_18.fnt gps-button)

   gui)

 ;; EVENT
 (lambda (t x y)
   (glgui-event gui t x y))

 ;; TERMINATE
 (lambda () #t)

 ;; SUSPEND
 (lambda () (glgui-suspend))

 ;; RESUME
 (lambda () (glgui-resume)))
