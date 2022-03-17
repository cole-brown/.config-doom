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
