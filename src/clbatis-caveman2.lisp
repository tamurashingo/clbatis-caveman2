(in-package :cl-user)
(defpackage clbatis-caveman2
  (:use :cl))
(in-package :clbatis-caveman2)

(cl-syntax:use-syntax :annot)

(defvar *connection-pool* NIL)

@export
(defun initialize-database (&rest params)
  "make connection pool.
parameters are same to cl-dbi-connection-pool:make-dbi-connection-pool's

Example:
(initialize-database :mysql
                     :database-name \"superb-app\"
                     :username \"root\"
                     :password \"password\"
                     :initial-size 20
                     :max-size 30)"
  (setf *connection-pool*
        (apply #'dbi-cp:make-dbi-connection-pool params)))


@export
(defun finalize-database ()
  "close all database connections"
  (prog1
      (dbi-cp:shutdown *connection-pool*)
    (setf *connection-pool* NIL)))

@export
(defmacro transactional ((db) &body body)
  "generate transaction block.
When go out block, commit automatically.
When some error occurred, rollback automatically.

In transaction block, no need to `commit` or `rollback` manually."
  `(let ((,db (batis:create-sql-session clbatis-caveman2::*connection-pool*)))
     (unwind-protect
          (handler-case
              (progn
                ,@body)
            (error (e)
              (progn
                (batis:rollback ,db)
                (error e)))
            (:no-error (c)
              (progn
                (batis:commit ,db)
                c)))
       (batis:close-sql-session ,db))))

@export
(defmacro transaction-manager ((db) &body body)
  "provice specifiec argument to handle transactions programmatically.

Example
(transaction-manager (db)
  (do-sql db \"insert into ... \")
  (commit db))"
  `(let ((,db (batis:create-sql-session clbatis-caveman2::*connection-pool*)))
     (unwind-protect
          (progn
            ,@body)
       (batis:close-sql-session ,db))))

