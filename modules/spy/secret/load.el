;;; spy/secret/load.el -*- lexical-binding: t; -*-
;;
;;; Code:


;; ┌───────────────────────────────────────────────────────────────────────────┐
;; │                        What's the Secret Word?                            │
;; └───────────────────────────────────────────────────────────────────────────┘


(imp:require :jerky)
(imp:require :path)

(require 'mis0/message)


;;------------------------------------------------------------------------------
;; Helper Functions for Loading Files
;;------------------------------------------------------------------------------

(defun int<spy>:secret:validate-and-load (caller feature file)
  "Load FEATURE from FILE for CALLER function.

FEATURE should be list of keyword/symbols for `imp:load'.

FILE should be filepath relative to secret's root directory.

CALLER should be a string of calling function's name.

Returns nil/non-nil for loading success.
Outputs warning to `mis0' warning buffer if secret fail validation."
  (let* ((plist (spy:secret:validate file)))
    (if-let* ((plist plist)
              (success   (plist-get plist :success))
              (path/load (plist-get plist :path/file/load)))
        ;; Validated successfully and have load path; try to load.
        ;; Success/Failure Return Value: `imp:load' return value.
        (imp:load :feature  feature
                  :path     path/load)

      ;; Failure Message.
      (mis0/init/warning caller
                             (mapconcat #'identity
                                        '("%s: Cannot load secret '%s'; invalid system secrets."
                                          "Validation Result:"
                                          "%s")
                                        "\n")
                             "[SKIP]"
                             file
                             (pp-to-string plist))
      ;; Failure Return Value
      nil)))

;;------------------------------------------------------------------------------
;; Initialization
;;------------------------------------------------------------------------------

(defun spy:secret:init ()
  "Load secret's root init.el."
  (int<spy>:secret:validate-and-load "spy:secret:init"
                                     '(:secret init)
                                      "init"))
;; (spy:secret:init)


;;------------------------------------------------------------------------------
;; Configuration
;;------------------------------------------------------------------------------

(defun spy:secret:config ()
  "Configure this system's secrets."
  (int<spy>:secret:validate-and-load "spy:secret:config"
                                     '(:secret config)
                                      "config"))
;; (spy:secret:config)


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(imp:provide :modules 'spy 'secret 'load)
