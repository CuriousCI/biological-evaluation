#import "lib.typ": *

#set page(margin: 1in)
= Reactome quirks

== Compartments

=== Physical entities with multiple compartments

Because the functions of biologic molecules critically depend on their
subcellular locations, #underline(text(red)[*chemically identical entities
located in different compartments are represented as distinct physical
entities*]). // TODO: (Reactome paper)
The problem is that many physical entities are related to multiple compartments,
even though they are already an instance of an entity related to a compartment.

#figure(
    ```
    MATCH
        (physicalEntity:PhysicalEntity),
        (physicalEntity)-[:compartment]->(compartment1:Compartment),
        (physicalEntity)-[:compartment]->(compartment2:Compartment)
    WHERE compartment1.dbId < compartment2.dbId
    OPTIONAL MATCH (compartment1)-[relation]-(compartment2)
    WITH
        DISTINCT physicalEntity,
        COLLECT(
            DISTINCT CASE
                WHEN relation IS NOT NULL THEN TYPE(relation)
                ELSE "none"
            END
        ) AS links
    RETURN
        apoc.coll.subtract(
            LABELS(physicalEntity),
            [
                "DatabaseObject", "Deletable", "Trackable",
                "PhysicalEntity", "EntitySet"
            ]
        ),
        links,
        COUNT(*)
    ```,
    caption: [
        Type of links between compartments of physical entities with multiple
        compartments.
    ],
)

#align(center, table(
    columns: (auto, auto, auto),
    align: (left, left, center),
    table.cell(align: center, strong[entity type]),
    table.cell(align: center, strong[compartments link types]),
    strong[\#],
    [CandidateSet], [none], [286],
    [CandidateSet], [surroundedBy], [29],
    [CandidateSet], [none, surroundedBy], [3],
    [DefinedSet], [none], [201],
    [DefinedSet], [instanceOf], [1],
    [DefinedSet], [surroundedBy], [129],
    [Polymer], [surroundedBy], [7],
))

If a Polymer involves multiple compartments (or, more generally, a
PhysicalEntity which is not an EntitySet) then:
1. Add new physcal entities, one for each compartment
2. Add reactions with infinite speed that move substance between compartments

// $
//     v_1 = k_1 dot.c p_1 \
//     v_2 = k_2 dot.c p_1
// $
//
// Where $k_1 = k_2$ and $k_1, k_2$ are very big
// If an entity set has multiple compartments

#figure(
    ```
    MATCH (entitySet:EntitySet)
    WHERE EXISTS {
        MATCH
            (entitySet)-[:hasMember|hasCandidate]->(physicalEntity:PhysicalEntity)
        WHERE
            NOT EXISTS {
                MATCH
                    (entitySet)-[rel1:compartment|includedLocation]-
                    (compartment:Compartment)
                    -[rel2:compartment|includedLocation]-(physicalEntity)
            }
    }
    RETURN COUNT(DISTINCT entitySet) // 0
    ```,
    caption: [
        There are no instances of EntitySet which don't share compartments with
        their members.
    ],
) <entity-set-no-shared-compartments>

If the relation type includedLocation is not used in
@entity-set-no-shared-compartments then there is an instance of a Complex that
doesn't share its compartment with the set its placed in.

=== Physical entities without compartments

Some physical entities do not have compartments. The good news is that these
entities are only 25 and are of type `Cell` _(the total number of cells in
reactome is 25)_. Moreover, all the reactions that involve cells are of type
`CellDevelopmentStep`

#figure(
    ```
    MATCH (physicalEntity:PhysicalEntity)
    WHERE NOT EXISTS {
        MATCH (physicalEntity)-[:compartment]->(:Compartment)
    }
    OPTIONAL MATCH path = (physicalEntity)--(:ReactionLikeEvent)
    RETURN physicalEntity, path
    ```,
    caption: [Phyiscal entities without any compartment and their reactions.],
)

To handle this case it's enough to add a default compartment.

=== On the compartments of reactions

#figure(
    ```
    MATCH (reaction:ReactionLikeEvent)
    WHERE EXISTS {
        MATCH
            (reaction)--(compartment1:Compartment),
            (reaction)--(compartment2:Compartment)
        WHERE
            compartment1 <> compartment2
    }
    RETURN COUNT (DISTINCT reaction) // 36322 (out of 93672)
    ```,
    caption: [
        Reactions connected to multiple compartments
    ],
)

The fact that reactions are connected to multiple compartments is not a problem!
In SBML the compartment is optional for reactions, as the simulators should be
able to deduce the compartment of the reaction based on the compartment of its
substrate.

// TODO: https://sbml.org/documents/faq/
// TODO: https://raw.githubusercontent.com/combine-org/combine-specifications/main/specifications/files/sbml.level-3.version-2.core.release-2.pdf

== Reactions

=== Reactions with multiple enzymes

#figure(
    ```
    MATCH (reaction:ReactionLikeEvent)
    WHERE EXISTS {
        MATCH
            (reaction)--(activity1:CatalystActivity),
            (reaction)--(activity2:CatalystActivity)
        WHERE
            activity1 <> activity2
    }
    RETURN COUNT(DISTINCT reaction) // 17 reactions out of 93672
    ```,
    caption: [
        Reactions with multiple CatalystActivity
    ],
)

