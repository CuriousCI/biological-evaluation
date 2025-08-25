#let indent-width = 1em
// #let indent-width = 1.2em

#let comment-color = luma(80)
#let association-color = rgb("b16286")
#let attribute-color = rgb("98971a")
#let class-color = rgb("458588")
#let keyword-color = rgb("d79921")

// #let comment-color = luma(80)
// #let association-color = rgb("458588")
// #let attribute-color = rgb("98971a")
// #let class-color = black
// #let keyword-color = rgb("d79921")

// #let comment-color = luma(80)
// #let association-color = luma(150)
// #let attribute-color = black
// #let class-color = black
// #let keyword-color = black

#let keyword-weight = "bold"

#let to-string(it) = {
    if type(it) == str {
        it
    } else if type(it) != content {
        str(it)
    } else if it.has("text") {
        it.text
    } else if it.has("children") {
        it.children.map(to-string).join()
    } else if it.has("body") {
        to-string(it.body)
    } else if it == [] {
        " "
    }
}

#let indent-block(body) = box(inset: (x: indent-width), body)

#let regular(body) = text(weight: "regular", body)

#let world-keywords = (
    "true",
    "false",
    "result",
    "now",
    "argmax",
    "argmin",
    "this",
    "auth",
    "sorted",
)
#let logic-keywords = ("forall", "exists", "and", "or", "xor", "in")
#let logic-symbols = ("<->", "<=", "!=", "->")

#let logic(body) = {
    show sym.space.nobreak: hide(`	`)
    show emph: set text(
        // font: "Latin Modern Mono",
        font: "LMMonoLt10",
        association-color,
        weight: keyword-weight,
    )

    show regex("[\w_]+\("): set text(attribute-color, weight: keyword-weight)
    show regex("\("): set text(black, weight: 300)
    show regex("\b(" + world-keywords.join("|") + ")\b"): set text(
        keyword-color,
        weight: keyword-weight,
    )
    show regex("\b(" + logic-keywords.join("|") + ")\b"): re => eval(
        re.text,
        mode: "math",
    )
    show regex(logic-symbols.join("|")): re => eval(re.text, mode: "math")

    show regex("not"): $not #h(-.25em)$

    show regex("\$(.*?)\$"): re => eval(re.text, mode: "markup")
    show regex("[A-Z]\w+"): set text(
        class-color,
        // font: "Latin Modern Mono Caps",
        font: "LMMonoCaps10",
        style: "normal",
        weight: keyword-weight,
    )
    show regex("\*(\S*)\*"): re => {
        show "*": ""
        emph(re.text)
    }

    // set text(font: "Latin Modern Mono", lang: "it")
    // show raw: set text(font: "Latin Modern Mono", lang: "it")
    set text(font: "LMMonoLt10", lang: "it")
    show raw: set text(font: "LMMonoLt10", lang: "it")

    body
}

// show raw: set text(font: "CaskaydiaCove NFM", lang: "it", weight: "light", size: 9pt)
// set text(font: "CaskaydiaCove NFM", lang: "it", weight: "light", size: 9pt)
// strong(text(font: "New Computer Modern", size: 11pt, title))

#let sub-par(
    title,
    body,
) = {
    // text(font: "Latin Modern Mono Caps", title)
    text(font: "LMMonoCaps10", title)
    linebreak()
    indent-block(logic(body))
}

// underline(offset: 1.5pt, stroke: .1pt, title)

#let constraint(
    name,
    body,
) = {
    box(
        stroke: (y: .25pt),
        inset: (y: .5em),
        width: 100%,
        logic(text(font: "LMMonoLt10", name)),
        // logic(text(font: "Latin Modern Mono", name)),
    )

    v(-.5em)

    par(indent-block(logic(body)))
}

// highlight(extent: .5em)[
// line(stroke: .1pt, length: 100%)
// line(stroke: .1pt, length: 100%)
// ]
//   #figure(kind: "constraint", supplement: to-string(name),
// )
// font: "New Computer Modern Math",
// set text(font: "Latin Modern Mono Caps", lang: "it")
// #label(to-string(name))
// #label("constraint")

#let operation(
    name,
    args: none,
    type: none,
    prec: none,
    post: none,
) = {
    box(
        stroke: (y: .25pt),
        inset: (y: .5em),
        width: 100%,
        // logic[#text(font: "Latin Modern Mono")[#name\(#args)#if (
        logic[#text(font: "LMMonoLt10")[#name\(#args)#if (
                type != none
            ) [: #type]]],
    )

    if prec != none {
        v(-.5em)
        par(indent-block(sub-par([preconditions:], prec)))
    }

    if post != none {
        v(-.5em)
        par(indent-block(sub-par([postconditions:], post)))
    }
}

// highlight(extent: .5em)[
// #figure(
//     kind: "operation",
//     supplement: to-string(name),
// )
// ]
// label(to-string(name))
// label("operation")


#let extension(
    body: none,
    new-objects: none,
    old-objects: none,
    tuple-variations: none,
) = {
    sub-par(
        [modifiche al livello estensionale:],
        {
            if body != none {
                v(2pt)
                body
            }

            if new-objects != none {
                if body != none { v(-.5em) }
                par(sub-par(regular[nuovi oggetti:], new-objects))
            }

            if old-objects != none {
                if body != none or new-objects != none { v(-.5em) }
                par(sub-par(regular[oggetti rimossi:], old-objects))
            }

            if tuple-variations != none {
                if body != none or new-objects != none or old-objects != none {
                    v(-.5em)
                }
                par(sub-par(regular[variazioni sulle tuple:], tuple-variations))
            }
        },
    )
}

// v(-.5em)
// v(-.5em)
// #let trigger(name, operations, function, invocation: [after]) = [
//     === [Trigger.Constraint.#name]
//
//     #indent-block[
//         / intercepted operations: #operations
//         / invocation: #invocation
//         #text(weight: "bold")[function]\(old, new)
//         #indent-block[#function]
//     ]
// ]
//
// #let query(name, type: [], args: [], body: []) = [
//
//     == #emph(name)\(#args)#if type != [] [: #type]
//
//     #v(5pt)
//
//     // #if pre != [] or post != [] [
//     // #h(10pt) #text(weight: "bold")[pre-condizioni]
//
//     // #if pre != [] [ #block( inset: ("left": 20pt), [#pre]) ]
//
//     // #h(10pt) #text(weight: "bold")[post-condizioni]
//
//     #if body != [] [ #block(inset: ("left": 20pt), [#body]) ]
//
//     #v(10pt)
//     // ]
// ]
