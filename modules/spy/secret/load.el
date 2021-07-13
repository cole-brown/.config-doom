;;; spy/secret/load.el -*- lexical-binding: t; -*-
;;
;;; Code:


;; todo: spy-fan

(imp:require :jerky)
(imp:require :modules 'spy 'file 'path)
(imp:require :modules 'spy 'system)

(require 'mis0/message)


;;------------------------------------------------------------------------------
;; Initialization
;;------------------------------------------------------------------------------

(defun spy:secret/init ()
  "Load secret's root init.el."
  (if (spy:secret/has)
      (sss:secret/load "init")

    ;; No secrets for this system.
    (mis0/init/message (concat "%S %S: "
                               "No secret hash, id, or 'init.el':\n"
                               "  hash: %S\n"
                               "  id:   %S")
                       "|spy:secret/init|"
                       "[SKIP]"
                       (spy:secret/hash)
                       (spy:secret/id))))


;;------------------------------------------------------------------------------
;; Configuration
;;------------------------------------------------------------------------------

(defun spy:secret/config ()
  "Configure this system's secrets."
  (if (spy:secret/has)
      (sss:secret/load "config")

    ;; No secrets for this system.
    (mis0/init/message (concat "%S %S: "
                               "No secret hash, id, or 'init.el':\n"
                               "  hash: %S\n"
                               "  id:   %S")
                       "|spy:secret/config|"
                       "[SKIP]"
                       (spy:secret/hash)
                       (spy:secret/id))))


;;------------------------------------------------------------------------------
;; Helper Functions for Loading Files
;;------------------------------------------------------------------------------

(defun sss:secret/load (file)
  "Load FILE (do not include '.el[c]') from this system's secrets
directory indicated by KEY, if it has secrets."
  (let* ((results (sss:secret/path file))
         (id (plist-get results :id))
         (path/name (plist-get results :path/file))
         (path/load (plist-get results :path/load)))

    ;; `sss:secret/path' took care of error cases, so just load if not nil.
    (when path/load
      (mis0/init/message "Loading %s secrets...\n   %s" id path/name)
      (load path/load))))


(defun sss:secret/load.path (&rest path)
  "For use in secrets files themselves, to load sub-files.

Attempts to load file at system's 'path/secret/init' as defined by ':spy/system'.

NOTE: Do not include file's extension ('.el[c]') in PATH."
  (if-let* ((hash (spy:secret/hash))
            (id   (spy:secret/id))
            (root (spy:system/get hash 'path 'secret 'emacs))
            (filepath (apply #'spy:path/to-file root path)) ; No ".el"; want compiled too.
            (name (concat filepath ".el")))

      ;; We got all the vars from jerky, so check for existance now.
      ;;    Do we have valid-ish data to check?
      (cond ((or (null filepath)
                 (not (stringp filepath)))
             (mis0/init/message "%s: Cannot load path; it is not a string: %s"
                                'sss:secret/load.path
                                filepath)
             (warn "%s: Cannot load path; it is not a string: %s"
                   'sss:secret/load.path
                   filepath)
             nil)

            ;; Does file even exist?
            ;; Add ".el" for actual file check.
            ((not (file-exists-p name))
             (mis0/init/message "%s: Cannot load path; it does not exist: %s"
                                'sss:secret/load.path
                                name)
             ;; Don't warn; some just don't exist.
             ;; (warn "%s: Cannot load path; it does not exist: %s"
             ;;       'sss:secret/load.path
             ;;       name)
             nil)

            ;; File exists; load it...
            (t
             (mis0/init/message "Loading secrets file...\n    %s" name)
             (load filepath)))

    ;; Else no hash or id or dir found...
    ;; TODO: warning? quiet? use mis0 or something?
    (mis0/init/message (concat "%s: No secret '%S' for this system:\n"
                               "   hash: %s\n"
                               "     id: %s\n"
                               "   root: %s\n"
                               "   path: %s\n"
                               "   name: %s\n")
                       'sss:secret/load.path
                       path
                       hash
                       id
                       root
                       filepath
                       name))
  nil)


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(imp:provide :modules 'spy 'secret 'load)
