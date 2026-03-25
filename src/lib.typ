#import "@preview/unify:0.7.1": *
#import "@preview/codly:1.3.0": *
#import "@preview/physica:0.9.5": *

#let template(
  font: "Times New Roman",
  math-font: "New Computer Modern Math",
  raw-font: "DejaVu Sans Mono",
  font-size: 14pt,
  raw-font-size: 10pt,
  h1-font-size: 16pt,
  h2-font-size: 14pt,
  link-color: blue,
  lang: "ru",
  hyphenate: false,
  page-margin: (left: 3cm, right: 1cm, top: 2cm, bottom: 2cm),
  page-number-align: bottom + center,
  par-first-line-indent: (amount: 1.25cm, all: true),
  par-spacing: 1.5em,
  par-line-spacing: 1.5em,
  table-par-line-spacing: 1em,
  footnote-par-spacing: 1.5em,
  footnote-par-line-spacing: 1em,
  table-par-spacing: 1em,
  heading-spacing: 2.5em,
  heading-numbering: none,
  pagebreak-h1-headings: true,
  part-dependent-figure-counters: false,
  cite-style: "gost-r-705-2008-numeric",
  bibliography-style: "gost-r-705-2008-numeric",
  body,
) = {
  let footnote-reset() = {
    counter(footnote).update(0)
  }

  set text(
    font: font,
    lang: lang,
    size: font-size,
    fallback: true,
    hyphenate: hyphenate,
  )

  // Set page style
  set page(
    margin: page-margin,
    numbering: "1",
    number-align: page-number-align,
    header: footnote-reset(),
  )

  // Set text paragraph style
  set par(
    justify: true,
    linebreaks: "optimized",
    first-line-indent: par-first-line-indent,
    leading: par-line-spacing,
    spacing: par-spacing,
  )

  // Set heading style
  show heading: set align(center)
  show heading: set block(above: heading-spacing, below: heading-spacing)
  show heading.where(level: 1): it => {
    set text(size: h1-font-size)

    if part-dependent-figure-counters {
      counter(figure.where(kind: image)).update(0)
      counter(figure.where(kind: table)).update(0)
      counter(figure.where(kind: raw)).update(0)
      counter(math.equation).update(0)
      counter("definition").update(0)
      counter("theorem").update(0)
      counter("statement").update(0)
    }

    if pagebreak-h1-headings {
      pagebreak(weak: true)
    }

    it
  }
  show heading.where(level: 2): it => {
    set text(size: h2-font-size)

    it
  }
  show heading: it => {
    set text(size: font-size)

    it
  }

  // Set footnote style
  show footnote.entry: set par(
    spacing: footnote-par-spacing,
    leading: footnote-par-line-spacing,
  )
  // Set footnote counter to be displayed as a number of asterisks
  set footnote(numbering: it => "*" * counter(footnote).get().at(0))

  // Set citation style
  set cite(style: cite-style)

  // Set outline style
  show outline: set outline(indent: 1.5em, depth: 3, title: "Содержание")

  // Set figure styles
  set figure(numbering: num => {
    if part-dependent-figure-counters {
      let part-count = context counter(heading.where(level: 1)).get().at(0)
      [#part-count.#num]
    } else {
      [#num]
    }
  })
  set figure.caption(separator: [ --- ])
  show figure: align.with(center)
  show figure: set block(breakable: false)
  // Set image figure style
  show figure.where(kind: image): set figure(supplement: [Рисунок])
  show figure.where(kind: image): set figure.caption(position: bottom)
  // Set table figure style
  show figure.where(kind: table): set figure(supplement: [Таблица])
  show figure.where(kind: table): set figure.caption(position: top)
  // Set listing figure style
  show figure.where(kind: raw): set figure(supplement: [Код])
  show figure.where(kind: raw): set figure.caption(position: bottom)

  // Set math equation style
  set math.equation(
    numbering: num => {
      if part-dependent-figure-counters {
        let part-count = context counter(heading.where(level: 1)).get().at(0)
        [(#part-count.#num)]
      } else {
        [(#num)]
      }
    },
    supplement: [Уравнение],
  )
  show math.equation: set text(font: math-font)

  // Set table style
  set table(align: center + horizon)
  show table: set par(
    leading: table-par-line-spacing,
    spacing: table-par-spacing,
  )

  // Set listing style
  show: codly-init.with()
  codly(
    number-format: none,
    zebra-fill: rgb("#f7f7f7"),
    stroke: 1pt + gray,
    lang-format: none,
    smart-indent: true,
  )
  show raw.where(block: true): set par(first-line-indent: 0cm)
  show raw: set text(size: raw-font-size, font: raw-font)

  // Set bibliography style
  show bibliography: set bibliography(
    title: "Список литературы",
    full: true,
    style: bibliography-style,
  )

  body
}

#let enable-heading-numbering(style: "1.", h1-style: "Глава 1.", body) = {
  show heading: set heading(numbering: style)
  show heading.where(level: 1): set heading(numbering: h1-style)

  body
}

#let disable-heading-numbering(body) = {
  show heading: set heading(numbering: none)

  body
}

#let include-pdf-page(pdf-path) = {
  page(
    margin: 0pt,
    header: none,
    footer: none,
  )[
    #image(pdf-path, width: 100%, height: 100%)
  ]
}

#let special-section(title, counter-name, use-part-counts: false, body) = {
  let section_cnt = context counter(counter-name).get().at(0)
  context counter(counter-name).step()

  if use-part-counts {
    let part_cnt = context counter(heading.where(level: 1)).get().at(0)
    [*#title #part_cnt.#section_cnt.* #body]
  } else {
    [*#title #section_cnt.* #body]
  }
}

#let definition(body) = {
  special-section("Определение", "definition", body)
}

#let theorem(body) = {
  special-section("Теорема", "theorem", body)
}

#let statement(body) = {
  special-section("Утверждение", "statement", body)
}

