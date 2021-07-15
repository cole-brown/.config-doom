;;; spy/secret/init.el -*- lexical-binding: t; -*-
;;
;;; Code:


;; todo: spy-fan

(imp:require :jerky)
(imp:require :modules 'spy 'file 'path)

(require 'mis0/message)


;;------------------------------------------------------------------------------
;; :spy:secret requirements
;;------------------------------------------------------------------------------

(load! "load")


;;------------------------------------------------------------------------------
;; Notes
;;------------------------------------------------------------------------------
;;
;; User must call both:
;;   `spy:secret/init'
;;   `spy:secret/config'
;;
;; They should be called in .doom.d/config.el, before anything that may require
;; their secrets.
;;
;; `spy:secret/init' must be called very early on.
;;
;; `spy:secret/config' could be called just after `spy:secret/init', or later
;; on in config, depending on how you use your secrets' init/config.


;;------------------------------------------------------------------------------
;; Getters
;;------------------------------------------------------------------------------

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


(defun sss:secret/path/root ()
  "Get secrets' base root dir for all systems."
  (spy:system/get (spy:secret/hash) 'path 'secret 'root))


(defun sss:secret/path/load ()
  "Get secrets' load root dir for all systems."
  (spy:system/get (spy:secret/hash) 'path 'secret 'emacs))


(defun sss:secret/path/system ()
  "Get this system's secrets' load dir."
  (spy:system/get (spy:secret/hash) 'path 'secret 'system))


(defun sss:secret/validate (file)
  "Validate ID, hash, and root directory exist and that FILE exists."
  (let* (success
         reason
         (hash (spy:secret/hash))
         (id   (spy:secret/id))
         (dir  (spy:system/get hash 'path 'secret 'system))
         (path (spy:path/to-file dir file)) ; No ".el"; want compiled too.
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
          (mis0/init/message (mapconcat #'identity
                                        '("sss:secret/path(%S)"
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
                                    '("sss:secret/path(%S)"
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


;;------------------------------------------------------------------------------
;; Configuration Helpers
;;------------------------------------------------------------------------------


(defmacro spy:secret/if (func-or-place skip-message &rest body)
  "Do BODY if this system has secrets.

Used to guard config blocks that depend on secrets.

FUNC-OR-PLACE and SKIP-MESSAGE are used only if no secrets. They are formatted
into a `mis0/init/message' for info about skipped config.
  - If SKIP-MESSAGE is a list, it will be passed through `format'."
  ;; Only eval inputs once.
  `(let ((mmm:func-or-place ,func-or-place)
         (mmm:skip-message ,skip-message))
     (if (spy:secret/has)
         ,@body
       (mis0/init/message (concat "\n|%s| %s: %s")
                          (or mmm:func-or-place
                              "spy:secret/if (unlabeled)")
                          "[SKIP]"
                          (if (listp mmm:skip-message)
                              (apply #'format mmm:skip-message)
                            mmm:skip-message)))))
;; (spy:secret/if "testing" "skip string" (message "I should not see this."))


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(imp:provide :modules 'spy 'secret)
