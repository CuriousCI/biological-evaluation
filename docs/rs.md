// TODO: still not ready to do full-on work on the graph

use std::time::Instant;

use neo4rs::*;


#[tokio::main]
async fn main() {
    let graph = Graph::connect(
        ConfigBuilder::default()
            .uri("neo4j://127.0.0.1:7687")
            .user("neo4j")
            .password("neo4j")
            .db("graph.db")
            .build()
            .unwrap(),
    )
    .await
    .unwrap();

    let time = Instant::now();

    {
        let mut plat_ancestors = graph
            .execute(query(
                "
                MATCH path = (n:PhysicalEntity {dbId: 158754})<-[*..2]-(r) 
                WHERE NOT r:InstanceEdit AND NOT r:MetaDatabaseObject
                RETURN DISTINCT r
                ",
            ))
            .await
            .unwrap();

        if let Ok(Some(row)) = plat_ancestors.next().await {
            let node = row.get::<neo4rs::Node>("r");
            println!("{node:#?}");
        }
    }

    println!("{:?}", time.elapsed());
}

// MATCH path = (n:PhysicalEntity {dbId: 158754})<-[*..2]-(r)
// WHERE NONE( x IN relationships(path)
//     WHERE type(x) IN ['author', 'modified', 'edited', 'authored', 'reviewed', 'created', 'updatedInstance', 'revised'])
// RETURN DISTINCT r

// MATCH path = (n {stIdVersion:'R-HSA-158750.4'})<-[*..1]-(r)
// WHERE NOT r:InstanceEdit AND NOT r:MetaDatabaseObject
// // WHERE NONE( x IN relationships(path)
//    //  WHERE type(x) IN ["author", "modified", "edited", "authored", "reviewed", "created", "updatedInstance", "revised"])
// RETURN r

// if let Ok(len) = row.get::<i64>("len") {
//     println!("{len}")
// }

// MATCH path = (n:PhysicalEntity {dbId: 158754})<-[*..10]-(r)
// RETURN DISTINCT r

// #[derive(Deserialize)]
// struct DatabaseObject {
//     #[serde(rename = "dbId")]
//     db_id: i64,
// }

// #[serde(rename = "displayName")]
// display_name: String,

// let mut result_rows_number = 0;
// let mut distinct_ids = BTreeSet::new();
// NONE(x IN relationships(path) WHERE type(x) IN ['author', 'modified', 'edited', 'authored', 'reviewed', 'created', 'updatedInstance', 'revised'])
// result_rows_number += 1;
// if result_rows_number % 10000 == 0 {
// println!("{result_rows_number} - {}", distinct_ids.len());
// println!("{result_rows_number}")
// }

// "MATCH (n) WHERE n.name CONTAINS 'ATP' RETURN n LIMIT 25",
// if let Ok(id) = row.get::<i64>("r.dbId") {
//     distinct_ids.insert(id);
// }

// let node = row.get::<Node>("r").unwrap();
// match row.get::<DatabaseObject>("n") {
//     Ok(obj) => println!("id: {}", obj.db_id),
//     _ => {
//     }
// }
// println!("{:?}", distinct_ids)
// MATCH (n:PhysicalEntity)<-[*..12]-(r)
// WHERE
//     n.displayName CONTAINS 'PLAT' AND
//     n.speciesName = 'Homo sapiens'
// RETURN r.dbId
