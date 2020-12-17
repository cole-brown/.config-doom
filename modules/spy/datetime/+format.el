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

(defun spy/datetime/string.get (name &optional time zone)
  "Uses `spy/datetime/format.get' to get format by NAME, then calls
`format-time-string' with format and optional TIME and ZONE.

Returns string from `format-time-string'.
"
  (format-time-string (spy/datetime/format.get name) time zone))


(defun spy/datetime/format.get (name)
  "Returns a datetime format string by NAME - a string/symbol or list of such.
Prepends '(datetime format) to the NAME.
"
  (jerky/get 'datetime 'format name))


(defun spy/datetime/format.set (name value docstr)
  "Sets a datetime format string by NAME.
Prepends '(datetime format) to the NAME.
"
  (jerky/set 'datetime 'format name
             :value value
             :docstr docstr))


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
  (spy/datetime/format.set '(iso-8601 short)
                           "%Y-%m-%d"
                           "ISO-8601 without timestamp.")

  ;; ISO-8601: long (space separator)
  (spy/datetime/format.set '(iso-8601 long)
                           "%Y-%m-%d %H:%M:%S"
                           "ISO-8601 with space separator for in text.")

  ;; ISO-8601: long ('T' separator)
  (spy/datetime/format.set '(iso-8601 log)
                           "%Y-%m-%dT%T%z"
                           "ISO-8601 with 'T' separator for in logs, etc.")

  ;; ISO-8601: long (for filenames)
  (spy/datetime/format.set '(iso-8601 file)
                           "%Y-%m-%d-T-%H-%M-%S"
                           (concat "ISO 8601-ish format, but works on Windows. "
                                   "Can strip hypens to get to ISO-8601 basic "
                                   "format (YYYYMMDDThhmmssZ)."))

  ;;--------------------
  ;; Misc Formats
  ;;--------------------

  ;; ISO-8601(ish): But meh. No separators makes it much less useful to the brain.
  (spy/datetime/format.set 'yyyymmdd
                           "%Y%m%d"
                           "Why would you use this?! Give my eyes a break.")

  ;; org-mode inactive: useful even when not in org-mode.
  (spy/datetime/format.set 'org-inactive
                           "[%Y-%m-%d]"
                           "org-time-stamp-inactive sans day name e.g.: [2019-09-19]")

  ;; USA: pretty much worst format
  (spy/datetime/format.set 'usa
                           "%m-%d-%Y"
                           (concat "Bad, US American format. "
                                   "Just terrible - why do we use this? "
                                   "I am ashamed.")))

;;---
;; Initialize our Common Formats
;;---
(spy/datetime/init)

;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(spy/provide :spy 'datetime 'format)
