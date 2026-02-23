#import "lib.typ": *

#show: template

#page(align(center + horizon)[
    #title[Mathematical Model & \ Reactome quirks]
    Ionuț Cicio
    #align(bottom, datetime.today().display("[day]/[month]/[year]"))
])


#page(outline())

#pagebreak()

= Kinetic constants estimation

Notation preliminaries:

- $NN_1 = NN - {0}$
- $RR^+ = { x | x in RR and x >= 0 }$

// == On biochemical networks

// #include "definition1.typ"

// #include "definition2.typ"

// #include "definition3.typ"

#include "definition4.typ"

#pagebreak()

// #include "kinetics.typ"

#include "kinetics2.typ"

#pagebreak()

#include "optimize.typ"

// #pagebreak()
//
// #include "q2a.typ"

// #include "reactome.typ"

// ```
// MATCH (reaction:ReactionLikeEvent)
// WHERE reaction.dbId IN []
// OPTIONAL MATCH path1 = (reaction)-[:input|output]->()
// OPTIONAL MATCH path2 = (reaction)-->(:CatalystActivity)-->(:PhysicalEntity)
// OPTIONAL MATCH path3 = (reaction)-->(:Regulation)-->(:PhysicalEntity)
// RETURN path1, path2, path3
// ```

// TODO: on the reversibility of reactions
// TODO: on reactions with same components
// TODO: on the denominator
// TODO: on the constraints and experimental data
// TODO: on entity sets

// TODO: how to check if a reaction is transport or not?

// TODO: I can try to rename "fixed point" to "reachability"
