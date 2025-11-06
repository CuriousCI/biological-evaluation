#import "logic.typ": *
#import "math.typ": *

#set text(font: "New Computer Modern", lang: "en", weight: "light", 11pt)
#set page(margin: 1.5in)
#set highlight(fill: luma(240))
#set list(indent: 1em)

#show heading: set block(above: 1.4em, below: 1em)
#show outline.entry.where(level: 1): set text(weight: "bold")
#show outline.entry.where(level: 1): set outline.entry(fill: none)
#show link: it => underline(offset: 2pt, it)
#show raw: set text(font: "LMMonoLt10", lang: "en", size: 11pt)

#let TODO(body) = box(fill: rgb("#f5f5f5"), inset: .75em)[
    #text(font: "LMMonoCaps10", underline[TODO]): #body
]

#page(align(center + horizon, {
    title[AI-driven analysis of molecular pathways]
    [Ionuț Cicio]

    align(bottom, datetime.today().display("[day]/[month]/[year]"))
    link("https://github.com/CuriousCI/bsys-eval")
}))

#page(outline())

#set heading(numbering: "1.1")
#set page(numbering: "1")

#pagebreak()

= Introduction

// The goal of the project is to develop a tool for the analysis of virtual patients.

Given a set of _target species_, a set of constraints on the _target species_
(constraints which model a scenario that could present, for example, in a
disease) and by taking into account all the reactions within a set _target
pathways_ that lead to the production, both directly and indirectly, of the
_target species_, the goal is to find a subset of virtual patients for the
described scenario.

#pagebreak()

= Problem definition

#definition("biological network")[
    A biological network $G$ is a triple $(S, R, E, sigma)$ s.t.
    - $S = U union.sq X union.sq Y$ is the set of species of the biological
        network
        - $U$ is the set of input species
        - $X$ is the set of other species in the network
        - $Y$ is the set of output species
    - $R$ is the set of reactions in the biological network
    // - $E subset.eq S times R = E_"reactant" union.sq E_"product" union.sq E_"pos_modifier" union.sq E_"neg_modifier"$
    - $E subset.eq S times R = E_"reactant" union.sq E_"product" union.sq E_"modifier"$
        is a relationship between species and reactions
    - $sigma : E_"reactant" union E_"product" -> NN^1$
]


#definition("constraint problem")[
    Given a biological network $G = (S, R, E, sigma)$ let $C$ be the constraint
    problem s.t.
]

// #pagebreak()

// Average quantities
//
// - $S' = S union { S_"avg" | s in S}$
// - $S' = G(S')$
// - $K: R -> RR_+^(|R|) = [10^(-6), 10^6]^(|R|)$
//
// // #pagebreak()
//
// // == Parametric problem definition (design?)
//
// - find $k$
//
// - subject to
//     - structural constraints
//         - partial order on $k$ due to
//             - fast/non fast reactions (TODO: as given by Reactome, but how?)
//             #logic[
//                 $
//                     & forall r_f, r_s space.en ( r_f in R_"fast" and r_s in R_"slow" ) -> r_f > r_s
//                 $
//             ]
//             - reaction modifiers (like above?)
//     - for all dynamics of environment
//         - avg concentration of species consistent to knowledge
//
//         $
//             & exists t_0 space.en forall t space.en forall s \
//             & quad (t > t_0 and s in S_"avg") -> s(t) in ["known range"]
//         $

#pagebreak()

// chi sono gli oggetti
// la relazione di "reazione" sugli oggetti
// la relazione transitiva sugli oggetti (chiusura transitiva)

// #box(stroke: .1pt, inset: 1em)[

// - $NN^+ = { n | n in NN and n > 0 }$

// #definition("biological graph")[
//     A _biological graph_ $G$ is a tuple $(S, R, E, F)$ s.t.
//     - $S$ is a set of species
//     - $R$ is a set of reactions
//     - $E : S times R -> NN^+$ // is the stoichiometry
//         - $E = E_"reactant" union E_"product" union E_"modifier"$
//     // - $F : E -> NN^+$ is the stoichiometry of the edges
//     // TODO: exclude modifiers
//     // TODO: do we really need NN^+ for modifiers too?
//     // TODO: also modifiers do not have the inverse order, they just act upon...
// ]

