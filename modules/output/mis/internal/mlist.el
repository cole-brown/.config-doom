;;; mis/internal/mlist.el -*- lexical-binding: t; -*-


(imp:require :mis 'internal 'const)
(imp:require :mis 'internal 'valid)


;;------------------------------------------------------------------------------
;; Format
;;------------------------------------------------------------------------------

;;(Ye Old mlist)
;; Input mlist format:
;;   (mis/style/boxed t)
;;     -> (:mis t :style (:mis :style :boxed t))

;; (Ye New mlist)
;; Output mlist format:
;;   ((:mis :out)
;;    (:string " foo ")
;;    (:align :center
;;     (:padding "-"))
;;    (:width 79)
;;    (:wrap ("# " " #")))


;;------------------------------------------------------------------------------
;; :mis/out alist
;;------------------------------------------------------------------------------

;; (defun -m//out/create (mlists)
;;   "Create the :mis/out alist from all inputs in all the MLISTS.
;;
;; Returns the created :mis/out alist."
;;   (let ((m/out (-m//out/init)))
;;     ;; Build main :mis/out list from each of the lists...
;;     (dolist (m/in mlists m/out)
;;       ;; Build :mis/out entries from each of the entries in this.
;;       (message "TODO HERE"))))


(defun -m//out/init (&optional entry)
  "Create the :mis/out alist with its first entry.

Guessing at wanting everything in backwards order."
  (if entry
      (list (-m//out/entry.set/create :mis :out)
            entry)
    (list (-m//out/entry.set/create :mis :out))))
;; (-m//out/init)
;; (-m//out/init)


;;------------------------------------------------------------------------------
;; Entry: Set
;;------------------------------------------------------------------------------

(defun -m//out/entry.set/create (key value)
  "Create the entry itself.

Returns the entry created."
  (cons key value))


(defun -m//out/entry.set/update (mout key value)
  "Update or create the entry in the MOUT alist.

Returns the MOUT alist."
  (setf (alist-get key mout) value)
  mout)


;; TODO: sanity checks?
(defun -m//out/entry.set (key value mout)
  "Create/update KEY in MOUT alist to VALUE."
  (if (not mout)
      ;; No :mis/out - create it with the new entry.
      (-m//out/init (-m//out/entry.set/create key value))

    ;; Existing :mis/out - update key if it exists else add.
    (-m//out/entry.set/update mout key value)
    mout))
;; (-m//out/entry.set nil :jeff 'jill)
;; (-m//out/entry.set '((:mis . :out) (:jeff . jeff)) :jeff 'jill)
;; A sub-entry:
;; (-m//out/entry.set '((:jeff . jill) (:width . 9001)) :width 80)


;;------------------------------------------------------------------------------
;; Entry: Get
;;------------------------------------------------------------------------------

(defun -m//out/entry.get (mout key)
  "Get a KEY's value from MOUT.

Returns `:mis/nil' if no KEY in MOUT."
  (alist-get key mout :mis/nil))
;; (-m//out/entry.get (-m//out/entry :jeff 'jill nil) :dne)
;; (-m//out/entry.get (-m//out/entry :jeff 'jill nil) :jeff)
;; A sub-entry:
;; (-m//out/entry.get '((:jeff . jill) (:width . 80)) :width)


;; How shoud mout vs mlist work even?
;; (mis/comment/wrap
;;  (-m//style/align "Hello There."
;;                   (list (mis/style/align :center)
;;                         (mis/style/padding "-"))))
;; --->
;; (mis/comment/wrap
;;  '((:mis . :out)
;;    (:align . :center)
;;    (:padding "-")
;;    (:string "Hello There.")))
;; So... Convert to mout instead of mlist?



;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(imp:provide :mis 'internal 'mlist)
