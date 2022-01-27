;;; init/systems.el -*- lexical-binding: t; -*-

;;------------------Init & Config Help for Multiple Systems.--------------------
;;--                     What computer is this anyways?                       --
;;--------------------------(probably the wrong one)----------------------------

(imp:require :modules 'spy 'system 'multiplex)


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
(spy:system/define :hash "ab48e5-886ff0"
                   :domain "home"
                   :date "2017"
                   :type "desk"
                   :description "(Windows/WSL) Home desktop PC built in 2017."
                   :path/secret/root "~/.config/spydez/secret")


;;---
;; home/2017/desk::02d29a-8bdef1
;;   via Windows 10
;;   (formerly known as: home/2017/desk::5730ce-91e149)
;;---
(spy:system/define :hash "02d29a-8bdef1" ;; Before I renamed it: "5730ce-91e149"
                   :domain "home"
                   :date "2017"
                   :type "desk"
                   :description "(Windows) Home desktop PC built in 2017."
                   :path/secret/root "~/.secret.d")


;;--------------------
;; work/2021/lap
;;   Host OS:  Ubuntu 20.04 LTS
;;   Guests:   Windows 10
;;--------------------


;;---
;; work/2021/lap::e29fbd-0d21c7
;;   via Ubuntu 20.04
;;   (formerly known as: home/2017/desk::5730ce-91e149)
;;---
(spy:system/define :hash "e29fbd-0d21c7"
                   :domain "work"
                   :date "2021"
                   :type "lap"
                   :description "Dell XPS 13 laptop"
                   :path/secret/root "~/.config/secret")



;; Generate a new system's UID using this:
;; - "home", "work", other domain
;; - year, or YYYY-MM-DD
;; - "desk", "lap", "tablet", other type
;;
;; (spy:system/unique-id "home" "2017" "desk")
;;
;; Then add the system by creating another `spy:system/define' call with the
;; string ID created.



;;----------------------------------------------------------
;; Domain: Work
;;----------------------------------------------------------


(imp:provide :dot-emacs 'init 'systems)
