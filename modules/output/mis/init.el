;;; mis/init.el -*- lexical-binding: t; -*-


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
;; Internal Mis:
;;   - int<mis>:
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


;;------------------------------------------------------------------------------
;; Load mis files...
;;------------------------------------------------------------------------------

;;------------------
;; Internal Functions
;;------------------

;; Load set-up code and then run our internal set-up for nub, mis vars, etc.
(load! "internal/setup")
(int<mis>:init)

;; Always load load. Cannot load anything else without it.
(load! "internal/load")

;; Load debug if not undesired...
(unless (featurep! -debug)
  (load! "internal/+debug"))

(load! "internal/const")
(load! "internal/valid")
(load! "internal/mlist")


;;------------------
;; Text & Styling
;;------------------
(load! "text/string")
(load! "style/style")


;;------------------
;; Code-Related Things
;;------------------
(load! "code/comment")


;;------------------
;; Messages
;;------------------
(load! "message/init")


;; TODO: Change misZero's provide to be `mis0' or something so this one can be `mis' via `imp:provide:with-emacs'.
;; TODO: Provide once we're sure that mis is all resolved and once someone wants misNonZero
;; TODO: Would probably have to also remove misNotNonZero at this time too.
;; (imp:provide:with-emacs :mis)
