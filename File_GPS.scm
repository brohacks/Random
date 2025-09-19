(define gui #f)
(define status-label #f)
(define start-button #f)
(define stop-button #f)
(define gps-lat-label #f)
(define gps-lng-label #f)
(define gps-ts-label #f)

(define elapsed 0.0)
(define label-visible? #t)
(define toggling? #f)

(define logging-active #f)
(define logging-file-open? #f)
(define logfile #f)
(define logfile-path #f)   ;; initialize later in INIT
(define logging-paused? #f)

;; --- Open logfile ---
(define (open-logfile)
  (unless logging-file-open?
    (set! logfile (open-output-file logfile-path #:append))
    (set! logging-file-open? #t)
    ;; Write CSV header if file is new
    (when (not (file-exists? logfile-path))
      (display "timestamp,latitude,longitude\n" logfile)
      (force-output logfile))))

;; --- Close logfile ---
(define (close-logfile)
  (when logging-file-open?
    (close-output-port logfile)
    (set! logging-file-open? #f)))

;; --- Toggle label ---
(define (toggle-label t)
  (when toggling?
    (set! elapsed (+ elapsed t))
    (when (> elapsed 1.0)   ;; ~1 second for toggle blink
      (if label-visible?
          (glgui-widget-set! gui status-label 'label "")
          (glgui-widget-set! gui status-label 'label "Hello!"))
      (set! label-visible? (not label-visible?))
      (set! elapsed 0.0))))

;; --- Update GPS display and write CSV ---
(define (update-gps-display)
  (let ((lat (gps-latitude))
        (lng (gps-longitude))
        (ts  (gps-timestamp)))
    ;; Update labels
    (glgui-widget-set! gui gps-lat-label 'label (string-append "Lat: " (number->string lat)))
    (glgui-widget-set! gui gps-lng-label 'label (string-append "Lng: " (number->string lng)))
    (glgui-widget-set! gui gps-ts-label  'label (string-append "TS:  " (number->string ts)))
    ;; Write CSV if logging
    (when logging-active
      (unless logging-file-open? (open-logfile))
      (when logging-file-open?
        (display (string-append (number->string ts) "," 
                                (number->string lat) "," 
                                (number->string lng) "\n")
                 logfile)
        (force-output logfile)))))

;; --- Start button action ---
(define (start-action g w t x y)
  (set! toggling? #t)
  (set! elapsed 0.0)
  (unless logging-active
    (set! logging-active #t)
    (open-logfile)
    (set! logging-paused? #f)))

;; --- Stop button action ---
(define (stop-action g w t x y)
  (set! toggling? #f)
  (when logging-active
    (set! logging-active #f)
    (close-logfile)
    (set! logging-paused? #f)))

;; --- MAIN ---
(main
 ;; INIT
 (lambda (w h)
   (make-window 320 480)
   (glgui-orientation-set! GUI_PORTRAIT)
   (set! gui (make-glgui))

   ;; Initialize logfile path here at runtime
   (set! logfile-path (string-append (system-directory) "/gps_log.csv"))

   ;; Title
   (glgui-label gui 100 440 200 30 "GPS Logger" ascii_18.fnt White)

   ;; Status label
   (set! status-label (glgui-label gui 100 400 200 30 "Hello!" ascii_18.fnt White))

   ;; GPS labels
   (set! gps-lat-label (glgui-label gui 20 340 280 30 "Lat: ..." ascii_18.fnt White))
   (set! gps-lng-label (glgui-label gui 20 310 280 30 "Lng: ..." ascii_18.fnt White))
   (set! gps-ts-label  (glgui-label gui 20 280 280 30 "TS:  ..." ascii_18.fnt White))

   ;; Buttons
   (set! start-button (glgui-button-string gui 60 220 100 36 "Start" ascii_18.fnt start-action))
   (set! stop-button  (glgui-button-string gui 180 220 100 36 "Stop"  ascii_18.fnt stop-action))

   gui)

 ;; EVENT / FRAME
 (lambda (t x y)
   (glgui-event gui t x y)
   (toggle-label t)
   (update-gps-display))

 ;; TERMINATE
 (lambda ()
   (when logging-file-open? (close-logfile))
   #t)

 ;; SUSPEND
 (lambda ()
   (when logging-file-open?
     (close-logfile)
     (set! logging-paused? #t))
   (glgui-suspend))

 ;; RESUME
 (lambda ()
   (glgui-resume)
   (when (and logging-active logging-paused?)
     (open-logfile)
     (set! logging-paused? #f))
   (update-gps-display)))
