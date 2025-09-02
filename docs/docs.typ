#import "logics.typ": *

#show (
    figure.where(kind: "constraint").or(figure.where(kind: "operation"))
): it => {
    set align(left)
    it.body
}

#show heading: set block(above: 1.4em, below: 1em)
#show outline.entry.where(level: 1): set text(weight: "bold")
#show outline.entry.where(level: 1): set outline.entry(fill: none)
#show link: it => underline(offset: 2pt, it)
#show math.equation: set text(
    font: "New Computer Modern Math",
    lang: "en",
    weight: "light",
    size: 10pt,
)
#show raw: set text(
    font: "New Computer Modern Math",
    lang: "en",
    weight: "light",
    size: 10pt,
)

#set text(font: "New Computer Modern", lang: "en", weight: "light", 11pt)
#set page(margin: 1.5in)
// #set highlight(fill: rgb("fbf1c744"))
// #set highlight(fill: rgb("#f5f5f5"))
#set highlight(fill: rgb("fbf1c788"))
#set list(indent: 1em)

#let proj-name = text(font: "LMMonoCaps10", "Bsys_eval")
#let TODO(body) = box(fill: rgb("#f5f5f5"), inset: .75em)[
    #text(font: "LMMonoCaps10", underline[TODO]): #body
]

#page(align(center + horizon, {
    heading(numbering: none, outlined: false, text(size: 2em, proj-name))
    [Ionuţ Cicio]

    align(bottom, datetime.today().display("[day]/[month]/[year]"))
    link("https://github.com/CuriousCI/bsys-eval")
}))

#page(outline())

#set heading(numbering: "1.1")
#set page(numbering: "1")

#pagebreak()

= #proj-name

== Introduction

#proj-name is a tool meant to help study the likelihood of a given situation in
a biological system.

Given a set of _target species_, a set of constraints on the _target species_
(constraints which model a situation that could present, for example, in a
disease) and by taking into account all the reactions within a set _target
    pathways_ that lead to the production, both directly and indirectly, of the
_target species_, the goal is to find a subset of virtual patients for the
described situation.

#TODO[
    find papers in literature that do similar things; what does this method add
    compared to other approaches? (i.e. using multiple pathways by generating
    the fixed point, ensemble of SAs etc...)
]

#TODO[add case study, multiple if possible]

#pagebreak()

== Requirements

The basic idea behind the software is to take the description of a model (with
_target species_, _target pathways_, constraints on the _target species_, and
the parameters $epsilon, delta in (0, 1)$ for the evalation of the constraints),
to generate a SBML model with
- all the reactions within the _target pathways_ that, both directly and
    indirectly, generate the _target species_
- parameters for the reactions' speeds
- structural constraints on the reactions' speeds (some reactions are faster
    than others) #TODO[I still haven't figured out how to get that information
        out of Reactome, maybe I just have to search more]
- constraints on the quantities of the entities (for which the model needs to be
    simulated)

#TODO[
    possibly take a configuration file as input, maybe PEtab could be good,
    otherwise `JSON` should be enough, as everything else is generated
    automatically from Reactome, the model should work with both StableIDVersion
    and ReactomeDbId;

    The #logic[TargetPathway]s should be optional. The ExtraConstraints should
    be optional. The PreferredCompartmentForSimulation could be specified.
]


// Fixed point
//

// The algorithm
//
// #TODO[better notation here, write something decent to introduce the algorithm]

#box(
    stroke: (y: .25pt),
    inset: (y: .5em),
    width: 100%,
    [ *Algorithm 1*: eval],
)
#box(stroke: (bottom: .25pt), inset: (bottom: 1em))[
    #indent-block(logic[
        *input*: $S_T$, set of PhysicalEntity; \
        *input*: $C_T$, set of constraints on $S_T$; \
        *input*: $P_I$, set of target pathways; \
        *input*: $epsilon, delta in (0, 1)$; \
        *input*: seed, random seed; \

        $F <-$ fixed_point($S_T$, $P_I$) \
        model $<-$ $(S_T, S(F), R(F), E(F))$ \
        // $S$ $union$ constraints($S$) $union$ $C$ \
        env $<-$ define env for model \
        $V$ = $emptyset$ #logic(text(comment-color)[\/\/ set of virtual
            patients]) \

        *while* $not$ halt requested *do* \
        ~ $v$ $<-$ parameter assignement for model #logic(text(
            comment-color,
        )[\/\/ virtual patient]) \
        ~ *if* $not$ $v$ satisfies structural constraints *then* \
        ~~ *continue*; \
        ~ *if* APSG(model, $v$, env, seed, $epsilon$, $delta$) *then* \
        ~~ $V <- V union { v }$; \
    ])
]

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


