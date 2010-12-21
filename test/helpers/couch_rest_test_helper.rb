require 'couchrest_model'

COUCHHOST   = "http://127.0.0.1:5984"
TESTDB      = 'tenacity-test'
TEST_SERVER = CouchRest.new
TEST_SERVER.default_database = TESTDB
COUCH_DB = TEST_SERVER.database(TESTDB)

