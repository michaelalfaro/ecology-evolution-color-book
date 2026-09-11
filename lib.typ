// lib.typ — the only file that knows how the book looks.
// Verified against Typst 0.15.1, hydra 0.6.3, marginalia 0.3.1 (spike 2026-09-10).
#import "@preview/hydra:0.6.3": hydra
#import "@preview/marginalia:0.3.1" as marginalia: wideblock

// ---------- palette & fonts ----------
#let accent = rgb("#2457B0")
#let ink-muted = rgb("#5B6470")
#let palette = (
  physics: rgb("#2457B0"),
  casestudy: rgb("#2E7D4F"),
  tryit: rgb("#DF5A1C"),
  keyconcept: rgb("#6B3FA0"),
  caveat: rgb("#B3413A"),
)
#let serif = "Libertinus Serif"
#let sans = "Source Sans 3"
#let mono = "JetBrains Mono"
#let mathfont = "Libertinus Math"

// ---------- counters ----------
#let part-counter = counter("part")
#let tryit-counter = counter("tryit")

// ---------- small helpers ----------
#let label-text(body) = text(font: sans, size: 9pt, weight: "semibold", tracking: 0.06em, fill: ink-muted, upper(body))
#let chapter-number() = context numbering("1", counter(heading).get().first())

// ---------- margin notes ----------
#let margin-note(body) = marginalia.note(numbering: none, text(size: 9pt, body))
#let measure-it(body) = marginalia.note(numbering: none)[#label-text[Measure it] \ #text(size: 9pt, body)]
#let margin-fig(path, caption, credit: none) = marginalia.notefigure(
  image(path, width: 100%),
  caption: if credit == none { caption } else { caption + [ #text(font: sans, size: 7.5pt, fill: ink-muted, credit)] },
)

// ---------- figures ----------
#let fig(path, caption, credit: none, width: 100%) = figure(
  image(path, width: width),
  caption: if credit == none { caption } else { caption + h(0.5em) + text(font: sans, size: 8pt, fill: ink-muted, credit) },
)

// ---------- parts ----------
// A part is a figure of kind "part" so it appears in the outline with its title;
// the show rule in `book` draws the full page.
#let part(title, gloss: none) = {
  pagebreak(to: "odd", weak: true)
  part-counter.step()
  figure(kind: "part", supplement: [Part], numbering: "I", caption: title, outlined: true,
    if gloss == none { [] } else { gloss })
  pagebreak(to: "odd", weak: true)
}

// ---------- boxes ----------
#let _titled-box(color, title, body) = block(
  width: 100%, radius: 4pt, stroke: 0.6pt + color, breakable: true, inset: 0pt, clip: true,
  above: 1.4em, below: 1.4em,
)[
  #block(width: 100%, fill: color, inset: (x: 10pt, y: 5pt), sticky: true, below: 0pt)[
    #text(font: sans, fill: white, weight: "semibold", size: 10pt, title)
  ]
  #block(width: 100%, fill: color.lighten(92%), inset: (x: 10pt, y: 8pt), above: 0pt, body)
]
#let physics(title: [Physics of Light], body) = _titled-box(palette.physics, title, body)
#let casestudy(title: [Case study], body) = _titled-box(palette.casestudy, [Case study: #title], body)
#let caveat(title: [Caveat], body) = _titled-box(palette.caveat, title, body)
#let keyconcept(body) = block(
  width: 100%, fill: palette.keyconcept.lighten(92%), stroke: (left: 3pt + palette.keyconcept),
  inset: (x: 10pt, y: 8pt), above: 1.4em, below: 1.4em, breakable: true,
)[#label-text[Key concept] \ #body]
#let tryit(title: [], body) = {
  tryit-counter.step()
  block(
    width: 100%, fill: palette.tryit.lighten(92%), stroke: (left: 3pt + palette.tryit),
    inset: (x: 10pt, y: 8pt), above: 1.4em, below: 1.4em, breakable: true,
  )[
    #text(fill: palette.tryit, weight: "semibold")[Try it #chapter-number()\.#context tryit-counter.display()]
    #if title != [] [ — #strong(title)] \
    #body
  ]
}

