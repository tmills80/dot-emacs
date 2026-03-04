;;; twem2-lint-fix.el --- Auto-detect and run project linters  -*- lexical-binding: t -*-

(defvar twem2--biome-config-files '("biome.json" "biome.jsonc"))

(defvar twem2--eslint-config-files
  '(".eslintrc" ".eslintrc.js" ".eslintrc.cjs"
    ".eslintrc.json" ".eslintrc.yml" ".eslintrc.yaml"
    "eslint.config.js" "eslint.config.mjs" "eslint.config.cjs"))

(defvar twem2--prettier-config-files
  '(".prettierrc" ".prettierrc.json" ".prettierrc.yml"
    ".prettierrc.yaml" ".prettierrc.json5" ".prettierrc.toml"
    "prettier.config.js" "prettier.config.cjs" "prettier.config.mjs"))

(defun twem2--project-has-config-p (root filenames)
  "Return non-nil if any of FILENAMES exist in ROOT."
  (cl-some (lambda (f) (file-exists-p (expand-file-name f root))) filenames))

(defun twem2--detect-linter ()
  "Detect which linter(s) to use based on config files in the project root.
Returns a list of symbols from: biome, eslint, prettier."
  (when-let* ((proj (project-current))
              (root (project-root proj)))
    (if (twem2--project-has-config-p root twem2--biome-config-files)
        '(biome)
      (append
       (when (twem2--project-has-config-p root twem2--eslint-config-files)
         '(eslint))
       (when (twem2--project-has-config-p root twem2--prettier-config-files)
         '(prettier))))))

(defun lint-fix-file ()
  "Run the appropriate linter --fix on the current file based on project config."
  (interactive)
  (let ((file (buffer-file-name))
        (linters (twem2--detect-linter)))
    (dolist (linter linters)
      (pcase linter
        ('biome
         (message "biome format+lint fixing %s" file)
         (shell-command (concat "npx biome format --write " file
                                " && npx biome lint --write " file)))
        ('eslint
         (message "eslint --fix %s" file)
         (shell-command (concat "npx eslint --fix " file)))
        ('prettier
         (message "prettier --write %s" file)
         (shell-command (concat "npx prettier --write " file)))))))

(defun lint-fix-file-and-revert ()
  (interactive)
  (lint-fix-file)
  (revert-buffer t t))

(provide 'twem2-lint-fix)
;;; twem2-lint-fix.el ends here
