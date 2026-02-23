#import "lib.typ": *

== Model definition 4

Let $roles = {input, output, enzyme, activator, inhibitor}$ be the set of roles
an entity can undertake in a reaction. In order to simplify notation, the
following subsets of $roles$ shall be defined:
- $roles_rstoichiometric = { input, output }$ the set of stoichiometric roles
- $roles_rmodifiers = { enzyme, activator, inhibitor }$ the set of modifier
    roles
- $roles_rreagents = { input } union roles_rmodifiers$ the set of reagent
    (input) roles


#definition[Biological network][
    A biological network
    $network = (nodes, edges, compartmentfunc, stoichiometry)$ is a
    semi-quantitative graph model where

    - $nodes = entities union.sq reactions union.sq compartments$

        - $entities$ is the set of physical entities

        - $reactions$ is the set of reactions

        - $compartments$ is the set of compartments in which the entities are
            located

    - $edges = edges_rstoichiometric union.sq edges_rmodifiers$

        - $edges_rstoichiometric subset.eq entities times reactions times roles_rstoichiometric$

        - $edges_rmodifiers subset.eq entities times reactions times roles_rmodifiers$


    - $compartmentfunc : entities -> compartments$ is a function that assigns to
        each entity a compartment

    - $stoichiometry : edges_rstoichiometric -> NN_1$ is the stoichiometry
        function
]

#definition[Scope][
    Given a biological network $network$ let
    $scope = (entities_interest, entities_boundary, reactions_interest)$
    be the scope of a problem in $network$, where

    - $entities_interest subset.eq entities$ is the set of entities whose
        reachability must be computed

    - $entities_boundary subset.eq entities$ is the set of entities on the
        boundary

    - $reactions_interest subset.eq reactions$ is the set of the only reaction
        that can be included in the reachability of $entities_interest$

]

#definition[Scope reachability][
    Given a biological network $network$ and a scope $scope$ in $network$ let
    $network' = (nodes', edges', compartmentfunc', stoichiometry')$ be the
    subgraph of $network$ reachable from $scope$.

    The set of reactions $reactions'$ in $network'$ is defined inductively as
    follows:

    // TODO: all reactions
    - if $entity$ is an entity and $reaction$ is a reaction where
        $entity in entities_interest and reaction in reactions_interest and (entity, reaction, output) in edges$
        then $reaction in reactions'$
    - if $reaction_1$ is a reaction in $reactions'$, $reaction_2$ is a reaction
        in $reactions_interest$ and there is some entity $entity$ where
        $entity in.not entities_boundary$ and
        ${(entity, reaction_1)} times roles_rreagents inter edges != emptyset$
        and $(entity, reaction_2, output) in edges$ then
        $reaction_2 in reactions'$

    // Let $reactions'$, the set of reactions in $network'$, be defined inductively
    // as follows
    // $
    //     & quad entity in.not entities_boundary and reaction_1 in reactions' and reaction_2 in reactions_interest and \
    //     & quad {(entity, reaction_1)} times roles_rreagents inter edges != emptyset and \
    //     & quad (entity, reaction_2, output) in edges \
    // $

    // #separator

    // $
    //     & forall entity, reaction \
    //     & quad \
    //     & quad quad => reaction in reactions'
    // $

    // #separator

    // $
    //     & forall entity, reaction_1, reaction_2 \
    //     & quad entity in.not entities_boundary and reaction_1 in reactions' and reaction_2 in reactions_interest and \
    //     & quad {(entity, reaction_1)} times roles_rreagents inter edges != emptyset and \
    //     & quad (entity, reaction_2, output) in edges \
    //     & quad quad
    //     => reaction_2 in reactions'
    // $

    // #separator

    - $entities' = { entity | exists reaction, role space space reaction in reactions' and (entity, reaction, role) in edges_reactions }$

    - $compartments'$ is the image of $compartmentfunc$ over $entities'$

    - $edges' = { (entity, reaction, role) | reaction in reactions' and (entity, reaction, role) in edges }$

    - $compartmentfunc'$ is just like $compartmentfunc$ but restricted to
        $entities'$

    - $stoichiometry'$ is just like $stoichiometry$ but restriceted to
        $edges'_rstoichiometric$
]

// #definition[Restructured biological network][
// ]









