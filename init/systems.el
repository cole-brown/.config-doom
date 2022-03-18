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


;;------------------------------
;; home/2017/desk
;;   Host OS:  Windows 10
;;   Guests:   Misc Linux via WSL2
;;------------------------------

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


;;------------------------------
;; work/2021/lap
;;   Host OS:  Ubuntu 20.04 LTS
;;   Guests:   Windows 10
;;------------------------------

;;---
;; work/2021/lap::e29fbd-0d21c7
;;   via Ubuntu 20.04
;;---
(spy:system/define :hash "e29fbd-0d21c7"
                   :domain "work"
                   :date "2021"
                   :type "lap"
                   :description "Dell XPS 13 laptop"
                   :path/secret/root "~/.config/secret")

;;---
;; work/2021/vm::d3dbd4-fa7934
;;   via Ubuntu 20.04
;;---
(spy:system/define :hash "d3dbd4-fa7934"
                   :domain "work"
                   :date "2021"
                   :type "vm"
                   :description "Windows 10 VM"
                   :path/secret/root (path:canonicalize user-emacs-directory ".." ".secret.d"))


;;------------------------------
;; NOTE: New Systems!
;;------------------------------

;; Open Emacs. Check "mis:init:messages" or "*Messages*" buffer. You should see something like:
;;   > [WARNING `spy:secret:init`]
;;   >     [SKIP]: Cannot load secret 'init'; invalid system secrets.
;;   >     Validation Result:
;;   >      ...
;;   >      ...
;;   >      :hash "012345-abcdef"
;;   >      ...
;;   > [/WARNING `spy:secret:init`]
;;
;; Add the new system using strings:
;;   - `:domain' - "home", "work", other domain
;;   - `:date'   - year, or YYYY-MM-DD
;;   - `:type'   - "desk", "lap", "vm", "tablet", etc
;;
;; For example:
;;    (spy:system/define :hash "012345-abcdef"
;;                       :domain "work"
;;                       :date "2025"
;;                       :type "vr"
;;                       :description "Linux VR Computer"
;;                       :path/secret/root (path:canonicalize user-emacs-directory ".." "secret"))
;;
;; Then add the system by creating another `spy:system/define' call with the
;; string ID created.



;;----------------------------------------------------------
;; The End.
;;----------------------------------------------------------
(imp:provide :dot-emacs 'init 'systems)