// Different situations can be compared by comparing the subsets of virtual
// patients obtained from those models.


// #proj-name The software shall take as input the species which I want to expand (backwards reachability), it shall somehow take the as input which section of Reactome we want to confine the backwards reachability to (i.e. cutoff species / reactions?).
// Then, it should generate a model from these reactions (how do I encode the model?)
// == Formalities

The idea is to expand a portion of Reactome

#TODO[this page is far from complete, you can skip to the next one]

*Definition 1* _(... Model)._ A ... model $G$ is a tuple $(S_T, S, R, E)$ where:

- $S_T$ the set of target species
- $S$ is the finite set of species s.t.
    - $S_T subset.eq S$
    - $S$ is the transitive closure of $S_I$ within the Reactome graph (to be
        more precise, the closure within the specified bounds, bounds yet to be
        defined)
    - $S' = S union {s_"avg" | s in S }$.
    - $accent(s, dot) = f(s_1, s_2, s_3, ..., s_n)$
- $R$ is the finite set of reactions
    - $R = R_"fast" union R_"slow"$
- $E$ is the set edges in the graph (where and edge goes from a species to a
    reaction, it also has a stoichiometry) // DONE: check whether the stoichiometry is in $QQ^+$ or in $NN^+$, it's in NN^+
    - $E subset.eq S times R times NN^1$
    - $E = E_"reactant" union E_"product" union E_"modifier"$
    - TODO: account for order (edges also have an "order" attribute, I have to
        check how it impacts the simulation and if it's optional)

Average quantities

- $S' = S union { S_"avg" | s in S}$
- $S' = G(S')$
- $K: R -> RR_+^(|R|) = [10^(-6), 10^6]^(|R|)$

// #pagebreak()

// == Parametric problem definition (design?)

- find $k$

- subject to
    - structural constraints
        - partial order on $k$ due to
            - fast/non fast reactions (TODO: as given by Reactome, but how?)
            #logic[
                $
                    & forall r_f, r_s space.en ( r_f in R_"fast" and r_s in R_"slow" ) -> r_f > r_s
                $
            ]
            - reaction modifiers (like above?)
    - for all dynamics of environment
        - avg concentration of species consistent to knowledge

        $
            & exists t_0 space.en forall t space.en forall s \
            & quad (t > t_0 and s in S_"avg") -> s(t) in ["known range"]
        $


#pagebreak()

// - DatabaseObject
//     - Compartment
//     - CatalystActivity
//     - Event
//         - Pathway
//             - IgnoredPathway
//         - ReactionLikeEvent
//     - PhysicalEntity
//         - InitialSpecies
//         - Complex
//         - OtherEntityType
//         - Drug
//             - RNADrug
//             - ProteinDrug
//             - ChemicalDrug
//
// - Model
// - ModelInstance
//     - SimulatedModelInstance
//     - Measurement
// - ReactionParameter
//
// - EnvironmentInstance
// - EnvironmentParameter

= Data types specification

- #logic[```js \d = /[0-9]/```]
- #logic[```js \w = /[A-Za-z0-9_]/```]

*Math*

#logic[Interval = (min: Real [0..1], max: Real [0..1])] \
#logic[MathML = String matching] https://www.w3.org/1998/Math/MathML/ \
#logic[MathMLBoolean = String matching #logic[MathML] returning a boolean] \
#logic[MathMLNumeric = String matching #logic[MathML] returning a number] \
#logic[Stoichiometry = Integer >= 0]

*Reactome*

#logic[ReactomeDbId = Integer] @reactome-DatabaseObject\
#logic[StableIdVersion = \
    ~ String matching regex ```js /^R-[A-Z]{3}-\d{8}\.\d{2,3}$/```]
@reactome-faq-identifiers \

*SBML*

#logic[String1 = String matching regex ```js //```] \
#logic[SId = String matching regex ```js /^[a-zA-Z_]\w*$/```]
#ref(
    <sbml>,
    supplement: [Section 3.1.7],
) \
#logic[UnitSId = String matching regex ```js /^[a-zA-Z_]\w*$/```] \
#logic[ReactionItem = (SpeciesInstance, Stoichiometry)]


== Interval

