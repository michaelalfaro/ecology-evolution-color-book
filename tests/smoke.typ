#import "../lib.typ": *
#show: book.with(title: [Smoke Test], subtitle: [Exercising lib.typ], author: [Test Author], affiliation: [UCLA], date: [2026], draft: true)

#frontmatter[
  #titlepage(title: [Smoke Test], subtitle: [Exercising lib.typ], author: [Test Author], affiliation: [UCLA], date: [2026], draft: true)
  #heading(level: 1, numbering: none, outlined: false)[Contents]
  #outline(title: none, depth: 2)
]

#mainmatter[
  #part([Light], gloss: [The illuminant and the object.])

  = What Color Is (and Isn't)
  #in-this-chapter([Color is a perception.], [Light is a spectrum.], [Endler's triangle.])
  #epigraph([The sky is blue because of the air, not despite it.], [A physicist])
  Body text with a citation @cuthill2017 and a margin note.#margin-note[Notes sit in the outer column.]
  #measure-it[Measure a feather at 45°.]

  == A section
  $ E = h nu $ <eq-planck>
  Equation @eq-planck, figure @fig-rect, margin figure @fig-margin, table @tbl-one.

  #fig("tests/smoke-rect.svg", [A test figure.], credit: [Photo: Test Author, CC BY 4.0]) <fig-rect>
  #margin-fig("tests/smoke-rect.svg", [A margin figure.]) <fig-margin>
  #figure(table(columns: 2, [a], [b]), caption: [A table.]) <tbl-one>

  #physics[Snell's law relates angles and refractive indices.]
  #casestudy(title: [The peacock])[Structural color in barbules.]
  #tryit(title: [Blue sky in a glass])[Shine a torch through milky water.]
  #tryit(title: [A second exercise])[Numbered 1.2.]
  #keyconcept[Color is made by the receiver.]
  #caveat[Human vision is not the reference.]

  #key-ideas([One], [Two], [Three])
  #open-questions([Why are some clades drab?])
  #going-further((cite: [@cuthill2017], note: [The field in twelve pages.]), [A plain item.])

  = Where Light Comes From
  == Another section
  Second chapter text.

  #part([Seeing])
  = Photoreceptors and Opsins
  Third chapter text. #tryit(title: [Restart])[Numbered 3.1.]
]

#heading(level: 1, numbering: none)[Bibliography]
#bibliography("smoke.bib", style: "apa", title: none)
