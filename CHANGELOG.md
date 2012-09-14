Version 0.5.8
-------------

* Bug fixes

  * ActiveSupport 3.2 compatibility fix.

Version 0.5.7
-------------

* Misc

  * Use ~> to specify the version of development dependencies to work around an issue with
    rubygems on Heroku.

Version 0.5.6
-------------

* Bug fixes

  * Fixed a few issues with regards to how ActiveRecord::Base.save behaves (raphaelcm)

Version 0.5.5
-------------

* Bug fixes

  * Modify association code to support qualified class names (Foo::Bar)

Version 0.5.4
-------------

* Bug fixes

  * Fixed a bug that was causing the associate objects in a _t_has_many association
    to be wiped out when saving an object that had not yet loaded the
    associated objects from the database.

Version 0.5.3
-------------

* Bug fixes

  * Modified ORM extensions to use a default id type if the id type could not
    be determined (was causing ActiveRecord migrations to fail)

Version 0.5.2
-------------

* Bug fixes

  * Changed relational DB clients to evaluate the schema to determine the type
    of the primary key, instead of just assuming it is an Integer

* Minor enhancements

  * Performance optimizations

Version 0.5.1
-------------

* Bug fixes

  * Should not re-load the source of the association when source.target(true)
    is called.

Version 0.5.0
-------------

* Major enhancements

  * Added code to verify target object in a t_belongs_to association exists when
    saving the source object
  * Don't allow the source object in a t_has_one or t_has_many association to be
    deleted if the target object in the association is holding its id
  * Removed the need for join tables for t_has_many associations
  * Added support for Ripple
  * Added support for Toystore

* Bug fixes

  * Fixed bug preventing an object including the Tenacity module from being saved
    successfully if it had no associations

Version 0.4.1
-------------

* Bug fixes

  * Fixed a couple of issues specific to Ruby 1.9

Version 0.4.0
-------------

* Major enhancements

  * Tenacity will no longer convert foreign keys to strings before storing them
    in the database.  Instead, the ID will be stored without any modification
    (when possible).

* Minor enhancements

  * Added support for the :dependent option to all associations
  * Added support for the :readonly option to all associations
  * Added support for the :limit option to the t_has_many association
  * Added support for the :offset option to the t_has_many association
  * Added support for the :autosave option to all associations
  * Added support for polymorphic associations to all associations

Version 0.3.0
-------------

* Major enhancements

  * Added support for Mongoid
  * Added support for DataMapper
  * Added support for Sequel

* Minor enhancements

  * Automatically save object when added to a t_has_many association, unless the
    parent object is not yet saved itself.
  * Added suport for destroy_all to the t_has_many association
  * Added suport for delete_all to the t_has_many association
  * Added support for push and concat to t_has_many association

* Bug fixes

  * Found and fixed many minor bugs thanks to a new test suite that tests all
    associations against all supported database clients.

Version 0.2.0
-------------

* Major enhancements

  * Added options to override assumptions on names of classes, foreign keys,
    tables, and columns.

* Minor enhancements

  * Added support for the :class_name option to all associations
  * Added support for the :foreign_key option to all associations
  * Added support for the :foreign_keys_property option to the t_has_many association
  * Added support for the :join_table option to the t_has_many association
  * Added support for the :association_foreign_key option to the t_has_many association
  * Added support for the :association_key option to the t_has_many association

* Bug fixes

  * t_has_one association was being initialized on the wrong class in the association
  * Fixed bug that causing t_has_many associations not to work with SQLite

Version 0.1.1
-------------

* Bug fixes

  * Fixed issue that was causing a load error if mongo mapper was not installed

Version 0.1.0
-------------

* Major enhancements

  * Initial release
  * Support for has_one, belongs_to, and has_many associations
  * Support for ActiveRecord, CouchRest, and MongoMapper
