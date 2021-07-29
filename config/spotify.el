;;; config/spotify.el -*- lexical-binding: t; -*-

;;------------------------------------------------------------------------------
;; Smudge (previously Spotify.el)
;;------------------------------------------------------------------------------
;; Control Spotify via Spotify Premium app.

(use-package! smudge

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
  ;; customization
  ;;--------------------
  (customize-set-variable 'smudge-transport 'connect)
  (customize-set-variable 'smudge-oauth2-callback-port "14576")
  (customize-set-variable 'smudge-oauth2-client-id     (plist-get secret:keys:spotify :id))
  (customize-set-variable 'smudge-oauth2-client-secret (plist-get secret:keys:spotify :secret))

  ;; Keybind: See config/keybinds/spotify.el
  ;; (define-key smudge-mode-map (kbd "C-c .") 'smudge-command-map)


  ;;--------------------
  ;; configuration
  ;;--------------------

 )