#definition("\"produces\" relation")[
    Given a _biological graph_ $G = (S, R, E, F)$ let $~>$ be a relation s.t.
    - $forall s, r quad (s, r) in "dom"(E_"reactant" union E_"modifier") => s ~> r$
    - $forall s, r quad (s, r) in "dom"(E_"product") => r ~> s$
    - $forall c, c', c'' quad (c ~> c' and c' ~> c'') => c ~> c''$

    $~>$ is the _"produces"_ relation
]

// #definition("model??")[
//     Given a set of target species $S_T$, a set of target pathways $P_T$ and a
//     biological graph $G = (S, E, R)$ s.t.
//     - $S_T subset.eq S$
//     A _model_ is a subgraph $G' = (S', E', R')$ s.t.
//     - $G' subset.eq G$
//     - $S' = { s | exists s_t space s in S and s_t in S_T and s scripts(~>)_G s_t}$
//     - $R' = { r | exists s_t space r in R and s_t in S_T and r scripts(~>)_G s_t}$
//     - $E' = ((s, r, n) | (s, r, n) in E and s in S' and r in R')$
//     // TODO: include target pathways somehow
//     // TODO: show that it is a biological graph?
// ]

#definition("constraint problem on a biological model")[
    Given a model $G$ with target species $S_T$ and target pathways $P_T$ let
    the following be a constraint problem


    - $k : R -> RR^(|R|)$ // k is an assignement of the constants of the reaction, where |R| is the number of constants

    *find* $k$
    *subject to*
    - partial order on $k$ from the structure of the graph
    - partial order on the quantities
    - constraint on enzymes such that
        $
            E + S <->^(k_1, k_(-1)) E S ->^(k_2) E + P
        $
    $
        k_1, k_(-1) >> k_2
    $

    - for all dynamics of the environment
        - average concentration of species consistent to knowledge
        $
            & exists t_0 space.en forall t space.en forall s \
            & quad (t > t_0 and s in S_"avg") -> s(t) in ["known range"]
        $

    Environment: all possible cuts \
    // DO NOT EXPAND OVER IT
    we can have excluded species!
]

// Average quantities
//
// - $S' = S union { S_"avg" | s in S}$
// - $S' = G(S')$
// - $K: R -> RR_+^(|R|) = [10^(-6), 10^6]^(|R|)$

$
    limits(x)^dot = k_+ product_(i = 1)^s S_i^k_i - k_- product_(j = 1)^p P_j^k_j
$

$
    limits(x)^dot = sum_(i = 1)^p "KP"_i - sum_(j = 1)^n "KN"_j
$

$
    & { sum_(j = 1)^n "KN"_j > "KP"_i | i in {1, ..., p} } union \
    & { sum_(i = 1)^n "KP"_i > "KN"_j | j in {1, ..., n} }
$

// OK,
//
// QUindi direi è inutile cercare l'info su fast nel grafo SBML, perché non ci sarà.
//
// Nel frattempo ho ricostruito il discorso che avevo iniziato l'ultima volta.
//
// la tipica equazione per la specie x avrà la forma
//
// der(x) = +KP_1... + KP_2... + ... KP_p - KN_1 ... - KN_2 ...  - ... KN_n
//
// in cui ci sono p termini con segno positivo (derivanti da reazioni che producono x)
// ed n termini con segno negativo (derivanti da reazioni che consumano x).
//
// Ora, minimalmente, i negativi insieme dovrebbero essere in grado di "frenare" qualsiasi positivo da solo, altrimenti la crescita sarebbe inarrestabile.
// Analogamente, i positivi dovrebbero essere in grado di accelerare qualsiasi negativo da solo, altrimenti la decrescita sarebbe inarrestabile.
//
// Quindi dovrebbe essere:
//
// KN_1 +  KN_2 + ... KN_n > KP_1
// KN_1 +  KN_2 + ... KN_n > KP_2
// ....
// KN_1 +  KN_2 + ... KN_n > KP_p
//
// KP_1 + KP_2 + ... KP_p > KN_1
// KP_1 + KP_2 + ... KP_p > KN_2
// ...
// KP_1 + KP_2 + ... KP_p > KN_n
//
// Poiché le equazioni si deducono dal grafo, forse questi vincoli si possono anche dedurre dal grafo.

