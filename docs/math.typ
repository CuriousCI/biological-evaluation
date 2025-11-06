#let definition(name, body) = context {
    [
        #heading(outlined: false, numbering: none, level: 4, {
            [Definition]
            counter("definition").step()
            math.space
            context counter("definition").display()
            [ (]
            text(style: "italic", name)
            [)]
        }) #label(name.replace(" ", "-"))
    ]

    box(inset: (left: .5em), body)
}

#let algorithm(name, body) = context {
    box(width: 100%, inset: (y: .5em), stroke: (y: .25pt), {
        counter("algorithm").step()
        strong({
            [Algorithm ]
            context counter("algorithm").display()
            [: ]
        })
        name
    })
    box(
        width: 100%,
        inset: (left: measure($quad$).width, bottom: .75em),
        stroke: (bottom: .25pt),
        body,
    )
}
