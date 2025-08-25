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
#set highlight(fill: rgb("fbf1c744"))
#set list(indent: 1em)

#let proj-name = text(font: "LMMonoCaps10", "Bsys_eval")
#let TODO(body) = box(fill: rgb("#f5f5f5"), inset: .75em)[
    #text(font: "LMMonoCaps10", "TODO"): #body

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
disease) and by taking into account all the reactions that lead to the
production, both directly and indirectly, of the _target species_, the goal is
to find a subset of virtual patients for the situation.

#TODO[
    find papers in literature that do similar things; what does this method add
    compared to other approaches? (i.e. using multiple pathways by generating
    the fixed point, ensemble of SAs etc...)
]

#TODO[
    add case study, multiple if possible
]

== Requirements


The algorithm

#TODO[better notation here, write something decent to introduce the algorithm]

#box(
    stroke: (y: .25pt),
    inset: (y: .5em),
    width: 100%,
    [ *Algorithm 1*: (high level pseudocode)],
)
#box(stroke: (bottom: .25pt), inset: (bottom: 1em))[
    #indent-block(logic[
        *input*: $S_T$, set of PhysicalEntity; \
        *input*: $C_T$, set of constraints on $S_T$; \
        *input*: $P_I$, set of ignored pathways; \
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

#page(width: auto, height: 841.89pt, margin: 20pt)[
    = UML class diagram
    #align(center + horizon, image("docs.svg", height: 770pt))
]

= Data types specification

- #logic[```js \d = /[0-9]/```]
- #logic[```js \w = /[A-Za-z0-9_]/```]

#logic[ReactomeDbId = Integer] @reactome-DatabaseObject\
#logic[StableId = String matching regex ```js /^R-[A-Z]{3}-\d{8}\.\d{2,3}$/```]
@reactome-faq-identifiers \
#logic[SId = String matching regex ```js /^[a-zA-Z_]\w*$/```]
#ref(
    <sbml>,
    supplement: [Section 3.1.7],
)
\
#logic[Interval = (min: Real [0..1], max: Real [0..1])] \
#logic[MathML = String according to] https://www.w3.org/1998/Math/MathML/ \

// #logic[Constraint = ...] \

== Interval

The #logic[Interval] type represents a real open interval of the type
$(min, max)$.

// TODO: When #logic[min] is not defined it's intended to be interpreted as $-infinity$
// TODO: When #logic[max] is not defined it's intended to be interpreted as $+infinity$

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

Other Reactome entities can be identified with a #logic[ReactomeDbId], but it's
pattern does not match the definition of #logic[SId] used to identify objects in
SBML. In order to generate a correct SBML Model the #logic[ReactomeDbId] must be
converted.

#operation(
    [into],
    args: [db_id: ReactomeDbId],
    type: [SId],
    post: [. . .],
)

== StableId

The #logic[StableId] type is used to identify a #logic[PhysicalEntity] or an
#logic[Event] in Reactome, but it's pattern does not match the definition of
#logic[SId] used to identify objects in SBML. In order to generate a correct
SBML Model the #logic[StableId] must be converted.

#operation(
    [into],
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

#pagebreak()

= Classes specification

== CatalystActivity

The one above is the reason why a #logic[PhysicalEntity]'s role in
#logic[_catalyst_entity_] has multiplicity 0..\*.

"If a #logic[PhysicalEntity] can enable multiple molecular functions, a separate
#logic[CatalystActivity] instance is created for each" #ref(
    <data-model-glossary>,
    supplement: [Page 5],
)


// may be associated to
// 0..\* #logic[CatalystActivity].


"If the #logic[PhysicalEntity] is a #logic[Complex] and a component of the
complex mediates the molecular function, that component should be identified as
the active unit of the #logic[CatalystActivity]." #ref(
    <data-model-glossary>,
    supplement: [Page 5],
)

// TODO: does it expand to multiple level complexes?
#constraint(
    [C.CatalystActivity.active_unit_is_in_complex],
    ```
    forall catalyst_activity, complex, complex_component
        (
            CatalystActivity(catalyst_activity) and
            Complex(complex) and
            PhysicalEntity(complex_component) and
            *catalyst_entity*(catalyst_activity, complex) and
            *catalyst_active_unit*(catalyst_activity, complex_component)
        ) ->
            *complex_has_component_entity*(complex, complex_component)
    ```,
)

== Compartment

== Event

== FastReaction

== Model

// args: [$S_I$: PhysicalEntity [1..\*]],
// args: [$S_I$: PhysicalEntity [1..\*]],
// prec: ```
// ```,
// exists $S_I$,
//     $S_I$ = { entity | *initial_entity_model*(this, entity) } ->

#operation(
    [fixed_point],
    type: [DatabaseObject [1..\*]],
    post: ```
    result = { object | exists entity
        *initial_entity_model*(this, entity) and
        fixed_point(entity, object)
    }
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


== Pathway

#operation(
    [reactions],
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
            reactions(pathway, reaction) }
    ```,
)

// exists events
//     events = { event | *pathway_has_event*(this, reaction) } ->

== PhysicalEntity

TODO: how should I handle complexes here?

#operation(
    [produced_by],
    type: [ReactionLikeEvent [0..\*]],
    post: ```
    result = { reaction |
        ReactionLikeEvent(reaction) and
        *output*(this, reaction) and
        not exists pathway
            IgnoredPathway(pathway) and
            reactions(pathway, reaction)
    }
    ```,
)

TODO: union with #logic[CatalystActivity]

#operation(
    [fixed_point],
    type: [DatabaseObject [0..\*]],
    post: ```
    result =
        { this } $union$
        produced_by(this) $union$
        { object | exists reaction, reaction_input
            produced_by(this, reaction) and
            (
                *input*(reaction, reaction_input) or
                (exists catalyst_activity
                    CatalystActivity(catalyst_activity) and
                    *catalyzed_event*(catalyst_activity, reaction)) and
                    *catalyst_entity*(catalyst_activity, reaction_input)
            ) and
            fixed_point(reaction_input, object)
        }

    ```,
)

// - TODO: add "reach backwards" operation! At least in high level.
// - TODO: add mathematical definition of problem

// TODO: should I add
// backwards_reachable_species()
// to PhysicalEntity?
//
// Nah, it takes PhysicalEntity [0..*]
// DONE!

== ReactionLikeEvent

== ReactionParameter??

- it must satisfy structural constraints


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