// HERE


// #pagebreak()

// == Parametric problem definition (design?)

// - find $k$
//
// - subject to
//     - structural constraints
//         - partial order on $k$ due to
//             - fast/non fast reactions (TODO: as given by Reactome, but how?)
//             #logic[
//                 $
//                     & forall r_f, r_s space.en ( r_f in R_"fast" and r_s in R_"slow" ) -> r_f > r_s
//                 $
//             ]
//             - reaction modifiers (like above?)
//     - for all dynamics of environment
//         - avg concentration of species consistent to knowledge
//
//         $
//             & exists t_0 space.en forall t space.en forall s \
//             & quad (t > t_0 and s in S_"avg") -> s(t) in ["known range"]
//         $


// - $forall s, r quad (s in S and r in R and (s, r) in E) => s ~> r$
// - $forall s, r quad (s in S and r in R and (r, s) in E) => r ~> s$


// - $forall m, r quad (m in S and r in R and (r, s) in E) => r ~> s$
// A _model graph_ $G$ is a tuple $(S_T, P_T, S, R, E)$ s.t.
// - $S_T$ is the set of target species
// - $P_T$ is the set of target pathways
// - $S$ is the finite set of species s.t.
//     - $S_T subset.eq S$
//     - $S$ is the set of species in the graph
// - $R$ is the finite set of reactions
// - $E$ is the set edges in the graph (an edge models the involvement of a
//     species in a reaction either as a reactant, a product and a modifier)
//     - $E subset.eq S times R times NN^+$
//     - $E = E_"reactant" union E_"product" union E_"modifier"$
// ]

// #box(stroke: .1pt, inset: 1em)[
//     #definition("transitive closure")[]
// ]

// - $S$ is the set of species in the transitive closure of $S_I$ within the
//     Reactome graph
// - $accent(s, dot) = f(s_1, s_2, s_3, ..., s_n)$

// #definition("SBML model")[
// (to be more precise, the closure within the specified bounds, bounds yet to be defined)
// - $S' = S union {s_"avg" | s in S }$.

// - $R = R_"fast" union R_"slow"$
// - TODO: account for order (edges also have an "order" attribute, I have
//     to check how it impacts the simulation and if it's optional)
// ]

// #pagebreak()
// KN_1 +  KN_2 + ... KN_n > KP_1
// KN_1 +  KN_2 + ... KN_n > KP_2
// ....
// KN_1 +  KN_2 + ... KN_n > KP_p
//
// KP_1 + KP_2 + ... KP_p > KN_1
// KP_1 + KP_2 + ... KP_p > KN_2
// ...
// KP_1 + KP_2 + ... KP_p > KN_n



#pagebreak()

= Data types specification

- #logic[```js \d = /[0-9]/```]
- #logic[```js \w = /[A-Za-z0-9_]/```]

*Math*

#logic[`Natural = Integer >= 0`] \
#logic[`Interval = (lower_bound: Real [0..1], upper_bound: Real [0..1])`] \
#logic[`MathML = String matching`] https://www.w3.org/1998/Math/MathML/ \
#logic[`MathMLBoolean = String` matching `MathML` returning a `Boolean`] \
#logic[`MathMLNumeric = String` matching `MathML` returning a `Number`] \
#logic[`Stoichiometry = Natural > 0`]

*Reactome*