The interesting fact about these reactions is that all of them are of type
BlackBoxEvent. It might be interesting to add an option to exclude certain types
of reactions. In this case a new reaction for each enzyme can be created.

=== On the reversibility of reactions

#figure(
    ```
    MATCH (:ReactionLikeEvent)-[relation]-(:ReactionLikeEvent)
    RETURN DISTINCT type(relation)
    ```,
    caption: [
        Types of links between reactions: \
        `[precedingEvent, inferredTo, normalReaction, reverseReaction]`

    ],
)

Explanation:
- _`precedingEvent`_: useful for visualization
- _`inferredTo`_: reactions inferred from reactions in a different species
- _`normalReaction`_: it reference to the normal version of a FailedReaction
- _`reverseReaction`_: reference to another reaction which is the reverse


#figure(
    ```
    MATCH (reaction:ReactionLikeEvent)-[:reverseReaction]->(:ReactionLikeEvent)
    RETURN COUNT(DISTINCT reaction) // 112
    ```,
    caption: [
        Number of reactions which have a reference to a reverse reaction
    ],
)

Such reactions are marked as `(Reversible)` in the PathwayBrowser

#figure(
    box(width: 85%, image("public/reactome-1.png")),
    caption: [
        Reversible reaction in the PathwayBrowser: #link(
            "https://reactome.org/PathwayBrowser/#/R-HSA-1483206&SEL=R-HSA-1482781&PATH=R-HSA-1430728,R-HSA-556833,R-HSA-1483257&FLG=R-HSA-1482794&FLGINT",
        )[#underline[link to view]],
        #link(
            "https://reactome.org/content/detail/R-HSA-1482894",
        )[#underline[link to reaction page]]
    ],
)

#figure(
    ```
    MATCH (reaction:ReactionLikeEvent)
    UNWIND keys(reaction) AS key
    RETURN DISTINCT key
    ```,
    caption: [
        Attributes of a generic ReactionLikeEvent.
    ],
)

The attributes are: `schemaClass`, `speciesName`, `isInDisease`, `releaseDate`,
`displayName`, `stIdVersion`, `dbId`, `name`, `isChimeric`, `category`, `stId`,
`isInferred`, `oldStId`, `releaseStatus`, `definition`, `systematicName`.

Non of them give information about the "reversibility" of the reaction.

#TODO[
    In the official exporter of Reactome the reversibility option is set to
    `false` by default: #link(
        "https://github.com/reactome/sbml-exporter/blob/aeaf341e49f48d408195740e9e319ed6a881f0f2/src/main/java/org/reactome/server/tools/sbml/converter/SbmlConverter.java#L113",
    )[#underline[link to code]].

    I couldn't find no other way to determine if a reaction is reversible or
    not, so only those 112 reaction can be considered reversible.
]

