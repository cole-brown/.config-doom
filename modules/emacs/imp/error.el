;;; emacs/imp/error.el -*- lexical-binding: t; -*-


;;------------------------------------------------------------------------------
;; Output Functions / Variables
;;------------------------------------------------------------------------------

(defconst int<imp>:output:level
  '((:error . (:prefix "[ERROR   ]: "
               :func error))
    (:debug . (:prefix "[   debug]: "
               :func message))

    ;; Not really a level, but available to debug messages via
    ;; `int<imp>:debug:newline'.
    (:blank . (:prefix ""
               :func message)))
  "Output message level (:debug, :error, etc) settings.")


(defun int<imp>:output:level/get (level setting)
  "Get a SETTING for an output LEVEL."
  (plist-get (alist-get level int<imp>:output:level)
             setting))
;; (int<imp>:output:level/get :error :prefix)
;; (int<imp>:output:level/get :debug :func)


(defun int<imp>:output (level caller string args)
  "Output a message (formatted from STRING & ARGS) from CALLER function.

LEVEL should be one of the alist keys in `int<imp>:output:prefix'.

CALLER should be a string of the calling function's name.
  - It can be nil, though it is /really/ not suggested.

STRING should be a string, which can have formatting info in it (see `format'),
and will be printed as the debug message.

ARGS should be a list of args for formatting the STRING, or nil."
  (when-let ((func (int<imp>:output:level/get level :func))
             (prefix (int<imp>:output:level/get level :prefix)))

    (apply func
           (concat prefix
                   caller
                   (if caller ": " "")
                   string)
           args)))


;;------------------------------------------------------------------------------
;; String Helpers
;;------------------------------------------------------------------------------

(defun int<imp>:output:callers (this &optional callers)
  "Builds a caller string from THIS & CALLERS strings."
  (let ((this (cond ((null this)
                     nil)
                    ((stringp this)
                     this)
                    (t
                     (format "%S" this))))
        (callers (cond ((null callers)
                        nil)
                       ((stringp callers)
                        callers)
                       (t
                        (format "%S" callers)))))
    (if callers
        (concat this " <-via- " callers)
      this)))


(defun int<imp>:error (caller string &rest args)
  "Create a formatted error message and raise an error signal with it.

Uses `:error' level settings in `int<imp>:output:level'.

STRING should be a string, which can have formatting info in it (see `format'),
and will be printed as the debug message.

ARGS should be a list of args for formatting the STRING."
  (int<imp>:output :error
                   caller
                   string
                   args))
;; (int<imp>:error "test:func" "True == %s" "False")
;; (let ((imp:error:function nil)) (int<imp>:error "test:func" "True == %s" "False"))
;; (let ((imp:error:function #'message)) (int<imp>:error "test:func" "True == %s" "False"))


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
;; Don't provide - entirely internal to imp.
;; (imp:provide :imp 'error)
