;;; config/spy/keybinds.el -*- lexical-binding: t; -*-


(require 'hydra)


(imp:provide :modules 'spy 'io 'signature)
(spy:config 'spy 'art)
(spy:config 'spy 'join)


;;------------------------------------------------------------------------------
;; Centering Helpers
;;------------------------------------------------------------------------------
;; TODO: move to mis.

(defun spy:cmd:center/width (full-width)
  "Sets `fill-column' to FULL-WIDTH then invokes `center-region', or
`center-line' if there is no active region."
  (interactive "nColumn Width: ")
  (let ((fill-column full-width))
    (if (doom-region-active-p)
        (center-region (doom-region-beginning)
                       (doom-region-end))
      (center-line))))


(defun spy:cmd:center/to (center-column)
  "Sets `fill-column' to CENTER-COLUMN * 2 then invokes `center-region', or
`center-line' if there is no active region."
  (interactive "nCenter at Column: ")
  (let ((fill-column (* center-column 2)))
    (if (doom-region-active-p)
        (center-region (doom-region-beginning)
                       (doom-region-end))
      (center-line))))


;;------------------------------------------------------------------------------
;; Align Regex Helpers
;;------------------------------------------------------------------------------
;; `Align-Regex' helper function idea came from this nice chap:
;; http://pragmaticemacs.com/emacs/aligning-text/

(defun spy:cmd:align-before (start end text)
  "Align columns by whitespace before TEXT. E.g. with text \"+=\" and region:
  Jeff.Jet(jeff.it).onClick += OnJeffClick;
  Jeff.Jet(jefferson.it).onClick += OnJeffersonClick;
becomes
  Jeff.Jet(jeff.it).onClick      += OnJeffClick;
  Jeff.Jet(jefferson.it).onClick += OnJeffersonClick;

Align currently selected region (if interactive), or region
indicated by START and END.
"
  (interactive "r\nsAlign Before: ")

  (let ((regexp (rx-to-string `(sequence
                                ;; target group: whitespace before input text
                                (group (zero-or-more whitespace))
                                ,text))))
    ;; (message "%S %S %S %S" start end text regexp)
    (align-regexp start end
                  regexp
                  ;; target group 1, min spacing 1, no repeat.
                  1 1 nil)))


(defun spy:cmd:align-after (start end text)
  "Align columns by whitespace after TEXT. E.g. with text \"+=\" and region:
  Jeff.Jet(jeff.it).onClick += OnJeffClick;
  Jeff.Jet(jefferson.it).onClick += OnJeffersonClick;
becomes
  Jeff.Jet(jeff.it).onClick +=      OnJeffClick;
  Jeff.Jet(jefferson.it).onClick += OnJeffersonClick;

Align currently selected region (if interactive), or region
indicated by START and END.
"
  (interactive "r\nsAlign After: ")

  (let ((regexp (rx-to-string `(sequence
                                ,text
                                ;; target group: whitespace after input text
                                (group (zero-or-more whitespace))))))
    ;; (message "%S %S %S %S" start end text regexp)
    (align-regexp start end
                  regexp
                  ;; target group 1, min spacing 1, no repeat.
                  1 1 nil)))


;;------------------------------------------------------------------------------
;; Fill/Unfill Commands, Functions, Hydras
;;------------------------------------------------------------------------------

;; from: nhoffman http://nhoffman.github.io/.emacs.d/#org40b27e4
;;   which is from: http://defindit.com/readme_files/emacs_hints_tricks.html
;;     which is from: Stefan Monnier <foo at acm.org>
;;       which is probably from the turtles that go all the way down
;;
;; This is actually the inverse of fill-paragraph. Takes a multi-line paragraph
;; and makes it into a single line of text.
(defun spy:cmd:fill/paragraph/unfill ()
  (interactive)
  (let ((fill-column (point-max)))
    (fill-paragraph nil)))


(defun sss:fill/paragraph/fn-for-mode ()
  "Mode-aware fill-paragraph so I only have to bind one thing in
the fill hydra. Separated the 'get func' out here so I can see if
in a mode with a special fill for hydra hinting."
  (cond
   ((derived-mode-p 'csharp-mode)
    #'c-fill-paragraph)

   ;; c-mode and all derivatives
   ((and (functionp 'c-buffer-is-cc-mode)
         (c-buffer-is-cc-mode))
    #'c-fill-paragraph)

   ;; elisp, other lispses
   ((or (derived-mode-p 'emacs-lisp-mode)
        (derived-mode-p 'lisp-mode))
    #'lisp-fill-paragraph)
   ;; Might just use `fill-paragraph'?
   ;; Seems to be what "M-q" is using right now?

   ;; python-mode
   ((derived-mode-p 'python-mode) #'python-fill-paragraph)

   ;; org-mode
   ((derived-mode-p 'org-mode) #'org-fill-paragraph)

   ;; default to the usual fill-paragraph
   (t #'fill-paragraph)))


(defun spy:cmd:fill/paragraph/per-mode (&optional justify)
  "Mode-aware fill-paragraph so I only have to bind one thing in
the fill prefix-map."
  (interactive)
  (funcall (sss:fill/paragraph/fn-for-mode) justify))


(defun spy:cmd:fill/region/single-line (&optional justify)
  "Grab start/end of current line and call `fill-region'. i.e.
\"'Fill Region' on just this line, please.\""
  (interactive)

  (let ((from (save-excursion (beginning-of-line) (point)))
        (to   (save-excursion (end-of-line)       (point))))
    (fill-region from to justify)))


;;------------------------------------------------------------------------------
;; Search
;;------------------------------------------------------------------------------

(defun spy:cmd:search/project/dir (directory &optional arg)
  "Conduct a text search in the supplied directory.
If prefix ARG is set, include ignored/hidden files."
  (interactive (list (read-directory-name "Start Search: ")
                     current-prefix-arg))
  (let* ((projectile-project-root nil)
         (disabled-command-function nil))
    (funcall-interactively #'+ivy/project-search arg nil directory)))


(defun spy:cmd:search/project/here (&optional arg)
  "Conduct a text search in the current buffer's `default-directory'.
If prefix ARG is set, include ignored/hidden files."
  (interactive "P")
  (funcall-interactively #'spy:cmd:search/project/dir
                         default-directory
                         arg))


;;------------------------------------------------------------------------------
;; Evil Spy Stuff.
;;------------------------------------------------------------------------------
;; See Doom's keybindings for how to do complicated things:
;; https://github.com/hlissner/doom-emacs/blob/develop/modules/config/default/+evil-bindings.el
(map! :leader       ; Be under the Doom SPC leader.

      ;;------------------------------
      ;; Start of 'spy' prefix "-"
      ;;------------------------------
      (:prefix ("-" . "spy") ; Not my first choice but no one uses dash,
                                        ; and it's easy on Dvorak.

       ;;------------------------------
       ;; Search
       ;;------------------------------
       (:prefix ("/" . "Search")
        :desc "Search from here..."       "/" #'spy:cmd:search/project/here
        :desc "Search from directory..."  "s" #'spy:cmd:search/project/dir)

       ;;------------------------------
       ;; Alignment
       ;;------------------------------
       (:prefix ("a" . "Alignment")

        :desc "spy:   Align Before"    "a" #'spy:cmd:align-before
        :desc "spy:   Align After"     "o" #'spy:cmd:align-after
        :desc "emacs: Align Regex"     ";" #'align-regexp
        :desc "emacs: C-u Align Regex" "q" (lambda () (interactive)
                                             (setq current-prefix-arg '(4))
                                             (call-interactively #'align-regexp))
        :desc "emacs: Align"           "'" #'align
        :desc "emacs: Align Current"   "," #'align-current

        ;; Centering is... kind of alignment?
        ;; Pull out of alignment if too confusing for my fingers.
        (:prefix ("c" . "Centering")
         :desc "Center at 40 (80 width)" "c" (cmd! (spy:cmd:center/width 80))
         :desc "Center to Column..."     "t" #'spy:cmd:center/to
         :desc "Center at Width..."      "w" #'spy:cmd:center/width))

       ;;------------------------------
       ;; Fill
       ;;------------------------------
       (:prefix ("f" . "Fill")
        ;; Regions
        :desc "Region"              "r" #'fill-region
        :desc "Region as Paragraph" "a" #'fill-region-as-paragraph
        :desc "Line"                "l" #'spy:cmd:fill/region/single-line

        ;; Paragraphs
        :desc (if (eq (sss:fill/paragraph/fn-for-mode) #'fill-paragraph)
                  "Default Fill ¶"
                "Mode-Aware Fill ¶")
        "p" #'spy:cmd:fill/paragraph/per-mode
        :desc "Individual ¶"  "i" #'fill-individual-paragraphs
        :desc "Non-Uniform ¶" "n" #'fill-nonuniform-paragraphs
        :desc "Default ¶"     "d" #'fill-paragraph

        ;; Unfill
        :desc "Unfill ¶"      "u" #'spy:cmd:fill/paragraph/unfill)


       ;;------------------------------
       ;; Join
       ;;------------------------------
       :desc "Join Lines"    "j" #'spy:join/lines


       ;;------------------------------
       ;; Transpose
       ;;------------------------------
       (:prefix ("t" . "Transpose")
        ;; Emacs
        :desc "Characters"                  "c" #'transpose-chars
        :desc "Words"                       "w" #'transpose-words
        :desc "Lines"                       "l" #'transpose-lines
        :desc "Sentences"                   "s" #'transpose-sentences
        :desc "Paragraphs"                  "p" #'transpose-paragraphs
        :desc "S-Expressions"               "x" #'transpose-sexps

        ;; Org-Mode
        :desc "Org-Mode Words"              "o" #'org-transpose-words
        :desc "Org-Mode Elements"           "e" #'org-transpose-element
        :desc "Org-Mode Table"              "t" #'org-table-transpose-table-at-point)


       ;;------------------------------
       ;; Box Drawning
       ;;------------------------------
       ;; Hydra
       :desc "Unicode Box"                  "b" #'spy:art.box/draw


       ;;------------------------------
       ;; Signatures
       ;;------------------------------
       (:prefix ("s" . "Signatures")
        ;; Insert Signatures:

        ;; TODO namespace, timestamp, comment:
        :desc (concat "TODO: " (spy:signature 'sigil 'todo))
        "t"   (cmd! (spy:signature/insert 'sigil 'todo :timestamp t :comment t))

        ;; Sigil for Note Prefix.
        :desc (concat "Note: " (spy:signature 'sigil 'note))
        "n" (cmd! (spy:signature/insert 'sigil 'note))


        ;; Signature for the end of an email or something.
        :desc (concat "Sign: " (spy:signature 'name 'sign))
        "s" (cmd! (spy:signature/insert 'name 'sign))

        ;; IDs
        (:prefix ("i" . "ID")
         ;; Just the Sigil.
         :desc (concat "Sigil: " (spy:signature 'id 'sigil))
         "s" (cmd! (spy:signature/insert 'id 'sigil))

         ;; Just the Name.
         :desc (concat "Name: " (spy:signature 'id 'name))
         "n" (cmd! (spy:signature/insert 'id 'name)))

        ;; Emails
        ;;   - Only show if we have any.
        (:when (spy:signature/exists 'id 'email)
         (:prefix ("e" . "Emails")
          ;; work namespace.
          (:when (spy:signature/exists 'id 'email :namespace :work)
           :desc (concat "work: " (spy:signature 'id 'email :namespace :work))
           "w" (cmd! (spy:signature/insert 'id 'sigil :namespace :work)))

          ;; home namespace.
          (:when (spy:signature/exists 'id 'email :namespace :home)
           :desc (concat "home: " (spy:signature 'id 'email :namespace :home))
           "h" (cmd! (spy:signature/insert 'id 'sigil :namespace :home)))

          ;; default namespace.
          (:when (spy:signature/exists 'id 'email :namespace :default)
           :desc (concat "default: " (spy:signature 'id 'email :namespace :default))
           "c" (cmd! (spy:signature/insert 'id 'sigil :namespace :default)))


          ;; TODO: Search for sigil, todo...

          ;; /Emails
          ))

        ;; /Signatures
        )

       ;;------------------------------
       ;; Org-Journal
       ;;------------------------------
       ;; They are in org-journal's entry in leader. See config/org-mode.el


       ;;------------------------------
       ;; File/Dir Names
       ;;------------------------------
       :desc "Copy Buffer's File Name"    "k" #'spy:cmd:file-or-dir-name/clipboard
       :desc "Copy Buffer's Dir Name"    "K" (cmd!! #'spy:cmd:file-or-dir-name/clipboard '(4)) ;; Call with simulated C-u prefix arg.
       ))
