;;; twem2-org-latex.el --- functions to make life writing LaTeX in org-mode easier -*- lexical-binding: t; -*-

;; Copyright (C) 2025 Tristan Mills

;; Author: Tristan Mills <tristan@eridu.org.uk>
;; Version: 0.1

;; This file is not part of GNU Emacs

;;

;;;###autoload
;; Insert quoted brackets

(defun twem2-org-latex-insert-brackets ()
  "Insert \(\) and move the the center of that"
  (interactive)
  (insert "\\(\\)")
  (backward-char 2))

(provide 'twem2-org-latex)
