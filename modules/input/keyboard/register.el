;;; input/keyboard/register.el -*- lexical-binding: t; -*-


;;------------------------------------------------------------------------------
;; Functions: Initialization
;;------------------------------------------------------------------------------

(defun input//kl:layout/init (layout keys functions)
  "Register LAYOUT with its KEYS and FUNCTIONS alists.

KEYS must be a /quoted symbol/ to an alist that satisfies
`input//kl:layout/active:keys' format.

FUNCTIONS must be a /quoted symbol/ to an alist that satisfies
`input//kl:layout/active:functions' format."
  (input//kl:alist/update layout
                          (list keys functions)
                          input//kl:layouts
                          t))


;;------------------------------------------------------------------------------
;; Functions: Configuration
;;------------------------------------------------------------------------------

(defun input//kl:layouts/config (active &optional default)
  "Set ACTIVE/desired layout, and optionally the DEFAULT.

ACTIVE/DEFAULT must be either:
  1) layout keyword (`:dvorak') or,
  2) layout flag symbol (`+layout/dvorak').

If DEFAULt is nil, `:qwerty'/`+layout/qwerty' is assumed.

Must be called after ACTIVE's keys/functions lists are defined."
  ;; Normalize to keywords.
  (let ((active (input//kl:flag->keyword active))
        (default (or
                  (input//kl:flag->keyword default)
                  :qwerty)))
    (when (null input//kl:layout/expected)
      (error (concat "Module :input/keyboard/layout: `input//kl:layouts/config' "
                     "No expected layout set; cannot configure keyboard layout! "
                     "expected: '%S'")
               input//kl:layout/expected))
    ;; Only allow the expected to config themselves.

    (when (eq active input//kl:layout/expected)
      ;; Get the keys/functions alist symobls from `input//kl:layouts' and then
      ;; set `input//kl:layout/{active,default}:{keys,functions}'.
      (let ((active-layout (input//kl:alist/get active
                                                input//kl:layouts))
            (default-layout (input//kl:alist/get default
                                                 input//kl:layouts)))
        (setq input//kl:layout/active            active
              input//kl:layout/default           default)))))
;; (input//kl:layouts/config :spydez)


(defun input:keyboard/layout:configure-active ()
  "Map the active keyboard layout to its keybinds."
  (if (null input//kl:layout/active)
      (error (concat "Module :input/keyboard/layout: "
                     "`input:keyboard/layout:configure-active' "
                     "No active layout set; cannot configure keyboard layout! "
                     "expected: '%S', "
                     "active: '%S'")
             input//kl:layout/expected
             input//kl:layout/active)

    (input:keyboard/layout:layout! input//kl:layout/active)))
;; (input//kl:layout/configure-active)