// #definition[Simulable model][
//     A simulable model $simulable$ is a tuple
//     $(entities, reactions, compartments, f_compartments, f_reactions)$ where
//
//     - $entities$ is the set of entities of the model
//     - $reactions$ is the set of reactions of the model
//     - $compartments$ is the set of compartments of the model
//
//     - $f_compartments : entities -> compartments$ denotes the compartment
//         associated to each entity
//     - $f_reactions : reactions -> powerset((entities times roles_rstoichiometric times NN_1) union (entities times roles_rmodifiers))$
//
//     // #TODO[
//     //     $f_reactions$ NON È CORRETTA (per come è definita ora ritorna un solo
//     //     oggetto, ma l'obiettivo sarebbe ritornare un insieme di oggetti, in
//     //     questo modo una reazione è interamente definita dai suoi componenti)
//     // ]
// ]



// #definition[Simulable model of a biochemical network][
//     Given a network $network = (nodes, edges, stoichiometry)$ let
//     $simulable = (entities', reactions', compartments', f_compartments, f_reactions)$
//     be the simulable model associated to the biochemical network $network$.
//
//     // - $D = (entities_data, v_data)$ where:
//     //     - $entities_data$ is the set of physical entities for which a target
//     //         value is known
//     //     - $v_data : entities_data -> [0, 1]$ is the target value at equilibrium
//     //         for the physical entity
//
//     - $entities' = entities$
//
//     - $compartments' = {compartment_entity | entity in entities' and compartment_entity = { compartment | (entity, compartment) in edges_compartments }}$
//     #v(5pt)
//     $
//         f_compartments : entities & -> compartments \
//                            entity & |-> compartment_entity
//     $
//
//
//     Let $ecomponents : entities times roles -> reactions$ be the function that
//     gives the set of reactions in which entity $entity$ is involved with role
//     $role$ in the biochemical network $network$.
//
//     $
//         ecomponents(entity, role) = {reaction | (entity, reaction, role) in edges_reactions}
//     $
//
//     #separator
//
//     $
//         q: reactions & -> powerset((entities times roles_rstoichiometric times NN_1) union (entities times roles_rmodifiers)) \
//         q (reaction) & |-> { (entity, role, stoichiometry) | (entity, reaction, role) in edges_rstoichiometric and stoichiometry(entity, reaction) = stoichiometry } \
//         & #hide($|->$) union { (entity, role) | (entity, reaction, role) in edges_rmodifiers }
//     $
//
//     #separator
//
//     // $
//     //     ecomponents : entities times roles & -> reactions \
//     //     (entity, role) & |-> { reaction | (entity, reaction, role) in edges_reactions}
//     // $
//
//
//     - $reactions' = reactions union.sq reactions_boundarysource union.sq reactions_boundarysink$
//         - $reactions_boundarysource = { reaction_entity | ecomponents (entity, input) = emptyset and ecomponents (entity, output) != emptyset }$
//         - $reactions_boundarysink = { reaction_entity | ecomponents (entity, input) != emptyset and ecomponents (entity, output) = emptyset }$
//
//     $
//         f_reactions (reaction) = cases(
//             q(reaction) quad & "if " reaction in reactions,
//             {(entity, output, 1)} quad & "if " reaction_entity in reactions_boundarysource,
//             {(entity, input, 1)} quad & "if " reaction_entity in reactions_boundarysink,
//         )
//     $
//
//     // - $reactions' = reactions union.sq reactions_frontierinput union.sq reactions_frontieroutput$
//     //     where
//     //     - $reactions_frontierinput = { reaction_entity | ecomponents (entity, input) = emptyset and ecomponents (entity, output) != emptyset }$
//     //     - $reactions_frontieroutput = { reaction_entity | ecomponents (entity, input) != emptyset and ecomponents (entity, output) = emptyset }$
//     //
//     // - $edges'_reactions = edges_reactions union.sq edges_reactions^frontierinput union.sq edges_reactions^frontieroutput$
//     //     - $edges_reactions^frontierinput = { (entity, reaction, output) | reaction_entity in reactions_frontierinput }$
//     //     - $edges_reactions^frontieroutput = { (entity, reaction, input) | reaction_entity in reactions_frontieroutput }$
//     //
//     // $
//     //     stoichiometry' (entity, reaction, role) = cases(
//     //         stoichiometry (entity, reaction, role) quad & "if " (entity, reaction, role) in edges_reactions,
//     //         1 quad & "if " (entity, reaction, role) in edges_reactions^frontierinput union edges_reactions^frontieroutput
//     //     )
//     // $
//
//     // #{
//     //     set math.equation(numbering: none)
//     //     $
//     //         reactions' & = reactions \
//     //         & union { { (entity, output, 1) } | ecomponents (entity, output) = emptyset and ecomponents (entity, input) != emptyset } \
//     //         & union { { (entity, input, 1) } | ecomponents (entity, output) != emptyset and ecomponents (entity, input) = emptyset } \
//     //         // & union { rcomponents(reaction) | reaction }
//     //     $
//     // }
// ]

