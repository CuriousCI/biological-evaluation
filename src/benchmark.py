import sys
import time
import json
from typing import Any

import neo4j
from neo4j import GraphDatabase

NEO4J_URL_REACTOME = 'bolt://localhost:7687'
AUTH = ('noe4j', 'neo4j')
REACTOME_DATABASE = 'graph.db'


# 0.003 seconds
def query(driver: neo4j.Driver) -> list[Any]:
    records, _, _ = driver.execute_query(
        """
        MATCH (n:PhysicalEntity)
        RETURN COUNT(n)
        """,
        database_=REACTOME_DATABASE,
    )

    return records


# 33 seconds, only PhysicalEntity
def query2(driver: neo4j.Driver) -> list[Any]:
    records, _, _ = driver.execute_query(
        """
        MATCH (n:PhysicalEntity)
        RETURN n
        """,
        database_=REACTOME_DATABASE,
    )

    return records


# 7 seconds - 225 ms on cluster
def query3(driver: neo4j.Driver) -> list[Any]:
    records, _, _ = driver.execute_query(
        """
        MATCH (n:ReactionLikeEvent) RETURN n
        """,
        database_=REACTOME_DATABASE,
    )

    return records


# 0.02 seconds
def query4(driver: neo4j.Driver) -> list[Any]:
    records, _, _ = driver.execute_query(
        """
        MATCH (n) RETURN COUNT(n)
        """,
        database_=REACTOME_DATABASE,
    )
    return records


# 2886311 items - 199.66688871383667 seconds
def query5(driver: neo4j.Driver) -> list[Any]:
    records, _, _ = driver.execute_query(
        """
        MATCH (n) RETURN n
        """,
        database_=REACTOME_DATABASE,
    )
    return records


# 495383 items -  40.77719449996948 seconds
def query6(driver: neo4j.Driver) -> list[Any]:
    records, _, _ = driver.execute_query(
        """
        MATCH (n) 
        WHERE 'PhysicalEntity' IN LABELS(n) OR 'ReactionLikeEvent' IN LABELS(n)
        RETURN n
        """,
        database_=REACTOME_DATABASE,
    )
    return records


# items 338621 - 24.08058261871338 seconds
def query7(driver: neo4j.Driver) -> list[Any]:
    records, _, _ = driver.execute_query(
        """
        MATCH (n:PhysicalEntity)-[r]-(m:ReactionLikeEvent)
        RETURN n
        """,
        database_=REACTOME_DATABASE,
    )
    return records


# items 835703 - 100.93174886703491 seconds - 1m11.595s on cluster
def query8(driver: neo4j.Driver) -> list[Any]:
    records, _, _ = driver.execute_query(
        """
        MATCH (n:PhysicalEntity)<-[r]-(m:PhysicalEntity)
        RETURN n, m 
        """,
        database_=REACTOME_DATABASE,
    )
    return records


# items 835703 - 62.581510066986084 seconds
def query9(driver: neo4j.Driver) -> list[Any]:
    records, _, _ = driver.execute_query(
        """
        MATCH (n:PhysicalEntity)<-[r]-(m:PhysicalEntity)
        RETURN n
        """,
        database_=REACTOME_DATABASE,
    )
    return records


# items 321574 - 21.66232204437256 seconds
def query10(driver: neo4j.Driver) -> list[Any]:
    records, _, _ = driver.execute_query(
        """
        MATCH (n:PhysicalEntity)-[:output]-(r:ReactionLikeEvent)-[:input]-(m:PhysicalEntity)
        RETURN n
        """,
        database_=REACTOME_DATABASE,
    )
    return records


# items 321574 - 36.138306856155396 seconds
def query11(driver: neo4j.Driver) -> list[Any]:
    records, _, _ = driver.execute_query(
        """
        MATCH (n:PhysicalEntity)-[:output]-(r:ReactionLikeEvent)-[:input]-(m:PhysicalEntity)
        RETURN n, m
        """,
        database_=REACTOME_DATABASE,
    )

    return records


#
def query12(driver: neo4j.Driver) -> list[Any]:
    records, _, _ = driver.execute_query(
        """
        MATCH (n:PhysicalEntity)-[:output *..2]-(m:PhysicalEntity)
        RETURN n
        """,
        database_=REACTOME_DATABASE,
    )
    return records


def query13(driver: neo4j.Driver) -> list[Any]:
    records, _, _ = driver.execute_query(
        """
        MATCH (n:PhysicalEntity)
        RETURN n 
        LIMIT 100000
        """,
        database_=REACTOME_DATABASE,
    )

    return records


def query_profile(driver: neo4j.Driver) -> list[Any]:
    summary: neo4j.ResultSummary
    records, summary, _ = driver.execute_query(
        """
        PROFILE
        MATCH (n:ReactionLikeEvent)
        RETURN n
        """,
        database_=REACTOME_DATABASE,
    )

    # print(json.dumps(summary.profile, indent=4))
    print(
        ';'.join(
            map(
                lambda child: json.dumps(child['children'], indent=4),
                summary.profile['children'],
            )
        )
    )

    return records


def query_profile2(driver: neo4j.Driver) -> list[Any]:
    summary: neo4j.ResultSummary
    records, summary, _ = driver.execute_query(
        """
        MATCH (n) RETURN n
        """,
        database_=REACTOME_DATABASE,
    )

    # print(json.dumps(summary.profile, indent=4))
    print(
        ';'.join(
            map(
                lambda child: json.dumps(child['children'], indent=4),
                summary.profile['children'],
            )
        )
    )

    return records


# neo4j MERGE
# noe4j explodes at depth 12?

if __name__ == '__main__':
    with GraphDatabase.driver(
        uri=NEO4J_URL_REACTOME, auth=AUTH, database=REACTOME_DATABASE
    ) as driver:
        try:
            driver.verify_connectivity()

            for query in [query, query13]:
                elapsed = time.time()
                records = query(driver)
                print(len(records))
                elapsed = time.time() - elapsed
                print(elapsed)

        except Exception as exception:
            print(exception)
            sys.exit(1)
