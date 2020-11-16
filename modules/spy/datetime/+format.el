;;; spy/datetime/+format.el -*- lexical-binding: t; -*-


;;-----------------------------------who?---------------------------------------
;;--                 Dates, Times, Datetimes, Timedates...                    --
;;------------------------(just the formats though...)--------------------------

(require 'dash)
(spy/require :spy 'jerky)


;;------------------------------------------------------------------------------
;; Getters, Setters.
;;------------------------------------------------------------------------------

;;--------------------
;; General
;;--------------------

(defun spy/datetime/get.string (name &optional time zone)
  "Uses `spy/datetime/format.get' to get format by NAME, then calls
`format-time-string' with format and optional TIME and ZONE.

Returns string from `format-time-string'.
"
  (format-time-string (spy/datetime/get.format name) time zone))


(defun spy/datetime/get.format (name)
  "Returns a datetime format string by NAME - a string/symbol or list of such.
Prepends '(datetime format) to the NAME. Flattens it into one list if needed.
"
  (jerky/get (-flatten (list 'datetime 'format name))))


(defun spy/datetime/set.format (name value docstr)
  "Sets a datetime format string by NAME.
Prepends '(datetime format) to the NAME. Flattens it into one list if needed.
"
  (jerky/set (-flatten (list 'datetime 'format name))
             :value value
             :docstr docstr))


;;--------------------
;; ISO-8061
;;--------------------

(defun spy/datetime.iso-8601/get.format (name)
  "Get an ISO-8601 datetime format string by NAME.
"
  (spy/datetime/get.format (list 'iso-8601 name)))


(defun spy/datetime.iso-8601/get.string (name &optional time zone)
  "Get an ISO-8601 datetime string for either now, or for TIME in ZONE.
"
  (spy/datetime/get.string (list 'iso-8601 name) time zone))


(defun spy/datetime.iso-8601/format.set (name value docstr)
  "Set an ISO-8601 datetime format string VALUE by NAME with docstr.
"
  (spy/datetime/set.format (list 'iso-8601 name) value docstr))


;;------------------------------------------------------------------------------
;; Some useful formats.
;;------------------------------------------------------------------------------

(defun spy/datetime/init ()
  "Set my datetime format strings into jerky.
"
  ;;--------------------
  ;; ISO-8601 Formats
  ;;--------------------

  ;; ISO-8601: short (no timestamp)
  (spy/datetime.iso-8601/set.format 'yyyy-mm-dd
                                    "%Y-%m-%d"
                                    "ISO-8601 without timestamp.")

  ;; ISO-8601: long (space separator)
  (spy/datetime.iso-8601/set.format 'yyyy-mm-dd_hh-mm-ss
                                    "%Y-%m-%d %H:%M:%S"
                                    "ISO-8601 with space separator for in text.")

  ;; ISO-8601: long ('T' separator)
  (spy/datetime.iso-8601/set.format 'log-format
                                    "%Y-%m-%dT%T%z"
                                    "ISO-8601 with 'T' separator for in logs, etc.")

  ;; ISO-8601: long (for filenames)
  (spy/datetime.iso-8601/set.format 'file-prefix
                                    "%Y-%m-%d-T-%H-%M-%S"
                                    (concat "ISO 8601-ish format, but works on Windows. "
                                            "Can strip hypens to get to ISO-8601 basic "
                                            "format (YYYYMMDDThhmmssZ)."))

  ;;--------------------
  ;; Misc Formats
  ;;--------------------

  ;; ISO-8601(ish): But meh. No separators makes it much less useful to the brain.
  (spy/datetime/set.format 'yyyymmdd
                           "%Y%m%d"
                           "Why would you use this?! Give my eyes a break.")

  ;; org-mode inactive: useful even when not in org-mode.
  (spy/datetime/set.format 'org-inactive
                           "[%Y-%m-%d]"
                           "org-time-stamp-inactive sans day name e.g.: [2019-09-19]")

  ;; USA: pretty much worst format
  (spy/datetime/set.format 'usa
                           "%m-%d-%Y"
                           (concat "Bad, US American format. "
                                   "Just terrible - why do we use this? "
                                   "I am ashamed.")))


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(spy/provide :spy 'datetime 'format)