// - $reactions' = reactions_reachable$

// & quad (exists role space role in roles_rreagents and (entity, reaction_1, role) in edges_reactions ) and \
// & quad (exists role space role in roles_rreagents and (entity, reaction_1, role) in edges_reactions ) and \
// & quad {entity} times {reaction_1} times roles_rreagents inter edges != emptyset and \

// #TODO[
//     Non basterebbe definire solo $edges', compartmentfunc'$ e
//     $stoichiometry'$ come restrizioni di $$ in base a $reactions'$ per avere in automatico anche
//     $entities'$ e $compartments'$?
// ]

// - $compartments' = compartmentfunc (entities')$
// - $compartments' = { compartment | exists entity space space entity in entities' and (entity, compartment) in edges_compartments }$
// - $compartments' = { compartment | exists entity space space entity in entities' and (entity, compartment) in edges_compartments }$

// - $edges'_reactions = { (entity, reaction, role) | reaction in reactions' and (entity, reaction, role) in edges_reactions }$
//
// - $edges'_compartments = { (entity, compartment) | entity in entities' and (entity, compartment) in edges_compartments }$


// - $stoichiometry' (entity, reaction, role) = stoichiometry(entity, reaction, role)$
//     where
//     $(entity, reaction, role) in edges'_rentities$

// TODO: should I put pathways here?

// Given a problem definition
// $scope = (entities_interest, entities_boundary, reactions_excluded, pathways_interest)$
// and the biochemical network $network = (nodes, edges, stoichiometry)$, let

// $network' = (nodes', edges', stoichiometry')$ be the biochemical network
// reachable from $scope$ in $network$.

// Let $pcomponents : pathways -> powerset(reactions)$ denote the set of
// reactions contained in the hierarhical structure of a certain pathway,
// where, given a pathway $pathway$, $pcomponents(pathway)$ is defined as

// $
//     pcomponents (pathway) = & { reaction | (reaction, pathway) in edges_pathways } \
//     & union { pcomponents(pathway') | (pathway', pathway) in edges_pathways }
// $
//
// Let $reactions_interest$ denote the set of reactions that can be considered
// for reachability of $scope$. All other reactions are not reachable from
// $scope$.

// that can be included in
// the fixed point associated to $problem$. All other reactions $network$ are
// excluded. // from the fixed point.

// #{
//     set math.equation(numbering: none)
//     $
//         reactions_interest = & { reaction | exists pathway space space pathway in pathways_interest and reaction in pcomponents(pathway)} - reactions_excluded
//     $
// }
// & - { reaction | exists entity, role space space entity in entities_excluded and (entity, reaction, role) in edges_reactions }

// #separator



// definition used to compute a fixed point within the
// Reactome biochemical network, where

// - $entities = entities_interest union.sq entities_frontier$ //  union.sq entities_excluded
// is the set of physical entities of the problem definition
// is the set of entities that can be included in the
//     fixed point, but whose reactions must not be expanded

// - $reactions_excluded$ is the set of reactions that must not be included in
//     the reachability

// - $entities_excluded$ is the set of entities excluded from the fixed
//     point

// - $pathways_interest$ is the set of pathways whose reactions can be included
//     in the fixed point


// union.sq edges_compartments union.sq edges_pathways
//
// - $pathways$ is the set of pathways in which the reactions are organized


// - $edges_compartments subset.eq entities times compartments$

// - $edges_pathways subset.eq (reactions union pathways) times pathways$


// Let $reactions_reachable$ be the set of reactions reachable from
// $entities_interest$ in the problem definition $scope$ within the biochemical
// network $network$.

