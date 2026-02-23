#import "lib.typ": *

// TODO: IMPORTANT!!
// TODO: le costanti cinetiche devono essere molto simili fra loro (quando sbrodolo una reazione)!
// TODO: iperparametro: tolleranza tra le costanti, se è 0 riuso la variabile, altrimenti aggiungo la variabile e il vincolo
// TODO: un po' come visto per la reversibilità (per reversibilità basta vedere l'originale)
// TODO: eventi E = { e_1, e_2, ..., e_n }
// - banana (valore): o istante in cui avviene
//
// INDICATORI (definiti dall'utente: nome: {id}, valore: numerico):
// - alla fine della simulazione sputo fuori gli indicatori
// - l'utente specifica un ordine parziale tra i valori degli indicatori
// - l'utente può specificare più vincoli di ordinamento parziale fra sottoinsiemi di questi indicatori
//    - [e1] < [e2]
//    - istante [e1] finale > istante [e2] finale
//
//
//    K1 -> i1, i2, i3
//    K2 -> i4, i5, i6
//
//    I' subset { indicatori istante di tempo specie arriva a conc. finale }
//    I' { i1, i2, i3 }
//
//    i1, i2
//    i3
//
// vincoli hard (possono esere aggiunti dall'utente, es. non tutti 0, strutturale, plausibilità fisiologica)
//
// CONSTRAINTS
// - structurals
// - indicators
// - the patient is alive
//
// - modificatori: disponibili quanto ne serve
//
//
//
//
// - vincoli: nome di funzione python che rappresenta quel vincolo + libreria di vincoli (nome funzione + args, o tutti gli indicatori e il corpo libero o "scope + violazione" e somma)

// #TODO[
//     Ho momentaneamente escluso la parte cinetica dal .pdf, la devo riscrivere in
//     base alle nuove definizioni.
//
//     Inoltre, la definizione del problema di soddisfacibilità sottostante va
//     riscritta dato che ora sono previste solo reazioni non-reversibili (dove le
//     reversibili sono divise in due reazioni separate)
// ]

// TODO: are the inverse reactions automatically take into account?
// TODO: one can prove that "if r in R_interest => then r_reverse in R_interest"

#let value = text(navy, $upright(v)$)
#let indicators = text(navy, $upright(I)$)

#definition[Biological model satisfiability problem][
    Given a biological network $network$ let $time, indicators$ be such that:
    - $time$ is the time horizon for the simulation
    - TODO: tollerances for kinetic constants of the same reaction
    - TODO: tollerances for kinetic constants of reversible reactions
    - $indicators$ is the set of indicators to measure
        - given a trajectory // $tau : [0, T] ->
    - TODO: additional constrain
    // $time, entities_data, value, epsilon, phi$ be such that:
    // - $time$ is the time horizon for the simulation
    // - $entities_data subset.eq entities$ is the subset of entities for which a
    //     target concentration must be reached at stability
    // - $value : entities_data -> [0, 1]$ is the function that defines the target
    //     concentration at stability
    // - $epsilon in RR$ the error (meaning
    //     $[entity] in [value(entity) - epsilon, value(entity) + epsilon]$
    // - $phi in [0, 1]$ is the ... after which the concentrations must be stable


    Let $chevron.l theta, D, C chevron.r$ be the satisfiability problem where

    $
        theta = & {t_reaction | reaction in reactions } \
        & union {t_entity | entity in entities} \
        & union {t^(entity, reaction)_A | (entity, reaction, activator) in edges } \
        & union {t^(entity, reaction)_I | (entity, reaction, inhibitor) in edges} \
        & union {t^(entity, reaction)_(m, +) | reaction "involves an enzyme and" entity "is a reactant of" reaction } \
        & union {t^(entity, reaction)_(m, -) | reaction "involves an enzyme and" entity "is a product of" reaction } \
        & union {entity_"avg" | entity in entities}
    $

    The respsective kinetic constants are defined as $10^t$, for example
    - $k^(entity, reaction)_A = 10^(t^(entity, reaction)_A)$

    $
        D = & { D_(t_entity) | D_(t_entity) = [0, 1] } \
            & union { "all other domains are" [-6, 6] }
    $

    Constraints

    $ forall entity in entities quad 0 <= [entity] <= 1 $

    $
        forall entity in entities_"avg" quad [entity] (phi dot.c T) - [entity] (T) = 0 "(stability)"
    $

    $
        forall entity_"avg" in entities_"avg" quad [entity_"avg"] in [value (entity) - epsilon, value(entity) + epsilon ]
    $

    $
        & forall k^reaction_1, k^reaction_2 in X, entity in entities \
        & quad "if " entity " is a modifier of " k_reaction_2 "and is produced by" k^reaction_1 "then" k_reaction_1 < k_reaction_2
        // & quad (p, r_1, i) in E and (s, r_2) in (E_(m^+) union E_(m^-)) and r_1 != r_2 -> k_r_1 < k_r_2
    $



    // other constraints here...

    // $ forall s in cal(S) quad 0 <= [s] <= 1 $
    // $
    //     & forall k_r_1, k_r_2 in cal(K), s in S \
    //     & quad (s, r_1, i) in E and (s, r_2) in (E_(m^+) union E_(m^-)) and r_1 != r_2 -> k_r_1 < k_r_2
    // $
    //
    // $ forall s in cal(S)_"avg" quad s (phi dot.c T) - s(T) = 0 $
]

