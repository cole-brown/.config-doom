;;; spy/system/+multiplex/systems.el -*- lexical-binding: t; -*-

;;------------------Init & Config Help for Multiple Systems.--------------------
;;--                     What computer is this anyways?                       --
;;--------------------------(probably the wrong one)----------------------------


;;------------------------------------------------------------------------------
;; /This/ System Right Now.
;;------------------------------------------------------------------------------
;; Find the Answer to the Ultimate Question:
;;----------
;; "Where the hell am I?", obviously.
;; Or maybe "Who the hell am I?"...

;; Set our system's hash.
(spy:system/hash)
;; (spy:system/get)
;; (jerky/get 'system 'hash)


;;------------------------------------------------------------------------------
;; All Systems: Initialize.
;;------------------------------------------------------------------------------


;;--------------------
;; home/2017/desk
;;   Host OS:  Windows 10
;;   Guests:   Misc Linux via WSL2
;;--------------------

;;---
;; home/2017/desk::ab48e5-886ff
;;   via WSL2
;;---
(let* ((hash "ab48e5-886ff0")
       (id   (concat "home/2017/desk::" hash))
       (path/root "~/.config/spydez/secret/")
       (path/doom.rel "emacs/doom")
       (path/doom.abs (spy:path/to-dir path/root path/doom.rel)))

  (spy:system/set :hash hash
                  :keys (list 'path 'secret 'root)
                  :value path/root
                  :docstr "Root for .secret.d")
  (spy:system/set :hash hash
                  :keys (list 'path 'secret 'emacs)
                  :value path/doom.abs
                  :docstr "Root for Per-Computer Set-Up of Emacs")
  (spy:system/set :hash hash
                  :keys (list 'id)
                  :value id
                  :docstr "Home desktop PC built in 2017.")

  ;; Have to set path per-system since work comps have restrictions on where
  ;; things can be, and home comps tend to have a random number of hard drives
  ;; just wherever.
  (spy:system/set :hash hash
                  :keys (list 'path 'secret id)
                  :value  (spy:system/path path/doom.abs id)
                  :docstr "Home desktop PC built in 2017."))


;;---
;; home/2017/desk::5730ce-91e149
;;   via Windows 10
;;---
(let* ((hash "5730ce-91e149")
       (id   (concat "home/2017/desk::" hash))
       (path/root "d:/home/spydez/.secret.d/")
       (path/doom.rel "emacs/doom")
       (path/doom.abs (spy:path/to-dir path/root path/doom.rel)))

  (spy:system/set :hash hash
                  :keys (list 'path 'secret 'root)
                  :value path/root
                  :docstr "Root for .secret.d")
  (spy:system/set :hash hash
                  :keys (list 'path 'secret 'emacs)
                  :value path/doom.abs
                  :docstr "Root for Per-Computer Set-Up of Emacs")
  (spy:system/set :hash hash
                  :keys (list 'id)
                  :value id
                  :docstr "Home desktop PC built in 2017.")

  ;; Have to set path per-system since work comps have restrictions on where
  ;; things can be, and home comps tend to have a random number of hard drives
  ;; just wherever.
  (spy:system/set :hash hash
                  :keys (list 'path 'secret 'system)
                  :value  (spy:system/path path/doom.abs id)
                  :docstr "Home desktop PC built in 2017."))


;; Generate a new system's UID using this:
;; - "home", "work", other domain
;; - year, or YYYY-MM-DD
;; - "desk", "lap", "tablet", other type
;;
;; (spy:system/unique-id "home" "2017" "desk")
;;
;; Then add it to jerky by copy/modifying a whole `let*' block above.
