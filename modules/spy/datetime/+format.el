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

(defun spy/datetime/string.get (&rest args)
  "Uses `spy/datetime/format.get' to get a datetime format and then calls
`format-time-string' with format and options to get a time string.

Splits ARGS out into a NAME and KEYWORD-ARGS.
The NAME is everything that comes before any of our keywords.

OPTIONAL keywords are:
  :time - A time (compatible with `format-time-string') to use instead of now.
  :zone - A timezone to use instead of the local one.

Returns string from `format-time-string'.
"
   (-let* (((name kwargs) (spy/lisp/func.args args :time :zone))
          ((&plist :time :zone) kwargs))
     (format-time-string (spy/datetime/format.get name) time zone)))
;; (spy/datetime/string.get 'iso-8601 'long)


(defun spy/datetime/format.get (&rest name)
  "Returns a datetime format string by NAME - strings, symbols or list of such.
Prepends '(datetime format) to the NAME.
"
  (jerky/get 'datetime 'format name))


(defun spy/datetime/format.set (&rest args)
  "Sets a datetime format string.

Splits ARGS out into a NAME and KEYWORD-ARGS.

The NAME is everything that comes before any of our keywords.
  - Prepends '(datetime format) to the NAME before saving to Jerky.

Keywords are:
  :value  - datetime format string
  :docstr - documentation string
"
  (-let* (((name kwargs) (spy/lisp/func.args args :value :docstr))
          ((&plist :value :docstr) kwargs))
    (jerky/set 'datetime 'format name
               :value value
               :docstr docstr)))


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
  (spy/datetime/format.set 'iso-8601 'short
                           :value  "%Y-%m-%d"
                           :docstr "ISO-8601 without timestamp.")

  ;; ISO-8601: long (space separator)
  (spy/datetime/format.set 'iso-8601 'long
                           :value  "%Y-%m-%d %H:%M:%S"
                           :docstr "ISO-8601 with space separator for in text.")

  ;; ISO-8601: long ('T' separator)
  (spy/datetime/format.set 'iso-8601 'log
                           :value  "%Y-%m-%dT%T%z"
                           :docstr "ISO-8601 with 'T' separator for in logs, etc.")

  ;; ISO-8601: long (for filenames)
  (spy/datetime/format.set 'iso-8601 'file
                           :value  "%Y-%m-%d-T-%H-%M-%S"
                           :docstr (concat "ISO 8601-ish format, but works on Windows. "
                                           "Can strip hypens to get to ISO-8601 basic "
                                           "format (YYYYMMDDThhmmssZ)."))

  ;;--------------------
  ;; Misc Formats
  ;;--------------------

  ;; ISO-8601(ish): But meh. No separators makes it much less useful to the brain.
  (spy/datetime/format.set 'yyyymmdd
                           :value  "%Y%m%d"
                           :docstr "Why would you use this?! Give my eyes a break.")

  ;; org-mode inactive: useful even when not in org-mode.
  (spy/datetime/format.set 'org-inactive
                           :value  "[%Y-%m-%d]"
                           :docstr "org-time-stamp-inactive sans day name e.g.: [2019-09-19]")

  ;; USA: pretty much worst format
  (spy/datetime/format.set 'usa
                           :value  "%m-%d-%Y"
                           :docstr (concat "Bad, US American format. "
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