#logic[`ReactomeDbId = Natural`] @reactome-DatabaseObject\
#logic[`StableIdVersion =
    String` matching regex ```js /^R-[A-Z]{3}-\d{1,8}\.\d{1,3}$/```]
@reactome-faq-identifiers \

*SBML*

#logic[`String1 = String` matching regex ```js //```] \
#logic[`SId = String` matching regex ```js /^[a-zA-Z_]\w*$/```]
#ref(
    <sbml>,
    supplement: [Section 3.1.7],
) \
#logic[`UnitSId = String` matching regex ```js /^[a-zA-Z_]\w*$/```]
// #logic[ReactionItem = (SpeciesInstance, Stoichiometry)]
//
// TODO: if PhysicalEntity in Reaction is catalyst, then it cannot be a reactant

== Interval

The #logic[`Interval`] type represents an open interval in $RR$ of the type
$(#logic[lower_bound], #logic[upper_bound])$ s.t.
- when #logic[`lower_bound`] is not defined, it is interpreted as $-infinity$
- when #logic[`upper_bound`] is not defined, it is interpreted as $+infinity$

#constraint(
    highlight(`C.Interval.lower_bound_leq_upper_bound`),
    ```
    forall interval, interval_lower_bound, interval_upper_bound
        (
            Interval(interval) and
            #lower_bound(interval, interval_lower_bound) and
            #upper_bound(interval, interval_upper_bound)
        ) ->
            interval_lower_bound <= interval_upper_bound
    ```,
)

== ReactomeDbId

This is required because not all instances of #logic[DatabaseObject] in Reactome
have a #logic[StableIdVersion], which is the one usually displayed in the
Reactome Pathway Browser @reactome-pathway-browser. Instances of
#logic[DatabaseObject] in Reactome can be identified with a
#logic[ReactomeDbId], but its pattern does not match the definition of
#logic[SId] used to identify objects in SBML.

In order to generate a correct #logic[SBMLDocument] the #logic[ReactomeDbId]
must be converted into a #logic[SId].

== StableIdVersion

The #logic[StableIdVersion] type is useful because is the one usually displayed
in the Reactome Pathway Browser @reactome-pathway-browser. It is useful to
accept it in the description of the models.

#operation(
    [from_stable_id_version],
    parameters: `stable_id_version: StableIdVersion`,
    type: [ReactomeDbId],
    postconditions: [. . .],
)

// The #logic[StableIdVersion] type is used to identify instances of
// #logic[PhysicalEntity] or #logic[Event] in Reactome, but it's pattern does not
// match the definition of #logic[SId] used to identify objects in SBML.
//
// In order to generate a correct #logic[SBMLModel] the #logic[StableId] must be
// converted.
//
// #operation(
//     [StableIdVersion_into_SId],
//     args: [st_id: StableId],
//     type: [SId],
//     post: [. . .],
// )


// post: [ to be defined],
// post: [...],
// In order to generate a correct SBML Model a conversion function must be
// defined.
// #TODO[this could be defined per class, meaning that different classes return a
//     different SId based on the class]

// #pagebreak()

#page(width: auto, height: 841.89pt, margin: 20pt)[
    = _(Reactome)_ UML class diagram
    #align(center + horizon, image("docs-database-object.svg", height: 770pt))
]

= Classes specification pt. 1

== CatalystActivity

The role of #logic[PhysicalEntity] in #logic[_catalyst_activity_entity_] has
multiplicity #logic[0..\*] because _"If a #logic[PhysicalEntity] can enable
multiple molecular functions, a separate #logic[CatalystActivity] instance is
created for each"_ #ref(<data-model-glossary>, supplement: [Page 5]).

An additional constraint is required for active units, because _"If the
#logic[PhysicalEntity] is a #logic[Complex] and a component of the complex
mediates the molecular function, that component should be identified as the
active unit of the #logic[CatalystActivity]."_ #ref(
    <data-model-glossary>,
    supplement: [Page 5],
)

// TODO: does it expand to multiple level complexes?