// #page(height: auto)[
//     == Roles physical entities have in reactions
//
//     ```
//     MATCH
//         (reaction:ReactionLikeEvent)
//     OPTIONAL MATCH (reaction)-[relation]-(entity)
//     WHERE
//         "CatalystActivity" IN labels(entity)
//         OR "PhysicalEntity" IN labels(entity)
//         OR "Regulation" IN labels(entity)
//     WITH reaction, relation ORDER BY type(relation)
//     WITH DISTINCT reaction, COLLECT(DISTINCT type(relation)) AS types
//     RETURN
//         apoc.coll.subtract(
//             labels(reaction),
//             [
//                 "DatabaseObject", "Deletable", "Trackable",
//                 "ReactionLikeEvent", "Event"
//             ]
//         ) AS labels,
//         types,
//         COUNT(*)
//     ORDER BY size(labels), labels DESC, size(types), types
//     ```
//     #table(
//         columns: (auto, auto, auto),
//         align: (left, left, center),
//         [Reaction], [input, output], [33271],
//         [Reaction], [catalystActivity, input, output], [43844],
//         [Reaction], [entityOnOtherCell, input, output], [188],
//         [Reaction], [input, output, regulatedBy], [2049],
//         [Reaction], [input, output, requiredInputComponent], [18],
//         [Reaction], [catalystActivity, entityOnOtherCell, input, output], [35],
//
//         [Reaction], [catalystActivity, input, output, regulatedBy], [3242],
//
//         [Reaction],
//         [catalystActivity, input, output, requiredInputComponent],
//         [10],
//
//         [Reaction], [entityOnOtherCell, input, output, regulatedBy], [11],
//
//         [Reaction], [input, output, regulatedBy, requiredInputComponent], [4],
//
//         [Reaction],
//         [catalystActivity, input, output, regulatedBy, requiredInputComponent],
//         [2],
//
//         [Polymerisation], [input, output], [178],
//         [Polymerisation], [catalystActivity, input, output], [32],
//         [Polymerisation], [input, output, regulatedBy], [15],
//         [Polymerisation], [catalystActivity, input, output, regulatedBy], [10],
//
//         [Polymerisation],
//         [catalystActivity, input, output, requiredInputComponent],
//         [4],
//
//         [FailedReaction], [input], [167],
//         [FailedReaction], [catalystActivity, input], [270],
//         [FailedReaction], [entityOnOtherCell, input], [4],
//         [FailedReaction], [input, regulatedBy], [5],
//         [FailedReaction], [catalystActivity, input, regulatedBy], [2],
//
//         [FailedReaction],
//         [catalystActivity, input, requiredInputComponent],
//         [1],
//
//         [Depolymerisation], [input, output], [3],
//         [Depolymerisation], [catalystActivity, input, output], [25],
//         [CellDevelopmentStep], [input, output], [3],
//         [CellDevelopmentStep], [input, output, regulatedBy], [16],
//         [CellDevelopmentStep],
//         [input, output, regulatedBy, requiredInputComponent],
//         [3],
//
//         [BlackBoxEvent], [input], [100],
//         [BlackBoxEvent], [output], [23],
//         [BlackBoxEvent], [catalystActivity, input], [116],
//         [BlackBoxEvent], [input, output], [5000],
//         [BlackBoxEvent], [input, regulatedBy], [9],
//         [BlackBoxEvent], [output, regulatedBy], [34],
//         [BlackBoxEvent], [catalystActivity, input, output], [2604],
//         [BlackBoxEvent], [entityOnOtherCell, input, output], [5],
//         [BlackBoxEvent], [input, output, regulatedBy], [2081],
//         [BlackBoxEvent], [input, output, requiredInputComponent], [7],
//
//         [BlackBoxEvent],
//         [catalystActivity, entityOnOtherCell, input, output],
//         [5],
//
//         [BlackBoxEvent], [catalystActivity, input, output, regulatedBy], [233],
//
//         [BlackBoxEvent],
//         [catalystActivity, input, output, requiredInputComponent],
//         [21],
//
//         [BlackBoxEvent], [entityOnOtherCell, input, output, regulatedBy], [6],
//
//         [BlackBoxEvent],
//         [input, output, regulatedBy, requiredInputComponent],
//         [14],
//
//         [BlackBoxEvent],
//         [catalystActivity, entityOnOtherCell, input, output, regulatedBy],
//         [2],
//     )
// ]

#page(height: auto)[
    == Roles physical entities have in reactions

    === Reactions classification based on the presence of reactants, products, enzymes and regulators

    ```
    MATCH
        (reaction:ReactionLikeEvent)
    OPTIONAL MATCH (reaction)-[relation]-(entity)
    WHERE
        NOT type(relation) IN [
            "precedingEvent", "negativePrecedingEvent", "normalReaction",
            "inferredTo", "reverseReaction"
        ]
        AND size(apoc.coll.intersection(
            [
                "ControlledVocabulary", "ReviewStatus", "UpdateTracker",
                "InstanceEdit", "Publication", "LiteratureReference",
                "ExternalOntology", "EvidenceType", "URL", "Pathway",
                "Figure", "Anatomy", "Book", "MetaDatabaseObject",
                "DatabaseIdentifier", "RegulationReference",
                "CatalystActivityReference", "EntityFunctionalStatus",
                "DrugActionType", "GO_CellularComponent", "GO_Term",
                "GO_BiologicalProcess", "Species", "Taxon", "Summation",
                "Compartment"
            ],
            labels(entity)
        )) = 0
    WITH
        reaction,
        apoc.coll.subtract(
            labels(entity),
            [
                "DatabaseObject", "Deletable", "Trackable",

                "ReactionLikeEvent", "Event",

                "EntitySet", "CandidateSet", "DefinedSet", "SimpleEntity",
                "EntityWithAccessionedSequence", "GenomeEncodedEntity",
                "OtherEntity", "Complex", "Disease",
                "Polymer", "ProteinDrug", "Cell", "Requirement",
                "Drug", "RNADrug", "ChemicalDrug",

                "NegativeRegulation", "PositiveRegulation",
                "NegativeGeneExpressionRegulation",
                "PositiveGeneExpressionRegulation"
            ]
        ) as labels
    UNWIND labels AS label
    WITH reaction, label ORDER BY label
    WITH DISTINCT reaction, COLLECT(DISTINCT label) AS types
    RETURN
        apoc.coll.subtract(
            labels(reaction),
            [
                "DatabaseObject", "Deletable", "Trackable",
                "Event", "ReactionLikeEvent"
            ]
        ) AS labels,
        types,
        COUNT(*) AS cnt
    ORDER BY labels DESC, size(types)
    ```

    In the table below reaction types are classified by the roles of the
    reagents in the reaction (where PhysicalEntity groups inputs and outputs).
    The rows marked in red indicate the reactions that have regulators
    (inhibitors and activators) but no enzyme.

    #{
        show table.cell: it => {
            if it.y in (2, 6, 10, 15, 18) {
                set block(fill: red.lighten(75%))
                it
            } else {
                it
            }
        }

        align(center, table(
            columns: (auto, auto, auto),
            align: (left, left, center),
            [Reaction], [PhysicalEntity], [33477],
            [Reaction], [CatalystActivity, PhysicalEntity], [43889],
            [Reaction], [PhysicalEntity, Regulation], [2064],
            [Reaction], [CatalystActivity, PhysicalEntity, Regulation], [3244],
            [Polymerisation], [PhysicalEntity], [178],
            [Polymerisation], [CatalystActivity, PhysicalEntity], [36],
            [Polymerisation], [PhysicalEntity, Regulation], [15],
            [Polymerisation],
            [CatalystActivity, PhysicalEntity, Regulation],
            [10],

            [FailedReaction], [PhysicalEntity], [171],
            [FailedReaction], [CatalystActivity, PhysicalEntity], [271],
            [FailedReaction], [PhysicalEntity, Regulation], [5],
            [FailedReaction],
            [CatalystActivity, PhysicalEntity, Regulation],
            [2],

            [Depolymerisation], [PhysicalEntity], [3],
            [Depolymerisation], [CatalystActivity, PhysicalEntity], [25],
            [CellDevelopmentStep], [PhysicalEntity], [3],
            [CellDevelopmentStep], [PhysicalEntity, Regulation], [19],
            [BlackBoxEvent], [PhysicalEntity], [5135],
            [BlackBoxEvent], [CatalystActivity, PhysicalEntity], [2746],
            [BlackBoxEvent], [PhysicalEntity, Regulation], [2144],
            [BlackBoxEvent],
            [CatalystActivity, PhysicalEntity, Regulation],
            [235],
        ))
    }
]


