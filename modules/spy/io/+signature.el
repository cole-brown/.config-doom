;;; spy/io/signature.el -*- lexical-binding: t; -*-

;;-----------------------------Illegible Squiggle-------------------------------
;;--                       Insert John Hancock Here.                          --
;;------------------------------------------------------------------------------


;; TODO: Should this be its own thing like jerky?


;;------------------------------------------------------------------------------
;; Imports
;;------------------------------------------------------------------------------
(require 'subr-x)

(spy:require :spy 'jerky)
(spy:require :spy 'buffer 'point)
(imp:require :modules 'spy 'datetime 'format)

(require 'mis0)


;;------------------------------------------------------------------------------
;; Helpers.
;;------------------------------------------------------------------------------

(defun spy:signature/get (&rest args)
  "Get a signature.

ARGS should be sig's type, optionally followed by `:namespace' and a namespace
symbol if desired.
"
  (apply #'jerky/get 'signature args))
;; (spy:signature/get 'id 'sigil :namespace :work)
;; (jerky/get '(signature id sigil) :work)


(defun spy:signature/set (&rest args)
  "Set a signature

ARGS should be sig's type, followed by keyword pairs:
  - required: :value <value>
  - optional: :namespace <namespace>
  - optional: :docstr <docstr>
"
 (apply #'jerky/set 'signature args))
;; (spy:signature/set 'id 'hail :value "hi")
;; (spy:signature/get 'id 'hail)
;; (spy:signature/get 'id 'email :namespace :home)

(defun spy:signature/exists (&rest args)
  "Returns non-nil if one or more signatures defined by ARGS exist.

ARGS should be sig's type, followed by keyword pairs:
  - optional: :namespace <namespace>
"
  (not (null (apply #'jerky/has 'signature args))))


(defun sss:signature/insert (signature &optional namespace)
  "Figure out what SIGNATURE is and insert it at point.
NAMESPACE is used with SIGNATURE to get a sig from `spy:signature/get'.
"
  (if-let ((sig (spy:signature/get signature namespace)))
      ;; We found something in jerky - use it.
      (insert sig)

    ;; Nothing found. Send a message for the minibuffer.
    (if (not (null namespace))
        (message "No signature found for '%s' in '%S'."
                 signature namespace)

      (message "No signature found for '%s'."
               signature))))


;;------------------------------------------------------------------------------
;; Set-Up Signatures in Jerky
;;------------------------------------------------------------------------------

;; https://unicode-table.com/en/blocks/miscellaneous-symbols/
;; Single unicode options:
;;   ʬ ʭ ҈ ҉ † ‡ ‣ ↀ ↂ ∀ ∎ ∮ ≈ ≜ ≡ ≣ ≷ ⊫ ⋈
;;   § ▀ ▄
;;  Can't see now, but maybe in future? Watch the line height though...
;;   ⛤ ⇶ ⌦ ⏩ ⏻ ␑ ␦ ⑄ ⚶
;;
;; Too tall, but nice: ⛧ ⚶
;; Right height, but eh... ok: § ▀
;; ▌
;; ┣━
;; ╠═╣
;; With Colons?
;; ╠:
;; ♫:
;; ♯:
;; §:
;; ▀:
(defun spy:signature/create (sigil name)
  "Create signatures and save them into jerky under 'signature' root key.
"
  ;;--------------------------
  ;; Identities To Use When Signing
  ;;--------------------------

  (spy:signature/set 'id 'sigil
                     :namespace :default
                     :value sigil
                     :docstr "Short 1-char signature for notes, comments...")

  ;; Could have multiple, but would make searching harder...
  ;; (spy:signature/set 'signature 'id 'default
  ;;            :namespace :home
  ;;            :value benchwarmer
  ;;            :docstr "Short 1-char signature for notes, comments...")

  (spy:signature/set 'id 'name
                     :namespace :default
                     :value name
                     :docstr "Name for use in signatures.")

  ;;--------------------------
  ;; Full Signatures
  ;;--------------------------

  (spy:signature/set 'sigil 'note
                     :namespace :default
                     :value (concat sigil ":")
                     :docstr "Short signature for prefixing note lines.")

  (spy:signature/set 'name 'sign
                     :namespace :default
                     :value (concat "-" name)
                     :docstr "Name for use in signatures.")

  ;;--------------------------
  ;; Email Addresses?
  ;;--------------------------

  ;; TODO: get emails...
  ;; For emails, see: `jerky' paths "signature.email.<blank>"

  ;;--------------------------
  ;; TODOs, Fancy Bookmarks, and Such
  ;;--------------------------

  (spy:signature/set 'sigil 'todo
                     :namespace :default
                     :value (concat sigil "-TODO-" sigil)
                     :docstr "Long signature for postfixing note lines or as last line of note block."))
;; (spy:signature/create)

;;------------------------------------------------------------------------------
;; Signatures - General
;;------------------------------------------------------------------------------

(defun spy:signature (&rest args)
  "Gets signature based on ARGS list.

Signature type is expected before keyword args, if any keywords are used.
For example:
(spy:signature 'id 'sigil :namespace :work)

Keywords are:
  - :types - following args are:
    - 'sigil or 'name
    - 'id, 'sigil, 'name, 'note, 'todo...

  - OPTIONAL:
    - :namespace - namespace to use for `jerky/get'
    - :timestamp - if non-nil, append `org-inactive' from `spy:datetime'.
    - :comment   - if non-nil, wrap signature in comment characters if deemed
                   appropriate to major mode and point's position (aka ask
                   `mis0/comment/wrap').
"
  ;; Break `args' up into type list and keyword args, then check for any of the
  ;; optional keywords.
  (-let* (((type keys) (spy:lisp/func.args args :namespace :timestamp :comment))
          ((&plist :namespace :timestamp :comment) keys))

    ;; First, we need the signature...
    (let ((sig (spy:signature/get type :namespace namespace)))
      ;; Add timestamp if desired.
      ;; Add it first - commenting could append to end.
      (when timestamp
        (setq sig (concat sig
                          " "
                          (spy:datetime/string.get 'org-inactive))))

      (when comment
        ;; Append ':' and wrap sig with comment characters if necessary.
        (setq sig (mis0/comment/wrap (concat sig ":"))))

      ;; Return it.
      sig)))
;; (spy:signature 'id 'sigil)
;; (spy:signature 'sigil 'todo :namespace :work)
;; (spy:signature 'sigil 'todo :timestamp t :comment t)


(defun spy:signature/insert (&rest args)
  "Uses ARGS to get a signature from `spy:signature', then inserts it into the
current buffer at the current point.

Sets evil to insert mode.
"
   (insert (apply #'spy:signature args))
   (evil-insert-state))
;; (spy:signature/insert 'sigil 'todo)


;;------------------------------------------------------------------------------
;; Signatures - Search...
;;------------------------------------------------------------------------------


(defvar sss:signature/search/history nil
  "Just a bucket to hold history for sig commands to keep
  segregated from general history.")


;; TODO: spy:signature/options function?

(defun spy:cmd:signature/search (signature)
  "Choose a signature and then search for it via `isearch-forward'."
  (interactive (list
    ;; Arg 0: signature type
    (completing-read
     ;; Prompt:
     "Search for Signature: "

     ;; Shown list.
     (spy:signature/options)

     ;; No predicate to limit above (shown list).
     nil

     ;; Set to 'confirm if want confirmation of non-list entry.
     ;; But right now I think deny all not on list via `true'.
     t

     ;; Deprecated.
     nil

     ;; Get our own separate history for this command.
     'sss:signature/search/history

     ;; default user input value
     nil)))

  (if (null signature)
      (message "Cannot search for nothing.")

    ;; Thank you, StackOverflow.
    ;; https://emacs.stackexchange.com/questions/2754/preset-search-isearch-string-from-command-line
    (isearch-forward nil 1)
    (isearch-yank-string (string-trim signature))))


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(spy:provide :spy 'io 'signature)
