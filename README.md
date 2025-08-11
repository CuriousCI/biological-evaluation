# Bsys-eval

[ConventionalCommits](https://www.conventionalcommits.org/en/v1.0.0/#summary)

## experiment

https://reactome.org/content/detail/R-HSA-158164

- [x] What indexes are available
    - docs/indexes.csv

- [x] MATCH?
    - [ ] longestPath from end-node to one of its ancestors (see shortestPath) ?
- [x] patterns
    - https://neo4j.com/docs/cypher-manual/4.4/syntax/patterns/
    - basically all the ones I know, literally nothing new (except the knowledge about <-\[*\]-)

- [x] MERGE?
    - basically just MATCH + CREATE (if it exists, take it, otherwise create it)
- [x] WITH?
    - basically allows to do a query in multiple steps, allowing multiple matches to simplify the queries
    - it allows to bring nodes to the next MATCH in the query (MATCH 1 gets m, MATCH 2 uses m to generate other stuff)

- [x] UNWIND?
    - The UNWIND clause makes it possible to transform any list back into individual rows. These lists can be parameters that were passed in, previously collect-ed result, or other list expressions.


- [x] test PROFILE baby!

- [ ] Cluster
    - [x] Make it work
    - [x] Automate slurm + singularity queries with script (bash take argument for query)
    - [x] Pass repository to cluster with SCP
    - [ ] Find a way to pass neo4j.conf (password problem?) and check if it makes a difference

- [ ] Performance 
    - [ ] Create an index
    - [ ] Find a way to pass it to the cluster (save a new dump + send that dump)
    - [ ] Test custom docker image with Reactome DB + neo4j 5 (enterprise) 
    - [ ] Test parallel query


<!-- I could use this to generate just the physical entitites and reactions, and then work on them in the next query? -->

- [ ] Planner + USING (https://neo4j.com/docs/cypher-manual/4.4/query-tuning/using/)

- [x] input|output are inversed


- [ ] What happens at depth 12?
- [ ] How to create and index on a relation
- [ ] EXTRA
    - [x] hasEvent? Cosa ci facciamo?
        - lo possiamo ignorare momentanemanet
    - [ ] hasEncapsulatedEvent?
- [ ] debug could help?

- [ ] TODO: what if I want an entire Pathway, how should I behave?