// MATCH ({reaction})-[:catalystActivity]->(:CatalystActivity)-[:physicalEntity]->(physicalEntity:PhysicalEntity)

// MATCH ({reaction})-[:regulatedBy]->(regulation:Regulation)-[:regulator]->(physicalEntity:PhysicalEntity)
// RETURN
//     COLLECT({{
//         physicalEntity: physicalEntity,
//         category: CASE
//             WHEN "PositiveRegulation" IN labels(regulation) THEN "positive_regulator"
//             WHEN "NegativeRegulation" IN labels(regulation) THEN "negative_regulator"
//             ELSE ""
//         END
//     }}) AS {reaction_regulators}

// The Reactome data model extends the concept of a biochemical reaction to include such things as the association of two proteins to form a complex, or the transport of an ubiquitinated protein into the proteasome. Reactions are chained together by shared physical entities; an output of one reaction may be an input for another reaction and serve as the catalyst for yet another reaction.
//

// == Assumptions
//
// === Assumption 1 (quasi-equilibrium of E and ES)
//
// Michaelis and Menten [5] considered a quasi-equilibrium between the free enzyme
// and the enzyme–substrate complex, meaning that the reversible conversion of $E$
// and $S$ to $"ES"$ is much faster than the decomposition of $"ES"$ into $E$ and
// $P$, or in terms of the kinetic constants, that is,
//
// $k_1, k_(-1) >> k_2$
//
// - (possibile assunzione "quasi-equilibrium" di enzima-libero e complesso) // TODO:
// enzima-specie "la reazione regolata da un enzima, che produce il complesso
// "enzima - specie" è molto più lenta della reazione che prende il complesso e ci
// fa cose!"
//
// === Assumption 2 (concentration of ES is constant)
//
// This works only if $S(t = 0) >> E$ (because the turnover rate of $E$ is kinda
// big, thus $(dif"ES") / (dif t) = 0$


// == Stuff
//
// 1. Draw a wiring diagram of all steps to consider (e.g., Eq. (4.11)). It
//     contains all substrates and products ($S$ and $P$) and $n$ free or bound
//     enzyme species
// ($E$ and $"ES"$).
// 2. The right sides of the ODEs for the concentrations changes sum up the rates
//     of all steps leading to or away from a certain substance (e.g., Eqs.
//     (4.12)–(4.15)). The rates follow mass action kinetics (Eq. (4.3)).
// // OK! So basically, I have the normal rates of the kinetics
// 3. The sum of all enzyme-containing species is equal to the total enzyme
//     concentration $E_"total"$ (the right side of all differential equations for
//     enzyme species sums up to zero). This constitutes one equation (ok, but what
//     if enzymes are produced?)
//
// 4. The assumption of quasi-steady state for $n - 1$ enzyme species (i.e.,
//     setting the right sides of the respective ODEs equal to zero) together with
//     (3) result in $n$ algebraic equations for the concentrations of the $n$
//     enzyme species.
//
// 5. The reaction rate is equal to the rate of product formation (e.g., Eq.
//     (4.16)). Insert the respective concen­ trations of enzyme species resulting
//     from (4).


