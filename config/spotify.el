;;; config/spotify.el -*- lexical-binding: t; -*-

;;------------------------------------------------------------------------------
;; `use-package': Smudge (previously Spotify.el)
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

  ;;---
  ;; Connection Settings
  ;;---
  (customize-set-variable 'smudge-transport 'connect)
  (customize-set-variable 'smudge-oauth2-callback-port "14576")
  (customize-set-variable 'smudge-oauth2-client-id     (plist-get secret:keys:spotify :id))
  (customize-set-variable 'smudge-oauth2-client-secret (plist-get secret:keys:spotify :secret))

  ;; HACK: This is a defconst so it doesn't update when you set a different port number.
  ;; So... Just force it to update.
  (setq smudge-api-oauth2-callback (concat "http://localhost:" smudge-oauth2-callback-port smudge-oauth2-callback-endpoint))

  ;; Refresh rate in seconds.
  ;; This has to make an API call every time, so... don't overdo it and
  ;; throttle yourself.
  (customize-set-variable 'smudge-player-status-refresh-interval 10)

  ;;---
  ;; Keybinds
  ;;---
  ;; Keybind: See config/keybinds/spotify.el
  ;; (define-key smudge-mode-map (kbd "C-c .") 'smudge-command-map)

  ;;---
  ;; Display
  ;;---

  ;; Put status in title-bar instead of modeline
  (customize-set-variable 'smudge-status-location 'title-bar)

  ;; smudge-player-status-format: default is "[%p: %a - %t ◷ %l %r%s]"
  ;;   - https://github.com/danielfm/smudge#customizing-the-player-status
  (customize-set-variable 'smudge-player-status-format "╠ <Spotify: [%r%s %p: %a - %t (◷%l)]> ╣")
  (customize-set-variable 'smudge-title-bar-separator "      ┅┅      ")
  ;; frame-title-format

  ;; I got a lot more room in the titlebar than the modeline...
  (customize-set-variable 'smudge-player-status-truncate-length 30) ;; default: 15

  ;;---
  ;; Status Text
  ;;---
  ;; Defaults are a grab-bag of words ("Playing"/"Stopped") and letters ("R"/"-").

  ;; Do I have unicode media icons?
  ;;   Play:         ▶ / ▶️
  ;;   Pause:        ⏸ / ⏸️
  ;;   Play/Pause:   ⏯ / ⏯️
  ;;   Stop:         ⏹ / ⏹️
  ;;   Skip Back:    ⏮ / ⏮️
  ;;   Skip Forward: ⏭ / ⏭️
  ;;   Shuffle:      🔀 / 🔀️
  ;;   Repeat:       🔁 / 🔁️
  ;;   'Blank/Off':  ◻

  ;; Unicode Icons:
  (customize-set-variable 'smudge-player-status-playing-text       "▶")
  (customize-set-variable 'smudge-player-status-paused-text        "⏸")
  (customize-set-variable 'smudge-player-status-stopped-text       "⏹")
  (customize-set-variable 'smudge-player-status-repeating-text     "🔁")
  (customize-set-variable 'smudge-player-status-not-repeating-text "◻️")
  (customize-set-variable 'smudge-player-status-shuffling-text     "🔀")
  (customize-set-variable 'smudge-player-status-not-shuffling-text "◻")

  ;; ASCII:
  ;; (customize-set-variable 'smudge-player-status-playing-text       "p")
  ;; (customize-set-variable 'smudge-player-status-paused-text        "-")
  ;; (customize-set-variable 'smudge-player-status-stopped-text       "x")
  ;; (customize-set-variable 'smudge-player-status-repeating-text     "R")
  ;; (customize-set-variable 'smudge-player-status-not-repeating-text "-")
  ;; (customize-set-variable 'smudge-player-status-shuffling-text     "S")
  ;; (customize-set-variable 'smudge-player-status-not-shuffling-text "-")


  ;;--------------------
  ;; configuration
  ;;--------------------
  )


;;------------------------------------------------------------------------------
;; Pause Spotify and close Smudge
;;------------------------------------------------------------------------------

(defun spy:workday:end/spotify ()
  "Cleans up Smudge for the day so it hopefully doesn't
have 11 zombie connections to spotify api tomorrow..."
  (interactive)
  (condition-case-unless-debug err
      (progn
        (smudge-connect-player-pause)
        (global-smudge-remote-mode -1)
        ;; TODO: Do I need to clean up any buffers?
        ;; (spy:cmd:buffer/kill.matching ...)?
        )
    ;; Catch signaled error 'error': downgrade to just message.
    ;; [2019-10-22]: This is just theory as spotify can get cranky if
    ;; connected but device was left paused...
    (error
     ;; Downgrade.
     (message "[ERROR]: spy:workday:end/spotify: Received error signal:" err))))


;;------------------------------------------------------------------------------
;; Spotify/Smudge Hydra
;;------------------------------------------------------------------------------

;; TODO: Add major-mode-hydra package so I can use pretty-mode-hydra.
;;   - https://github.com/jerrypnz/major-mode-hydra.el#pretty-hydra
;; TODO: Create a pretty hydra with 'Now Playing' info.
;;   - ugly: https://github.com/cole-brown/spotify.el/blob/6c5b3eb9aa35723d04b2126fea36f9cb241bf5c9/spotify-hydra.el
;;   - old spotify.el setup: https://github.com/cole-brown/spotify.el/tree/6c5b3eb9aa35723d04b2126fea36f9cb241bf5c9
