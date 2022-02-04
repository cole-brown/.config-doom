;;; config/hydra.el -*- lexical-binding: t; -*-


;; ┌──────────────────────────────────═══───────────────────────────────────┐ ;;
;; │                                 ═════                                  │ ;;
;; │           Multi-Headed Monster - Major, Pretty, and Original           │ ;;
;; │                                 ═════                                  │ ;;
;; └──────────────────────────────────═══───────────────────────────────────┘ ;;

(require 's)
(require 'all-the-icons)


;;------------------------------------------------------------------------------
;; Major-Mode & Pretty Hydra
;;------------------------------------------------------------------------------
;; NOTE: Major-Mode Hydra includes Pretty-Hydra, but you can install
;; Pretty-Hydra on its own if you want...
;;   https://github.com/jerrypnz/major-mode-hydra.el
;;   https://github.com/jerrypnz/major-mode-hydra.el#pretty-hydra

;; NOTE: Slow Rendering
;; If you experience a slow down in performance when rendering multiple icons
;; simultaneously, you can try setting the following (emacs) variable:
;;   (setq inhibit-compacting-font-caches t)

;; NOTE: Troubleshooting
;;   TODO: Some of my Font Awesome icons are wrong, so I might have to do this...
;; https://github.com/domtronn/all-the-icons.el#troubleshooting

;;------------------------------
;; The Missing Functions:
;;------------------------------
;; NOTE [2022-02-04]:
;; Docs for Pretty Hydra use some of these in their example, which is great,
;; except they don't exist... So I found a GitHub Gist that defines them:
;;   https://gist.github.com/mbuczko/e15d61363d31cf78ff17427072e0c325"

(defun with-faicon (icon str &optional height v-adjust)
  "Return string of Font Awesome ICON and STR.

Passes HEIGHT and V-ADJUST to `all-the-icons-faicon'.

[2022-02-04] https://gist.github.com/mbuczko/e15d61363d31cf78ff17427072e0c325"
  (s-concat (all-the-icons-faicon icon
                                  :v-adjust (or v-adjust 0)
                                  :height (or height 1))
            " "
            str))


(defun with-fileicon (icon str &optional height v-adjust)
  "Return string of File ICON and STR.

Passes HEIGHT and V-ADJUST to `all-the-icons-fileicon'.

[2022-02-04] https://gist.github.com/mbuczko/e15d61363d31cf78ff17427072e0c325"
  (s-concat (all-the-icons-fileicon icon
                                    :v-adjust (or v-adjust 0)
                                    :height (or height 1))
            " "
            str))


(defun with-octicon (icon str &optional height v-adjust)
  "Return string of Octicon ICON and STR.

Passes HEIGHT and V-ADJUST to `all-the-icons-octicon'.

[2022-02-04] https://gist.github.com/mbuczko/e15d61363d31cf78ff17427072e0c325"
  (s-concat (all-the-icons-octicon icon
                                   :v-adjust (or v-adjust 0)
                                   :height (or height 1))
            " "
            str))


(defun with-material (icon str &optional height v-adjust)
  "Return string of Material ICON and STR.

Passes HEIGHT and V-ADJUST to `all-the-icons-material'.

[2022-02-04] https://gist.github.com/mbuczko/e15d61363d31cf78ff17427072e0c325"
  (s-concat (all-the-icons-material icon
                                    :v-adjust (or v-adjust 0)
                                    :height (or height 1))
            " "
            str))


(defun with-mode-icon (mode str &optional height no-space face)
  "Return string of MODE's icon and STR.

If HEIGHT and/or FACE are non-nil, passes them to `all-the-icons-icon-for-mode'.

Automatically sets `:v-adjust' based on... `major-mode'???
  - IDK.

If NO-SPACE is nil, adds a space between MODE's icon and STR.

[2022-02-04] https://gist.github.com/mbuczko/e15d61363d31cf78ff17427072e0c325"
  (let* ((v-adjust (if (eq major-mode 'emacs-lisp-mode) 0.0 0.05))
         (args     `(:height ,(or height 1) :v-adjust ,v-adjust))
         (_         (when face
                      (lax-plist-put args :face face)))
         (icon     (apply #'all-the-icons-icon-for-mode mode args))
         (icon     (if (symbolp icon)
                       (apply #'all-the-icons-octicon "file-text" args)
                     icon)))
    (s-concat icon (if no-space "" " ") str)))


;;------------------------------------------------------------------------------
;; Major-Mode Hydra
;;------------------------------------------------------------------------------
;; https://github.com/jerrypnz/major-mode-hydra.el#major-mode-hydra

(use-package! major-mode-hydra
  ;; If you want a keybind:
  ;; NOTE: "M-SPC" is an alt. keybind for Doom leader.
  ;; :bind
  ;; ("M-SPC" . major-mode-hydra)
  )


;;------------------------------------------------------------------------------
;; Pretty Hydra
;;------------------------------------------------------------------------------
;; https://github.com/jerrypnz/major-mode-hydra.el#pretty-hydra

;; `with-faicon'
;;   - Uses `all-the-icons-faicon'.
;;   - aka "With Font Awesome icon"
;;
;; All-the-Icons: Inserting Icons Directly
;;   https://github.com/domtronn/all-the-icons.el#inserting-icons-directly
;;
;; The icon alists are prefixed with: `all-the-icons-data/'
;;   (pp all-the-icons-data/fa-icon-alist)

;;
;;
;; No package setup, currently.
;;
;;


;;------------------------------------------------------------------------------
;; Original Hydra
;;------------------------------------------------------------------------------

;;
;;
;; No package setup, currently.
;;
;;


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(imp:provide :dot-emacs 'config 'hydra)
