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

  ;; HACK: This is a defconst so it doesn't update when you set a different port number.
  ;; So... Just force it to update.
  (setq smudge-api-oauth2-callback (concat "http://localhost:" smudge-oauth2-callback-port smudge-oauth2-callback-endpoint))

  ;; Keybind: See config/keybinds/spotify.el
  ;; (define-key smudge-mode-map (kbd "C-c .") 'smudge-command-map)


  ;;--------------------
  ;; configuration
  ;;--------------------

 )