#constraint(
    highlight(`C.CatalystActivity.active_unit_is_component_of_complex`),
    ```
    forall catalyst_activity, complex, complex_component
        (
            CatalystActivity(catalyst_activity) and
            Complex(complex) and
            PhysicalEntity(complex_component) and
            catalyst_activity_entity(catalyst_activity, complex) and
            catalyst_activity_active_unit(
                catalyst_activity,
                complex_component
            )
        ) ->
            complex_has_component_entity(complex, complex_component)
    ```,
)

== Compartment

// #TODO[move this information to the #logic[_compartment_entity_] association, or
//     to #logic[PreferredCompartmentForSimulation]]

The #logic[Compartment] class has some quirks. In Reactome, the
#logic[Compartment]'s role in the #logic[_compartment_entity_] association has
multiplicity #logic[0..\*]. The problem is that the SBML model requires
#logic[1..1] multiplicity for this association to be simulated.

In Reactome there are currently (TODO: version??) 19 physical entities which
don't have a compartment (see queries/helper.cypher), so this can be easily
solved by just adding a *default compartment* to the SBML model to which these
entities map to.

On the other hand there are 14046 entities which have multiple compartments
(TODO: how many compartments has each exactly?), so the easiest choice right now
is to just pick any of them. For this reason the


// TODO: actual model requires 1..1 compartments for PhysicalEntity
//
// - if no compartment is present just use a default one
// - if multiple compartments are present use whichever you want (for now)

// == DatabaseObjectWithStableId
//
// #constraint(
//     [C.DatabaseObjectWithStableId.either_database_id_or_id_is_defined],
//     ```
//     forall object
//         DatabaseObjectWithStableId(object) ->
//             exists id
//                 database_id(object, id) or id(object, id)
//     ```,
// )

== Pathway

The instances of #logic[Pathway] are organized hierarchically, i.e. all the
signaling pathways are collected under the Signal Transduction top level
#logic[Pathway] (#logic[StableIdVersion] R-HSA-162582.13). This allows to easily
extract a subset of reactions by specifying the _target pathways_ in a model and
taking into consideration only the reactions which are included, both directly
or indirectly, in that pathway (see the #logic[included_reactions()] operation).

There are about 34 top level pathways.

#operation(
    `included_reactions`,
    type: `ReactionLikeEvent [0..*]`,
    // prec: ```
    // ```,
    postconditions: ```
    result =
        { reaction |
            ReactionLikeEvent(reaction) and
            pathway_has_event(this, reaction) }
        $union$
        { reaction | exists pathway
            Pathway(pathway) and
            pathway_has_event(this, pathway) and
            #included_reactions(pathway, reaction) }
    ```,
)


#pagebreak()

== PhysicalEntity

// #TODO[how should I handle complexes here?]

The set of reactions which produce #logic[this] is needed to determine the
transitive closure of the _target entities_.

#operation(
    [directly_produced_by],
    type: [ReactionLikeEvent [0..\*]],
    postconditions: ```
    result = { reaction |
        ReactionLikeEvent(reaction) and output(this, reaction)
    }
    ```,
)

The set of instances of #logic[DatabaseObject] which are directly or indirectly
involved in the production of #logic[this].

#operation(
    [produced_by],
    type: [DatabaseObject [0..\*]],
    postconditions: ```
    result =
        { this } $union$
        { reaction | directly_produced_by(this, reaction) } $union$
        { object | exists reaction, reaction_input
            directly_produced_by(this, reaction) and
            (
                *input*(reaction, reaction_input) or
                (exists catalyst_activity
                    CatalystActivity(catalyst_activity) and
                    *catalyzed_event*(
                        catalyst_activity,
                        reaction
                    ) and
                    *catalyst_activity_entity*(
                        catalyst_activity,
                        reaction_input
                    )
                )
            ) and
            produced_by(reaction_input, object)
        }

    ```,
)

// #TODO[handle active units too]

