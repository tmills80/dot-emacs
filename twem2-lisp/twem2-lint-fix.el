;;; twem2-lint-fix.el --- Auto-detect and run project linters  -*- lexical-binding: t -*-

(require 'seq)
(require 'project)

(defvar twem2-lint-fix-linters
  '((biome
     :configs ("biome.json" "biome.jsonc")
     :command "npx biome format --write %s && npx biome lint --write %s")
    (eslint
     :configs (".eslintrc" ".eslintrc.js" ".eslintrc.cjs"
               ".eslintrc.json" ".eslintrc.yml" ".eslintrc.yaml"
               "eslint.config.js" "eslint.config.mjs" "eslint.config.cjs")
     :command "npx eslint --fix %s")
    (prettier
     :configs (".prettierrc" ".prettierrc.json" ".prettierrc.yml"
               ".prettierrc.yaml" ".prettierrc.json5" ".prettierrc.toml"
               "prettier.config.js" "prettier.config.cjs" "prettier.config.mjs")
     :command "npx prettier --write %s"))
  "Alist of linters to detect and run.
Each entry is (NAME :configs FILES :command COMMAND).
COMMAND is a format string where %s is replaced with the file path.")

(defun twem2--project-has-config-p (root filenames)
  "Return non-nil if any of FILENAMES exist in ROOT."
  (seq-some (lambda (f) (file-exists-p (expand-file-name f root))) filenames))

(defun twem2--detect-linters ()
  "Detect which linters to run based on config files in the project root.
Returns a list of matching entries from `twem2-lint-fix-linters'."
  (when-let* ((proj (project-current))
              (root (project-root proj)))
    (seq-filter
     (lambda (entry)
       (twem2--project-has-config-p root (plist-get (cdr entry) :configs)))
     twem2-lint-fix-linters)))

(defun lint-fix-file ()
  "Run the appropriate linter --fix on the current file based on project config."
  (interactive)
  (let ((file (buffer-file-name))
        (linters (twem2--detect-linters)))
    (dolist (linter linters)
      (let ((name (car linter))
            (cmd (plist-get (cdr linter) :command)))
        (message "%s fixing %s" name file)
        (shell-command (format cmd file))))))

(defun lint-fix-file-and-revert ()
  (interactive)
  (lint-fix-file)
  (revert-buffer t t))

(provide 'twem2-lint-fix)
;;; twem2-lint-fix.el ends here