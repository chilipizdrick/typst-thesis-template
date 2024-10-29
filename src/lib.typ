#import "@preview/unify:0.5.0": *
#import "@preview/codly:0.2.0": *
#import "@preview/tablex:0.0.8": *
#import "@preview/physica:0.9.3": *
#import "@preview/indenta:0.0.3": fix-indent

#let part_count = counter("parts")
#let total_part = context[#part_count.final().at(0)]
#let appendix_count = counter("appendix")
#let total_appendix = context[#appendix_count.final().at(0)]
#let total_page = context[#counter(page).final().at(0)]
#let total_fig = context[#counter(figure).final().at(0)]
#let total_table = context[#counter(figure.where(kind: table)).final().at(0)]
#let total_bib = context (query(selector(ref)).filter(it => it.element ==
none).map(it => it.target).dedup().len())

#let template(
  font-type: "Times New Roman", font-size: 14pt, heading1-font-size: 16pt, heading2-font-size: 14pt,
  link-color: blue, languages: {}, body,
) = {
  set text(
    font: font-type, lang: "ru", size: font-size, fallback: true,
    hyphenate: false,
  )

  set page(
    margin: (top: 2cm, bottom: 2cm, left: 2cm, right: 1cm), // размер полей (ГОСТ 7.0.11-2011, 5.3.7)
  )

  set par(
    justify: true, linebreaks: "optimized", first-line-indent: 2.5em, leading: 1em,
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

    if it.level == 1 {
      counter(math.equation).update(0)
      counter(figure.where(kind: table)).update(0)
      counter(figure.where(kind: image)).update(0)
      counter(figure.where(kind: math.equation)).update(0)
      counter(math.equation).update(0)
      counter(figure.where(kind: raw)).update(0)
    } else {}
    it
  }

  set ref(supplement: it => {
    if it.func() == figure {}
  })

  show: codly-init.with()
  codly(languages: languages)

  let eq_number(it) = {
    let part_number = counter(heading.where(level: 1)).get()
    part_number

    it
  }
  set math.equation(
    numbering: num =>
    (
      "(" + (counter(heading.where(level: 1)).get() + (num,)).map(str).join(".") + ")"
    ), supplement: [Уравнение],
  )

  show figure: align.with(center)
  set figure(supplement: [Рисунок])
  set figure.caption(separator: [ -- ])
  // set figure(numbering: num =>
  // ((counter(heading.where(level: 1)).get() + (num,)).map(str).join(".")))

  show figure.where(kind: table): set figure.caption(position: top)
  show figure.where(kind: table): set figure(supplement: [Таблица])
  // show figure.where(kind: table): set figure(numbering: num =>
  // ((counter(heading.where(level: 1)).get() + (num,)).map(str).join(".")))
  show figure: set block(breakable: true)

  set enum(indent: 2.5em)
  set list(indent: 2.5em)

  state("section").update("body")

  let footnote_reset() = {
    counter(footnote).update(0)
  }

  set page(
    numbering: "1", number-align: center + bottom, header: footnote_reset(),
  )

  set footnote(numbering: it => {
    "*" * counter(footnote).get().at(0)
  })

  body
}

#let indent-par(it) = par[#h(2.5em)#it]

#let phd-appendix(body) = {
  counter(heading).update(0)

  show heading.where(level: 1): set heading(numbering: "Приложение A. ", supplement: [Приложение])
  show heading.where(level: 2): set heading(numbering: "A.1 ", supplement: [Приложение])

  set figure(numbering: (x) => locate(loc => {
    let idx = numbering("A", counter(heading).at(loc).first())
    [#idx.#numbering("1", x)]
  }))

  show heading: it => {
    appendix_count.step()
    counter(figure.where(kind: table)).update(0)
    counter(figure.where(kind: image)).update(0)
    counter(figure.where(kind: math.equation)).update(0)
    counter(figure.where(kind: raw)).update(0)

    it
  }

  // Set that we're in the annex
  state("section").update("annex")

  body
}

#let icon(image) = {
  box(height: .8em, baseline: 0.05em, image)
  h(0.1em)
}