// \
//
// One enzyme molecule can catalyze thousands of reactions per second (this
// so-called turn­ over number ranges from 102 to 107 s 1). Enzyme cataly­ sis leads
// to a rate acceleration of about 106 up to 1012-fold compared to the
// noncatalyzed, spontaneous reaction.
//
// The turnover number (kcat) of an enzyme is the maximum number of substrate
// molecules one enzyme active site can convert into product per second, indicating
// its catalytic efficiency, calculated as Vmax (maximum reaction velocity) divided
// by the total enzyme concentration. It shows how fast an enzyme works, with
// values ranging from less than one to millions of molecules per second, and is
// key to understanding how effectively an enzyme processes substrates
//
// $10^2 "to" 10^7 "reactions"/s$
//
// Chemical and biochemical kinetics rely on the assumption that the reaction rate
// v at a certain point in time and space can be expressed as a unique function of
// the concentrations of all substances at this point in time and space.
//
// Classical enzyme kinetics assumes for sake of simplicity a spatial homogeneity
// (the “well-stirred” test tube) and no direct dependency of the rate on time:
//
// *time-invariant* system
//
// concentration: always based on a volume
// - $n / V space "quantity" / "litre"$


// \
//
// $
//     S -> P
// $
//
// $
//     limits(v)^dot = (k_2 dot.c E dot.c S) / (S + (k_(-1) + k_2) / k_1)
// $
//
// \
//
// $
//     "sia" S_1 + S_2 -> P "una reazione con enzima" E
// $
//
// $
//     limits(v)^dot = (k_2 dot.c [E] dot.c [S_1 dot.c S_2]) / ([S_1 dot.c S_2] + (k_(-1) + k_2) / k_1)
// $
//
// #align(center)[ dove $[S]$ è la concentrazione della species S]

// - $E_"modifier" = E_("enzyme") union E_("inhibitor")$

// - $nu : S times R times {"reactant", "product"} -> NN_1$ is the
//     stoichiometry function

// TODO: what if the reaction is not reversible
// TODO: mass-action -> power-law (generalization of mass action, why is it a generalization? how does it work?)
// TODO: how many species are involved in a reaction on average? This can determine how the law scales
// https://pmc.ncbi.nlm.nih.gov/articles/PMC1781438/

// \

// #line(stroke: .1pt, length: 100%)

// \

// === Kinetics

// #align(center, box(width: auto)[
//     $
//         v = E_"total" dot.c
//         // (
//         product_((s, r) in E_"enzyme") s^(n^s_r) / (K^s_r + s^(n^s_r))
//         product_((s, r) in E_"inhibitor") K^s_r / (K^s_r + s^(n^s_r))
//         // f_"reg"
//         // )
//         dot.c
//         (
//         k^"for"_"cat" limits(product)_((s, r) in E_"reactant") (s / K_(m, s))^(nu_"reactant" (s, r))
//         - k^"back"_"cat" limits(product)_((s, r) in E_"product") (s / K_(m, s))^(nu_"product" (s, r))
//         ) /
//         D
//     $
// ])

// product_i (1 + sum_(a = 1)^i (S_i / K_(m, S_i))^a)
// + product_j (1 + sum_(a = 1)^j (P_j / K_(m, P_j))^a)
// - 1

// k^"for"_"cat" product_i (S_i / K_(m, S_i))^(n_(-i))
// - k^"back"_"cat" product_j (P_j / K_(m, P_j))^(n_j)

// X, D, C


// Approximation: An "irreversible" reaction in biological networks is often modeled as a very fast forward reaction with a negligible reverse rate constant, which fits within the convenience kinetics framework by making the product release term dominant or the reverse rate effectively zero.

// Focus on Flux: By emphasizing the saturation curve and steady-state behaviour (like quasi-steady-state), it captures how enzyme activity changes with substrate concentration, mimicking unidirectional flow in metabolic pathways.

// TODO: compute how many constants does a specific model have

// TODO: is there a species which is both inhibitor and enzyme in the same reaction?
// TODO: does cineca slurm support slurm rest api? Nah, it doesnt, it must enable job submission from node


// "modifier"^+

// - $nu : E_r -> NN_+$
// - $nu : E_p -> NN_+$
// - $nu : E_r union E_p -> NN_1$ is the *stoichiometry* of the reactants of
//     products of the reaction

// is the set of relationship types between species and reactions
// , with $T$ the relationship type


// TODO: maybe time horizon >= 0
// TODO: what other constraints do I have to handle?
// - I handle the 0 <= s <= 1
// - I handle the modifiers concentrations
// - I handle the the transitory
// - TODO: I have to handle the mythical "target values" or something ("aderenza" baby)
// #pagebreak()

// TODO: not exists reaction1 s.t (reaction1)-[:reverseReaction]->(reaction)

// TODO: https://github.com/reactome/sbml-exporter/blob/aeaf341e49f48d408195740e9e319ed6a881f0f2/src/main/java/org/reactome/sbml/rel/ReactionHandler.java#L39
// TODO: https://github.com/reactome/sbml-exporter/blob/aeaf341e49f48d408195740e9e319ed6a881f0f2/src/main/java/org/reactome/server/tools/sbml/data/DataFactory.java#L33

// https://sbml.org/documents/specifications/level-3/version-1/qual/
// https://github.com/reactome/sbml-exporter?tab=readme-ov-file#known-limitations