// #page(width: auto, height: 841.89pt, margin: 20pt)[
//     = _(Biological scenario definition)_ UML class diagram
//     // #align(center + horizon, image("docs-2.svg", height: 770pt))
//     #align(center + horizon, image(
//         "docs-biological-scenario-definition.svg",
//         height: 770pt,
//     ))
// ]

#page(
    flipped: true,
    width: auto,
    height: auto,
    align(center + horizon, image("docs-biological-scenario-definition.svg")),
)

// = _(Biological scenario definition)_ UML class diagram



= Classes specification pt. 2

// == CompartmentDefinition
//
// #constraint(
//     [C.CompartmentDefinition.entities_have_compartment_listed],
//     ```
//     forall compartment_definition, compartment, species, physical_entity
//         (
//             CompartmentDefinition(compartment_instance) and
//             Compartment(compartment) and
//             SpeciesDefinition(species) and
//             PhysicalEntity(physical_entity) and
//             *compartment_definition*(compartment, compartment_instance) and
//             *compartment_species*(compartment_definition, species) and
//             *physical_entity_species*(physical_entity, species)
//         ) ->
//             *compartment_entity*(compartment, physical_entity)
//     ```,
// )
//
// #TODO[what happens if it a PhysicalEntity has some compartments?]

== BiologicalScenarioDefinition

The following operation finds the transitive closure of the _target entities_
specified in the scenario, by including only reactions within the _target
pathways_ if necessary.

#operation(
    [model_objects],
    type: [DatabaseObject [1..\*]],
    postconditions: ```
    result = { object | exists entity
        PhysicalEntity(entity) and
        DatabaseObject(object) and
        target_physical_entity(this, entity) and
        #produced_by(entity, object) and
        (
            not RestrictedDefinition(this) or
            exists pathway, reaction
                Pathway(pathway) and
                ReactionLikeEvent(reaction) and
                included_reactions(pathway, reaction) and
                (
                    object = reaction or
                    entity_reaction(object, reaction) or
                    catalyzed_reaction(object, reaction)
                )
        )
    }
    ```,
)

#pagebreak()

== ModelInstance

#constraint(
    [C.ModelInstance.no_local_parameters_without_value],
    ```
    forall model_instance, model, reaction, kinetic_law, local_parameter
        (
            ModelInstance(model_instance) and
            Model(model) and
            ReactionDefinition(reaction) and
            KineticLaw(kinetic_law) and
            LocalParameter(local_parameter) and
            *instance_model*(model_instance, model) and
            *model_definition*(model, reaction) and
            *kinetic_law_reaction*(kinetic_law, reaction) and
            *kinetic_law_local_parameter*(kinetic_law, local_parameter) and
            not exists value
                value(local_parameter, value)
        ) ->
            exists local_parameter_assignment
                LocalParameterAssignment(local_parameter_assignment) and
                *model_instance_paramenter*(
                    model_instance,
                    local_parameter_assignment
                ) and
                *assignment_local_paramenter*(
                    local_parameter_assignment,
                    local_parameter
                )

    ```,
)

== SimulatedModelInstance

#operation(
    [is_valid],
    postconditions: `. . .`,
)

== Measurement

#constraint(
    [C.Measurement.species_in_model],
    ```
    forall measurement, model_instance, model, species
        (
            Model(model) and
            SimulatedModelInstance(model_instance) and
            Measurement(measurement) and
            Species(species) and
            *measurement_species*(measurement, species) and
            *measurement_simulation*(measurement, model_instance) and
            *instance_model*(model_instance, model)
        ) ->
            *model_definition*(model, species)

    ```,
)

== UnitDefinition

#ref(<sbml>, supplement: [page 45])

#TODO[better description]

// #pagebreak()

= Use-case diagram

\

#align(center, image("docs-use-case.svg"))

\

#pagebreak()

== "Helper" use-case

