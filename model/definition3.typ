#import "lib.typ": *

== Model definition 3

// The roles a physical entity can have in a reaction are denoted with

Let $roles = {input, output, enzyme, activator, inhibitor}$ be the set of roles
an entity can undertake in a reaction. In order to simplify notation, the
following subsets of $roles$ shall be defined:
- $roles_rstoichiometric = { input, output }$ the set of stoichiometric roles
- $roles_rmodifiers = { enzyme, activator, inhibitor }$ the set of modifier
    roles
- $roles_rreagents = { input } union roles_rmodifiers$ the set of reagent
    (input) roles


#definition[Biochemical network][
    A biochemical network $network = (nodes, edges, stoichiometry)$ is a
    semi-quantitative graph model where

    - $nodes = entities union.sq reactions union.sq compartments union.sq pathways$

        - $entities$ is the set of physical entities

        - $reactions$ is the set of reactions

        - $compartments$ is the set of compartments in which the entities are
            located

        - $pathways$ is the set of pathways in which the reactions are organized


    - $edges = edges_reactions union.sq edges_compartments union.sq edges_pathways$

        - $edges_reactions = edges_rstoichiometric union.sq edges_rmodifiers$

            - $edges_rstoichiometric subset.eq entities times reactions times roles_rstoichiometric$

            - $edges_rmodifiers subset.eq entities times reactions times roles_rmodifiers$

        - $edges_compartments subset.eq entities times compartments$

        - $edges_pathways subset.eq (reactions union pathways) times pathways$


    - $stoichiometry : edges_rstoichiometric -> NN_1$ is the stoichiometry
        function
]

// TODO: find a better name
#definition["Kernel"][
    Let
    $scope = (entities_interest, entities_boundary, reactions_excluded, pathways_interest)$
    denote a problem definition used to compute a fixed point within the
    Reactome biochemical network, where

    // - $entities = entities_interest union.sq entities_frontier$ //  union.sq entities_excluded
    // is the set of physical entities of the problem definition

    - $entities_interest$ is the set of entities whose fixed point must be
        computed

    - $entities_boundary$ is the set of entities that can be included in the
        fixed point, but whose reactions must not be expanded

    - $reactions_excluded$ is the set of reactions that must not be included in
        the reachability

    // - $entities_excluded$ is the set of entities excluded from the fixed
    //     point

    - $pathways_interest$ is the set of pathways whose reactions can be included
        in the fixed point

]


// is the set of physical entities of interest, from
//     which the sub-network associated to the problem definition

// is the set of physical entities whose input
//     reactions can be excluded in the generation of the biochemical
//     network

// is the set of physical entities which must not
//     appear in the sub-network associated to the problem definition


#definition[Kernel reachable reactions][
    Given a problem definition
    $scope = (entities_interest, entities_boundary, reactions_excluded, pathways_interest)$
    and the biochemical network $network = (nodes, edges, stoichiometry)$, let
    $network' = (nodes', edges', stoichiometry')$ be the biochemical network
    reachable from $scope$ in $network$.

    Let $pcomponents : pathways -> powerset(reactions)$ denote the set of
    reactions contained in the hierarhical structure of a certain pathway,
    where, given a pathway $pathway$, $pcomponents(pathway)$ is defined as

    $
        pcomponents (pathway) = & { reaction | (reaction, pathway) in edges_pathways } \
        & union { pcomponents(pathway') | (pathway', pathway) in edges_pathways }
    $

    Let $reactions_interest$ denote the set of reactions that can be considered
    for reachability of $scope$. All other reactions are not reachable from
    $scope$.

    // that can be included in
    // the fixed point associated to $problem$. All other reactions $network$ are
    // excluded. // from the fixed point.

    #{
        set math.equation(numbering: none)
        $
            reactions_interest = & { reaction | exists pathway space space pathway in pathways_interest and reaction in pcomponents(pathway)} - reactions_excluded
        $
    }
    // & - { reaction | exists entity, role space space entity in entities_excluded and (entity, reaction, role) in edges_reactions }

    // #separator

    Let $reactions_reachable$ be the set of reactions reachable from
    $entities_interest$ in the problem definition $scope$ within the biochemical
    network $network$.

    #separator

    $
        & forall entity, reaction \
        & quad entity in entities_interest and reaction in reactions_interest and (entity, reaction, output) in edges_reactions \
        & quad quad => reaction in reactions_reachable
    $

    #separator

    $
        & forall entity, reaction_1, reaction_2 \
        & quad
        entity in.not entities_boundary and \
        & quad
        reaction_1 in reactions_reachable and \
        & quad reaction_2 in reactions_interest and \
        & quad
        (exists role space role in roles_rreagents and (entity, reaction_1, role) in edges_reactions ) and \
        & quad
        (entity, reaction_2, output) in edges_reactions \
        & quad quad
        => reaction_2 in reactions_reachable
    $

    #separator

    - $reactions' = reactions_reachable$

    - $entities' = { entity | exists reaction, role space space reaction in reactions' and (entity, reaction, role) in edges_reactions }$

    - $compartments' = { compartment | exists entity space space entity in entities' and (entity, compartment) in edges_compartments }$

    - $edges'_reactions = { (entity, reaction, role) | reaction in reactions' and (entity, reaction, role) in edges_reactions }$

    - $edges'_compartments = { (entity, compartment) | entity in entities' and (entity, compartment) in edges_compartments }$


    - $stoichiometry' (entity, reaction, role) = stoichiometry(entity, reaction, role)$
        where
        $(entity, reaction, role) in edges'_rstoichiometric$

    // TODO: should I put pathways here?
]

