// $
//     v_r = f_regulation^r dot.c
//     (
//         k_+^r product_((p,input,nu) \ in \ f_reactions (r)) [p]^nu
//         - k_-^r product_((p,output,nu) \ in \ f_reactions (r)) [p]^nu
//     )
// $

// TODO: at least one per entity
// text(red, $R$)
// - $R = ({p_1, p_2, p_3}, {p_4, p_5, p_6}, nu_prod, nu_reactant)$

// TODO: , cal(P)
// - $cal(P)$ is the set of pathways in which the fixed point is limited
// #note[should I handle here other options, like "ignore EntitySets"?]
// class BiologicalScenarioDefinition:
//     physical_entities: set[PhysicalEntity]
//     pathways: set[Pathway]
//     constraints: PartialOrder[PhysicalEntity]
//     max_depth: IntGTZ | None = field(default=None)
//     excluded_physical_entities: set[PhysicalEntity] = field(default_factory=set)
//     default_kinetic_law: KineticLaw = field(default=law_of_mass_action)
//     kinetic_laws: dict[ReactionLikeEvent, KineticLaw] = field(
//         default_factory=dict
//     )

// In order to build a dynamic model of a biochemical network, its kinetics must be
// described with rate laws for the reactions.
// #pagebreak()
// $G = (V, E)$
// TODO: handle sets
// $E_C$

// TODO: diventa un ipergrafo orientato
// le reazioni sono iperachi
// le specie e i compartimenti sono nodi
// TODO: https://en.wikipedia.org/wiki/Hypergraph
// coppia di due sottoinsiemi, code e punte
// TODO: simboli di funzione: chi sono i prodotti / reattanti etc...?


// TODO: brutale, una MEGA xi che data una reazione mi da tutti i suoi dati!

// #definition[Biochemical network][
//     A biochemical network $network$ is a tuple
//     $(entities, reactions, compartments, nu, mu, xi)$
//     where
//
//     - $entities$ is the set of physical entities in the biochemical network; to
//         be consisten with Reactome a physical entity models the instance of a
//         chemical entity in a compartment
//
//     - $reactions$ is the set of reactions in the biochemical network
//
//
//     - $roles() = roles(subset: stoichiometric) union.sq roles(subset: modifiers)$
//         denotes the roles a physical entity can have in a reaction
//
//         - $roles(subset: stoichiometric) = {input, output}$
//
//         - $roles(subset: modifiers) = {enzyme, activator, inhibitor}$
//
//     - $nu : reactions -> (powerset(entities times roles(subset: stoichiometric)) -> NN_1)$
//         denotes the reactants and products of each reaction, along with their
//         stoichiometries
//
//     - $mu : reactions -> powerset(entities times roles(subset: modifiers))$
//         denotes the modifiers of each reaction
//
//     - $compartments$ is the set of compartments in which the physical entities
//         of the network are located
//
//         - $xi : entities -> powerset(compartments)$ denotes the compartments
//             each physical entity can move into
//
//
//
//     // - $reactions_reversible subset.eq reactions$ is the subset of reactions
//     //     which are reversible
//
//     // - $edges(reactions + "ciao") : reactions -> (powerset(entities times roles(subset: stoichiometric)) -> NN_1)$
//     //
//     // - $edges(reactions) : reactions -> powerset(entities times roles(subset: modifiers))$
//     //     describes the roles the physical entities have in the reactions, with
//     //     $roles() = roles(subset: stoichiometric) union roles(subset: modifiers)$
//     //     where
//     //     - $roles(subset: stoichiometric) = {input, output}$
//     //     - $roles(subset: modifiers) = {enzyme, activator, inhibitor}$
//
//     // - $edges(reactions) : reactions ->
//     //     (powerset(entities times roles(subset: stoichiometric)) -> NN_1)
//     //     times powerset(entities times roles(subset: modifiers))$ describes the
//     //     roles the physical entities have in the reactions, with
//     //     $roles() = roles(subset: stoichiometric) union roles(subset: modifiers)$
//     //     where
//     //     - $roles(subset: stoichiometric) = {input, output}$
//     //     - $roles(subset: modifiers) = {enzyme, activator, inhibitor}$
//
//     // - $compartments$ is the set of compartments in which the species are located
//     //
//     //     - $edges(compartments) : entities -> powerset(compartments)$ relates
//     //         physical entities with their compartments; each entity must have at
//     //         least one compartments
// ]

// interest intersect excluded  = emptyset()

// $
//     & forall entity, reaction \
//     & quad (entity in entities_interest and reaction in reactions and (entity, reaction, output) in edges(reactions)) => \
//     & quad quad reaction in reactions'
// $

// $
//     & forall entity, reaction_1, reaction_2 \
//     & quad entity in.not entities_excluded and \
//     & quad reaction_1 in reactions' and \
//     & quad {entity} times roles()_upright(I) inter xi(reaction_1) != emptyset and \
//     & quad (entity, output) in xi(reaction_2) \
//     & quad quad => \
//     & quad quad quad reaction_2 in reactions'
// $


// $
//     & forall entity, reaction_1, reaction_2 \
//     & quad ( \
//     & quad quad entity in.not entities_excluded and \
//     & quad quad reaction_1 in reactions' and \
//     & quad quad entity in xi(reaction_1) != emptyset and \
//     & quad quad (entity, output) in xi(reaction_2) \
//     & quad ) => \
//     & quad quad reaction_2 in reactions'
// $

// - $entity in entities_interest => entity in entities'$
// - $(entity in entities' - entities_excluded and exists reaction in reactions, stoichiometry in NN_1 space (entity, output, stoichiometry) in edges(reactions)(reaction)) =>
//     reaction in reactions'$
// - $(reaction in reactions' and exists entity, stoichiometry (entity, input, stoichiometry) in edges(reactions)(reaction)) => entity in entities'$
// - $reaction in reactions' => edges(reactions)' (reaction) = edges(reactions) (reaction)$

// #definition[Biochemical network][
//     A biochemical network $G$ is a tuple
//     $(entities, reactions, compartments, edges(reactions), edges(compartments), stoichiometry)$
//     where
//
//     - $entities$ is the set of physical entities in the biochemical network; to
//         be consisten with `Reactome` a physical entity models the instance of a
//         chemical entity in a compartment
//
//     - $reactions$ is the set of reactions in the biochemical network
//
//         - $reactions_reversible subset.eq reactions$ is the subset of reactions
//             which are reversible
//
//     - $compartments$ is the set of compartments in which the species are located
//
//     - $edges(reactions) subset.eq entities times reactions times roles()$
//         describes the roles the physical entities have in the reactions, with
//         $roles() = {output, input, enzyme, activator, inhibitor}$ as the set of
//         roles
//
//         - given the definition of $edges(reactions)$, let
//             $edges(reactions)^role= {(p, r) | (p, r, role) in E}$ be the
//             selection of $E_R$ over $role in T$
//
//     - $E_C subset.eq P times C$ relates physical entities with their
//         compartments; handles both entities without compartments and entities
//         that spread accross multiple compartments.
//
//     - $nu = (nu_input, nu_output)$
//
//         - $nu_t : E_(R, t) -> NN_1$ with $t in {input, output}$ describes the
//             stoichiometries of the reactants and products of the reactions
// ]

// == Problem definition

// #TODO[
//     The definition below can be definetily improved. Note that some object must
//     be removed too, not only added (e.g. if an entity with multiple compartments
//     is split int two entities, then it must be removed from the graph).
//
//     NOTE: would it be better to write an algorithm here instead of doing this
//     cumbersome definition?
// ]

// TODO: frontiera