#operation(
    [yield_sbml_model],
    parameters: `description: BiologicalScenarioDefinition`,
    type: [(SBMLDocument, )],
    postconditions: [
        TODO:
        - create necessary units (TODO: which? how?)
        - create default CompartmentDefinition
        - create CompartmentDefinition from Compartment
            - convert id to SId
        - create SpeciesDefinition from PhysicalEntity
            - convert id to SId
            - add one of the compartments if the entity has any
            - otherwise assign to default
        - create ReactionDefinition
            - convert id to SId
            - connect products (inputs)
            - connect reactants (outputs)
            - connect modifiers (catalysts)
            - add kinetic law (either manually specified or automatic, like
                LawOfMassAction)
            - add local parameters
        - create constraints
            - i.e. from known_range attribute
        -
    ],
)

#operation(
    [instantiate_model],
    parameters: `model: SBMLDocument`,
    type: [ModelInstance],
    postconditions: [
        TODO:
        - add LocalParameterAssignment for undefined LocalParameters
        - add environment parameters to model (Parameter)
    ],
)

// #pagebreak()

#operation(
    [simulate_model],
    parameters: `instance: ModelInstance`,
    type: [SimulatedModelInstance],
    postconditions: [
        TODO:
        - generate measurements
    ],
)

#pagebreak()

= OpenBox on the Slurm Workload Manager

The HPC cluster at the Computer Science Department has some restrictions in
place, as it's used by many different teams / students and no single user can
request the indefinite usage of the whole cluster for a single job (jobs have a
time limit of 6, 24 or 72 hours based on permissions and resoruces required).

// TODO: somehow store the OpenBox model of a job
// TODO: test both "students" and "multicore" partition to see which is more convenient
The goals of this section are to
- be able to run an OpenBox throught *multiple sessions*
- run *multiple smaller jobs* to increase *fairness* among users, instead of
    running a single big job for the whole simulation
- provide a simple framework that can be used *locally to simulate* executions
    on the cluster

== Analysis

In order to use OpenBox on the cluster in different sessions, it's a good idea
to store the results of the simulations in a database (i.e. PostgreSQL) to
retrieve the data of different session for an overall analysis.

// #page(
//     flipped: true,
//     width: auto,
//     height: auto,
//     align(center + horizon, image("docs-biological-scenario-definition.svg")),
// )
#box(inset: (y: 5pt), align(center, image("./docs-openbox-jobs.svg")))

=== Data types specification

#logic[
    `SlurmJobId = Integer >= 1` \
    `String1 = String` matching regex ```js /^\S$|^\S.*\S$/```
]

#pagebreak()

=== Classes specification

==== Job

#constraint(
    highlight(`C.Job.all_parameters_are_instantiated`),
    ```
    forall job, blackbox, parameter
      (
        Job(job) and
        Blackbox(blackbox) and
        Parameter(parameter) and
        blackbox_job(blackbox, job) and
        blackbox_parameter(blackbox, parameter)
      ) ->
        job_parameter(job, parameter)
    ```,
)

#constraint(
    highlight(`C.Job.continuity_1`),
    ```
    forall job, submit_time, start_time
      (
        Job(job) and
        #submit_time(job, submit_time) and
        #start_time(job, start_time)
      ) ->
        submit_time <= start_time
    ```,
)

#constraint(
    highlight(`C.Job.continuity_2`),
    ```
    forall job, start_time, end_time
      (
        Job(job) and
        #start_time(job, start_time) and
        #end_time(job, end_time)
      ) ->
        start_time <= end_time
    ```,
)

#pagebreak()

== Implementation

Diagram restructuration for PostgreSQL. The SQL code is available in the
`migration.sql` file.

#box(inset: (y: 5pt), align(
    center,
    image("./docs-openbox-jobs-restructuration.svg"),
))

=== Data types definitions

// TODO: I could just use a serial id, but it is nice to have the job_id that can be generated only by slurm, so one can't add a "fake job"
```sql
CREATE DOMAIN String1 AS varchar CHECK(value ~ '^\S$|^\S.*\S$');
CREATE DOMAIN SlurmJobId AS integer CHECK(value >= 1);
```