// ---------- chapter apparatus ----------
#let epigraph(quote, who) = block(inset: (left: 2em, right: 2em), above: 1em, below: 2em)[
  #emph(quote) \ #align(right, text(size: 9.5pt, fill: ink-muted)[— #who])
]
#let _apparatus(title, items) = block(above: 1.6em, below: 1.2em, width: 100%)[
  #label-text(title) \
  #list(..items)
]
#let in-this-chapter(..items) = block(above: 0pt, below: 1.5em, width: 100%)[
  #label-text[In this chapter] \
  #text(font: sans, size: 10pt)[#list(..items.pos())]
]
#let key-ideas(..items) = _apparatus([Key ideas], items.pos())
#let open-questions(..items) = _apparatus([Open questions], items.pos())
#let going-further(..items) = _apparatus([Going further], items.pos().map(it =>
  if type(it) == dictionary { [#it.cite #h(0.4em) #text(fill: ink-muted, it.note)] } else { it }))

// ---------- title page & matter ----------
#let titlepage(title: [], subtitle: [], author: [], affiliation: [], date: [], draft: true) = page(header: none, footer: none)[
  #v(22%)
  #text(size: 34pt, weight: "bold", title) \
  #v(0.6em)
  #text(size: 16pt, fill: ink-muted, subtitle)
  #v(2.5em)
  #text(size: 14pt, author) \ #text(size: 11pt, fill: ink-muted, affiliation)
  #v(1fr)
  #text(font: sans, size: 9pt, fill: ink-muted)[#date #if draft [ · DRAFT — not for redistribution]]
]
#let frontmatter(body) = { set page(numbering: "i"); body }
#let mainmatter(body) = { set page(numbering: "1"); counter(page).update(1); body }

// ---------- the book wrapper ----------
#let book(title: [], subtitle: [], author: [], affiliation: [], date: [], draft: true, body) = {
  set document(title: title, author: if type(author) == str { author } else { "" })
  set page(paper: "us-letter", binding: left, numbering: "1", footer: none,
    header: context {
      // no running head on a page that opens a chapter or a part
      let openers = query(heading.where(level: 1)).filter(h => h.location().page() == here().page())
      let parts = query(figure.where(kind: "part")).filter(p => p.location().page() == here().page())
      if openers.len() > 0 or parts.len() > 0 { none } else {
        set text(font: sans, size: 9pt, fill: ink-muted)
        let n = counter(page).display()
        if calc.odd(here().page()) { [#hydra(2) #h(1fr) #n] } else { [#n #h(1fr) #hydra(1)] }
      }
    })
  show: marginalia.setup.with(
    inner: (far: 12mm, width: 0mm, sep: 0mm), outer: (far: 10mm, width: 42mm, sep: 8mm),
    top: 20mm, bottom: 24mm, book: true)
  set text(font: serif, size: 11pt, number-type: "old-style")
  show math.equation: set text(font: mathfont)
  show raw: set text(font: mono, size: 9pt)
  set par(justify: true, first-line-indent: (amount: 1.2em, all: false), leading: 0.62em)
  show link: set text(fill: accent)

  // headings: level 1 = chapter, 2 = section, 3 = subsection
  set heading(numbering: "1.1.1")
  show heading.where(level: 1): it => {
    if it.numbering == none {
      pagebreak(to: "odd", weak: true)
      block(above: 3em, below: 2em, text(size: 26pt, weight: "bold", it.body))
    } else {
      pagebreak(to: "odd", weak: true)
      tryit-counter.update(0)
      counter(figure.where(kind: image)).update(0)
      counter(figure.where(kind: table)).update(0)
      counter(math.equation).update(0)
      block(above: 4em, below: 2.5em, width: 100%)[
        #text(font: sans, size: 11pt, weight: "semibold", tracking: 0.08em, fill: accent)[CHAPTER #counter(heading).display("1")]
        #v(0.2em) #line(length: 100%, stroke: 0.75pt + accent)
        #v(0.4em) #text(size: 26pt, weight: "bold", it.body)
        #v(0.4em) #line(length: 100%, stroke: 0.75pt + accent)
      ]
    }
  }
  show heading.where(level: 2): it => block(above: 1.8em, below: 0.9em)[
    #text(size: 15pt, weight: "bold")[#text(fill: accent, counter(heading).display("1.1")) #h(0.6em) #it.body]
  ]
  show heading.where(level: 3): it => block(above: 1.4em, below: 0.7em)[
    #text(size: 12pt, weight: "bold")[#text(fill: accent, counter(heading).display("1.1.1")) #h(0.6em) #it.body]
  ]

  // per-chapter numbering of figures, tables, equations
  set figure(numbering: n => numbering("1.1", counter(heading).get().first(), n))
  set math.equation(numbering: n => numbering("(1.1)", counter(heading).get().first(), n))
  show figure.caption: it => text(size: 9.5pt, it)

  // part pages
  show figure.where(kind: "part"): it => page(fill: accent.lighten(88%), header: none, footer: none)[
    #set align(left)
    #set par(first-line-indent: 0pt)
    #pad(left: 12mm, top: 28%)[
      #text(size: 120pt, weight: "bold", fill: accent)[#context part-counter.display("I")]
      #v(0.5em)
      #text(size: 32pt, weight: "bold", it.caption.body)
      #v(1em)
      #text(size: 13pt, fill: ink-muted, it.body)
    ]
  ]

  // outline: part banners, then chapters and sections
  show outline.entry: it => {
    if it.element.func() == figure {
      v(1em, weak: true)
      block(fill: accent.lighten(85%), inset: 6pt, width: 100%)[
        #text(weight: "bold")[Part #numbering("I", part-counter.at(it.element.location()).first()) #h(1em) #it.element.caption.body]
      ]
    } else if it.level == 1 {
      v(0.6em, weak: true); strong(it)
    } else { it }
  }
  set outline(target: selector.or(heading.where(outlined: true), figure.where(kind: "part")))

  body
}