The #logic[Interval] type represents an open interval in $RR$ of the type
$(#logic[min], #logic[max])$ s.t.
- when #logic[min] is not defined, it is interpreted as $-infinity$
- when #logic[max] is not defined, it is interpreted as $+infinity$

#constraint(
    [C.Interval.min_leq_max],
    ```
    forall interval, interval_min, interval_max
        (
            Interval(interval) and
            min(interval, interval_min) and
            max(interval, interval_max)
        ) ->
            interval_min <= interval_max
    ```,
)

== ReactomeDbId

This is required because not all instances of #logic[DatabaseObject] in Reactome
have a #logic[StableIdVersion], which is the one usually displayed in the
Reactome Pathway Browser @reactome-pathway-browser. Instances of
#logic[DatabaseObject] in Reactome can be identified with a
#logic[ReactomeDbId], but its pattern does not match the definition of
#logic[SId] used to identify objects in SBML.

In order to generate a correct #logic[SBMLModel] the #logic[ReactomeDbId] must
be converted into a #logic[SId].

#operation(
    [ReactomeDbId_into_SId],
    args: [db_id: ReactomeDbId],
    type: [SId],
    post: [. . .],
)

== StableIdVersion

The #logic[StableIdVersion] type is useful because is the one usually displayed
in the Reactome Pathway Browser @reactome-pathway-browser. It is useful to
accept it in the description of the models.

The #logic[StableIdVersion] type is used to identify instances of
#logic[PhysicalEntity] or #logic[Event] in Reactome, but it's pattern does not
match the definition of #logic[SId] used to identify objects in SBML.

In order to generate a correct #logic[SBMLModel] the #logic[StableId] must be
converted.

#operation(
    [StableIdVersion_into_SId],
    args: [st_id: StableId],
    type: [SId],
    post: [. . .],
)


// post: [ to be defined],
// post: [...],
// In order to generate a correct SBML Model a conversion function must be
// defined.
// #TODO[this could be defined per class, meaning that different classes return a
//     different SId based on the class]

// #pagebreak()

#page(width: auto, height: 841.89pt, margin: 20pt)[
    = _(Reactome)_ UML class diagram
    #align(center + horizon, image("docs-1.svg", height: 770pt))
]

= Classes specification pt. 1

== CatalystActivity

The role of #logic[PhysicalEntity] in #logic[_catalyst_activity_entity_] has
multiplicity #logic[0..\*] because _"If a #logic[PhysicalEntity] can enable
    multiple molecular functions, a separate #logic[CatalystActivity] instance
    is created for each"_ #ref(<data-model-glossary>, supplement: [Page 5]).

An additional constraint is required for active units, because _"If the
    #logic[PhysicalEntity] is a #logic[Complex] and a component of the complex
    mediates the molecular function, that component should be identified as the
    active unit of the #logic[CatalystActivity]."_ #ref(
    <data-model-glossary>,
    supplement: [Page 5],
)

// TODO: does it expand to multiple level complexes?

#constraint(
    [C.CatalystActivity.active_unit_is_component_of_complex],
    ```
    forall catalyst_activity, complex, complex_component
        (
            CatalystActivity(catalyst_activity) and
            Complex(complex) and
            PhysicalEntity(complex_component) and
            *catalyst_activity_entity*(catalyst_activity, complex) and
            *catalyst_activity_active_unit*(
                catalyst_activity,
                complex_component
            )
        ) ->
            *complex_has_component_entity*(complex, complex_component)
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

== Pathway

The instances of #logic[Pathway] are organized hierarchically, i.e. all the
signaling pathways are collected under the Signal Transduction top level
#logic[Pathway] (#logic[StableIdVersion] R-HSA-162582.13). This allows to easily
extract a subset of reactions by specifying the _target pathways_ in a model and
taking into consideration only the reactions which are included, both directly
or indirectly, in that pathway (see the #logic[included_reactions()] operation).

Ignoring the #logic[_inferred_to_ association] there are about 34 top level
pathways.

#TODO[handle #logic[_inferred_to_]]

#operation(
    [included_reactions],
    type: [ReactionLikeEvent [0..\*]],
    // prec: ```
    // ```,
    post: ```
    result =
        { reaction |
            ReactionLikeEvent(reaction) and
            *pathway_has_event*(this, reaction) }
        $union$
        { reaction | exists pathway
            Pathway(pathway) and
            *pathway_has_event*(this, pathway) and
            included_reactions(pathway, reaction) }
    ```,
)

