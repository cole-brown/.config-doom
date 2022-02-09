;;; config/code/+fish.el -*- lexical-binding: t; -*-


;;------------------------------------------------------------------------------
;; Fish
;;------------------------------------------------------------------------------

(use-package! fish-mode

  ;;-----
  :config
  ;;-----

  (customize-set-variable 'fish-indent-offset
                          (jerky/get 'code 'tab 'normal)
                          "Set indent to tab-width.")

  ;; Create and add my fish-mode hook function to fish-mode's hook var.
  (spy:hook/defun-and-hooker fish-mode-hook
    '(:name "fish/settings"
      :file ".doom.d/config/code/+fish.el"
      :docstr "Settings for fish-mode itself. Non-LSP stuff."
      :quiet t)

    ;; Run ~fish_indent~ before saving.
    (add-hook 'before-save-hook
              'fish_indent-before-save)))


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(imp:provide :dot-emacs 'config 'code '+fish)
