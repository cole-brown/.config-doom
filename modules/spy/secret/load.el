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

;; TODO: Move to nub or mis or str?
;;   - Probably str?
(defun int<spy>:secret:plist:pretty-string (plist)
  "Pretty print plist to string."
  (let ((plist-too (copy-sequence plist))
        (width/key 0)
        output)

    ;; Figure out format width.
    (while plist
      (let ((key (pop plist))
            (_ (pop plist))) ;; Don't care about value (yet).
        (setq width/key (max width/key
                             (length (symbol-name key))))))

    ;; Format each line.
    (let ((fmt/line (concat "  " ;; leading indent
                            "%" (number-to-string width/key) "S"
                            " "
                            "%S")))
      (while plist-too
        (let ((key (pop plist-too))
              (value (pop plist-too)))
          (push (format fmt/line key value) output))))

    ;; Combine lines and output.
    (mapconcat #'identity
               (nreverse output)
               "\n")))
;; (spy:secret:validate :load "init")
;; (int<spy>:secret:plist:pretty-string (spy:secret:validate :load "init"))


(defun int<spy>:secret:validate-and-load (caller feature file)
  "Load FEATURE from FILE for CALLER function.

FEATURE should be list of keyword/symbols for `imp:load'.

FILE should be filepath relative to secret's load directory.

CALLER should be a string of calling function's name.

Returns nil/non-nil for loading success.
Outputs warning to `mis0' warning buffer if secret fail validation."
  (let* ((plist (spy:secret:validate :load file)))
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
                             (int<spy>:secret:plist:pretty-string plist))
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
