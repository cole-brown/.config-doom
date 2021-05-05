;;; config/theme.el -*- lexical-binding: t; -*-


;;------------------------------------------------------------------------------
;; Set Theme
;;------------------------------------------------------------------------------

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
;; (setq doom-theme 'doom-one)

;; This is the best theme:
(setq doom-theme 'doom-zenburn)
(load-theme doom-theme t)

;;------------------------------------------------------------------------------
;; Customize Theme
;;------------------------------------------------------------------------------

;; Zenburn Customizations:
(when (eq doom-theme 'doom-zenburn)
  (spy/config 'theme 'zenburn))
