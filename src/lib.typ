#import "@preview/unify:0.7.0": *
#import "@preview/codly:1.2.0": *
#import "@preview/tablex:0.0.9": *
#import "@preview/physica:0.9.3": *

#let part_count = counter("parts")
#let total_part = context [#part_count.final().at(0)]
#let appendix_count = counter("appendix")
#let total_appendix = context [#appendix_count.final().at(0)]
#let total_page = context [#counter(page).final().at(0)]
#let total_fig = context [#counter(figure).final().at(0)]
#let total_table = context [#counter(figure.where(kind: table)).final().at(0)]
#let total_bib = context (
  query(selector(ref))
    .filter(it => it.element == none)
    .map(it => it.target)
    .dedup()
    .len()
)

#let template(
  font-type: "Times New Roman",
  font-size: 14pt,
  heading1-font-size: 16pt,
  heading2-font-size: 14pt,
  link-color: blue,
  body,
) = {
  set text(
    font: font-type,
    lang: "ru",
    size: font-size,
    fallback: true,
    hyphenate: false,
  )

  let footnote_reset() = {
    counter(footnote).update(0)
  }

  set page(
    margin: (top: 2cm, bottom: 2cm, left: 3cm, right: 1cm),
    numbering: "1",
    number-align: center + bottom,
    header: footnote_reset(),
  )

  set par(
    justify: true,
    linebreaks: "optimized",
    first-line-indent: (amount: 2.5em, all: true),
    leading: 1.5em,
    spacing: 1.5em,
  )

  set heading(numbering: "1.", outlined: true, supplement: [Раздел])
  show heading: it => {
    set align(center)
    if it.level == 1 {
      set text(font: font-type, size: heading1-font-size)
    } else if it.level == 2 {
      set text(font: font-type, size: heading2-font-size)
    } else {
      set text(font: font-type, size: font-size)
    }
    set block(above: 2em, below: 2em)
    it
  }

  set ref(
    supplement: it => {
      if it.func() == figure { }
    },
  )

  show: codly-init.with()
  codly(
    number-format: none,
    zebra-fill: rgb("#f7f7f7"),
    stroke: 1pt + gray,
    lang-format: none,
    smart-indent: true,
  )

  show raw.where(block: true): set par(first-line-indent: 0em)
  show raw.where(block: true): set text(size: 10pt, font: "JetBrains Mono NL")

  let eq_number(it) = {
    let part_number = counter(heading.where(level: 1)).get()
    part_number

    it
  }
  set math.equation(
    numbering: num => (
      "("
        + (counter(heading.where(level: 1)).get() + (num,)).map(str).join(".")
        + ")"
    ),
    supplement: [Уравнение],
  )

  show figure: align.with(center)
  set figure.caption(separator: [ -- ])

  show figure: set block(breakable: false)
  show figure.where(kind: image): set figure(supplement: [Рисунок])
  show figure.where(kind: image): set figure.caption(position: bottom)
  show figure.where(kind: image): set block(breakable: false)

  show figure.where(kind: table): set figure(supplement: [Таблица])
  show figure.where(kind: table): set figure.caption(position: top)
  show figure.where(kind: table): set block(breakable: false)

  show figure.where(kind: raw): set figure(supplement: [Код])
  show figure.where(kind: raw): set figure.caption(position: bottom)
  show figure.where(kind: raw): set block(breakable: false)

  set enum(indent: 2.5em)
  set list(indent: 2.5em)

  state("section").update("body")

  set footnote(
    numbering: it => {
      "*" * counter(footnote).get().at(0)
    },
  )

  body
}

