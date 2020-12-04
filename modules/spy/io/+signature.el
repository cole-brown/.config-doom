;;; spy/io/signature.el -*- lexical-binding: t; -*-

;;-----------------------------Illegible Squiggle-------------------------------
;;--                       Insert John Hancock Here.                          --
;;------------------------------------------------------------------------------


;; TODO: Should this be its own thing like jerky?


;;------------------------------------------------------------------------------
;; Imports
;;------------------------------------------------------------------------------
(require 'subr-x)

(spy/require :spy 'jerky)
(spy/require :spy 'buffer 'point)
(spy/require :spy 'datetime 'format)

(require 'mis/code/comment)


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

(defun spy/io/signatures/create (sigil name)
  "Create signatures and save them into jerky under 'signature' root key.
"
  ;;--------------------------
  ;; Identities To Use When Signing
  ;;--------------------------

  (jerky/set 'signature 'id 'sigil
             :namespace :default
             :value sigil
             :docstr "Short 1-char signature for notes, comments...")

  ;; Could have multiple, but would make searching harder...
  ;; (jerky/set 'signature 'id 'default
  ;;            :namespace :home
  ;;            :value benchwarmer
  ;;            :docstr "Short 1-char signature for notes, comments...")

  (jerky/set 'signature 'id 'name
             :namespace :default
             :value name
             :docstr "Name for use in signatures.")

  ;;--------------------------
  ;; Full Signatures
  ;;--------------------------

  (jerky/set 'signature 'sigil 'note
             :namespace :default
             :value (concat sigil ":")
             :docstr "Short signature for prefixing note lines.")

  (jerky/set 'signature 'name 'sign
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

  (jerky/set 'signature 'sigil 'todo
             :namespace :default
             :value (concat sigil "-TODO-" sigil)
             :docstr "Long signature for postfixing note lines or as last line of note block."))



;;------------------------------------------------------------------------------
;; Helpers.
;;------------------------------------------------------------------------------

(defun _//signature/get (signature &optional namespace)
  "Figure out what SIGNATURE is and return it or nil.
NAMESPACE is used with SIGNATURE to try to get something from jerky.
"
  (if-let ((jerky (jerky/get signature :namespace namespace)))
      ;; We found something in jerky - use it.
      jerky
    ;; Else, no other place to look right now.
    nil))


(defun _//signature/insert (signature &optional namespace)
  "Figure out what SIGNATURE is and insert it at point.
NAMESPACE is used with SIGNATURE to get a sig from `_//signature/get'.
"
  (if-let ((sig (_//signature/get signature namespace)))
      ;; We found something in jerky - use it.
      (insert sig)

    ;; Nothing found. Send a message for the minibuffer.
    (if (not (null namespace))
        (message "No signature found for '%s' in '%S'."
                 signature namespace)

      (message "No signature found for '%s'."
               signature))))


;;------------------------------------------------------------------------------
;; Signatures - TODOs
;;------------------------------------------------------------------------------

(defun smd/signature.todo/insert ()
  "DWIM function for TODO signatures/comments.

Takes '(spy signature todo) and uses as-is, or adds comment
characters to it, as appropriate for where point is and what's around it.
"
  (interactive)
  (cond
   ;; Just sig str if in string.
   ((spy/point/inside-string-p)
    spy/signature/todo)

   ;; Just sig str if in comment.
   ((spy/point/inside-comment-p)
    spy/signature/todo)

   ;; Empty line? insert indented comment.
   ((spy/point/current-line-empty-p)
    (comment-indent)
    (spy/signature/todo/comment))

   ;; Default... IDK. Just sig str?
   (t
    spy/signature/todo)))


(defun spy/signature.todo (&optional timestamp comment namespace)
  "Returns a 'TODO'-related signature.

Optionally adds a TIMESTAMP (if non-nil) to the signature.

Optionally returns the signature commented out if COMMENT is non-nil.
"
  ;; First, we need the signature...
  (let ((sig (_//signature/get '(signature sigil todo) namespace)))
    ;; Add timestamp if desired.
    ;; Add it first - commenting could append to end.
    (when timestamp
      (setq sig (concat sig
                        " "
                        (spy/datetime/string.get 'org-inactive))))

    (when comment
      ;; Append ':' and wrap sig with comment characters.
      (setq sig (mis/comment/wrap (concat sig ":"))))

    ;; return it
    sig))
;; (spy/signature.todo)
;; (spy/signature.todo t)
;; (spy/signature.todo t t)


;;------------------------------------------------------------------------------
;; Signatures - Search...
;;------------------------------------------------------------------------------


(defvar _s//signature/search/history nil
  "Just a bucket to hold history for sig commands to keep
  segregated from general history.")


(defun smd/signature/search (signature)
  "Choose a signature and then search for it via `isearch-forward'."
  (interactive (list
    ;; Arg 0: signature type
    (completing-read
     ;; Prompt:
     "Search for Signature: "

     ;; Shown list.
     (spy/signature/options)

     ;; No predicate to limit above (shown list).
     nil

     ;; Set to 'confirm if want confirmation of non-list entry.
     ;; But right now I think deny all not on list via `true'.
     t

     ;; Deprecated.
     nil

     ;; Get our own separate history for this command.
     '_s//signature/search/history

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
(spy/provide :spy 'io 'signature)
