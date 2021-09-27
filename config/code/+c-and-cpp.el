;;; config/code/+c.el -*- lexical-binding: t; -*-

;;------------------------------
;; NOTE:
;;------
;; C and C++ are exactly the same right now... so both are here together.
;;
;; If they start to diverge, split them up into "+c.el" and "+cpp.el".
;;------------------------------




;;----------------------------------------------------------------------------
;; Use-Package
;;----------------------------------------------------------------------------

;; TODO: Check this?
;;   https://github.com/dholm/dotemacs/blob/master/.emacs.d/lisp/modes/c-c%2B%2B.el
;;   CEDET and stuff...
(use-package cc-mode
  ;; Just in case `use-package-always-ensure' is `t'...
  :ensure nil

  ;;--------------------
  :init
  ;;--------------------

  (spy:hook/defun c-common-hook
    '(:name "c-and-cpp/settings"
      :file ".doom.d/config/code/+c-and-cpp.el"
      :docstr "Settings for C/C++ mode. Non-LSP stuff."
      ;; :quiet nil
      )

    ;; Use BSD style in C, C++.
    (c-set-style "bsd")
    ;; Available C style:
    ;;   - "gnu":        The default style for GNU projects
    ;;   - "k&r":        What Kernighan and Ritchie, the authors of C used in their book
    ;;   - "bsd":        What BSD developers use, aka "Allman style" after Eric Allman.
    ;;   - "whitesmith": Popularized by the examples that came with Whitesmiths C, an early commercial C compiler.
    ;;   - "stroustrup": What Stroustrup, the author of C++ used in his book
    ;;   - "ellemtel":   Popular C++ coding standards as defined by "Programming in C++, Rules and Recommendations," Erik Nyquist and Mats Henricson, Ellemtel
    ;;   - "linux":      What the Linux developers use for kernel development
    ;;   - "python":     What Python developers use for extension modules
    ;;   - "java":       The default style for java-mode (see below)
    ;;   - "user":       When you want to define your own style
    ;;   - See `c-style-alist' for supported strings.
    ;;
    ;; See this for visuals: https://en.wikipedia.org/wiki/Indentation_style

    (setq c-basic-offset (jerky/get 'code 'tab 'normal))

    (c-set-offset 'innamespace 0) ; Don't indent namespace - waste of indent level
    (c-set-offset 'case-label '+) ; indent case labels by c-indent-level, too

    ;; Separate CamelCase & snake_case into separate words?
    ;; (subword-mode t)
    ;; Too much work for forwards/back normally. Easy toggle would be nice?
    )

  ;;--------------------
  :hook
  ;;--------------------
  ((c++-mode . sss:hook/c-and-cpp/settings)
   (c-mode . sss:hook/c-and-cpp/settings))

  ;;--------------------
  :config
  ;;--------------------

  ;;--------------------
  ;; customization: C / C++
  ;;--------------------

  ;;--------------------
  ;; configuration: C / C++
  ;;--------------------

  (add-to-list 'auto-mode-alist '("\\.cxx$" . c++-mode))
  (add-to-list 'auto-mode-alist '("\\.cpp$" . c++-mode))

  ;; Can setup auto-complete, company, flycheck, lots others here.
  ;; TODO: Lots more here maybe when I do some C/C++ work again.

  )
