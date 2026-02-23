#let REACTOME-LABELS = (
    "\b(" + csv("public/labels.csv").flatten().join("|") + ")\b"
)
#let REACTOME-RELATIONS = (
    "\b(" + csv("public/relations.csv").flatten().join("|") + ")\b"
)


#let navy = blue.darken(30%)
// #let navy = black

// ---

#let roles = text(navy, $cal(T)$)
#let role = text(navy, $t$)

#let input = text(navy, `reactant`)
#let output = text(navy, `product`)
#let enzyme = text(navy, `enzyme`)
#let activator = text(navy, `activator`)
#let inhibitor = text(navy, `inhibitor`)

#let rstoichiometric = text(navy, `stoichiometric`)
#let rmodifiers = text(navy, `modifier`)
#let rreagents = text(navy, `reagent`)
// #let rreagents = text(navy, $upright(cal(R))$)

// ---

#let network = text(navy, $upright(G)$)
#let nodes = text(navy, $upright(V)$)
#let edges = text(navy, $upright(E)$)
#let edge = text(navy, $upright(e)$)
// #let stoichiometry = text(navy, $upright(nu)$)
#let stoichiometry = text(navy, $n$)

// ---

#let entities = text(navy, $upright(X)$)
#let entity = text(navy, $x$)

#let pathways = text(navy, $scr(P)$)
// #let pathway = text(navy, $scr(p)$)
#let pathway = text(navy, $p$)

#let reactions = text(navy, $upright(R)$)
#let reaction = text(navy, $r$)

#let compartments = text(navy, $upright(C)$)
#let compartment = text(navy, $c$)
#let compartmentfunc = text(navy, $cal(c)$)

// ---

#let rcomponents = text(navy, $xi$)
#let ecomponents = text(navy, $rho$)
#let pcomponents = text(navy, $phi$)

// ---

#let scope = text(navy, $upright(S)$)

#let boundary = text(navy, `boundary`)
#let interest = text(navy, `interest`)
#let excluded = text(navy, `excluded`) // TODO: add excluded species

#let data = text(navy, `data`)

// ---

#let boundaryincoming = text(navy, `incoming`)
#let boundaryoutgoing = text(navy, `outgoing`)

// #interest
#let reachable = text(navy, `reachable`)







#let reversible = text(blue, `reversible`)
#let regulation = `regulation`
#let rate = `rate`

#let modifiers = text(navy, $upright(M)$)
#let reagents = text(navy, $upright(I)$)

// ---

#let simulable = text(navy, $upright(S)$)
#let time = text(navy, $upright(T)$)


// In particular let $roles_inputs, roles_modifiers, roles_entities$
// #let stoichiometric = ""
// #let modifiers = ""
// #let roles(subset: none) = {
//     if subset == stoichiometric {
//         return text(red, $roles()_upright(S)$)
//     }
//
//     if subset == modifiers {
//         return text(red, $roles()_upright(M)$)
//     }
//
//     text(red, $upright(T)$)
// }

// where $roles_upright(I) = { input } union roles(rmodifier)$



// #let edges(type) = text(red, $upright(E)_type$)
// #let edges2 = text(red, $upright(E)$)

#let powerset(set_) = text(navy, $cal(P)$) + $(#set_)$
#let domain(func_) = text(navy, $cal(D)(#func_)$)

// sigma

// #{
//     set math.equation(numbering: none)
// }

// (type) = {
//     if type == none {
//         return text(red, $nu$)
//     }
//
//     return text(red, $nu_type$)
// }

// REACTION_SPEED = auto()
// PRODUCTION_SPEED = auto()
// CONSUMPTION_SPEED = auto()
// SPECIES_CONCENTRATION = auto()
// HALF_SATURATION = auto()

// substarte
// Metabolites
// partecipants

#let TODO(it) = box(stroke: 1pt + red, fill: red.lighten(95%), inset: 1em, it)

#let definition(caption, body) = {
    let definition = "definition"
    strong({
        upper(definition.first()) + definition.slice(1)
        sym.space
        context counter(definition).step()
        context counter(definition).display()
        sym.space
    })
    [_(#caption)*.*_]
    linebreak()

    body
    // sym.space
    // block(inset: 1em, fill: silver, body)
}

#let separator = line(stroke: .1pt + gray, length: 100%)

#let template(doc) = {
    set text(
        font: "New Computer Modern",
        lang: "en",
        weight: "light",
        size: 11pt,
    )
    // set page(margin: 1.75in)
    set page(margin: 1.55in)
    set par(leading: 0.55em, spacing: 0.85em, justify: true)
    set heading(numbering: "1.1")
    set math.equation(numbering: "(1)")
    set raw(syntaxes: "public/Cypher.sublime-syntax", lang: "cyp")
    set table(stroke: .25pt)

    show sym.exists: sym.exists + $space.thin$
    show sym.not: sym.not + $space.thin$
    show sym.emptyset: sym.diameter

    show heading: set block(above: 1.4em, below: 1em)
    show raw: set text(font: "LMMonoLt10", size: 10.5pt)
    show raw: set block(
        fill: luma(253),
        stroke: .1pt,
        breakable: false,
        width: 100%,
        inset: 1em,
    )

    show regex(REACTOME-LABELS): it => underline(stroke: .1pt, offset: 2pt, raw(
        it.text,
    ))

    show table: it => {
        show regex(REACTOME-RELATIONS): it => emph(raw(it.text))
        it
    }

    show figure: it => {
        show regex(REACTOME-RELATIONS): it => emph(raw(it.text))
        it
    }

    show math.equation: it => {
        show raw: set text(size: 9pt)
        it
    }

    show "Reactome": it => context {
        show raw: set text(size: text.size)
        raw(it.text)
    }

    show "SBML": it => context {
        show raw: set text(size: text.size)
        raw(it.text)
    }

    doc
}
