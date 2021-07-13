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
  (let* ((hash (spy:system/hash))
         (id   (spy:system/get hash 'id))
         (file/name "init")
         (file/ext ".el")
         (secret/path/emacs (spy:system/get hash 'path 'secret 'emacs))
         ;; No file extension so we can load compiled if it exists.
         (secret/path/load (concat secret/path/emacs file/name))
         ;; With file extension so we can check that file exists.
         (secret/path/file (concat secret/path/load file/ext)))

    ;; Check that we have a valid secret to load.
    (cond ((or (null hash)
               (null id))
           (mis0/init/message (concat "%S %S: "
                                      "No secret hash and/or id:\n"
                                      "hash: %S\n"
                                      "id:   %S")
                              "|secret|"
                              "[SKIP]"
                              hash
                              id))

          ;; Found a path to use?
          ((or (null secret/path/emacs)
               (not (stringp secret/path/emacs)))
           (mis0/init/message "Secrets %s for this system (%s) cannot be determined; directory is not a string: %s"
                              "root emacs directory"
                              id secret/path/emacs)
           ;; TODO: no warn? Just use mis0?
           (warn "Secrets %s for this system (%s) cannot be determined; directory is not a string: %s"
                 "root emacs directory"
                 id secret/path/emacs)
           nil)

          ;; Does path even exist?
          ((not (file-directory-p secret/path/emacs))
           (mis0/init/message "Secrets %s for this system (%s) does not exist: %s"
                              "root emacs directory"
                              id secret/path/emacs)
           ;; TODO: no warn? Just use mis0?
           (warn "Secrets %s for this system (%s) does not exist: %s"
                 "root emacs directory"
                 id secret/path/emacs)
           nil)

          ;; What about the filepath?
          ((not (file-exists-p secret/path/file))
           (mis0/init/message "Secrets %s for this system (%s) does not exist: %s"
                              (concat "root emacs '" file/name file/ext "'")
                              id secret/path/file)
           ;; TODO: no warn? Just use mis0?
           (warn "Secrets %s for this system (%s) does not exist: %s"
                 (concat "root emacs '" file/name file/ext "'")
                 id secret/path/file)
           nil)

          ;; File exists; load it...
          (t
           (mis0/init/message "Loading %s for %s...\n   load path: %s"
                              (concat "root emacs '" file/name "'")
                              id
                              secret/path/load)
           (message "%s: Loading %s for %s...\n   load path: %s"
                    "|secret|"
                    (concat "root emacs '" file/name "'")
                    id
                    secret/path/load)
           ;; TODO: no message? Just use mis0?
           (load secret/path/load)))))


;;------------------------------------------------------------------------------
;; Configuration
;;------------------------------------------------------------------------------

(defun spy:secret/config ()
  "Configure this system's secrets."
  (sss:secret/load 'emacs "config"))


;;------------------------------------------------------------------------------
;; Helper Functions for Loading Files
;;------------------------------------------------------------------------------

(defun sss:secret/load (key file)
  "Load FILE (do not include '.el[c]') from this system's secrets
directory indicated by KEY, if it has secrets.

It must have these keys in jerky:
  hash: 'system 'hash
  id:   'system 'secret 'identities <hash>
  dir:  'system 'path 'secret KEY

And it must have FILE in <dir>.
"
  ;; Load our specific secrets if we have the system set up for it.
  (if-let* ((hash (spy:system/hash))
            (id   (spy:system/get hash 'id))
            (dir  (spy:system/get hash 'path 'secret 'system))
            (path (spy:path/to-file dir file)) ; No ".el"; want compiled too.
            (name (concat path ".el")))
      (progn
        (mis0/init/message (mapconcat #'identity
                            '("sss:secret/load(%S %S)"
                              "  hash: %S"
                              "  id:   %S"
                              "  dir:  %S"
                              "  path  %S"
                              "  name: %S")
                            "\n")
                 key file hash id dir path name)

        ;; We got all the vars from jerky, so check for existance now.
        ;;    Do we have valid-ish data to check?
        (cond ((or (null dir)
                   (not (stringp dir)))
               (mis0/init/message "Secrets %s for this system (%s) cannot be determined; directory is not a string: %s"
                        "directory"
                        id dir)
               (warn "Secrets %s for this system (%s) cannot be determined; directory is not a string: %s"
                     "directory"
                     id dir)
               nil)

              ;; Does dir even exist?
              ((not (file-directory-p dir))
               (mis0/init/message "Secrets %s for this system (%s) do not exist: %s"
                        "directory"
                        id dir)
               (warn "Secrets %s for this system (%s) do not exist: %s"
                     "directory"
                     id dir)
               nil)

              ;; What about the filepath?
              ;; Add ".el" for actual file check.
              ((not (file-exists-p name))
               (mis0/init/message "Secrets %s for this system (%s) does not exist: %s"
                        "file"
                        id path)
               (warn "Secrets %s for this system (%s) does not exist: %s"
                     "file"
                     id path)
               nil)

              ;; File exists; load it...
              (t
               (mis0/init/message "Loading %s secrets...\n   %s" id name)
               (message "SECRETS IS LOADING... %S" path )
               ;; TODO: no message? use mis0 or something?
               (load path))))

    ;; Else no hash or id or dir found...
    ;; TODO: warning? quiet? use mis0 or something?
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
                       hash id dir path name))
  nil)


(defun sss:secret/load.path (&rest path)
  "Attempts to load file rooted at jerky key:
  - 'system <hash> 'path 'secret 'emacs

Appends PATH (do not include '.el[c]' in the last, filename, component).
"
  (if-let* ((hash (spy:system/hash))
            (id   (spy:system/get hash 'id))
            (root (spy:system/get (spy:system/hash) 'path 'secret 'emacs))
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
