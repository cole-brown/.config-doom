;;; spy/secret/functions.el -*- lexical-binding: t; -*-

;; todo: spy-fan

(imp:require :jerky)
(imp:require :modules 'spy 'file 'path)

(require 'mis0/message)


;;------------------------------------------------------------------------------
;; Getters
;;------------------------------------------------------------------------------

;;------------------------------
;; Identity
;;------------------------------

(defun spy:secret/hash ()
  "Get this system's secret hash, which is the same as the system's hash."
  (spy:system/hash))
;; (spy:secret/hash)
;; (string= (spy:secret/hash) (spy:system/hash))


(defun spy:secret/id ()
  "Get this system's secrets ID.

Returns nil if no secrets ID for this system."
  (spy:system/get (spy:system/hash) 'id))
;; (spy:secret/id)


;;------------------------------
;; Paths
;;------------------------------

(defun sss:secret/path/root ()
  "Get secrets' base root dir for all systems."
  (spy:system/get (spy:secret/hash) 'path 'secret 'root))


(defun sss:secret/path/load ()
  "Get secrets' load root dir for all systems."
  (spy:system/get (spy:secret/hash) 'path 'secret 'emacs))


(defun sss:secret/path/system ()
  "Get this system's secrets' load dir."
  (spy:system/get (spy:secret/hash) 'path 'secret 'system))


;;------------------------------------------------------------------------------
;; Validation
;;------------------------------------------------------------------------------

(defun sss:secret/validate (file)
  "Validate ID, hash, and root directory exist and that FILE exists."
  (let* (success
         reason
         (hash (spy:secret/hash))
         (id   (spy:secret/id))
         (dir  (sss:secret/path/system))
         (path (spy:path:file-path dir file)) ; No ".el"; want compiled too.
         (name (concat path ".el")))

    ;; Check for validity.
    (cond
     ((null hash)
      (setq success nil
            reason (format "Secrets hash is null for this system.")))

     ((null id)
      (setq success nil
            reason (format "Secrets ID is null for this system.")))

     ((or (null dir)
          (not (stringp dir)))
      (setq success nil
            reason (format "Secrets %s for this system (%s) is invalid: %s"
                           "directory"
                           id
                           dir)))

     ;; Does dir even exist?
     ((not (file-directory-p dir))
      (setq success nil
            reason (format "Secrets %s for this system (%s) does not exist: %s"
                           "directory"
                           id
                           dir)))

     ;; What about the filepath?
     ;; Add ".el" for actual file check.
     ((not (file-exists-p name))
      (setq success nil
            reason (format "Secrets %s for this system (%s) does not exist: %s"
                           "file"
                           id
                           name)))

     ;; File exists; return the load path...
     (t
      (setq success t
            reason nil)))

  ;; Return plist of vars and success/reason.
  (list :success success
        :reason reason
        :hash hash
        :id id
        :path/load path
        :path/name name)))
;; (sss:secret/validate "init")


;;------------------------------------------------------------------------------
;; Paths
;;------------------------------------------------------------------------------

(defun sss:secret/path (file)
  "Get the path to secrets FILE for this system.

NOTE FILE must be filename sans extension (e.g. \"init\", not \"init.el\")!

Returns a plist with keys:
  - :id        - `spy:secret/id' string or nil.
  - :path/name - Path to FILE, with extension.
  - :path/load - Path to FILE, without extension. Use this for loading the file."
  (let* ((vars (sss:secret/validate file))
         (hash (plist-get vars :hash))
         (id (plist-get vars :id))
         (path/load (plist-get vars :path/load))
         (path/name (plist-get vars :path/name)))
    (if (not (plist-get vars :success))
        (progn
          ;; Invalid something or other. Print what.
          (mis0/init/warning "sss:secret/path"
                             (mapconcat #'identity
                                        '("  ->file: %S"
                                          "    hash: %S"
                                          "    id:   %S"
                                          "    path: %S"
                                          "    name: %S"
                                          "  [FAILURE]: %S")
                                        "\n")
                             file hash id path/load path/name
                             (plist-get vars :reason))

          ;; Return nils on error.
          (list :id id :path/name nil :path/load nil))

      ;; Valid vars.
      (mis0/init/message (mapconcat #'identity
                                    '("sss:secret/path"
                                      "  ->file: %S"
                                      "    hash: %S"
                                      "    id:   %S"
                                      "    path: %S"
                                      "    name: %S"
                                      "  [SUCCESS]")
                                    "\n")
                         file hash id path/load path/name
                        (plist-get vars :reason))


      ;; Return the load path on success.
      (list :id id :path/name path/name :path/load path/load))))
;; (sss:secret/path "init")


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
      (not (null (plist-get (sss:secret/validate "init") :success)))
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
