;;; spy/secret/init.el -*- lexical-binding: t; -*-
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
            (file (spy/path/to-file dir "init")) ; No ".el"; want compiled too.
            (name (concat file ".el")))

      ;; We got all the vars from jerky, so check for existance now.
      ;;    Does dir even exist?
      (cond ((not (file-directory-p dir))
             (warning "Secrets %s for this system (%s) do not exist: %s"
                      "directory"
                      id dir))

            ;; What about the init file?
            ;; Add ".el" for actual file check.
            ((not (file-exists-p name))
             (warning "Secrets %s for this system (%s) does not exist: %s"
                      "init.el file"
                      id file))

            ;; File exists; load it...
            (t
             (mis/init/message "Loading %s secrets...\n   %s" id name)
             ;; TODO: no message? use mis or something?
             (load file)))

    ;; Else no hash or id or dir found...
    ;; TODO: warning? quiet? use mis or something?
    (mis/init/message (concat "No secret '%s' for this system:\n"
                              "   hash: %s\n"
                              "     id: %s\n"
                              "    dir: %s\n"
                              "   file: %s\n"
                              "   name: %s\n")
                      key
                      hash
                      id
                      dir
                      file
                      name)))


;;------------------------------------------------------------------------------
;; Configure Secrets
;;------------------------------------------------------------------------------

;; Go get our Secrets if we have the system set up for it.
;; Only do this if we have:
;;   - A hash & id for this computer.
;;   - A valid root init.el for secrets.
;; secrets/init.el will do the per-computer stuff.
(spy//secret/load 'root "init")


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(spy/provide :spy 'secret)
