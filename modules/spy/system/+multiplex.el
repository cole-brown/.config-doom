;;; spy/system/+multiplex.el -*- lexical-binding: t; -*-

;;------------------Init & Config Help for Multiple Systems.--------------------
;;--                     What computer is this anyways?                       --
;;--------------------------(probably the wrong one)----------------------------

(spy/require :spy 'jerky)
(spy/require :spy 'path)


;;------------------------------------------------------------------------------
;; System UID
;;------------------------------------------------------------------------------

(defun spy/system/hash ()
  "Generate a system hash from `system-name' and `system-type'.
"
  (spy/hash/pretty (list (system-name) system-type)))
;; (spy/system/hash)


(defun spy/system/unique-id (domain date name)
  "Generate a system UID from the specified DOMAIN, DATE and NAME, with
`system-name' and `system-type' as additional information.
"
  (spy/hash (list domain date name)
            (list (system-name) system-type)))
;; (spy/system/unique-id "jeff" "2020" "compy")


(defun spy/system/path (root unique-id)
  "Generate a path to where the secrets file should be, based
on the UNIQUE-ID of the system and the ROOT path.
"
  (spy/path/to-dir root
            (replace-regexp-in-string "::" "_"
                                      (replace-regexp-in-string "/" "-"
                                                                unique-id))))


;;------------------------------------------------------------------------------
;; /This/ System Right Now.
;;------------------------------------------------------------------------------
;; Find the Answer to the Ultimate Question:
;;----------
;; "Where the hell am I?", obviously.
;; Or maybe "Who the hell am I?"...

(jerky/set :system
           'hash
           :value (spy/system/hash)
           :docstr "Pretty hash of /current/ system-name and system-type.")


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
       (id   (concat "home/2017/desk::" hash)))

  (jerky/set :system
             'secret
             'identities
             hash
             :value id
             :docstr "Home desktop PC built in 2017.")

  ;; Have to set path per-system since work comps have restrictions on where
  ;; things can be, and home comps tend to have a random number of hard drives
  ;; just wherever.
  (jerky/set :system
             :path
             :secret
             id
             :value  (spy/system/path "~/.config/spydez/secret/emacs/doom" id)
             :docstr "Home desktop PC built in 2017."))

;; Generate a new system's UID using this:
;; - "home", "work", other domain
;; - year, or YYYY-MM-DD
;; - "desk", "lap", "tablet", other type
;;
;; (spy/system/unique-id '("home" "2017" "desk"))
;;
;; Then add it to jerky by copy/modifying a whole `let*' block above.
