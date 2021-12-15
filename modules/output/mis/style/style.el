;;; mis/style/style.el -*- lexical-binding: t; -*-


(imp:require :mis 'internal 'const)
(imp:require :mis 'internal 'valid)
(imp:require :mis 'internal 'mlist)


;;------------------------------------------------------------------------------
;; Constants
;;------------------------------------------------------------------------------

(defconst int<mis>:styles
  '(:width
    :margin
    :border
    :padding
    :align
    :boxed)
  "Valid mis :style section keywords.")


(defconst int<mis>:style/alignments
  '(:left
    :center
    :right)
  "Valid mis :align keywords.")


;;------------------------------------------------------------------------------
;; Field Setters
;;------------------------------------------------------------------------------

(defun mis:style/width (width &optional mlist)
  "Sets a style width. Returns an mlist.
"
  (int<mis>:out.style/width.set mlist width))


(defun mis:style/margin (margin &optional mlist)
  "Sets a style margin. Returns an mlist.
"
  (int<mis>:out.style/margin.set mlist margin))


(defun mis:style/border (border &optional mlist)
  "Sets a style border. Returns an mlist.
"
  (int<mis>:out.style/border.set mlist border))
;; (mis:style/border "x")


(defun mis:style/padding (padding &optional mlist)
  "Sets a style padding. Returns an mlist.
"
  (int<mis>:out.style/padding.set mlist padding))


(defun mis:style/align (alignment &optional mlist)
  "Sets an alignment. Returns an mlist.
"
  (unless (memq alignment int<mis>:style/alignments)
    (nub:error int<mis>:nub:user
               "mis:style/align"
               "'%S' is not a valid alignment. Choices are: %S"
               alignment
               int<mis>:style/alignments))
  (int<mis>:out.style/align.set mlist alignment))
;; (mis:style/align :center)


(defun mis:style/boxed (boxed &optional mlist)
  "Sets 'boxed' style flag based on BOXED.

Will be set to t if BOXED is non-nil, else set to nil.

Returns an mlist.
"
  (int<mis>:out.style/boxed.set mlist (not (null boxed))))


;;------------------------------------------------------------------------------
;; Alignment
;;------------------------------------------------------------------------------