#TODO[
    Theorem: if a reaction is in $reactions_reachable$ then its reverse is also
    in $reactions_reachable$.

    Define the "reverse" reaction of a reaction (a reaction with the same
    modifiers, but inverted $input$ and $output$ roles, with the same
    stoichiometries).

    It requires that a reaction and its reverse share pathways
]

#definition[Simulable model][
    A simulable model $simulable$ is a tuple
    $(entities, reactions, compartments, f_compartments, f_reactions)$ where

    - $entities$ is the set of entities of the model
    - $reactions$ is the set of reactions of the model
    - $compartments$ is the set of compartments of the model

    - $f_compartments : entities -> compartments$ denotes the compartment
        associated to each entity
    - $f_reactions : reactions -> powerset((entities times roles_rstoichiometric times NN_1) union (entities times roles_rmodifiers))$

    // #TODO[
    //     $f_reactions$ NON È CORRETTA (per come è definita ora ritorna un solo
    //     oggetto, ma l'obiettivo sarebbe ritornare un insieme di oggetti, in
    //     questo modo una reazione è interamente definita dai suoi componenti)
    // ]
]



#definition[Simulable model of a biochemical network][
    Given a network $network = (nodes, edges, stoichiometry)$ let
    $simulable = (entities', reactions', compartments', f_compartments, f_reactions)$
    be the simulable model associated to the biochemical network $network$.

    // - $D = (entities_data, v_data)$ where:
    //     - $entities_data$ is the set of physical entities for which a target
    //         value is known
    //     - $v_data : entities_data -> [0, 1]$ is the target value at equilibrium
    //         for the physical entity

    - $entities' = entities$

    - $compartments' = {compartment_entity | entity in entities' and compartment_entity = { compartment | (entity, compartment) in edges_compartments }}$
    #v(5pt)
    $
        f_compartments : entities & -> compartments \
                           entity & |-> compartment_entity
    $


    Let $ecomponents : entities times roles -> reactions$ be the function that
    gives the set of reactions in which entity $entity$ is involved with role
    $role$ in the biochemical network $network$.

    $
        ecomponents(entity, role) = {reaction | (entity, reaction, role) in edges_reactions}
    $

    #separator

    $
        q: reactions & -> powerset((entities times roles_rstoichiometric times NN_1) union (entities times roles_rmodifiers)) \
        q (reaction) & |-> { (entity, role, stoichiometry) | (entity, reaction, role) in edges_rstoichiometric and stoichiometry(entity, reaction) = stoichiometry } \
        & #hide($|->$) union { (entity, role) | (entity, reaction, role) in edges_rmodifiers }
    $

    #separator

    // $
    //     ecomponents : entities times roles & -> reactions \
    //     (entity, role) & |-> { reaction | (entity, reaction, role) in edges_reactions}
    // $


    - $reactions' = reactions union.sq reactions_boundaryincoming union.sq reactions_boundaryoutgoing$
        - $reactions_boundaryincoming = { reaction_entity | ecomponents (entity, input) = emptyset and ecomponents (entity, output) != emptyset }$
        - $reactions_boundaryoutgoing = { reaction_entity | ecomponents (entity, input) != emptyset and ecomponents (entity, output) = emptyset }$

    $
        f_reactions (reaction) = cases(
            q(reaction) quad & "if " reaction in reactions,
            {(entity, output, 1)} quad & "if " reaction_entity in reactions_boundaryincoming,
            {(entity, input, 1)} quad & "if " reaction_entity in reactions_boundaryoutgoing,
        )
    $

    // - $reactions' = reactions union.sq reactions_frontierinput union.sq reactions_frontieroutput$
    //     where
    //     - $reactions_frontierinput = { reaction_entity | ecomponents (entity, input) = emptyset and ecomponents (entity, output) != emptyset }$
    //     - $reactions_frontieroutput = { reaction_entity | ecomponents (entity, input) != emptyset and ecomponents (entity, output) = emptyset }$
    //
    // - $edges'_reactions = edges_reactions union.sq edges_reactions^frontierinput union.sq edges_reactions^frontieroutput$
    //     - $edges_reactions^frontierinput = { (entity, reaction, output) | reaction_entity in reactions_frontierinput }$
    //     - $edges_reactions^frontieroutput = { (entity, reaction, input) | reaction_entity in reactions_frontieroutput }$
    //
    // $
    //     stoichiometry' (entity, reaction, role) = cases(
    //         stoichiometry (entity, reaction, role) quad & "if " (entity, reaction, role) in edges_reactions,
    //         1 quad & "if " (entity, reaction, role) in edges_reactions^frontierinput union edges_reactions^frontieroutput
    //     )
    // $

    // #{
    //     set math.equation(numbering: none)
    //     $
    //         reactions' & = reactions \
    //         & union { { (entity, output, 1) } | ecomponents (entity, output) = emptyset and ecomponents (entity, input) != emptyset } \
    //         & union { { (entity, input, 1) } | ecomponents (entity, output) != emptyset and ecomponents (entity, input) = emptyset } \
    //         // & union { rcomponents(reaction) | reaction }
    //     $
    // }
]

