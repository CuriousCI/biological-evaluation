#import "lib.typ": *

== Reactions rate laws

In order to describe the kinetics of a biochemical network, the rate law for
each reaction must be defined.

// Given a biochemical network $network = (nodes, edges, stoichiometry)$, let
Given a simulable model $simulable = (entities, reactions, compartments)$, let
$[entity]$ denote the concentration of the physical entity $entity in entities$,
and $v_reaction$ denote the rate of reaction $r in R$.


A reaction has inputs, outputs, enzymes, activators and inhibitors. In order to
handle activators and inhibitors of the reaction $reaction$ let
$f_regulation^reaction$ be defined as:

$
    f_regulation^reaction =
    product_((entity, activator) \ in \ f_reactions (reaction)) [entity] / (K_A^(entity, reaction) + [entity])
    product_((entity, inhibitor) \ in \ f_reactions (reaction)) K_I^(entity, reaction) / (K_I^(entity, reaction) + [entity])
$

Given a reaction $reaction in reactions$, its rate $v_reaction$ can be defined
based on the reversibility of the reaction and the requirement of enzymes for
the reaction.

// 1. $r in.not R_reversible and not space exists e space (e, r) in E_R^enzyme$

// $
//     v_r = f_regulation^r dot.c k_+^r product_((p, r) \ in \ E_R^input) [p]^(nu_input (p, r))
// $ <mass-action-rule-1>

// 2. $r in R_reversible and not space exists e space (e, r) in E_(R,enzyme)$

$
    v_reaction = f_regulation^reaction dot.c
    (
        k_+^reaction product_((entity, input, stoichiometry) \ in \ f_reactions (reaction)) [entity]^stoichiometry
        - k_-^reaction product_((entity, output, stoichiometry) \ in \ f_reactions(reaction)) [entity]^stoichiometry
    )
$ <mass-action-rule-2>

// #TODO[
//     In @mass-action-rule-1 and @mass-action-rule-2 I'm not sure if
//     $f_regulation^r$ can be written there. In literature regulators act on
//     enzymes, but there are some reactions in Reactome with regulators and
//     without enzymes (@ /* TODO */).
// ]

// https://drive.google.com/drive/folders/1rYPkKR8hABMQrqS_t_V-kypnfoOCBtBM

// TODO: could be useful to add "r" to the contants only in the satisfiability problem definition
// in rate laws discussion ignore the "r"
// $
//     f_"reg" =
//     product_((s, r) \ in \ E_"activator") [s]^(n_s) / (K_s + [s]^(n_s))
//     product_((s, r) \ in \ E_"inhibitor") K_s / (K_s + [s]^(n_s))
// $
// If an enzyme is involved in a reaction, then the following happen:
// where

// 3. $r in.not R_reversible and exists e space (e, r) in E_R^enzyme$
//
// $
//     v_r = [e] dot.c f_regulation^r dot.c k_("cat",+)^r product_((p, r) \ in \ E_R^input) (sum_(n = 0)^(nu_input (p, r)) ([p] / K_m^(p, r))^(-n) )^(-1)
// $
// in R_reversible

If
$reaction "is reversible" and exists e space (e, enzyme) in f_reactions (reaction)$,
let @modular-rate-laws be the general form of a modular rate law that describes
the kinetics of the reaction

$
    v_reaction = [e] dot.c f_regulation^reaction dot.c N / D
$ <modular-rate-laws>

where

$
    N =
    k_("cat", +)^reaction product_((entity, input, stoichiometry) \ in \ f_reactions (reaction)) ([entity] / K_m^(entity, reaction))^stoichiometry
    - k_("cat", -)^reaction product_((entity, output, stoichiometry) \ in \ f_reactions (reaction)) ([entity] / K_m^(entity, reaction))^stoichiometry
$

$
    D = product_( (entity, input, stoichiometry) \ in \ f_reactions (reaction)) (sum_(n = 0)^stoichiometry ([entity] / K_m^(entity, reaction))^n )
    + product_( (entity, output, stoichiometry) \ in \ f_reactions (reaction) ) (sum_(n = 0)^stoichiometry ([entity] / K_m^(entity, reaction))^n )
    - 1
$ <common-modular-rate-law>

In the "Systems Biology" book #link(
    "https://drive.google.com/drive/folders/1rYPkKR8hABMQrqS_t_V-kypnfoOCBtBM",
)[(#underline[Klipp, Edda, Kowald, Axel], pages 49-50)] it says that the the
denominator $D$ can be one of the following:

1. Power-law modular rate law: $D = 1$

2. Common modular rate law (@common-modular-rate-law)

3. Simultaneous binding modular rate law
$
    D =
    product_( (entity, input, stoichiometry) \ in \ f_reactions (reaction)) (1 + [entity] / K_m^(entity, reaction))^stoichiometry
    product_( (entity, output, stoichiometry) \ in \ f_reactions (reaction)) (1 + [entity] / K_m^(entity, reaction))^stoichiometry
$

4. Direct binding modular rate law:
$
    D = 1
    + product_( (entity, input, stoichiometry) \ in \ f_reactions (reaction)) ([entity] / K_m^(entity, reaction))^stoichiometry
    + product_( (entity, output, stoichiometry) \ in \ f_reactions (reaction)) ([entity] / K_m^(entity, reaction))^stoichiometry
$

5. Force-dependent modular rate law:
$
    D = sqrt(
        product_( (entity, input, stoichiometry) \ in \ f_reactions (reaction)) (1 + [entity] / K_m^(entity, reaction))^stoichiometry
        product_( (entity, output, stoichiometry) \ in \ f_reactions (reaction)) (1 + [entity] / K_m^(entity, reaction))^stoichiometry
    )
$

