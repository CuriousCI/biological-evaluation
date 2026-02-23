#import "lib.typ": *

== Model definition 1

The roles a physical entity can have in a reaction are denoted with
$ roles = {input, output, enzyme, activator, inhibitor} $

To simplify notation, let
- $roles_rentity = {input, output}$
- $roles_rmodifier = {enzyme, activator, inhibitor}$
- $roles_reagent = {input, enzyme, activator, inhibitor}$

\

#definition[Biochemical network][
    A biochemical network $network$ is a graph $(nodes, edges, stoichiometry)$
    where

    - $nodes = entities union.sq reactions union.sq compartments$ with

        - $entities$ the set of physical entities of the biochemical network

        - $reactions$ the set of reactions of the biochemical network

        - $compartments$ the set of compartments in which the physical entities
            of the network are located


    - $edges = edges_compartments union.sq edges_reactions$ denotes the edges of
        the graph, where

        - $edges_compartments subset.eq entities times compartments$

        - $edges_reactions subset.eq entities times reactions times roles$

    For notational purposes let
    $edges_reactions^role = { (entity, reaction) | (entity, reaction, role) in edges_reactions }$
    denote the edges between entites and reactions of type $role$.

    - $stoichiometry = (stoichiometry_input, stoichiometry_output)$ denotes the
        stoichiometries of the reactions
        - $stoichiometry_role : edges_reactions^role -> NN_1$
            where $role in roles_rentity$

    Let $rcomponents$ denote the components of each reaction
    $
        rcomponents : reactions -> entities union (entities times roles) union (entities times roles_rentity times NN_1)
    $

    $
        rcomponents (reaction) & = { entity | (entity, reaction) in edges_reactions^role } \
        & union { (entity, role) | (entity, reaction) in edges_reactions^role } \
        & union { (entity, role, stoichiometry) | role in roles_rentity and (entity, reaction) in edges_reactions^role and stoichiometry_role (entity, reaction) = stoichiometry }
    $
]

#definition[Problem definition][
    Let $scope = (entities_interest, entities_boundary, D)$ be a problem
    definition where

    - $entities_interest$ is the set of physical entities of interest, from
        which the biochemical network associated to the problem definition is
        defined

    - $entities_boundary$ is the set of physical entities whose input reactions
        can be excluded in the generation of the biochemical network

    - $D = (entities_data, v_data)$ where:
        - $entities_data$ is the set of physical entities for which a target
            value is known
        - $v_data : entities_data -> [0, 1]$ is the target value at equilibrium
            for the physical entity
]

#definition[Problem definition closure][
    Given a problem definition $scope$ and the biochemical network
    $network = (nodes, edges, stoichiometry)$, let
    $network' = (nodes', edges', stoichiometry')$ be the closure of $scope$ in
    the network $network$ where:

    $
        forall entity, reaction quad (entity in entities_interest and (entity, reaction) in edges_reactions^output) => reaction in reactions'
    $

    $
        & forall entity, reaction_1, reaction_2 \
        & quad
        entity in.not entities_boundary and \
        & quad
        reaction_1 in reactions' and \
        & quad
        (entity, reaction) in edges_reactions^input union edges_reactions^enzyme union edges_reactions^activator union edges_reactions^inhibitor and \
        & quad
        (entity, output) in rcomponents(reaction_2) \
        & quad quad
        => \
        & quad quad quad reaction_2 in reactions'
        // {entity} times roles_reagent inter rcomponents(reaction_1) != emptyset and \
    $

    - $entities' = { entity | exists reaction space reaction in reactions' and entity in rcomponents(reaction) }$

    - $edges'_reactions = { (entity, reaction, role) | reaction in reactions' and (entity, reaction) in edges_reactions^role}$

    - $stoichiometry'_role (entity, reaction) = stoichiometry_role (entity, reaction)$
        where
        $entity in entities' and reaction in reactions' and role in roles_rentity$
]

