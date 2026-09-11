// main.typ — the order of the book. Design lives in lib.typ; prose lives in chapters/.
#import "lib.typ": *

#let title = [The Ecology and Evolution of Color]
#let subtitle = [From Photons to Phylogenies]
#let only = sys.inputs.at("chapter", default: none)   // e.g. --input chapter=05
#let today = datetime.today().display("[month repr:long] [day], [year]")

// ch(n, path): include a chapter; in single-chapter mode, skip others and set the chapter number.
#let ch(n, path) = {
  if only == none { include path }
  else if only == n { counter(heading).update(int(n) - 1); include path }
}
// parts are skipped in single-chapter mode
#let pt(title, gloss: none) = if only == none { part(title, gloss: gloss) }

#show: book.with(title: title, subtitle: subtitle, author: "Michael E. Alfaro",
  affiliation: [Department of Ecology and Evolutionary Biology, UCLA], date: [Draft of #today], draft: true)

#if only == none [
  #frontmatter[
    #titlepage(title: title, subtitle: subtitle, author: [Michael E. Alfaro],
      affiliation: [Department of Ecology and Evolutionary Biology, UCLA],
      date: [Draft of #today], draft: true)
    #include "frontmatter/preface.typ"
    #heading(level: 1, numbering: none, outlined: false)[Contents]
    #outline(title: none, depth: 2)
  ]
]

#mainmatter[
  #pt([Light], gloss: [The illuminant and the object. Endler's triangle is the spine of the book.])
  #ch("01", "chapters/01-what-color-is.typ")
  #ch("02", "chapters/02-where-light-comes-from.typ")
  #ch("03", "chapters/03-scattering.typ")
  #ch("04", "chapters/04-interference-and-reflection.typ")

  #pt([Seeing], gloss: [The receiver, bottom-up: molecule, organ, circuit, experience.])
  #ch("05", "chapters/05-photoreceptors-and-opsins.typ")
  #ch("06", "chapters/06-evolution-of-eyes.typ")
  #ch("07", "chapters/07-building-a-color-percept.typ")
  #ch("08", "chapters/08-umwelten.typ")

  #pt([Measuring and Modeling Color], gloss: [The bridge from physics and vision to everything that follows.])
  #ch("09", "chapters/09-measuring-color.typ")
  #ch("10", "chapters/10-modeling-the-receiver.typ")

  #pt([Making Color])
  #ch("11", "chapters/11-pigments.typ")
  #ch("12", "chapters/12-structural-color.typ")
  #ch("13", "chapters/13-mixed-mechanisms.typ")
  #ch("14", "chapters/14-color-change.typ")

  #pt([Patterning])
  #ch("15", "chapters/15-how-patterns-form.typ")
  #ch("16", "chapters/16-genetics-of-color-and-pattern.typ")

  #pt([What Color Does])
  #ch("17", "chapters/17-crypsis.typ")
  #ch("18", "chapters/18-aposematism-and-mimicry.typ")
  #ch("19", "chapters/19-signals.typ")
  #ch("20", "chapters/20-color-for-the-body.typ")
  #ch("21", "chapters/21-color-beyond-animals.typ")

  #pt([Color Across the Tree of Life])
  #ch("22", "chapters/22-how-we-study-color-evolution.typ")
  #ch("23", "chapters/23-how-life-became-colorful.typ")
  #ch("24", "chapters/24-epilogue.typ")
]

#if only == none [
  #heading(level: 1, numbering: none)[Bibliography]
  #bibliography("refs.bib", style: "apa", title: none)
]
