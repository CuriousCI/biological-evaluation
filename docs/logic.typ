#let association_predicate(it) = text(rgb("b16286"), it)
#let attribute_predicate(it) = text(rgb("98971a"), it)
#let comment(it) = text(luma(125), it)
#let formula_variable(it) = emph(it)
#let keyword(it) = text(rgb("d79921"), it)
#let operation_parameter(it) = underline(stroke: .3pt, emph(it))
#let type_predicate(it) = text(rgb("458588"), style: "normal", it)

// TODO: find a way to handle all Typst shorthands available in maths, without having to write them manually
// TODO: how can I (query / reference) (constraints / operations) / procedures? metadata()? label()?
// TODO: handle variables scopes

#let world-keywords = (
    "true",
    "false",
    "min",
    "max",
    "argmin",
    "argmax",
    "sorted",
    "now",
    "adesso",
    "auth",
    "this",
    "result",
)
#let logic-keywords = ("forall", "exists", "and", "or", "xor", "in")
#let logic-symbols = (
    "<=",
    ">=",
    "!=",
    "->",
    "-->",
    "=>",
    "==>",
    "<->",
    "<=>",
    "<==>",
)


#let logic(body, extra: ()) = {
    show regex("--.*\n"): re => comment(re)

    show regex("[A-Z]\w+"): re => type_predicate(re)

    show regex("[a-z][\w_]*\("): re => {
        show regex("[a-z][\w_]*"): re => association_predicate(re)
        re
    }

    show regex("#[a-z][\w_]*\("): re => {
        show regex("[a-z][\w_]*"): re => attribute_predicate(re)
        show "#": ""
        re
    }

    show regex("\b(" + world-keywords.join("|") + ")\b"): re => keyword(re)

    show regex("\b(" + logic-keywords.join("|") + ")\b"): re => eval(
        re.text,
        mode: "math",
    )

    show regex(logic-symbols.join("|")): re => eval(re.text, mode: "math")

    show regex("not"): $not #h(-.25em)$

    show regex("\$(.*?)\$"): re => eval(re.text, mode: "markup")

    let variables = ()
    if body.func() == raw {
        variables = body
            .text
            .split(regex("\n|\("))
            // Variables can be quantified with "forall", "exists" or in "set definitions"
            .filter(line => line.contains(regex("forall|exists|\{.*\|")))
            .map(line => line
                // "forall" and "exists" might be matched as variables with (\w+)
                .replace(regex("forall|exists"), "")
                .matches(regex("(\w+)"))
                .map(match => match.captures))
            .flatten()
    }

    // Exclude associations and attributes when matching variables
    show regex("[a-z][\w_]*\b[^\(].*[^\)]"): re => {
        show regex("\b(" + variables.join("|") + ")\b"): re => formula_variable(
            re,
        )
        show regex("\b(" + extra.join("|") + ")\b"): re => operation_parameter(
            re,
        )

        re
    }

    body
}


#let item(name, body, extra: ()) = {
    logic(name)
    list(marker: `  `, logic(body, extra: extra))
}

#let constraint(name, body) = item(name, body)

#let operation(
    name,
    parameters: ``,
    type: none,
    preconditions: none,
    postconditions: none,
) = {
    let entra = parameters
        .text
        .matches(regex("([\w]+):\s*(?:[A-Z][\w]+)"))
        .map(match => match.captures)
        .flatten()

    logic(extra: entra, {
        show raw: set block(above: .75em, below: .75em)
        name
        `(`
        parameters
        `)`
        if type != none {
            `:`
            type
        }
    })

    list(marker: `  `, {
        if preconditions != none {
            list.item(item(
                context ("it": `precondizioni`, "en": `preconditions`).at(
                    text.lang,
                ),
                preconditions,
                extra: entra,
            ))
        }
        if postconditions != none {
            list.item(item(
                context ("it": `postcondizioni`, "en": `postconditions`).at(
                    text.lang,
                ),
                postconditions,
                extra: entra,
            ))
        }
    })
}

// TODO: I can't use this in `raw` block
#let extension(
    body: none,
    new-objects: none,
    old-objects: none,
    tuple-variations: none,
) = {
    item(
        `modifiche al livello estensionale:`,
        {
            if body != none {
                // v(2pt)
                body
            }

            if new-objects != none {
                item([nuovi oggetti:], new-objects)
            }

            if old-objects != none {
                item([oggetti rimossi:], old-objects)
            }

            if tuple-variations != none {
                item(
                    regular[variazioni sulle tuple:],
                    tuple-variations,
                )
            }
        },
    )
}