#definition[Restructured biochemical network][
    Given a network $network = (nodes, edges, stoichiometry)$ let
    $network' = (nodes', edges', stoichiometry')$ be the restructured version of
    $network$ for SBML where

    $
        ecomponents : entities times roles & -> reactions \
        (entity, role) & |-> { reaction | (entity, reaction) in edges_reactions^role}
    $

    - $reactions' = reactions union.sq reactions_boundaryincoming union.sq reactions_boundaryoutgoing$
        where
        - $reactions_boundaryincoming = { reaction_entity | ecomponents (entity, output) = emptyset and ecomponents (entity, input) != emptyset }$
        - $reactions_boundaryoutgoing = { reaction_entity | ecomponents (entity, output) != emptyset and ecomponents (entity, input) = emptyset }$

    - $edges'_reactions = edges_reactions union.sq edges_reactions^boundaryincoming union.sq edges_reactions^boundaryoutgoing$
        - $edges_reactions^boundaryincoming = { (entity, reaction, output) | reaction_entity in reactions_boundaryincoming }$
        - $edges_reactions^boundaryoutgoing = { (entity, reaction, input) | reaction_entity in reactions_boundaryoutgoing }$

    $
        stoichiometry'_output (entity, reaction) = cases(
            stoichiometry_output (entity, reaction) quad & "if " reaction in reactions,
            1 quad & "if " reaction_entity in reactions_boundaryincoming
        )
    $

    $
        stoichiometry'_input (entity, reaction) = cases(
            stoichiometry_input (entity, reaction) quad & "if " reaction in reactions,
            1 quad & "if " reaction_entity in reactions_boundaryoutgoing
        )
    $

    $
        reactions' & = reactions \
        & union { (entity, output, 1) | ecomponents (entity, output) = emptyset and ecomponents (entity, input) != emptyset } \
        & union { (entity, input, 1) | ecomponents (entity, output) != emptyset and ecomponents (entity, input) = emptyset }
    $

    // - $
    //         rcomponents' (reaction) = cases(
    //             rcomponents (reaction) quad & "if " reaction in reactions,
    //             {entity, (entity, output), (entity, output, 1)}
    //         )
    //     $

    // $
    //     edges'_reactions (reaction) = cases(
    //         edges_reactions (reaction) quad & "if " reaction in reactions,
    //         {(entity, output, 1)} quad & "if " reaction_entity in reactions_frontierinput,
    //         {(entity, input, 1)} quad & "if " reaction_entity in reactions_frontieroutput,
    //     )
    // $
]

// $network' = (entities', reactions', compartments, edges(reactions), edges(compartments))$

// - $P = P union P_"compartments"$
//     - $P_"compartments" = { p_c | (p, c) in E_C and (exists c' space c' != c and (p, c) in E_C)}$
//         adds a new entity for each compartment an entity is related to; then
//         a fast reaction that
// TODO: 2 step
// - simbolo di funzione che prendono una specie e danno le reazioni di cui sono reagenti
// - definisci l'insieme usando i simboli di funzione
// - data una specie p definisce
// forall p t.c. XYZ definisco una reazione fatta così

// - $R' = R union R_"input" union R_"output" union R_"compartments"$
//     - $R_"input" = { r_p | p in P and (not exists r' space (p, r') in E_(R,"product")) and (exists r' space (p, r') in E_(R,"reactant") ) }$
//     - $R_"output" = { r_p | p in P and (not exists r' space (p, r') in E_(R,"reactant")) and (exists r' space (p, r') in E_(R,"product") ) }$
//     - $R_"compartments" = { r_(p, c, c') | p_c != p_c' and p_c in P_"compartments" and p_c' in P_"compartments"}$
//     - $R'_"reversible" = R_"reversible" union R_"compartments"$
// - $E'_R = E_R union E_"input" union E_"output"$
//     - $E_"input" = { (p, r, "product") | r_p in R_"input" }$
//     - $E_"output" = { (p, r, "reactant") | r_p in R_"output" }$
//
// - $E'_C = E_C union E_(C,2)$
//     - $E_(C, 2) = { (p, c) | p_c in P_"compartments"}$
//
// $
//     nu'_"reactant" (p, r) = cases(
//         nu_"reactant" (p, r) quad & "if " (p, r) in E_(R, "reactant"),
//         1 quad & "otherwise"
//     )
// $
// $
//     nu'_"product" (p, r) = cases(
//         nu_"product" (p, r) quad & "if " (p, r) in E_(R, "reactant"),
//         1 quad & "otherwise"
//     )
// $
