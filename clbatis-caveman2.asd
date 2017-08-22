#|
  This file is a part of clbatis-caveman2 project.
  Copyright (c) 2017 tamura shingo (tamura.shingo@gmail.com)
|#

#|
  clbatis-caveman2 integrates Cl-Batis seamlessly with Caveman2

  Author: tamura shingo (tamura.shingo@gmail.com)
|#

(in-package :cl-user)
(defpackage clbatis-caveman2-asd
  (:use :cl :asdf))
(in-package :clbatis-caveman2-asd)

(defsystem clbatis-caveman2
  :version "0.1"
  :author "tamura shingo"
  :license "MIT"
  :depends-on (:cl-syntax
               :cl-batis)
  :components ((:module "src"
                :components
                ((:file "clbatis-caveman2"))))
  :description "clbatis-caveman2 integrates Cl-Batis seamlessly with Caveman2"
  :long-description
  #.(with-open-file (stream (merge-pathnames
                             #p"README.markdown"
                             (or *load-pathname* *compile-file-pathname*))
                            :if-does-not-exist nil
                            :direction :input)
      (when stream
        (let ((seq (make-array (file-length stream)
                               :element-type 'character
                               :fill-pointer t)))
          (setf (fill-pointer seq) (read-sequence seq stream))
          seq)))
  :in-order-to ((test-op (test-op clbatis-caveman2-test))))
