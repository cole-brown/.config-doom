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
(load! "alist")
(load! "map")
(load! "register")


;;------------------------------------------------------------------------------
;; Load: Optional
;;------------------------------------------------------------------------------

;; None at the moment.


;;------------------------------------------------------------------------------
;; Error Checking & Setting of `input//kl:layout/expected'
;;------------------------------------------------------------------------------

;; Should not have more than one keyboard layout, but only check when loading.
(if load-file-name
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

  ;; Else we're not loading a file... probably evaluating this buffer directly
  ;; for dev/testing. Set expected to a testing default.
  (setq input//kl:layout/expected :spydez))

;;------------------------------------------------------------------------------
;; Module Helpers
;;------------------------------------------------------------------------------

(defun input//kl:loading-for (layout)
  "Returns non-nil if loading (or developing/debugging) for the LAYOUT.

LAYOUT can be the flag symbol or keyword (see `input//kl:flag->keyword').

E.g. if `:dvorak' is our desired layout, this returns non-nil for LAYOUT
`:dvorak', and nil for others."
  (and input//kl:layout/expected
       layout
       (eq input//kl:layout/expected
           (input//kl:flag->keyword layout))))
;; (input//kl:loading-for :spydez)
;; (input//kl:loading-for :qwerty)

(defun input//kl:file/exists? (relative-path)
  "Returns non-nil if RELATIVE-PATH exists relative to this file's directory."
  (file-exists-p (concat (file-name-as-directory (dir!)) relative-path)))
;; (input//kl:file/exists? "layout/spydez/init.el")


(defun input//kl:flag->keyword (flag)
  "Convert keyboard layout flag to a keyboard layout keyword.

If FLAG is already a keyword, it is returned as is.

If FLAG is nil, nil will be returned (allows for default args).

Otherwise the flag prefix is removed and it is converted into a keyword.

E.g. `+layout/dvorak' -> `:dvorak'."
  (cond ((null flag)
         nil)
        ((keywordp flag)
         flag)
        (t
         (intern (concat ":"
                         (string-remove-prefix "+layout/"
                                               (symbol-name flag)))))))
;; (input//kl:flag->keyword '+layout/spydez)
;; (input//kl:flag->keyword :spydez)
;; (input//kl:flag->keyword nil)


(defun input//kl:symbol->name (symbol)
  "Convert keyboard layout flag or keyword to the layout name string.

E.g.
  1) `+layout/dvorak' -> \"dvorak\"
  1) `:dvorak' -> \"dvorak\""
 (string-remove-prefix ":"
                        (string-remove-prefix "+layout/"
                                              (symbol-name symbol))))
;; (input//kl:symbol->name '+layout/spydez)
;; (input//kl:symbol->name :spydez)


(defun input:keyboard/layout:load-file (layout load-name &optional directory)
  "Load LOAD-NAME file if its LAYOUT directory and LOAD-NAME file exists on the
filesystem.

DIRECTORY, if nil, will be FLAG minus its '+' prefix (e.g. `+dvorak' is
'dvorak/' directory).
  - The keyboard layout's keyword is also accepted (e.g. `:dvorak').

LOAD-NAME should be filename (without extension) to be passed to `load!' as:
(concat (file-name-as-directory \"layout\")
        (file-name-as-directory DIRECTORY)
        LOAD-NAME)

The extension '.el' is used to check for file existance."
  ;; Allow keyword or flag.
  (let* ((directory (or directory
                        (input//kl:symbol->name layout)))
         (path (concat (file-name-as-directory "layout")
                       (file-name-as-directory directory)
                       load-name)))
    ;; Is it ok for some files to not exist, maybe?
    ;; Perhaps a layout has an init.el but not a config.el right now?..
    (when (input//kl:file/exists? (concat path ".el"))
      (load! path))
    ;; If not, switch back to this:
    ;; (if (input//kl:file/exists? (concat path ".el"))
    ;;     (load! path)
    ;;   (warn (concat "Doom Module `:input/keyboard' init.el could not find "
    ;;                 "'%s' file for '%s'. path: %s")
    ;;         load-name
    ;;         flag
    ;;         (concat path ".el")))
    ))
;; (input:keyboard/layout:load-file :spydez "config")


(defun input:keyboard/layout:load-if (layout load-name &optional directory)
  "Load LAYOUT if is the desired layout according to `input//kl:loading-for' and
if its LOAD-NAME file exists on the filesystem.

DIRECTORY, if nil, will be FLAG minus its default prefix (e.g. `+layout/dvorak'
is 'dvorak/' directory).
  - The keyboard layout's keyword is also accepted (e.g. `:dvorak').

LOAD-NAME should be filename (without extension) to be passed to `load!' as:
(concat (file-name-as-directory \"layout\")
        (file-name-as-directory DIRECTORY)
        LOAD-NAME)

The extension '.el' is used to check for file existance."
  (when (input//kl:loading-for layout)
    (input:keyboard/layout:load-file layout load-name directory)))
;; (input:keyboard/layout:load-if :spydez "config")


;;------------------------------------------------------------------------------
;; Init: Keyboard Layouts
;;------------------------------------------------------------------------------

;;------------------------------
;; Layout Builder Functions
;;------------------------------
(load! "layout/init")


;;------------------------------
;; Qwerty
;;------------------------------
;; Always need qwerty (right now) for unmapping help.
(load! "layout/qwerty/init")
;; (input:keyboard/layout:load-if :qwerty "init")


;;------------------------------
;; Dvorak (Optional)
;;------------------------------

;; Normal Dvorak
(input:keyboard/layout:load-file :dvorak "init")

;; Dvorak with non-standard keybinds of mine.
(input:keyboard/layout:load-file :spydez "init")


;;------------------------------
;; <NEXT LAYOUT> (Optional)
;;------------------------------


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
