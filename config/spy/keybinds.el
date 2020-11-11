;;; config/spy/keybinds.el -*- lexical-binding: t; -*-

;;------------------------------------------------------------------------------
;; Align Regex Helpers
;;------------------------------------------------------------------------------
;; `Align-Regex' helper function idea came from this nice chap:
;; http://pragmaticemacs.com/emacs/aligning-text/

(defun spydez/align-before (start end text)
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


(defun spydez/align-after (start end text)
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
(defun spy/fill/paragraph/unfill ()
  (interactive)
  (let ((fill-column (point-max)))
    (fill-paragraph nil)))


(defun spy//fill/paragraph/fn-for-mode ()
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


(defun spy/fill/paragraph/per-mode (&optional justify)
  "Mode-aware fill-paragraph so I only have to bind one thing in
the fill prefix-map."
  (interactive)
  (funcall (spy//fill/paragraph/fn-for-mode) justify))


(defun spy/fill/region/single-line (&optional justify)
  "Grab start/end of current line and call `fill-region'. i.e.
\"'Fill Region' on just this line, please.\""
  (interactive)

  (let ((from (save-excursion (beginning-of-line) (point)))
        (to   (save-excursion (end-of-line)       (point))))
    (fill-region from to justify)))


;;------------------------------------------------------------------------------
;; Evil Spy Stuff.
;;------------------------------------------------------------------------------

;; See Doom's keybindings for how to do complicated things:
;; https://github.com/hlissner/doom-emacs/blob/develop/modules/config/default/+evil-bindings.el
(map! :leader       ; Be under the SPC leader.
      :desc   "spy"

      ;;-------------------
      ;; Start of 'spy' prefix "-"
      ;;-------------------
      (:prefix-map ("-" . "spy") ; Not my first choice but no one uses dash,
                                 ; and it's easy on Dvorak.

       ;;-------------------
       ;; Alignment
       ;;-------------------
       (:prefix-map ("a" . "Alignment")

        :desc "spy:   Align Before"    "a" #'spy/align-before
        :desc "spy:   Align After"     "o" #'spy/align-after
        :desc "emacs: Align Regex"     ";" #'align-regexp
        :desc "emacs: C-u Align Regex" "q" (lambda () (interactive)
                                             (setq current-prefix-arg '(4))
                                             (call-interactively #'align-regexp))
        :desc "emacs: Align"           "'" #'align
        :desc "emacs: Align Current"   "," #'align-current)


       ;;-------------------
       ;; Fill
       ;;-------------------
       (:prefix-map ("f" . "Fill")
        ;; Regions
        :desc "Region"              "r" #'fill-region
        :desc "Region as Paragraph" "a" #'fill-region-as-paragraph
        :desc "Line"                "l" #'spy/fill/region/single-line

        ;; Paragraphs
        :desc (if (eq (spy//fill/paragraph/fn-for-mode) #'fill-paragraph)
                  "Default Fill ¶"
                "Mode-Aware Fill ¶")
                              "p" #'spy/fill/paragraph/per-mode
        :desc "Individual ¶"  "i" #'fill-individual-paragraphs
        :desc "Non-Uniform ¶" "n" #'fill-nonuniform-paragraphs
        :desc "Default ¶"     "d" #'fill-paragraph

        ;; Unfill
        :desc "Unfill ¶"      "u" #'spy/fill/paragraph/unfill)))
