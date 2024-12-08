#import "lib.typ": *

#set cite(style: "./csl/bib-style.csl")
#show: template.with()
#show heading: set heading(numbering: none)
#counter(page).update(2)

// Table of contents
#outline(title: "Содержание", indent: 1.5em, depth: 3, fill: none)

#show heading: it => {
  if it.level == 1 {
    pagebreak();
  }
  it
}

#include "./parts/intro.typ"

// Chapters of the document
#part_count.step()
#include "./parts/theory.typ"

#part_count.step()
#include "./parts/practice.typ"

// Conclusion
#include "./parts/conclusion.typ"

// Bibliography
#set text(lang: "en")
#bibliography(
  "./common/bibliography.bib",
  title: "Список литературы",
  full: true,
  style: "./csl/bib-style.csl",
)
#set text(lang: "ru")

#counter(figure.where(kind: image)).update(0)
#counter(figure.where(kind: raw)).update(0)
#counter(figure.where(kind: table)).update(0)
// Appendix
#include "./parts/appendix.typ"