;; (defun int<mis>:style/align (string mlists)
;;   "Align STRING based on alignment, padding settings in MLISTS.

;; Returns a string of length WIDTH, padding with spaces (default) or characters
;; from :string/padding styles in MLISTS."
;;   (declare (pure t) (side-effect-free t))

;;   (message "align: %S, string: '%S', width: %S, padding: %S"
;;            (int<mis>:style/first :align mlists :mis/nil)
;;            string
;;            (int<mis>:line/width mlists)
;;            (int<mis>:style/first :padding mlists " "))
;;   (let ((aligned (int<mis>:style/align/to (int<mis>:style/first :align mlists :mis/nil)
;;                                      string
;;                                      (int<mis>:line/width mlists)
;;                                      (int<mis>:style/first :padding mlists " "))))
;;     (if (int<mis>:return/invalid? aligned '(:mis/nil nil))
;;         ;; No alignment supplied or no string or something...
;;         ;; Return empty string.
;;         ""
;;       aligned)))
;; ;; (int<mis>:style/align "foo" (list (mis:style/align :center) (mis:style/padding "x")))
;; ;; (int<mis>:style/align " foo " (list (mis:style/align :center)))
;; ;; (int<mis>:style/align " foo " (list (mis:style/align :center) (mis:style/padding "-")))


;; (defun int<mis>:style/align/to (align string width padding)
;;   "Choose the proper alignment function for the ALIGN keyword.

;; Calls that function with the rest of the params and returns its value."
;;   (declare (pure t) (side-effect-free t))
;;   (cond ((eq align :center)
;;          (int<mis>:style/align/to.center string width padding))
;;         ((eq align :left)
;;          (int<mis>:style/align/to.left string width padding))
;;         ((eq align :right)
;;          (int<mis>:style/align/to.right string width padding))
;;         (t
;;          :mis/error)))
;; ;; (int<mis>:style/align/to :center "foo" fill-column "-")
;; ;; (int<mis>:style/align/to :center " foo " fill-column "-")
;; ;; (int<mis>:style/align/to :left "foo" fill-column "-")
;; ;; (int<mis>:style/align/to :right "foo" fill-column "-")


;; (defun int<mis>:style/align/to.center (string width padding)
;;   "Pad string to WIDTH with PADDING characters so that it is centered.

;; If STRING is too long, returns it (as-is/un-truncated)."
;;   (declare (pure t) (side-effect-free t))
;;   (let ((pad-amt (max 0 (- width (length string)))))
;;     (concat
;;      (make-string (ceiling pad-amt 2) (string-to-char padding))
;;      string
;;      (make-string (floor pad-amt 2) (string-to-char padding)))))


;; (defun int<mis>:style/align/to.left (string width padding)
;;   "Pads STRING with PADDING on the left up to WIDTH.

;; If STRING is too long, returns it (as-is/un-truncated)."
;;   (declare (pure t) (side-effect-free t))
;;   (let ((pad-amt (max 0 (- width (length string)))))
;;     (concat (make-string pad-amt (string-to-char padding))
;;             string)))


;; (defun int<mis>:style/align/to.right (string width padding)
;;   "Pads STRING with PADDING on the right up to WIDTH.

;; If STRING is too long, returns it (as-is/un-truncated)."
;;   (declare (pure t) (side-effect-free t))
;;   (let ((pad-amt (max 0 (- width (length string)))))
;;     (concat string
;;             (make-string pad-amt (string-to-char padding)))))


;;------------------------------------------------------------------------------
;; Style Output
;;------------------------------------------------------------------------------

(defun int<mis>:out.style/width.get (mout)
  "Get :style/width from MOUT list.

Returns :mis/nil if none."
  (int<mis>:out/entry.get mout :width))


(defun int<mis>:out.style/width.set (mout value)
  "Set :style/width to VALUE in MOUT list.

Returns updated MOUT list."
  (int<mis>:out/entry.set mout :width value))


(defun int<mis>:out.style/margin.get (mout)
  "Get :style/margin from MOUT list.

Returns :mis/nil if none."
  (int<mis>:out/entry.get mout :margin))


(defun int<mis>:out.style/margin.set (mout value)
  "Set :style/margin to VALUE in MOUT list.

Returns updated MOUT list."
  (int<mis>:out/entry.set mout :margin value))


(defun int<mis>:out.style/border.get (mout)
  "Get :style/border from MOUT list.

Returns :mis/nil if none."
  (int<mis>:out/entry.get mout :border))


(defun int<mis>:out.style/border.set (mout value)
  "Set :style/border to VALUE in MOUT list.

Returns updated MOUT list."
  (int<mis>:out/entry.set mout :border value))


(defun int<mis>:out.style/padding.get (mout)
  "Get :style/padding from MOUT list.

Returns :mis/nil if none."
  (int<mis>:out/entry.get mout :padding))


(defun int<mis>:out.style/padding.set (mout value)
  "Set :style/padding to VALUE in MOUT list.

Returns updated MOUT list."
  (int<mis>:out/entry.set mout :padding value))


(defun int<mis>:out.style/align.get (mout)
  "Get :style/align from MOUT list.

Returns :mis/nil if none."
  (int<mis>:out/entry.get mout :align))


(defun int<mis>:out.style/align.set (mout value)
  "Set :style/align to VALUE in MOUT list.

Returns updated MOUT list."
  (int<mis>:out/entry.set mout :align value))


(defun int<mis>:out.style/boxed.get (mout)
  "Get :style/boxed from MOUT list.

Returns :mis/nil if none."
  (int<mis>:out/entry.get mout :boxed))


(defun int<mis>:out.style/boxed.set (mout value)
  "Set :style/boxed to VALUE in MOUT list.

Returns updated MOUT list."
  (int<mis>:out/entry.set mout :boxed value))


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(imp:provide:with-emacs :mis 'style 'style)
