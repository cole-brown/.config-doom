;;; spy/secret/init.el -*- lexical-binding: t; -*-


;; todo: spy-fan

(spy/require :spy 'jerky)
(spy/require :spy 'path)

(require 'mis/message)


;;------------------------------------------------------------------------------
;; Configure Secrets
;;------------------------------------------------------------------------------

;; Go get our Secrets if we have the system set up for it.
(if-let* ((hash (jerky/get "system/hash"))
          (id   (jerky/get "system/secret/identities" hash))
          (dir  (jerky/get "system/path/secret" id))
          (file (spy/path/to-file dir "init")) ; No ".el"; want compiled too.
          (name (concat file ".el")))

    ;; We got all the vars from jerky, so check for existance now.
    ;;    Does dir even exist?
    (cond ((not (file-directory-p dir))
           (warning "Secrets %s for this system (%s) does not exist: %s"
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
  (mis/init/message (concat "No secrets for this system:\n"
                            "   hash: %s\n"
                            "     id: %s\n"
                            "    dir: %s\n"
                            "   file: %s\n"
                            "   name: %s\n")
                    hash
                    id
                    dir
                    file
                    name))
