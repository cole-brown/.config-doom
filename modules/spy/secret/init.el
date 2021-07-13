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


(defun sss:secret/path (file)
  "Get the path to secrets FILE for this system.

NOTE FILE must be filename sans extension (e.g. \"init\", not \"init.el\")!

Returns a plist with keys:
  - :id        - `spy:secret/id' string or nil.
  - :path/name - Path to FILE, with extension.
  - :path/load - Path to FILE, without extension. Use this for loading the file. "
  (if-let* ((hash (spy:secret/hash))
            (id   (spy:secret/id))
            (dir  (spy:system/get hash 'path 'secret 'system))
            (path (spy:path/to-file dir file)) ; No ".el"; want compiled too.
            (name (concat path ".el")))
      (progn
        (mis0/init/message (mapconcat #'identity
                            '("sss:secret/path(%S)"
                              "  hash: %S"
                              "  id:   %S"
                              "  dir:  %S"
                              "  path: %S"
                              "  name: %S")
                            "\n")
                 file hash id dir path name)


        ;; We got all the vars from jerky, so check for existance now.
        ;;    Do we have valid-ish data to check?
        (cond ((or (null dir)
                   (not (stringp dir)))
               (mis0/init/message
                (concat "%s(%s): "
                        "Secrets %s for this system (%s) cannot be determined; "
                        "directory is not a string: %s")
                "sss:secret/path"
                file
                "directory"
                id
                dir)

               ;; TODO: warn?

               ;; Return a 'does not exist'.
               (list :id id :file-name nil :load-path nil))

              ;; Does dir even exist?
              ((not (file-directory-p dir))
               (mis0/init/message
                (concat "%s(%s): "
                        "Secrets %s for this system (%s) does not exist: %s")
                "sss:secret/path"
                file
                "directory"
                id
                dir)

               ;; TODO: warn?

               ;; Return a 'does not exist'.
               (list :id id :file-name nil :load-path nil))

              ;; What about the filepath?
              ;; Add ".el" for actual file check.
              ((not (file-exists-p name))
               (mis0/init/message
                (concat "%s(%s): "
                        "Secrets %s for this system (%s) does not exist: %s")
                "sss:secret/path"
                file
                "file"
                id
                name)

               ;; TODO: warn?

               ;; Return a 'does not exist'.
               (list :id id :file-name nil :load-path nil))

              ;; File exists; return the load path...
              (t
               (list :id id :file-name name :load-path path))))

    ;; Else no hash or id or dir found...
    (mis0/init/message (mapconcat #'identity
                                  '("sss:secret/load:"
                                    "  No secret '%s' for this system."
                                    "  file: %s"
                                    "  -> hash: %s"
                                    "  ->   id: %s"
                                    "  ->  dir: %s"
                                    "  -> path: %s"
                                    "  -> name: %s")
                               "\n")
                       key file
                       hash id dir path name)

    ;; TODO: warn?

    ;; Return a 'does not exist'.
    (list :id id :file-name nil :load-path nil)))


(defun spy:secret/has ()
  "Returns non-nil if this system has secrets.

The system is considered to have secrets if:
  - It has a hash.
  - It has an ID.
  - And it has a secrets 'init.el' file."
  (condition-case _
      (not (null (sss:secret/path "init")))
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
