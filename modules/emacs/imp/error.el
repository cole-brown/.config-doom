;;; emacs/imp/error.el -*- lexical-binding: t; -*-


;;                                 ──────────                                 ;;
;; ╔════════════════════════════════════════════════════════════════════════╗ ;;
;; ║                            Errors & Output                             ║ ;;
;; ╚════════════════════════════════════════════════════════════════════════╝ ;;
;;                                   ──────                                   ;;
;;                           404 - Error Not Found                            ;;
;;                                 ──────────                                 ;;


;;------------------------------------------------------------------------------
;; Output Functions / Variables
;;------------------------------------------------------------------------------

(defcustom imp:output:buffer "ⓘ-imp:output-ⓘ"
  "Name of the output buffer used by `int<imp>:output:insert'.")


(defcustom imp:output:level
  '((:error . (:prefix "[ERROR   ]: "
               :func error))
    (:error:user . (:prefix "[ERROR   ]:USER-ERROR: "
                    :func user-error))
    (:debug . (:prefix "[   debug]: "
               ;; :func message
               :func int<imp>:output:insert))

    ;; Not really a level, but available to debug messages via
    ;; `int<imp>:debug:newline'.
    (:blank . (:prefix ""
               ;; :func message
               :func int<imp>:output:insert)))
  "Output message level (:debug, :error, etc) settings.")


(defun int<imp>:output:level/get (level setting)
  "Get a SETTING for an output LEVEL."
  (plist-get (alist-get level imp:output:level)
             setting))
;; (int<imp>:output:level/get :error :prefix)
;; (int<imp>:output:level/get :debug :func)


(defun int<imp>:output:insert (message &rest args)
  "Output MESSAGE formatted with ARGS to the `imp:output:buffer'."
  (with-current-buffer (get-buffer-create imp:output:buffer)
    ;; We are now in BUFFER, so just insert the formatted string on a new line at the end.
    (goto-char (point-max))
    (insert (apply #'format
                   ;; Add a string format for newline-or-nothing.
                   (concat "%s" message)
                   ;; Prepend a newline, unless this is a new/empty buffer.
                   (if (= (buffer-size) 0)
                       ""
                     "\n")
                   args))))
;; (int<imp>:output:insert "General Kenobi.")
;; (int<imp>:output:insert "Hello there.")


(defun int<imp>:output (level caller string args)
  "Output a message (formatted from STRING & ARGS) from CALLER function.

LEVEL should be one of the alist keys in `int<imp>:output:prefix'.

CALLER should be a string of the calling function's name.
  - It can be nil, though it is /really/ not suggested.

STRING should be:
  - A string (which can have formatting info in it (see `format')).
    Will be printed as the debug message.
  - A list of strings (which can have formatting info in it (see `format')).
    Will be concatenated and printed as the debug message.

ARGS should be a list of args for formatting the STRING, or nil."
  (when-let ((func (int<imp>:output:level/get level :func))
             (prefix (int<imp>:output:level/get level :prefix)))

    (apply func
           (concat prefix
                   caller
                   (if caller ": " "")
                   (cond ((stringp string)
                          string)
                         ((null string)
                          nil)
                         ((listp string)
                          (apply #'concat string))))
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

Uses `:error' level settings in `imp:output:level'.

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


(defun int<imp>:error:user (caller string &rest args)
  "Create a formatted error message and raise an error signal with it.

Uses `:error' level settings in `imp:output:level'.

STRING should be a string, which can have formatting info in it (see `format'),
and will be printed as the debug message.

ARGS should be a list of args for formatting the STRING."
  (int<imp>:output :error:user
                   caller
                   string
                   args))

;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
;; Don't provide - entirely internal to imp.
;; (imp:provide :imp 'error)
