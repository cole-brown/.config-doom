;;; config/org-mode.el -*- lexical-binding: t; -*-

;;------------------------------------------------------------------------------
;; Org-Mode
;;------------------------------------------------------------------------------

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(if-let (lily (jerky/get :default :path: :lily))
    ;; Set org to use lily dir if we have it.
    (setq org-directory lily)
  ;; Otherwise not sure... This is fine until something is figured out.
  (setq org-directory "~/org/"))


;;------------------------------------------------------------------------------
;; Org-Journal
;;------------------------------------------------------------------------------

;; TODO: setup journal


;;------------------------------------------------------------------------------
;; Org-Mode's Legion of Minions
;;------------------------------------------------------------------------------

;; TODO: set up other org-mode stuff
