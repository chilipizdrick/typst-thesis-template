#import "lib.typ": *

#show: template.with()

#set cite(style: "./csl/bib-style.csl")

#show heading: set heading(numbering: none)
#include "./parts/intro.typ"

// Enable enumeration
#show heading.where(level: 1): set heading(numbering: "1.")
#show heading.where(level: 2): set heading(numbering: "1.1.")
#show heading.where(level: 3): set heading(numbering: "1.1.1.")

#part_count.step()
#include "./parts/theory.typ"
#part_count.step()
#include "./parts/practice.typ"

// Disable enumeration
#show heading: set heading(numbering: none)

// Conclusion
#include "./parts/conclusion.typ"

// Bibliography
#set text(lang: "en")
#bibliography(
  title: "Список литературы", "./common/bibliography.bib", full: true, style: "./csl/bib-style.csl",
)
#set text(lang: "ru")

// Appendix
#include "./parts/appendix.typ"
