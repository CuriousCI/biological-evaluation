// https://neo4j.com/docs/cypher-manual/4.4/indexes-for-search-performance/
// https://neo4j.com/docs/cypher-manual/4.4/query-tuning/
// https://neo4j.com/docs/cypher-manual/4.4/query-tuning/indexes/
// https://neo4j.com/docs/operations-manual/4.4/performance/index-configuration/
CREATE [index_type] INDEX [index_name]



// A database index is a redundant copy of some of the data in the database for the purpose of making searches of related data more efficient. This comes at the cost of additional storage space and slower writes, so deciding what to index and what not to index is an important and often non-trivial task.
// Guess what? I don't care about writes and storage!


// There are multiple index types available: B-tree (deprecated), fulltext, lookup, and text index types.
// Token lookup indexes contain nodes with one or more labels or relationship types, without regard for any properties.


CREATE [BTREE] INDEX [index_name] [IF NOT EXISTS]
FOR (n:LabelName)
ON (n.propertyName)
[OPTIONS "{" option: value[, ...] "}"]

// Create a single-property index on nodes. Index provider and configuration can be specified using the OPTIONS clause.

CREATE [BTREE] INDEX [index_name] [IF NOT EXISTS]
FOR ()-"["r:TYPE_NAME"]"-()
ON (r.propertyName)
[OPTIONS "{" option: value[, ...] "}"]

// Create a single-property index on relationships. Index provider and configuration can be specified using the OPTIONS clause.

CREATE [BTREE] INDEX [index_name] [IF NOT EXISTS]
FOR (n:LabelName)
ON (n.propertyName_1,
    n.propertyName_2,
    ...
    n.propertyName_n)
[OPTIONS "{" option: value[, ...] "}"]

// Create a composite index on nodes. Index provider and configuration can be specified using the OPTIONS clause.


CREATE LOOKUP INDEX [index_name] [IF NOT EXISTS]
FOR (n)
ON EACH labels(n)
[OPTIONS "{" option: value[, ...] "}"]

// Create a node label lookup index. Index provider can be specified using the OPTIONS clause.


CREATE LOOKUP INDEX [index_name] [IF NOT EXISTS]
FOR ()-"["r"]"-()
ON [EACH] type(r)
[OPTIONS "{" option: value[, ...] "}"]

// Create a relationship type lookup index. Index provider can be specified using the OPTIONS clause.


DROP INDEX index_name [IF EXISTS]


// OK, useful stuff

SHOW [ALL | BTREE | FULLTEXT | LOOKUP | TEXT] INDEX[ES]
  [YIELD { * | field[, ...] } [ORDER BY field[, ...]] [SKIP n] [LIMIT n]]
  [WHERE expression]
  [RETURN field[, ...] [ORDER BY field[, ...]] [SKIP n] [LIMIT n]]
