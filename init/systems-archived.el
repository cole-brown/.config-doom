;;; init/systems-archived.el -*- lexical-binding: t; -*-

;;----------------------Retirement Home for Old Systems.------------------------
;;--                          What's that, Sonny?                             --
;;---------------------------(Yell - they're old.)------------------------------


;;------------------------------------------------------------------------------
;; Archived: 2021-06-30
;; Domain:   Work
;; ID:       work/2013/desk::4c4925-0b54bd
;; OS:       Windows 7
;;------------------------------------------------------------------------------
(let* ((hash "4c4925-0b54bd")
       (id   (concat "work/2013/desk::" hash))
       (path/root "c:/home/cole/.secret.d/")
       (path/doom.rel "emacs/doom")
       (path/doom.abs (path:dir-path path/root path/doom.rel)))

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
                  :docstr "2013 work desktop PC - Windows 7")

  ;; Have to set path per-system since work comps have restrictions on where
  ;; things can be, and home comps tend to have a random number of hard drives
  ;; just wherever.
  (spy:system/set :hash hash
                  :keys (list 'path 'secret id)
                  :value  (spy:system/path path/doom.abs id)
                  :docstr "2013 work desktop PC - Windows 7"))
