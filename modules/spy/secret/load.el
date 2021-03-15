;;; spy/secret/load.el -*- lexical-binding: t; -*-
;;
;;; Code:


;; todo: spy-fan

(spy/require :spy 'jerky)
(spy/require :spy 'path)

(require 'mis/message)


;;------------------------------------------------------------------------------
;; Secret-Getter
;;------------------------------------------------------------------------------

(defun spy//secret/load (key file)
  "Load FILE (do not include '.el[c]') from this system's secrets
directory indicated by KEY, if it has secrets.

It must have these keys in jerky:
  hash: 'system 'hash
  id:   'system 'secret 'identities <hash>
  dir:  'system 'path 'secret KEY

And it must have FILE in <dir>.
"
  ;; Load our specific secrets if we have the system set up for it.
  (if-let* ((hash (jerky/get 'system 'hash))
            (id   (jerky/get 'system 'secret 'identities hash))
            (dir  (jerky/get 'system 'path 'secret key))
            (path (spy/path/to-file dir file)) ; No ".el"; want compiled too.
            (name (concat path ".el")))
      (progn
        (message "spy//secret/load(%S %S) ->\n%S %S %S %S %S" key file hash id dir path name)

        ;; We got all the vars from jerky, so check for existance now.
        ;;    Do we have valid-ish data to check?
        (cond ((or (null dir)
                   (not (stringp dir)))
               (message "Secrets %s for this system (%s) cannot be determined; directory is not a string: %s"
                        "directory"
                        id dir)
               (warn "Secrets %s for this system (%s) cannot be determined; directory is not a string: %s"
                     "directory"
                     id dir)
               nil)

              ;; Does dir even exist?
              ((not (file-directory-p dir))
               (message "Secrets %s for this system (%s) do not exist: %s"
                        "directory"
                        id dir)
               (warn "Secrets %s for this system (%s) do not exist: %s"
                     "directory"
                     id dir)
               nil)

              ;; What about the filepath?
              ;; Add ".el" for actual file check.
              ((not (file-exists-p name))
               (message "Secrets %s for this system (%s) does not exist: %s"
                        "file"
                        id path)
               (warn "Secrets %s for this system (%s) does not exist: %s"
                     "file"
                     id path)
               nil)

              ;; File exists; load it...
              (t
               (mis/init/message "Loading %s secrets...\n   %s" id name)
               (message "SECRETS IS LOADING... %S" path )
               ;; TODO: no message? use mis or something?
               (load path))))

    ;; Else no hash or id or dir found...
    ;; TODO: warning? quiet? use mis or something?
    (mis/init/message (concat "No secret '%s' for this system:\n"
                              "   hash: %s\n"
                              "     id: %s\n"
                              "    dir: %s\n"
                              "   path: %s\n"
                              "   name: %s\n")
                      key
                      hash
                      id
                      dir
                      path
                      name))
  nil)


(defun spy//secret/load.path (&rest path)
  "Attempts to load file rooted at jerky key:
  - 'system 'path 'secret 'emacs

Appends PATH (do not include '.el[c]' in the last, filename, component).
"
  (if-let* ((hash (jerky/get 'system 'hash))
            (id   (jerky/get 'system 'secret 'identities hash))
            (root (jerky/get 'system 'path 'secret 'emacs))
            (filepath (apply #'spy/path/to-file root path)) ; No ".el"; want compiled too.
            (name (concat filepath ".el")))

      ;; We got all the vars from jerky, so check for existance now.
      ;;    Do we have valid-ish data to check?
      (cond ((or (null filepath)
                 (not (stringp filepath)))
             (mis/init/message "%s: Cannot load path; it is not a string: %s"
                               'spy//secret/load
                               filepath)
             (warn "%s: Cannot load path; it is not a string: %s"
                   'spy//secret/load
                   filepath)
             nil)

            ;; Does file even exist?
            ;; Add ".el" for actual file check.
            ((not (file-exists-p name))
             (mis/init/message "%s: Cannot load path; it does not exist: %s"
                               'spy//secret/load
                               name)
             ;; Don't warn; some just don't exist.
             ;; (warn "%s: Cannot load path; it does not exist: %s"
             ;;       'spy//secret/load
             ;;       name)
             nil)

            ;; File exists; load it...
            (t
             (mis/init/message "Loading secrets file...\n    %s" name)
             (load filepath)))

  ;; Else no hash or id or dir found...
  ;; TODO: warning? quiet? use mis or something?
  (mis/init/message (concat "%s: No secret '%S' for this system:\n"
                            "   hash: %s\n"
                            "     id: %s\n"
                            "   root: %s\n"
                            "   path: %s\n"
                            "   name: %s\n")
                    'spy//secret/load
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
(spy/provide :spy 'secret 'load)