#align(center)[
    #box(width: 150%, ```python
    def restructure_reaction(reaction: Reaction) -> set[Reaction]:
      if (all reaction.components are not EntitySet):
        return { kinetic_law(reaction) }

      result = {}
      for component in reaction.components:
        if component is EntitySet:
          for ...? in ...?:
            result = result union {restructure_reaction(reaction with ...? instead of component)}

      return result
    ```)
]

// are there reactions without pathways

// - $stoichiometry'_role (entity, reaction) = stoichiometry_role (entity, reaction)$
//     where
//     $entity in entities' and reaction in reactions' and role in roles_rentity$

// $
//     stoichiometry'_input (entity, reaction) = cases(
//         stoichiometry_input (entity, reaction) quad & "if " reaction in reactions,
//         1 quad & "if " reaction_entity in reactions_frontieroutput
//     )
// $

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

// To simplify notation
// denote either modifiers or
//     reactants in a reaction

// - $roles_reagent = {input, enzyme, activator, inhibitor}$
// \


// For notational purposes let
// $edges_reactions^role = { (entity, reaction) | (entity, reaction, role) in edges_reactions }$
// denote the edges between entites and reactions of type $role$.
//
// - $stoichiometry = (stoichiometry_input, stoichiometry_output)$ denotes the
//     stoichiometries of the reactions
//     - $stoichiometry_role : edges_reactions^role -> NN_1$
//         where $role in roles_rentity$
//
// Let $rcomponents$ denote the components of each reaction
// $
//     rcomponents : reactions -> entities union (entities times roles) union (entities times roles_rentity times NN_1)
// $
//
// $
//     rcomponents (reaction) & = { entity | (entity, reaction) in edges_reactions^role } \
//     & union { (entity, role) | (entity, reaction) in edges_reactions^role } \
//     & union { (entity, role, stoichiometry) | role in roles_rentity and (entity, reaction) in edges_reactions^role and stoichiometry_role (entity, reaction) = stoichiometry }
// $

// Let $problem = (entities_interest, entities_frontier, D)$ be a problem
// definition where
// $
//     & forall entity, reaction \
//     & quad entity in entities_interest and \
//     & quad reaction in reactions_interest and \
//     & quad (entity, reaction, output) in edges_reactions \
//     & quad quad => reaction in reactions_closure
// $


// & quad (exists pathway space space pathway in pathways and reaction in pcomponents(pathway)) and \
// & quad (not exists entity', role space space entity' in entities_excluded and (entity', reaction, role) in edges_reactions) \

// ( (entity, reaction_1, input) in edges_reactions or exists role space (entity, reaction_1, role) in edges_rmodifiers) and \
// & quad (exists pathway space space pathway in pathways and reaction_2 in pcomponents(pathway)) and \
// & quad (not exists entity', role space space entity' in entities_excluded and (entity', reaction_2, role) in edges_reactions) \


// - $stoichiometry' : edges'_rentities -> NN_1$


// - $edges'_reactions = { (entity, reaction, role) | reaction in reactions' and (entity, reaction) in edges_reactions^role}$

// $
//     and not exists entity, role space (entity in entities_excluded and (entity, reaction, role) in edges_rentities)
// $


