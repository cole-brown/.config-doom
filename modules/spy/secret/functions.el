;;; spy/secret/functions.el -*- lexical-binding: t; -*-

;; ┌───────────────────────────────────────────────────────────────────────────┐
;; │                        What's the Secret Word?                            │
;; └───────────────────────────────────────────────────────────────────────────┘


(imp:require :jerky)
(imp:require :path)

(require 'mis0/message)


;;------------------------------------------------------------------------------
;; Getters
;;------------------------------------------------------------------------------

;;------------------------------
;; Identity
;;------------------------------

(defun spy:secret:hash ()
  "Get this system's secret hash, which is the same as the system's hash."
  (spy:system/hash))
;; (spy:secret:hash)
;; (string= (spy:secret:hash) (spy:system/hash))


(defun spy:secret:id ()
  "Get this system's secrets ID.

Returns nil if no secrets ID for this system."
  (spy:system/get (spy:system/hash) 'id))
;; (spy:secret:id)


;;------------------------------
;; Paths
;;------------------------------

(defun spy:secret:path/root ()
  "Get secrets' base root dir for all systems."
  (spy:system/get (spy:secret:hash) 'path 'secret 'root))


(defun spy:secret:path/load ()
  "Get secrets' load root dir for all systems."
  (spy:system/get (spy:secret:hash) 'path 'secret 'emacs))


(defun spy:secret:path/system ()
  "Get this system's secrets' load dir."
  (spy:system/get (spy:secret:hash) 'path 'secret 'system))


;;------------------------------------------------------------------------------
;; Validation
;;------------------------------------------------------------------------------

(defun spy:secret:validate (path/type filepath)
  "Validate that secrets exist for this system.

PATH/TYPE should be one of:
  - `:root'   - FILEPATH is relative to secret directory.
  - `:load'   - FILEPATH is relative to root init/load secret directory.
  - `:system' - FILEPATH is relative to system's secret directory.

FILEPATH should not include file extension. \".el\" will be appended!

Validate that:
  - system ID & hash exist
  - secret root directory exists
  - system's secret directory exists
  - FILEPATH exists"
  (let* ((success t)
         reason
         (hash           (spy:secret:hash))
         (id             (spy:secret:id))
         (path/root      (spy:secret:path/root))
         (path/load      (spy:secret:path/load))
         (path/system    (spy:secret:path/system))
         path/file/load
         path/file/name)

    ;;------------------------------
    ;; Determine file paths.
    ;;------------------------------
    (cond ((eq path/type :root)
           (setq path/file/load (path:join path/root filepath)))
          ((eq path/type :load)
           (setq path/file/load (path:join path/load filepath)))
          ((eq path/type :system)
           (setq path/file/load (path:join path/system filepath)))
          ;; Unknown PATH/TYPE.
          (t
           (setq success nil
                 reason (format "Unknown PATH/TYPE `%S'; expected one of: %S"
                                path/type
                                '(:root :load :system)))))

    ;;------------------------------
    ;; Check for validity.
    ;;------------------------------
    ;; If we already failed, don't bother with more.
    (when success
      ;; Valid `path/type'; fill in `path/file/name' by adding file extension.
      (setq path/file/name (concat path/file/load ".el"))

      ;; Validity checks.
      (cond
       ;;---
       ;; Hash, ID, basic stuff.
       ;;---
       ((null hash)
        (setq success nil
              reason (format "Secrets hash is null for this system.")))

       ((null id)
        (setq success nil
              reason (format "Secrets ID is null for this system.")))

       ;;---
       ;; Paths
       ;;---
       ((or (null path/root)
            (not (stringp path/root)))
        (setq success nil
              reason (format "Secrets %s for this system (%s) is invalid: %s"
                             "root directory"
                             id
                             path/root)))

       ((or (null path/load)
            (not (stringp path/load)))
        (setq success nil
              reason (format "Secrets %s for this system (%s) is invalid: %s"
                             "load directory"
                             id
                             path/load)))

       ((or (null path/system)
            (not (stringp path/system)))
        (setq success nil
              reason (format "Secrets %s for this system (%s) is invalid: %s"
                             "system directory"
                             id
                             path/system)))

       ((not (file-directory-p path/root))
        (setq success nil
              reason (format "Secrets %s for this system (%s) does not exist: %s"
                             "root directory"
                             id
                             path/root)))

       ((not (file-directory-p path/load))
        (setq success nil
              reason (format "Secrets %s for this system (%s) does not exist: %s"
                             "load directory"
                             id
                             path/load)))

      ((not (file-directory-p path/system))
        (setq success nil
              reason (format "Secrets %s for this system (%s) does not exist: %s"
                             "system directory"
                             id
                             path/system)))

       ;;---
       ;; File
       ;;---
       ;; What about the filepath?
       ;; Add ".el" for actual file check.
       ((not (file-exists-p path/file/name))
        (setq success nil
              reason (format "Secrets %s for this system (%s) does not exist: %s"
                             "file"
                             id
                             path/file/name)))

       ;; File exists; return the load path...
       (t
        (setq success t
              reason nil))))

    ;;------------------------------
    ;; Return plist of vars and success/reason.
    ;;------------------------------
    (list :success         success
          :reason          reason
          :hash            hash
          :id              id
          :path/dir/root   path/root
          :path/dir/load   path/load
          :path/dir/system path/system
          :path/file/load  path/file/load
          :path/file/name  path/file/name)))
;; (spy:secret:validate :load "init")


;;------------------------------------------------------------------------------
;; Helpers
;;------------------------------------------------------------------------------

(defun spy:secret/has ()
  "Returns non-nil if this system has secrets.

The system is considered to have secrets if:
  - It has a hash.
  - It has an ID.
  - And it has a secrets 'init.el' file."
  (condition-case _
      (not (null (plist-get (spy:secret:validate :load "init") :success)))
    (error nil)))
;; (spy:secret/has)


(defmacro spy:secret/if (func-or-place messages &rest body)
  "Do BODY if this system has secrets.

Used to guard config blocks that depend on secrets.

FUNC-OR-PLACE and MESSAGES are used only for printing mis0 message/warning.
  - MESSAGES should be nil, or a plist with `:skip' and/or `:eval' keys.
    - Values should be either a string or a list to pass to `format'.

If skipping, FUNC-OR-PLACE and skip message (if present) are formatted
into a `mis0/init/warning' for info about skipped config.

If not skipping and an 'eval message' is present, FUNC-OR-PLACE and eval message
are formatted into a `mis0/init/warning' for info about skipped config."
  (declare (indent 2))
  ;; Only eval inputs once.
  `(let ((mmm:func-or-place ,func-or-place)
         (mmm:messages ,messages))
     (if (spy:secret/has)
         (progn
           ;; Only display this message if it exists.
           (let ((mmm:message (plist-get mmm:messages :eval)))
             ;; (message "eval msg: %S" mmm:message)
             (cond ((and (stringp mmm:message)
                         (string= "" mmm:message))
                    ;; Just an empty string for a "message" - don't display.
                    nil)

                   ((stringp mmm:message)
                    (mis0/init/message mmm:message))

                   ((listp mmm:message)
                    (apply #'mis0/init/message mmm:message))

                   (t
                    nil)))

           ,@body)

       (let ((mmm:message (plist-get mmm:messages :skip)))
         ;; (message "skip msg: %S" mmm:message)
         ;; Always display a warning.
         (mis0/init/warning (or mmm:func-or-place
                                "spy:secret/if_(caller/unlabeled)")
                            (concat "[SKIP]: %s")
                            (cond ((listp mmm:message)
                                   (apply #'format mmm:message))
                                  ((stringp mmm:message)
                                   mmm:message)
                                  (t
                                   "Skipping...")))))))
;; (spy:secret/if "testing" "skip string" (message "I should not see this."))
;; (spy:secret/if nil "skip string" (message "I should not see this."))


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(imp:provide :modules 'spy 'secret 'functions)
