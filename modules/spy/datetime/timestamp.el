;;; spy/datetime/timestamp.el -*- lexical-binding: t; -*-

(imp:require :modules 'spy 'datetime 'format)

;;-----------------------------------who?---------------------------------------
;;--                 Dates, Times, Datetimes, Timedates...                    --
;;------------------------------------------------------------------------------


;;------------------------------------------------------------------------------
;; Timestamp Functions (& Datestamp functions?)
;;------------------------------------------------------------------------------

;;--------------------
;; Interactive: Insert Timestamp
;;--------------------

(defun spy:cmd:timestamp/iso-8601.insert ()
  "Produces and inserts a full ISO 8601 format timestamp (with ' '
date/time separator) of current time.
"
  (interactive)
  (insert (spy:datetime/string.get 'iso-8601 'long)))


(defun spy:cmd:timestamp/org.insert ()
  "Produces and inserts a timestamp of [yyyy-mm-dd], similar to
inactive ORG timestamp."
  (interactive)
  (insert (spy:datetime/string.get 'org-inactive)))



;;--------------------
;; Misc
;;--------------------

;; Was used in an old weekly-status template
(defun spy:timestamp/next-friday (format)
  "Returns a string of next Friday's date formatted to the
spy:datetime/timestamp FORMAT string.
"
  (let ((today (nth 6 (decode-time (current-time)))))
    (format-time-string
     format
     (time-add
      (current-time)
      (days-to-time
       (if (eq 5 today) ; saturday is only day bigger than friday
           6
         (- 5 today)))))))


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(imp:provide :modules 'spy 'datetime 'timestamp)
