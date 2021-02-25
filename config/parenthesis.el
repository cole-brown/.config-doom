;;; config/parenthesis.el -*- lexical-binding: t; -*-

;;------------------------------------------------------------------------------
;; SmartParens
;;------------------------------------------------------------------------------

;; Should I try disabling all the 'auto-insert'/'auto-delete' stuff?
;;
;; Or should I just globally disable it?
;;
;; Try disabling the auto-shenanigans first.


;;----------------------------
;; Globally disable?
;;----------------------------
;; https://github.com/hlissner/doom-emacs/blob/develop/docs/faq.org#how-to-disable-smartparensautomatic-parentheses-completion

;; (remove-hook 'doom-first-buffer-hook #'smartparens-global-mode)


;;----------------------------
;; Disable Auto-Insert/Delete?
;;----------------------------

;; Look for all the 'defcustom's here:
;;   https://github.com/Fuco1/smartparens/blob/master/smartparens.el

;; sp-autoinsert-pair
;; sp-autodelete-pair
;; sp-autodelete-closing-pair
;; sp-autodelete-opening-pair
;; ? sp-autodelete-wrap

(customize-set-variable 'sp-autoinsert-pair nil)
(customize-set-variable 'sp-autodelete-pair nil)
(customize-set-variable 'sp-autodelete-closing-pair nil)
(customize-set-variable 'sp-autodelete-opening-pair nil)