=== Additional constraints

==== Job

#constraint(
    highlight(`C.Job.end_implies_job_was_scheduled`),
    ```
    forall job, end_time
      (Job(job) and #end_time(job, end_time)) ->
        exists start_time #start_time(job, start_time)
    ```,
)

A result is present if and only if the job ended

#constraint(
    highlight(`C.Job.result_only_on_end_time`),
    ```
    forall job, job_result
      (Job(job) and #result(job, job_result)) ->
        exists end_time #end_time(job, end_time)
    ```,
)

#constraint(
    highlight(`C.Job.end_time_only_on_result`),
    ```
    forall job, end_time
      (Job(job) and #end_time(job, end_time)) ->
        exists job_result #result(job, job_result)
    ```,
)

#page(bibliography("bibliography.bib"))

// #operation(
//     `ultima_manutenzione`,
//     args: `i: Istante`,
//     type: `Manutenzione`,
//     prec: ```
//     exists $m$ manu_auto(this, $m$)
//     ```,
//     post: ```
//     A = {($m$, $i_m$) |
//         manu_auto($m$, this) and
//         #istante($m$, $i_m$)
//     }
//
//     result in $limits("argmax")_((m, i_m) in A) space  i_m$
//     ```,
// )


// == "Study" use-case
//
// #operation(
//     [describe_model],
//     args: [\
//         ~ target_entities: PhysicalEntity [1..\*] \
//         ~ target_pathways: Pathway [0..\*] \
//     ],
//     type: [ModelDescription],
//     prec: ```
//     target species are within the target pathways
//     ```,
//     post: [return a model description],
// )
// #operation(
//     [evaluate],
//     args: [model: Model],
//     type: [VirtualPatient [0..\*]],
//     post: [run algorithm at page 4],
// )

// #TODO[
//     possibly take a configuration file as input, maybe PEtab could be good,
//     otherwise `JSON` should be enough, as everything else is generated
//     automatically from Reactome, the model should work with both StableIDVersion
//     and ReactomeDbId;
//
//     The #logic[TargetPathway]s should be optional. The ExtraConstraints should
//     be optional. The PreferredCompartmentForSimulation could be specified.
// ]
//

// Fixed point
//

// The algorithm
//
// #TODO[better notation here, write something decent to introduce the algorithm]

// TODO: helper functions are described at page 15

// Ignoring the #logic[_inferred_to_ association] there are about 34 top level
// pathways.
// exists events
//     events = { event | *pathway_has_event*(this, reaction) } ->
// #TODO[handle #logic[_inferred_to_]]

// #pagebreak()

// #constraint(
//     [C.Model.objects_have_corresponding_definitions],
//     ```
//     forall model, object
//         (
//             Model(model) and
//             DatabaseObject(object) and
//             model_objects(model, object)
//         ) ->
//             exists definition
//                 Definition(definition) and
//                 *definition_model*(definition, model) and
//                 *database_object_definition*(object, definition)
//     ```,
// )

// == ModelInstance
// #constraint(
//     [C.ModelInstance.every_reaction_has_a_parameter],
//     ```
//     ```,
// )


// #constraint(
//     [C.ModelInstance.reaction_parameters_are_structurally_valid],
//     [],
//     // [. . .],
// )


// == ReactionParameter??
//
// - it must satisfy structural constraints


// #set highlight(fill: rgb("fbf1c788"))
// #set highlight(fill: rgb("fbf1c744"))
// #set highlight(fill: rgb("#f5f5f5"))
// weight: "light",
// size: 10pt,

// #show math.equation: set text(
//     font: "New Computer Modern Math",
//     lang: "en",
//     weight: "light",
//     size: 10pt,
// )

// #logic[
//     ```
//     A = {(nol, costo) | exists ist
//         soc_nol(this, nol) and
//         calcola_costo_totale(nol, costo) and
//         #istante_noleggio(nol, ist) and
//         i <= ist <= f
//     }
//     ```
// ]
