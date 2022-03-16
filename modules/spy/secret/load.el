;;; spy/secret/load.el -*- lexical-binding: t; -*-
;;
;;; Code:


;; todo: spy-fan

(imp:require :jerky)
(imp:require :path)

(require 'mis0/message)


;;------------------------------------------------------------------------------
;; Helper Functions for Loading Files
;;------------------------------------------------------------------------------

(defun sss:secret/load.root (file)
  "Load FILE (do not include '.el[c]') from the secrets root
init/config directory, if it has secrets.

Does not check for validity."
  (load (path:abs:file (sss:secret/path/load) file)))


(defun sss:secret/load.path/required (&rest path)
  "Load an expected/required system-specific secret file.

For use in secrets files themselves, to load sub-files.

Attempts to load file at the system's secrets dir, if it has secrets.
  - Complains if a secrets var doesn't exist.
  - Complain if file indicated by PATH doesn't exist.

NOTE: Do not include file's extension ('.el[c]') in PATH."
  (if-let* ((hash (spy:secret/hash))
            (id   (spy:secret/id))
            (root (sss:secret/path/load))
            (filepath (apply #'path:abs:file root path)) ; No ".el"; want compiled too.
            (name (concat filepath ".el")))

      ;; We got all the vars from jerky, so check for existance now.
      ;;    Do we have valid-ish data to check?
      (cond ((or (null filepath)
                 (not (stringp filepath)))
             (mis0/init/warning 'sss:secret/load.path
                                "Cannot load path; it is not a string: %s"
                                filepath)
             nil)

            ;; Does file even exist?
            ;; Add ".el" for actual file check.
            ((not (file-exists-p name))
             (mis0/init/warning 'sss:secret/load.path
                                "Cannot load path; it does not exist: %s"
                                name)
             nil)

            ;; File exists; load it...
            (t
             (mis0/init/message "Loading secrets file...\n    %s" name)
             (load filepath)))

    ;; Else no hash or id or dir found...
    (mis0/init/warning 'sss:secret/load.path
                       (concat "No secret '%S' for this system:\n"
                               "   hash: %s\n"
                               "     id: %s\n"
                               "   root: %s\n"
                               "   path: %s\n"
                               "   name: %s\n")
                       path
                       hash
                       id
                       root
                       filepath
                       name))
  nil)


(defun sss:secret/load.path/optional (&rest path)
  "Load an optional system-specific secret file.

For use in secrets files themselves, to load sub-files.

Attempts to load file at the system's secrets dir, if it has secrets.
  - Complains if a secrets var doesn't exist.
  - Does _NOT_ complain if file indicated by PATH doesn't exist.

NOTE: Do not include file's extension ('.el[c]') in PATH."
  (if-let* ((hash (spy:secret/hash))
            (id   (spy:secret/id))
            (root (sss:secret/path/load))
            (filepath (apply #'path:abs:file root path)) ; No ".el"; want compiled too.
            (name (concat filepath ".el")))

      ;; We got all the vars from jerky, so check for existance now.
      ;;    Do we have valid-ish data to check?
      (cond ((or (null filepath)
                 (not (stringp filepath)))
             (mis0/init/warning 'sss:secret/load.path
                                "Cannot load path; it is not a string: %s"
                                filepath)
             nil)

            ;; Does file even exist?
            ;; Add ".el" for actual file check.
            ((not (file-exists-p name))
             ;; Optional file, so don't complain.
             nil)

            ;; File exists; load it...
            (t
             (mis0/init/message "Loading secrets file...\n    %s" name)
             (load filepath)))

    ;; Else no hash or id or dir found...
    (mis0/init/warning 'sss:secret/load.path
                       (concat "No secret '%S' for this system:\n"
                               "   hash: %s\n"
                               "     id: %s\n"
                               "   root: %s\n"
                               "   path: %s\n"
                               "   name: %s\n")
                       path
                       hash
                       id
                       root
                       filepath
                       name))
  nil)


;;------------------------------------------------------------------------------
;; Initialization
;;------------------------------------------------------------------------------

(defun spy:secret/init ()
  "Load secret's root init.el."
  (if (spy:secret/has)
      (sss:secret/load.root "init")

    ;; No secrets for this system.
    (let ((path/init (path:abs:file (sss:secret/path/system) "init.el")))
      (mis0/init/warning "spy:secret/init"
                         (mapconcat #'identity
                                    '("%s: Cannot init; system has no secrets."
                                      "  hash: %s"
                                      "  ID:   %s"
                                      "  init: %s"
                                      "   - exists?: %s")
                                    "\n")
                         "[SKIP]"
                         (spy:secret/hash)
                         (spy:secret/id)
                         path/init
                         (if (file-exists-p path/init)
                             "yes"
                           "no")))))
;; (spy:secret/init)


;;------------------------------------------------------------------------------
;; Configuration
;;------------------------------------------------------------------------------

(defun spy:secret/config ()
  "Configure this system's secrets."
  (if (spy:secret/has)
      (sss:secret/load.root "config")

    ;; No secrets for this system.
    (let ((path/init (path:abs:file (sss:secret/path/system) "init.el"))
          (path/config (path:abs:file (sss:secret/path/system) "config.el")))
      (mis0/init/warning "spy:secret/init"
                         (mapconcat #'identity
                                    '("%s: Cannot init; system has no secrets."
                                      "  hash:   %s"
                                      "  ID:     %s"
                                      "  init:   %s"
                                      "   - exists?: %s"
                                      "  config: %s"
                                      "   - exists?: %s")
                                    "\n")
                         "[SKIP]"
                         (spy:secret/hash)
                         (spy:secret/id)
                         path/init
                         (if (file-exists-p path/init)
                             "yes"
                           "no")
                         path/config
                         (if (file-exists-p path/config)
                             "yes"
                           "no")))))
;; (spy:secret/config)


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(imp:provide :modules 'spy 'secret 'load)