#definition[Optimization problem][
    Basically take the satisfiability problem above and turn it in a "single
    objective optimization problem"

]

// $
//     X = & { K^(entity, reaction)_A | (entity, activator) in f_reactions (reaction) } \
//     & union {K^(entity, reaction)_I | (entity, inhibitor) in f_reactions (reaction)} \
//     & union {k^reaction | reaction in reactions } \
//     & union {K^(entity, reaction)_(m, +) | exists nu space (entity, output, nu) in f_reactions (reaction) and exists e space (e, enzyme) in f_reactions (reaction))} \
//     & union {K^(entity, reaction)_(m, -) | exists nu space (entity, input, nu) in f_reactions (reaction) and exists e space (e, enzyme) in f_reactions (reaction))} \
//     & union {K_entity | entity "is both sink and source" }
// $


// , a subset , a function for the entities, $epsilon$ (the

// Given a simulable model $simulable$, // normalized biochemical network $G$ let
// $T$ the simulation horizon, $f_data : entities_data -> [0, 1]$ the
// experimental concentrations of some entities, let
// $chevron.l space.thin X,D,C space.thin chevron.r$ be the satisfiability
// problem where:
//
// $
//     X = & { K^(entity, reaction)_A | (entity, activator) in f_reactions (reaction) } \
//     & union {K^(entity, reaction)_I | (entity, inhibitor) in f_reactions (reaction)} \
//     & union {k^reaction | reaction in reactions } \
//     & union {K^(entity, reaction)_(m, +) | exists nu space (entity, output, nu) in f_reactions (reaction) and exists e space (e, enzyme) in f_reactions (reaction))} \
//     & union {K^(entity, reaction)_(m, -) | exists nu space (entity, input, nu) in f_reactions (reaction) and exists e space (e, enzyme) in f_reactions (reaction))} \
//     & union {K_entity | entity "is both sink and source" }
// $

// union & {K^(p, r)_I | r in R and exists p space (p, r) in E_R^inhibitor)} \
// union & {k^r_+ | r in R and not exists e space (e, r) in E_R^enzyme)} \
// union & {k^r_- | r in R_reversible and not exists e space (e, r) in E_R^enzyme)} \
// union & {k^r_("cat", +) | r in R and exists e space (e, r) in E_R^enzyme)} \
// union & {k^r_("cat", -) | r in R_reversible and exists e space (e, r) in E_R^enzyme)} \
// union & {k^(entity, reaction)_(m, -) | (entity, r) in E_R^output and exists e space (e, r) in E_R^enzyme)} \

// $
//     X = & { K^(p, r)_A | r in R and exists p space (p, r) in E_R^activator)} \
//     union & {K^(p, r)_I | r in R and exists p space (p, r) in E_R^inhibitor)} \
//     union & {k^r_+ | r in R and not exists e space (e, r) in E_R^enzyme)} \
//     union & {k^r_- | r in R_reversible and not exists e space (e, r) in E_R^enzyme)} \
//     union & {k^r_("cat", +) | r in R and exists e space (e, r) in E_R^enzyme)} \
//     union & {k^r_("cat", -) | r in R_reversible and exists e space (e, r) in E_R^enzyme)} \
//     union & {k^(p, r)_(m) | (p, r) in E_R^input and exists e space (e, r) in E_R^enzyme)} \
//     union & {k^(p, r)_(m) | (p, r) in E_R^output and exists e space (e, r) in E_R^enzyme)} \
// $

// #separator

// #separator


// Given a biological model $B = (G, cal(K))$ and a let $cal(S)$ be the set of
// concentrations of species of the species in the network,
// $cal(S) = {s | s in S}$ and $S_"avg" = {s_"avg" | s in S}$ the set of
// average concentrations of the species, $T in RR^+$ the time horizon,
// $phi in [0, 1]$ the following constraints must hold:

