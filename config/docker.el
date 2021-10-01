;;; config/docker.el -*- lexical-binding: t; -*-

;;------------------------------------------------------------------------------
;; Dockerfile Mode
;;------------------------------------------------------------------------------
;;  - https://github.com/spotify/dockerfile-mode
;;  - https://melpa.org/#/dockerfile-mode

(use-package! dockerfile-mode
  ;; ;;--------------------
  ;; :init
  ;; ;;--------------------

  ;; ;;--------------------
  ;; :hook
  ;; ;;--------------------

  ;;--------------------
  :config
  ;;--------------------

  ;;--------------------
  ;; customization:
  ;;--------------------
  ;; Added by Dooom:
  ;; (add-to-list 'auto-mode-alist '(".dockerfile\\'" . dockerfile-mode))
  ;; (add-to-list 'auto-mode-alist '("/Dockerfile\\(?:\\.[^/\\]*\\)?\\'" . dockerfile-mode))
  (add-to-list 'auto-mode-alist '("build.docker.txt\\'" . dockerfile-mode))

  ;;--------------------
  ;; configuration:
  ;;--------------------

  ;; It looks for this file-local variable for image name.
  ;;   - You can build the image via:
  ;;     + `dockerfile-build-buffer'          ("C-c C-b")
  ;;     + `dockerfile-build-no-cache-buffer' ("C-c M-b")
  (put 'docker-image-name 'safe-local-variable #'stringp))


;;------------------------------------------------------------------------------
;; Docker Commands
;;------------------------------------------------------------------------------
;;  - https://github.com/Silex/docker.el
;;  - https://melpa.org/#/docker

;;---
;; ~M-x docker~
;;---

;; (use-package! docker
;;   ;; ;;--------------------
;;   ;; :init
;;   ;; ;;--------------------
;;
;;   ;; ;;--------------------
;;   ;; :hook
;;   ;; ;;--------------------
;;
;;   ;;--------------------
;;   :config
;;   ;;--------------------
;;
;;   ;;--------------------
;;   ;; customization:
;;   ;;--------------------
;;
;;   ;;--------------------
;;   ;; configuration:
;;   ;;--------------------
;;
;;   ;; Currently nothing but could do stuff. See GitHub README:
;;   ;;   https://github.com/Silex/docker.el
;;   ;;   https://github.com/Silex/docker.el#customizations
;;   ;;
;;   ;; example:
;;   ;; (add-to-list
;;   ;;  'docker-image-run-custom-args
;;   ;;  `("^postgres" ("-e POSTGRES_PASSWORD=postgres" . ,docker-run-default-args)))
;;  )
