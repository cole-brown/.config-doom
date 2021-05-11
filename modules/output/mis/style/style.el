;;; mis/args/style2.el -*- lexical-binding: t; -*-


(-m//require 'internal 'const)
(-m//require 'internal 'valid)
(-m//require 'internal 'mlist2)


;;------------------------------------------------------------------------------
;; Constants
;;------------------------------------------------------------------------------

(defconst -m//styles
  '(:width
    :margin
    :border
    :padding
    :align
    :boxed)
  "Valid mis :style section keywords.")


(defconst -m//style/alignments
  '(:left
    :center
    :right)
  "Valid mis :align keywords.")


;;------------------------------------------------------------------------------
;; Field Setters
;;------------------------------------------------------------------------------

(defun mis2/style/width (width &optional mlist)
  "Sets a style width. Returns an mlist.
"
  (mis2//out.style/width.set mlist width))


(defun mis2/style/margin (margin &optional mlist)
  "Sets a style margin. Returns an mlist.
"
  (mis2//out.style/margin.set mlist margin))


(defun mis2/style/border (border &optional mlist)
  "Sets a style border. Returns an mlist.
"
  (mis2//out.style/border.set mlist border))
;; (mis2/style/border "x")


(defun mis2/style/padding (padding &optional mlist)
  "Sets a style padding. Returns an mlist.
"
  (mis2//out.style/padding.set mlist padding))


(defun mis2/style/align (alignment &optional mlist)
  "Sets an alignment. Returns an mlist.
"
  (unless (memq alignment -m//style/alignments)
    (error "mis2/style/align: '%S' is not a valid alignment. Choices are: %S"
           alignment
           -m//style/alignments))
  (mis2//out.style/align.set mlist alignment))
;; (mis2/style/align :center)


(defun mis2/style/boxed (boxed &optional mlist)
  "Sets 'boxed' style flag based on BOXED.

Will be set to t if BOXED is non-nil, else set to nil.

Returns an mlist.
"
  (mis2//out.style/boxed.set mlist (not (null boxed))))


;;------------------------------------------------------------------------------
;; Alignment
;;------------------------------------------------------------------------------

;; (defun -m//style/align (string mlists)
;;   "Align STRING based on alignment, padding settings in MLISTS.

;; Returns a string of length WIDTH, padding with spaces (default) or characters
;; from :string/padding styles in MLISTS."
;;   (declare (pure t) (side-effect-free t))

;;   (message "align: %S, string: '%S', width: %S, padding: %S"
;;            (-m//style/first :align mlists :mis2/nil)
;;            string
;;            (-m//line/width mlists)
;;            (-m//style/first :padding mlists " "))
;;   (let ((aligned (-m//style/align/to (-m//style/first :align mlists :mis2/nil)
;;                                      string
;;                                      (-m//line/width mlists)
;;                                      (-m//style/first :padding mlists " "))))
;;     (if (-m//return/invalid? aligned '(:mis2/nil nil))
;;         ;; No alignment supplied or no string or something...
;;         ;; Return empty string.
;;         ""
;;       aligned)))
;; ;; (-m//style/align "foo" (list (mis2/style/align :center) (mis2/style/padding "x")))
;; ;; (-m//style/align " foo " (list (mis2/style/align :center)))
;; ;; (-m//style/align " foo " (list (mis2/style/align :center) (mis2/style/padding "-")))


;; (defun -m//style/align/to (align string width padding)
;;   "Choose the proper alignment function for the ALIGN keyword.

;; Calls that function with the rest of the params and returns its value."
;;   (declare (pure t) (side-effect-free t))
;;   (cond ((eq align :center)
;;          (-m//style/align/to.center string width padding))
;;         ((eq align :left)
;;          (-m//style/align/to.left string width padding))
;;         ((eq align :right)
;;          (-m//style/align/to.right string width padding))
;;         (t
;;          :mis2/error)))
;; ;; (-m//style/align/to :center "foo" fill-column "-")
;; ;; (-m//style/align/to :center " foo " fill-column "-")
;; ;; (-m//style/align/to :left "foo" fill-column "-")
;; ;; (-m//style/align/to :right "foo" fill-column "-")


;; (defun -m//style/align/to.center (string width padding)
;;   "Pad string to WIDTH with PADDING characters so that it is centered.

;; If STRING is too long, returns it (as-is/un-truncated)."
;;   (declare (pure t) (side-effect-free t))
;;   (let ((pad-amt (max 0 (- width (length string)))))
;;     (concat
;;      (make-string (ceiling pad-amt 2) (string-to-char padding))
;;      string
;;      (make-string (floor pad-amt 2) (string-to-char padding)))))


;; (defun -m//style/align/to.left (string width padding)
;;   "Pads STRING with PADDING on the left up to WIDTH.

;; If STRING is too long, returns it (as-is/un-truncated)."
;;   (declare (pure t) (side-effect-free t))
;;   (let ((pad-amt (max 0 (- width (length string)))))
;;     (concat (make-string pad-amt (string-to-char padding))
;;             string)))


;; (defun -m//style/align/to.right (string width padding)
;;   "Pads STRING with PADDING on the right up to WIDTH.

;; If STRING is too long, returns it (as-is/un-truncated)."
;;   (declare (pure t) (side-effect-free t))
;;   (let ((pad-amt (max 0 (- width (length string)))))
;;     (concat string
;;             (make-string pad-amt (string-to-char padding)))))


;;------------------------------------------------------------------------------
;; Style Output
;;------------------------------------------------------------------------------

(defun mis2//out.style/width.get (mout)
  "Get :style/width from MOUT list.

Returns :mis2/nil if none."
  (-m//out/entry.get mout :width))


(defun mis2//out.style/width.set (mout value)
  "Set :style/width to VALUE in MOUT list.

Returns updated MOUT list."
  (-m//out/entry.set mout :width value))


(defun mis2//out.style/margin.get (mout)
  "Get :style/margin from MOUT list.

Returns :mis2/nil if none."
  (-m//out/entry.get mout :margin))


(defun mis2//out.style/margin.set (mout value)
  "Set :style/margin to VALUE in MOUT list.

Returns updated MOUT list."
  (-m//out/entry.set mout :margin value))


(defun mis2//out.style/border.get (mout)
  "Get :style/border from MOUT list.

Returns :mis2/nil if none."
  (-m//out/entry.get mout :border))


(defun mis2//out.style/border.set (mout value)
  "Set :style/border to VALUE in MOUT list.

Returns updated MOUT list."
  (-m//out/entry.set mout :border value))


(defun mis2//out.style/padding.get (mout)
  "Get :style/padding from MOUT list.

Returns :mis2/nil if none."
  (-m//out/entry.get mout :padding))


(defun mis2//out.style/padding.set (mout value)
  "Set :style/padding to VALUE in MOUT list.

Returns updated MOUT list."
  (-m//out/entry.set mout :padding value))


(defun mis2//out.style/align.get (mout)
  "Get :style/align from MOUT list.

Returns :mis2/nil if none."
  (-m//out/entry.get mout :align))


(defun mis2//out.style/align.set (mout value)
  "Set :style/align to VALUE in MOUT list.

Returns updated MOUT list."
  (-m//out/entry.set mout :align value))


(defun mis2//out.style/boxed.get (mout)
  "Get :style/boxed from MOUT list.

Returns :mis2/nil if none."
  (-m//out/entry.get mout :boxed))


(defun mis2//out.style/boxed.set (mout value)
  "Set :style/boxed to VALUE in MOUT list.

Returns updated MOUT list."
  (-m//out/entry.set mout :boxed value))


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(-m//provide 'args 'style2)
(provide 'mis/args/style2)
