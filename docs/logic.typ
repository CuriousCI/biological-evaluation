#let comment-color = luma(80)
#let association-color = rgb("b16286")
#let attribute-color = rgb("98971a")
#let class-color = rgb("458588")
#let keyword-color = rgb("d79921")
#let keyword-weight = 400

#let association-color = black
#let attribute-color = black
#let class-color = black
#let keyword-color = black


#let world-keywords = (
    "true",
    "false",
    "min",
    "max",
    "argmin",
    "argmax",
    "sorted",
    "now",
    "auth",
    "this",
    "result",
)
#let logic-keywords = ("forall", "exists", "and", "or", "xor", "in")
#let logic-symbols = ("<->", "<=", "!=", "->")

// TODO: instead of function, do something like "show raw.where(lang: "logic")
// TODO: use more \b
#let logic(body) = {
    show sym.space.nobreak: hide(`  `)

    show regex("\b(" + world-keywords.join("|") + ")\b"): set text(
        keyword-color,
    )

    show regex("[A-Z]\w+"): set text(class-color, weight: 600)
    show regex("([\w_]+)\("): re => {
        show regex("[\w_]+"): re_group => text(
            association-color,
            re_group.text,
        )

        show regex("\b[a-z][\w_]+\b"): re_group => text(
            style: "italic",
            re_group.text,
        )


        re.text
    }

    show regex("#([\w_]+)\("): re => {
        show regex("[\w_]+"): re_group => text(
            attribute-color,
            underline(stroke: .25pt, re_group.text),
        )

        show "#": ""
        re.text
    }


    show regex("\b(" + logic-keywords.join("|") + ")\b"): re => eval(
        re.text,
        mode: "math",
    )

    show regex(logic-symbols.join("|")): re => eval(re.text, mode: "math")
    show regex("not"): $not #h(-.25em)$
    show regex("\$(.*?)\$"): re => eval(re.text, mode: "markup")

    body
}

#let v-half-line = v(-.5em)

#let indent(body) = context block(
    inset: (x: measure(`  `).width),
    body,
)

#let subsection(name, body) = {
    logic(name)
    v-half-line
    indent(logic(body))
}

#let constraint(name, body) = subsection(name, body)

#let operation(
    name,
    args: none,
    type: none,
    prec: none,
    post: none,
) = {
    logic[#name`(`#args`)`#if (type != none) [`:` #type]]

    if prec != none {
        v-half-line
        indent(subsection(`preconditions:`, prec))
    }

    if post != none {
        v-half-line
        indent(subsection(`postconditions:`, post))
    }
}


#let extension(
    body: none,
    new-objects: none,
    old-objects: none,
    tuple-variations: none,
) = {
    subsection(
        `modifiche al livello estensionale:`,
        {
            if body != none {
                v(2pt)
                body
            }

            let regular(body) = text(weight: "regular", body)

            if new-objects != none {
                if body != none { v(-.5em) }
                subsection(regular[nuovi oggetti:], new-objects)
            }

            if old-objects != none {
                if body != none or new-objects != none { v(-.5em) }
                subsection(regular[oggetti rimossi:], old-objects)
            }

            if tuple-variations != none {
                if body != none or new-objects != none or old-objects != none {
                    v(-.5em)
                }
                subsection(
                    regular[variazioni sulle tuple:],
                    tuple-variations,
                )
            }
        },
    )
}