// 1. Identifying the Reactome Compartment containing the Reactome PhysicalEntities
//     that appear as SBML species in the resulting SBML model. It is not always
//     clear from the database which Compartment is appropriate; as some
//     PhysicalEntities list multiple Compartments to account for their possible
//     location in different places. This issue is being addressed by the Reactome
//     curators.
//
// 2. There are currently no SBOTerms created for any SBML reaction. The
//     information in the ReactomeDB is not fine-grained enough to categorise types
//     of Reactome ReactionLikeEvents. Work is progressing to provide this
//     information.
//
// 3. Reactome creates some PhysicalEntities as a set of possible/probably
//     participants in a Reaction. Currently these get encoded as a single SBML
//     species and added as a reactant/product/modifier. This is inaccurate in
//     terms of the intended meaning of an SBML species. Further thought is being
//     given to how to more accurately portray this information in SBML.

// #note[Should inconsistent reactions be discarded from the final model?]
// TODO: mantenere i rapporti fra le concentrazioni delle specie nel set

// == Convenience Kinetics and Modular Rate Laws
//
// #set math.equation(numbering: none)
//
// #align(center)[#box(width: auto)[
//         $
//             v = E_"total" dot.c f_"reg" dot.c
//             (k^"for"_"cat" product_i (S_i / K_(m, S_i))^(n_(-i)) - k^"back"_"cat" product_j (P_j / K_(m, P_j))^(n_j)) /
//             (
//             product_i (1 + sum_(a = 1)^i (S_i / K_(m, S_i))^a)
//             + product_j (1 + sum_(a = 1)^j (P_j / K_(m, P_j))^a)
//             - 1
//             )
//         $
//     ]
// ]
//
// / $v$: amount of substance that is converted in the reaction
// / $E_"total"$: ? oh, wait, wtf????? Is it computable? $E_"total"$ is the enzyme
//     concentration
// / $f_"reg"$: ?
// / $k^"for"_"cat"$: constant of reaction moving "forward" when the reaction is
//     reversible (why cat?)
// / $k^"back"_"cat"$: turnover rate!!! (same for forward)
// / $K_(m, S_i), K_(m, P_j)$: constant which somehow reduces the probability of
//     reaction of that species, what does that $m$ stand for?
//
// $
//     f_"reg" = cases(
//         1 quad & "if no regulation is present",
//         product (M/(K_A + M) dot.c K_I / (K_I + M)) quad & "otherwise (resp. positive and negative regulation)"
//     )
// $
// where
// - $M$ is the concentration of the modifier
// - $K_A, K_I$ measured in concentration units (values denote concentrations, at
//     which the inhibitor or activator has its half-maximal effect)
//
// now:
// - the denominator should somehow "slow down" the reaction... right?
//     - well, in the worst case the denominator is exactly 1
// - is it > or < of 1? It must be at least 1
// - what is the domain of $K_(m, S)$? Is it >= 0? Yeah, it must be.
// - Where are the modifiers? Are the modifiers in $E_"total"$?
//
// $
//     K_V = (K^"for"_"cat" dot.c K^"back"_"cat")^(1/2)
// $
//
// $ E_"total" $
// pare pericolosa, perché è la somma della concentrazione degli enzimi + la somma
// del prodotto

// A turnover rate (or number, kcat) in a reaction, especially with enzymes or
// catalysts, measures how efficiently a single active site converts substrate
// molecules into products per unit of time, typically seconds. It's the maximum
// number of substrate molecules transformed per active site when the enzyme is
// fully saturated with substrate, expressed as molecules/active site/second (s⁻¹).
// A higher turnover number indicates a faster, more efficient catalyst

// when is a reaction half-maximal? When it reaches 50% of its maximum response or rate.
// K_m: substrate concentration yielding half of the maximum velocity  V_max / 2
// half-maximal if the reaction products are absent
// #pagebreak()


// TODO: case 1 when there is no regulation
// TODO: 1 + p / K
// TODO: K_m, K_A, K_I are all between 0 and 1, since they are the "half maximal" effect in enzymatic reactions

// $
//     p / (K + p) = p / (p dot.c (1 + K / p)) = 1 / (1 + K / p)
// $
//
// $
//     p / (K + p) = p / (K dot.c (1 + p / K)) = p / (K dot.c ((K + p) / K)) = p / (K dot.c (K/K + p / K)) = 1 + p / K
// $
//
// $
//     p / (K dot.c (1 + p / K)) = p / K dot.c 1 / (1 + p / K)
// $

// Let $r$ be a reaction s.t. $r in R_"reversible"$



// #figure(
//     ```
//     MATCH
//         path1 = (reaction1 {dbId: 1482894})-[:reverseReaction]-(reaction2),
//         path2 = (reaction1)--(:PhysicalEntity),
//         path3 = (reaction2)--(:PhysicalEntity)
//     RETURN path1, path2, path3
//     ```,
//     caption: [
//         On the reversibility of reactions
//     ],
// )

