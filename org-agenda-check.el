;;; org-agenda.el ---

;; Copyright (C) 2014 Grégoire Jadi

;; Author: Grégoire Jadi <gregoire.jadi@gmail.com>

;; This program is free software: you can redistribute it and/or
;; modify it under the terms of the GNU General Public License as
;; published by the Free Software Foundation, either version 3 of
;; the License, or (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;;; Code:

(defcustom org-agenda-ignore-files nil
  "The files not to be used for agenda display."
  :group 'org-agenda
  :type '(repeat :tag "List of files" file))

(defun org-agenda-check-file ()
  "Check whether the visited file is in `org-agenda-files'. If
not, ask the user to add it. If the user refuse to add the file,
it is added to `org-agenda-ignore-files'."
  (let ((file (buffer-file-name)))
    (when file
      (if (and (not (or (find file org-agenda-files :test #'file-equal-p)
                        (find file org-agenda-ignore-files :test #'file-equal-p)))
               (yes-or-no-p (format "Do you want to add `%s' to org-agenda-files? " file)))
          (org-agenda-file-to-front)
        (pushnew file org-agenda-ignore-files))
      (setq org-agenda-file-in-agenda (find file org-agenda-files :test #'file-equal-p)))))

(defvar-local org-agenda-file-in-agenda nil)

(defun org-agenda-mode-line-string ()
  (when (and (buffer-file-name)
             (derived-mode-p 'org-mode)
             org-agenda-file-in-agenda)
    "A"))

(advice-add 'org-agenda-file-to-front :after
            (lambda (&rest r)
              "Remove the file from the ignore list when added to `org-agenda-files'."
              (setq org-agenda-ignore-files (cl-delete (buffer-file-name)
                                                       org-agenda-ignore-files
                                                       :test #'equal))
              (setq org-agenda-file-in-agenda t))
            '((name . org-agenda-remove-from-ignore-files-when-added)))

(advice-add 'org-remove-file :after
            (lambda (&rest r)
              "Add the file to the ignore list when removed from `org-agenda-files'."
              (pushnew (buffer-file-name) org-agenda-ignore-files)
              (setq org-agenda-file-in-agenda nil))
            '((name . org-agenda-add-to-ignore-files-when-removed)))

(add-hook 'org-mode-hook 'org-agenda-check-file)

(provide 'org-agenda-check)

;;; org-agenda-check.el ends here
