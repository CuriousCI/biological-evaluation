// , and the parameters $epsilon, delta in (0, 1)$ for the evalation of the constraints
// - structural constraints on the reactions' speeds (some reactions are faster
//     than others) #TODO[I still haven't figured out how to get that information
//         out of Reactome, maybe I just have to search more]

// #box(
//     stroke: (y: .25pt),
//     inset: (y: .5em),
//     width: 100%,
//     [ *Algorithm 1*: eval],
// )
// #box(stroke: (bottom: .25pt), inset: (bottom: 1em))[
//     #indent[
//         *input*: $S_T$, set of #logic[PhysicalEntity]\; \
//         *input*: $P_T$, set of target #logic[Pathway]\; \
//         *input*: $C_T$, set of constraints on $S_T$; \
//         *input*: $epsilon, delta in (0, 1)$; \
//         *input*: seed, random seed; \
//
//         #logic[
//             scenario $<-$ biological_scenario_definition($S_T$, $P_T$, $C_T$)] \
//         #logic[(sbml_model, vp_definition, env) $<-$ yield_sbml_model(scenario)]
//         \
//
//         $V$ = $emptyset$ #logic(text(comment-color)[\/\/ set of virtual
//             patients]) \
//         *while* $not$ halt requested *do* \
//         ~ $v$ $<-$ #logic[instantiate(vp_definition)] #logic(text(
//             comment-color,
//         )[\/\/ virtual patient]) \
//         ~ *if* ( \
//         $quad quad$ $v$ satisfies structural constraints $and$ \
//         $quad quad$ #logic[APSG(sbml_model, $v$, env, seed, $epsilon$, $delta$)]
//         \
//         ~ ) *then* \
//         $quad quad$ $V <- V union { v }$; \
//
//         *return* V
//     ]
// ]

// $S$ $union$ constraints($S$) $union$ $C$ \
// env $<-$ define env for model \
// instantiate
// generate
// biological
// model
// instance

// *input*: horizon?
// EAA()
// ~ model_instance $<-$ model + $v$ \
// ~ env_instance $<-$ random instance of env
// *function* fixed_point($S_T$)

// ```
// ~ test
// ```

// Algorithm

// #proj-name is a tool meant to help study the plausability of a given biological system.
// biological
// system.


// Different scnearios can be compared by comparing the subsets of virtual
// patients obtained from those models.


// #proj-name The software shall take as input the species which I want to expand (backwards reachability), it shall somehow take the as input which section of Reactome we want to confine the backwards reachability to (i.e. cutoff species / reactions?).
// Then, it should generate a model from these reactions (how do I encode the model?)
// == Formalities


// The bulk of the logic is in the #logic[yield_sbml_model()] function.
// The idea is to expand a portion of Reactome

// #TODO[this page is far from complete, you can skip to the next one]

// #definition("SBML model")[
//     A _SBML model_ $G$ is a tuple $(S_T, S, R, E)$ s.t.
//     - $S_T$ the set of target species
//     - $S$ is the finite set of species s.t.
//         - $S_T subset.eq S$
//         - $S$ is the transitive closure of $S_I$ within the Reactome graph (to
//             be more precise, the closure within the specified bounds, bounds yet
//             to be defined)
//         - $S' = S union {s_"avg" | s in S }$.
//         - $accent(s, dot) = f(s_1, s_2, s_3, ..., s_n)$
//     - $R$ is the finite set of reactions
//         - $R = R_"fast" union R_"slow"$
//     - $E$ is the set edges in the graph (where and edge goes from a species to a
//         reaction, it also has a stoichiometry)
//         - $E subset.eq S times R times NN^1$
//         - $E = E_"reactant" union E_"product" union E_"modifier"$
//     // - TODO: account for order (edges also have an "order" attribute, I have
//     //     to check how it impacts the simulation and if it's optional)
// ]

// #let proj-name = text(font: "LMMonoCaps10", "Bsys_eval")
// heading(numbering: none, outlined: false, text(size: 2em, proj-name))
//
// proj-name is a tool meant to help study the likelihood of a given scenario in a
// biological system.

// = proj-name
// #TODO[
//     find papers in literature that do similar things; what does this method add
//     compared to other approaches? (i.e. using multiple pathways by generating
//     the fixed point, ensemble of SAs etc...)
// ]
// #TODO[case studies]


// == Requirements
//
// The basic idea behind the software is to take the description of a scenario
// (with _target species_, _target pathways_ and ordering constraints on the
// _target species_), to generate a SBML model with
// - the reactions within the _target pathways_ that, both directly and indirectly,
//     generate the _target species_
// - parameters for the speeds of the reactions
// - constraints on the quantities of the species _(for which the model needs to be
//     simulated)_