// #note[
//     The section below needs to be revisited, constants are not the same for all
//     reactions! And better names should be given in order to describe the
//     behaviour
// ]
//
// #listing-def[Dynamic biological model][
//     Given a biochemical network $G = (S, R, E, nu)$ let $B = (G′, cal(K))$ be
//     the biological model derived from $G$ with added modular law kinetics, with
//     $G′ =
//     (S, R′, E′, nu′)$ where
//
//     - $R' = R union R_"input" union R_"output"$ with
//         - $R_"input" = { r_s | s in U - Y}$
//         - $R_"output" = { r_s | s in Y - U}$
//     - $E' = E union {(s, r, "product") | r_s in R_"input"} union {(s, r, "reactant") | r_s in R_"output"}$
//
//     - $nu' = (nu'_"reactant", nu'_"product")$
//         - $
//                 nu'_"reactant"(s, r) = cases(
//                     1 quad & "if " (s, r) in R_"input",
//                     nu_"reactant" (s, r) quad & "otherwise"
//                 )
//             $
//         - $
//                 nu'_"product"(s, r) = cases(
//                     1 quad & "if " (s, r) in R_"output",
//                     nu_"product" (s, r) quad & "otherwise"
//                 )
//             $
//
//     Then $cal(K)$, the set of constants, can be defined on $G'$ as
//     $
//         cal(K) = & { k^"for"_("cat", r) | r in R' } union \
//                  & { k^"back"_("cat", r) | r in R' } union \
//                  & { K^r_(m, s) | (s, r) in E'_"reactant" union E'_"product" } union \
//                  & { K^s_r | r in R' and (s, r) in E_"modifier" } union \
//                  & { n^s_r | r in R' and (s, r) in E_"modifier" }
//     $
//     where
//     - $k_r$ is the kinetic constant of reaction $r$
//     - $K_r^s$ is the apparent dissociation constant of modifier $s$ in reaction
//         $r$
//     - $n_s^r$ the hill coefficient of modifier $s$ in reaction $r$
// ]

// ```
// MATCH (reaction)
// WHERE reaction.dbId IN [187246, 189119]
// OPTIONAL MATCH path1 = (reaction)-[:input]->()
// OPTIONAL MATCH path2 = (reaction)-[:output]->()
// OPTIONAL MATCH path3 = (reaction)-->(:CatalystActivity)-->(:PhysicalEntity)
// OPTIONAL MATCH path4 = (reaction)-->(:PositiveRegulation)-->(:PhysicalEntity)
// OPTIONAL MATCH path5 = (reaction)-->(:NegativeRegulation)-->(:PhysicalEntity)
// RETURN reaction, path1, path2, path3, path4, path5
// ```
//
// ```
// MATCH (reaction:ReactionLikeEvent)
// OPTIONAL MATCH (reaction)-[:input]->(entity1)
// OPTIONAL MATCH (reaction)-[:output]->(entity2)
// OPTIONAL MATCH (reaction)-->(:CatalystActivity)-->(entity3:PhysicalEntity)
// OPTIONAL MATCH (reaction)-->(:PositiveRegulation)-->(entity4:PhysicalEntity)
// OPTIONAL MATCH (reaction)-->(:NegativeRegulation)-->(entity5:PhysicalEntity)
// WITH
//     reaction,
//     entity1,
//     entity2,
//     entity3,
//     entity4,
//     entity5
//     ORDER BY entity1.dbId, entity2.dbId, entity3.dbId, entity4.dbId, entity5.dbId
// WITH
//     reaction,
//     COLLECT(DISTINCT entity1.dbId) AS inputs,
//     COLLECT(DISTINCT entity2.dbId) AS outputs,
//     COLLECT(DISTINCT entity3.dbId) AS enzymes,
//     COLLECT(DISTINCT entity4.dbId) AS pos,
//     COLLECT(DISTINCT entity5.dbId) AS neg
// RETURN inputs, outputs, enzymes, pos, neg, reaction.dbId
// ORDER BY SIZE(inputs), SIZE(outputs), SIZE(enzymes), SIZE(pos), SIZE(neg), inputs, outputs, enzymes, pos, neg, reaction.dbId
// ```
//
// ```
// MATCH (reaction:ReactionLikeEvent)
// CALL {
//     WITH reaction
//     MATCH (reaction)-[:input]->(entity)
//     WITH entity ORDER BY entity.dbId
//     WITH COLLECT(entity.dbId) AS entities
//     RETURN apoc.convert.toJson(entities) AS inputs
// }
// RETURN inputs, reaction.dbId
// ORDER BY inputs
// ```

// k_+^r product_((p, reactant, nu) \ in \ f(r)) [p]^(nu_reactant (p, r))
// - k_-^r product_((p, prod) \ in \ f(r)) [p]^(nu_prod (p, r))


// == Modeling



// handles both entities without
// compartments and entities that spread accross multiple compartments
// - $reactions subset.eq entities times T times stoichiometry(#none)$
// - $f : reactions -> powerset(entities times roles) times (entities times {reactant, prod} -> NN)$
// - $f : reactions times entities times {reactant, prod} -> NN_1$ where
// - $R subset.eq powerset(entities) times roles$

// - $reactions = (entities, edges(#none), stoichiometry(#none), stoichiometry(reactant))$
//     with
//     - $entities_reactant subset.eq powerset(entities)$ is the set of
//         reactants of the reaction
//     - $entities_prod subset.eq powerset(entities)$ is the set of products of
//         the reaction
//     - $stoichiometry(prod) : entities_prod -> NN_1$ describes the
//         stoichiometries of the reactants of the reaction
//     - $stoichiometry(reactant) : entities_reactant -> NN_1$ describes the
//         stoichiometries of the products of the reaction