// exists events
//     events = { event | *pathway_has_event*(this, reaction) } ->

#pagebreak()

== PhysicalEntity

#TODO[how should I handle complexes here?]

The reactions which directly have #logic[this] as a product.

#operation(
    [directly_produced_by],
    type: [ReactionLikeEvent [0..\*]],
    post: ```
    result = { reaction |
        ReactionLikeEvent(reaction) and *output*(this, reaction)
    }
    ```,
)
// not exists pathway
//     IgnoredPathway(pathway) and reactions(pathway, reaction)

// #pagebreak()

The set of instances of #logic[DatabaseObject] which are directly or indirectly
involved in the production of #logic[this].

#operation(
    [produced_by],
    type: [DatabaseObject [0..\*]],
    post: ```
    result =
        { this } $union$
        { reaction | directly_produced_by(this, reaction) } $union$
        { object | exists reaction, reaction_input
            directly_produced_by(this, reaction) and
            (
                *input*(reaction, reaction_input) or
                (exists catalyst_activity
                    CatalystActivity(catalyst_activity) and
                    *catalyzed_event*(catalyst_activity, reaction) and
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

#TODO[handle active units too]

#page(width: auto, height: 841.89pt, margin: 20pt)[
    = _(Simulation)_ UML class diagram
    #align(center + horizon, image("docs-2.svg", height: 770pt))
]


= Classes specification pt. 2

== CompartmentDefinition

#constraint(
    [C.CompartmentDefinition.entities_have_compartment_listed],
    ```
    forall compartment_Definition, compartment, species, physical_entity
        (
            CompartmentDefinition(compartment_instance) and
            Compartment(compartment) and
            SpeciesDefinition(species) and
            PhysicalEntity(physical_entity) and
            *compartment_Definition*(compartment, compartment_instance) and
            *compartment_species*(compartment_Definition, species) and
            *physical_entity_species*(physical_entity, species)
        ) ->
            *compartment_entity*(compartment, physical_entity)
    ```,
)

#TODO[what happens if it a PhysicalEntity has some compartments?]

== Model

// args: [$S_I$: PhysicalEntity [1..\*]],
// args: [$S_I$: PhysicalEntity [1..\*]],
// prec: ```
// ```,
// exists $S_I$,
//     $S_I$ = { entity | *initial_entity_model*(this, entity) } ->

#operation(
    [model_objects],
    type: [DatabaseObject [1..\*]],
    post: ```
    result = { object | exists entity
        PhysicalEntity(entity) and
        DatabaseObject(object) and
        *model_target_entity*(this, entity) and
        produced_by(entity, object) and
        (
            not RestrictedModel(this) or
            exists pathway, reaction
                Pathway(pathway) and
                ReactionLikeEvent(reaction) and
                included_reactions(pathway, reaction) and
                (
                    object = reaction or
                    *entity_reaction*(object, reaction) or
                    *catalyzed_reaction*(object, reaction)
                )
        )
    }
    ```,
)

#pagebreak()

#constraint(
    [C.Model.objects_have_corresponding_definitions],
    ```
    forall model, object
        (
            Model(model) and
            DatabaseObject(object) and
            model_objects(model, object)
        ) ->
            exists definition
                Definition(definition) and
                *definition_model*(definition, model) and
                *database_object_definition*(object, definition)
    ```,
)

== ModelInstance

#constraint(
    [C.ModelInstance.every_reaction_has_a_parameter],
    ```
    ```,
)

#constraint(
    [C.ModelInstance.reaction_parameters_are_structurally_valid],
    ```

    ```,
)

== SimulatedModelInstance

#operation(
    [is_valid],
    post: ```
    ```,
)


== ReactionParameter??

- it must satisfy structural constraints


== UnitDefinition

Basically a unit definition is a product of the single units inside (m/s, m/s^2
etc...), easy as that.

// #set text(font: "New Computer Modern", lang: "en", weight: "light", size: 11pt)
// #set page(margin: 1.75in)
// #set par(
//     leading: 0.55em,
//     spacing: 0.85em,
//     first-line-indent: 1.8em,
//     justify: true,
// )
// #set heading(numbering: "1.1")
// #set math.equation(numbering: "(1)")

// #page(align(center + horizon, [
// #heading(numbering: none, outlined: false, text(size: 2em, [MyPrecious]))
// #text(size: 1.7em, [Ionuţ Cicio]) \
// senza risparmiare neanche un carattere
// ]))

#pagebreak()

#page(bibliography("bibliography.bib"))
