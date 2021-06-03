;;; layout/keyboard/init.el -*- lexical-binding: t; -*-


;;                                  ──────────                                ;;
;; ╔════════════════════════════════════════════════════════════════════════╗ ;;
;; ║                            Keyboard Layouts                            ║ ;;
;; ╚════════════════════════════════════════════════════════════════════════╝ ;;
;;                                  ──────────                                ;;


;;------------------------------------------------------------------------------
;; Constants & Variables
;;------------------------------------------------------------------------------

;;------------------------------
;; Module-Level
;;------------------------------

(defvar input//kl:layout/expected nil
  "Cached :input/keyboard flag (converted to layout keyword) for desired
keyboard layout.

e.g. `+layout/dvorak' -> `:dvorak'")


(defvar input//kl:layouts nil
  "Collection of registered layouts. A layout should add its entry via
`input//kl:layout/register' during init.

An entry is: (:layout-keyword keys-alist-symbol funcs-alist-symbol)")
;; (setq input//kl:layouts nil)


;;------------------------------
;; Layouts: Active / Default
;;------------------------------

(defvar input//kl:layout/active nil
  "Cached keyword for the active/desired keyboard layout.")


(defvar input//kl:layout/default nil
  "Cached keyword for the keyboard layout which is being overwritten.")


;;------------------------------------------------------------------------------
;; Load: Required
;;------------------------------------------------------------------------------

;; NOTE: Order could matter - take care if modifying.
(load! "error")
(load! "load")
(load! "alist")
(load! "map")
(load! "register")


;;------------------------------------------------------------------------------
;; Load: Optional
;;------------------------------------------------------------------------------

;; None at the moment.


;;------------------------------------------------------------------------------
;; Debugging Helper
;;------------------------------------------------------------------------------

(defun input//kl:loading? ()
  "Use this to hide code you only want to run during Doom/Emacs start-up or to
do some debugging vs actual stuff.

For best, most consistent results: do not use this at all.

Returns non-nil if `doom-init-p' is nil."
  ;; This var is set to `t' after Doom has been initialized.
  (not doom-init-p))


;;------------------------------------------------------------------------------
;; Error Checking & Setting of `input//kl:layout/expected'
;;------------------------------------------------------------------------------

;; Should not have more than one keyboard layout, but only check when loading.
(if (input//kl:loading?)
    ;; We are loading, so check our module flags.
    (let ((flags (doom-module-get :input 'keyboard :flags))
          (layouts 0)
          (suppress-warning nil))
      (when (and (> 1
                    (dolist (flag flags layouts)
                      (when (eq flag '+suppress/layouts)
                        (setq suppress-warning t))
                      (when (string-prefix-p "+layout/" (symbol-name flag))
                        ;; Save first/only as expected/desired layout.
                        (when (null input//kl:layout/expected)
                          (setq input//kl:layout/expected
                                (intern
                                 (concat ":"
                                         (string-remove-prefix "+layout/"
                                                               (symbol-name flag))))))
                        ;; Count for a warning (if not suppressed).
                        (setq layouts (1+ layouts)))))
                 ;; Warn only if we didn't see the suppression.
                 (not suppress-warning))
        (warn (concat "Doom Module `:input/keyboard' init detected %d keyboard "
                      "layout flags. You should really only have one. Suppress "
                      "this by adding the `+suppress/layouts' flag. flags: %S")
              layouts
              flags)))

  ;; Else we're not running during init... probably evaluating this buffer
  ;; directly for dev/testing. Set expected to a testing default.
  (setq input//kl:layout/expected :spydez))


;;------------------------------------------------------------------------------
;; Module Helpers
;;------------------------------------------------------------------------------

(defun input//kl:layout:normalize->string (input)
  "Normalize INPUT to a layout string.

If INPUT is:
  - String:  Remove \"+layout/\" prefix,
             (then remove \":\" prefix if exists), and return.
  - Keyword: Get symbol name, remove \":\" prefix, and return.
  - Symbol:  Get symbol name, remove \"+layout/\" prefix,
             (then remove \":\" prefix if exists), and return.
E.g.
  1) \"dvorak\" -> \"dvorak\"
  2) `:dvorak' -> \"dvorak\"
  3) `+layout/dvorak' -> \"dvorak\""
  ;; Remove keyword's leading ":"?
  (string-remove-prefix
   ":"
   ;; Remove module flag's leading "+layout/"?
   (string-remove-prefix
    "+layout/"
    ;; Remove layout dir's leading "+"?
    (string-remove-prefix
     "+"
     (if (stringp input)
         input
       (symbol-name input))))))
;; (input//kl:layout:normalize->string '+layout/spydez)
;; (input//kl:layout:normalize->string :spydez)
;; (input//kl:layout:normalize->string "spydez")
;; (input//kl:layout:normalize->string "+spydez")


(defun input//kl:normalize->keyword (input)
  "Convert INPUT to a keyboard layout keyword.

If INPUT is:
  - Keyword: It is returned as is.
  - nil:     nil will be returned (allows for default args).

Otherwise INPUT is normalized to a string and then converted to a keyword.

E.g. `+layout/dvorak' -> `:dvorak'."
  (cond ((null input)
         nil)
        ((keywordp input)
         input)
        (t
         (intern (concat ":"
                         (input//kl:layout:normalize->string input))))))
;; (input//kl:normalize->keyword '+layout/spydez)
;; (input//kl:normalize->keyword :spydez)
;; (input//kl:normalize->keyword "spydez")
;; (input//kl:normalize->keyword nil)


;;------------------------------------------------------------------------------
;; Init: Keyboard Layouts
;;------------------------------------------------------------------------------

;;------------------------------
;; Layout Builder and Specific Layouts' Inits
;;------------------------------
(load! "layout/init")


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