// $
//     f_regulation^r =
//     product_((p, activator) \ in \ f (r) ) [p] / (K_A^(p, r) + [p])
//     product_((p, r) \ in \ E_R^inhibitor) K_I^(p, r) / (K_I^(p, r) + [p])
// $

// ```
// MATCH
//     (reaction1:ReactionLikeEvent)-[:input]->(entity),
//     (reaction2:ReactionLikeEvent)
// WHERE
//     reaction1 <> reaction2
//     AND NOT EXISTS {
//         MATCH (reaction2)-[:input]->(entity)
//     }
// RETURN COUNT(DISTINCT reaction1)
//
// ```

// ```
// MATCH
//     (reaction1:ReactionLikeEvent),
//     (reaction2:ReactionLikeEvent)
// WHERE
//     reaction1.dbId < reaction2.dbId
//     AND EXISTS {
//         MATCH (reaction1)-[:input]->(entity:PhysicalEntity)
//         WHERE NOT EXISTS { MATCH (reaction2)-[:input]->(entity) }
//     }
// RETURN COUNT(DISTINCT [reaction1.dbId, reaction2.dbId])
// ```

// - $reactions = (entities_prod, entities_reactant, stoichiometry(type: prod), stoichiometry(type: reactant))$
//     with
//     - $entities_reactant subset.eq powerset(entities)$ is the set of
//         reactants of the reaction
//     - $entities_prod subset.eq powerset(entities)$ is the set of products of
//         the reaction
//     - $stoichiometry(type: prod) : entities_prod -> NN_1$ describes the
//         stoichiometries of the reactants of the reaction
//     - $stoichiometry(type: prod) : entities_reactant -> NN_1$ describes the
//         stoichiometries of the products of the reaction


// - $edges(compartments) subset.eq entities times compartments$

// - $f_reactions : reactions -> powerset(entities times roles)$
// - $f_reactions : reactions -> (entities times {input, output} -> NN_1) union powerset(entities times {enzyme, activator, inhibitor})$
//
// #definition[Biochemical network][
//     A biochemical network $G$ is a tuple
//     $(entities, reactions, compartments, edges(reactions), edges(compartments), stoichiometry(#none))$
//     where
//
//     // - $entities$ is the set of physical entities in the biochemical network; to
//     //     be consisten with `Reactome` a physical entity models the instance of a
//     //     chemical entity in a compartment
//
//     // - $reactions$ is the set of reactions in the biochemical network
//     //
//     //     - $reactions_reversible subset.eq reactions$ is the subset of reactions
//     //         which are reversible
//
//     // - $compartments$ is the set of compartments in which the species are located
//
//     // - $edges(reactions) subset.eq entities times reactions times T$ describes
//     //     the roles the physical entities have in the reactions, with
//     //     $T = {output, input, enzyme, activator, inhibitor}$ as the set of roles
//     //
//     //     - given the definition of $edges(reactions)$, let
//     //         $edges(reactions)^role= {(p, r) | (p, r, role) in E}$ be the
//     //         selection of $E_R$ over $role in T$
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
//
// "activator means"
// 1. chemical catalysts: ioni di metalli, acidi o basi
// 2. cofactor: cambiamenti in temperatura, luce etc...
// 3. spontaneous reactions: guidate da condizioni termodinamiche favorevoli
// #note[
//     Qui ci aggiungerei la procedura che porta a generare un biochemical network
//     $G$ a partire da uno scenario $cal(S)$, come posso fare?
//
//     - in realtà ho già pronta l'analisi della parte di Reactome di interesse, e
//         l'operazione che produce $G$ a partire da $cal(S)$ scritta in FOL
//     - posso scrivere un algoritmo
// ]

// MATCH (reaction:ReactionLikeEvent {dbId: 10072442})
// OPTIONAL MATCH path1 = (reaction)-[:input|output]->()
// OPTIONAL MATCH path2 = (reaction)-->(:Regulation)-->(:PhysicalEntity)
// RETURN path1, path2

// MATCH
//     (reaction:ReactionLikeEvent)-[:input|output]->(entity:PhysicalEntity),
//     (reaction)-->(:Regulation)
// WHERE NOT EXISTS {
//     MATCH (reaction)-->(:CatalystActivity)
// }
// RETURN DISTINCT reaction.dbId
// LIMIT 20

// where
// - $xi (reaction) = { entity | (entity, reaction, role) in edges(reactions) }$
//
// - $reactions_reversible = { reaction }$
// denotes the roles a physical entity can have in a reaction
//
// - $roles(stoichiometric) = $
//
// - $roles(modifiers) = {}$


// #TODO[
//     At this point I think I'll work with @common-modular-rate-law, but allow the
//     tool to be configured in order to specify which rate law to use.
//
//     This can already be done in the current version of the code, but the only
//     rate law supported is the Mass Action rule.
// ]
/
