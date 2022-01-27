;;; config/code/python.el -*- lexical-binding: t; -*-


;;------------------------------------------------------------------------------
;; Python
;;------------------------------------------------------------------------------

(use-package! python

  ;;-----
  :config
  ;;-----

  (customize-set-variable 'python-indent-offset
                          (jerky/get 'code 'tab 'normal)
                          "Set indent to tab-width.")

  (customize-set-variable 'python-fill-docstring-style
                          'symmetric)

  ;; Create and add my python-mode hook function to python-mode's hook var.
  (spy:hook/defun-and-hooker python-mode-hook
    '(:name "python/settings"
      :file ".doom.d/config/code/+python.el"
      :docstr "Settings for python-mode itself. Non-LSP stuff."
      :quiet t)

    ;; pycodestyle insists 79 is the One True Fill Column...
    ;; We'll try it for all our python in general.
    (setq fill-column 79)))


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(imp:provide :dot-emacs 'config 'code '+python)
