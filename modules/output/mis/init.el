;;; mis/init/init.el -*- lexical-binding: t; -*-


;;------------------------------------------------------------------------------
;; Load local files...
;;------------------------------------------------------------------------------

;; Load set-up code and then run our internal set-up for nub, mis vars, etc.
(load! "setup")
(int<mis>:init)

;; Always load load. Cannot load anything else without it.
(load! "load")

;; Load debug if not undesired...
(unless (featurep! -debug)
  (load! "+debug"))


;;------------------------------------------------------------------------------
;; Function Naming
;;------------------------------------------------------------------------------

;; Emacs doesn't /really/ like some chars, even though they're allowed.
;; For example, '.' in the function name is escaped technically.
;;
;; Ripgrep doesn't like other chars. '-m//' didn't work out well for a private
;; functions prefix as "-" screwed up rg.
;;
;; However... I do still want to separate the public API from the
;; private/internal functions for a cleaner 'C-h f' list.


;;------------------
;; mis Public
;; ------
;; Make It So API:
;;   - mis:
;;
;;------------------

;;------------------
;; mis Private
;; -------
;; Make Message Mmmm... Private Interface:
;;   - mmm:
;;
;; -------
;; File/Folder Internal
;; -------
;; Make Message Mmyes.
;;   - mmm://
;;
;;------------------

;;------------------------------------------------------------------------------
;; Set imp Root
;;------------------------------------------------------------------------------

(imp:path:root :mis
               (imp:path:paths->path doom-private-dir
                                     "modules"
                                     "output"
                                     "mis")
               "init.el")

;; TODO: imp:require / imp:provide
;;   - Replace mmm:require/mmm:provide.
;;   - Make sure each file has the correct requirements up top.


;;------------------------------------------------------------------------------
;; Load more of mis now that we can load...
;;------------------------------------------------------------------------------

;;------------------
;; Internal Functions
;;------------------
(mmm:require 'internal 'const)
(mmm:require 'internal 'valid)
(mmm:require 'internal 'mlist)

;;------------------
;; Text & Styling
;;------------------
(mmm:require 'text 'string)
(mmm:require 'style 'style)

;;------------------
;; Code-Related Things
;;------------------
(mmm:require 'code 'comment)

;;------------------
;; Messages
;;------------------
;; TODO: (mmm:require 'message)

;; TODO: provide once we're sure that mis0 is all resolved and once someone wants misNonZero
;; (imp:provide:with-emacs :mis)
