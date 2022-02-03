;;; config/theme.el -*- lexical-binding: t; -*-


;;------------------------------------------------------------------------------
;; Faces
;;------------------------------------------------------------------------------

;;---
;; I need to customize some org-mode faces - they're not the greatest (IMO) in
;; Zenburn. So here are the vars at their defaults. A theme config file can
;; update them as needed.
;;---

(defface spy:theme.face/org.todo.keyword/todo
  (list (cons
         ;; display type
         t
         ;; attributes
         (list
          :weight 'bold
          :inherit 'warning)))
  "Face for todo keyword in todo sequence."
  :group 'doom-themes)


(defface spy:theme.face/org.todo.keyword/background
  (list (cons
         ;; display type
         t
         ;; attributes
         nil))
  "Face for todo keyword in todo sequence."
  :group 'doom-themes)


(defface spy:theme.face/org.todo.keyword/done.good
  (list (cons
         ;; display type
         t
         ;; attributes
         (list
          :inherit 'org-done)))
  "Face for todo keyword in todo sequence."
  :group 'doom-themes)


(defface spy:theme.face/org.todo.keyword/done.bad
  (list (cons
         ;; display type
         t
         ;; attributes
         (list
          :inherit 'org-done)))
  "Face for todo keyword in todo sequence."
  :group 'doom-themes)


(defface spy:theme.face/org.todo.keyword/info
  (list (cons
         ;; display type
         t
         ;; attributes
         (list
          :inherit 'org-done)))
  "Face for todo keyword in todo sequence."
  :group 'doom-themes)

(defface spy:theme.face/org.todo.keyword/null
  (list (cons
         ;; display type
         t
         ;; attributes
         (list
          :inherit 'org-done)))
  "Face for todo keyword in todo sequence."
  :group 'doom-themes)


;;------------------------------------------------------------------------------
;; Set Theme
;;------------------------------------------------------------------------------

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
;; (setq doom-theme 'doom-one)

;; This is the best theme:
(setq doom-theme 'doom-zenburn)

;; I need the theme loaded now if I want to tweak colors. If it's not loaded,
;; updating the `spy:theme.face/...' vars will fail silently.
(load-theme doom-theme t)


;;------------------------------------------------------------------------------
;; Customize Theme
;;------------------------------------------------------------------------------

;; Zenburn Customizations:
(when (eq doom-theme 'doom-zenburn)
  (imp:load :feature  '(:dot-emacs config theme zenburn)
            :path     (imp:path:current:dir/relative :dot-emacs)
            :filename "zenburn"))


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(imp:provide :dot-emacs 'config 'theme 'config)
