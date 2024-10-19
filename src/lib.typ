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
#let total_bib = context (query(selector(ref)).filter(it => it.element == none).map(it => it.target).dedup().len())

#let template(
  font-type: "Times New Roman",
  font-size: 14pt,
  heading1-font-size: 18pt,
  heading2-font-size: 16pt,
  link-color: blue,
  languages: {},
  body,
) = {
  // Configure font
  set text(font: font-type, lang: "ru", size: font-size, fallback: true, hyphenate: false)
  // Configure page settings
  set page(
    margin: (top: 2cm, bottom: 2cm, left: 2cm, right: 1cm), // размер полей (ГОСТ 7.0.11-2011, 5.3.7)
  )
  // Установка свойств параграфа
  set par(
    justify: true,
    linebreaks: "optimized",
    first-line-indent: 2.5em, // Абзацный отступ. Должен быть одинаковым по всему тексту и равен пяти знакам (ГОСТ Р 7.0.11-2011, 5.3.7).
    leading: 1em, // Полуторный интервал (ГОСТ 7.0.11-2011, 5.3.6)
  )

  // форматирование заголовков
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
    set block(above: 3em, below: 3em) // Заголовки отделяют от текста сверху и снизу тремя интервалами (ГОСТ Р 7.0.11-2011, 5.3.5)

    if it.level == 1 {
      pagebreak()
      counter(figure).update(0) // сброс значения счетчика рисунков
      counter(math.equation).update(0) // сброс значения счетчика уравнений
    } else {}
    it
  }

  // Отображение ссылок на figure (рисунки и таблицы) - ничего не отображать
  set ref(supplement: it => {
    if it.func() == figure {}
  })

  // Настройка блоков кода
  show: codly-init.with()
  codly(languages: languages)

  // Нумерация уравнений
  let eq_number(it) = {
    let part_number = counter(heading.where(level: 1)).get()
    part_number

    it
  }
  set math.equation(numbering: num =>
  ("(" + (counter(heading.where(level: 1)).get() + (num,)).map(str).join(".") + ")"), supplement: [Уравнение])

  // Настройка рисунков
  show figure: align.with(center)
  set figure(supplement: [Рисунок])
  set figure.caption(separator: [ -- ])
  set figure(numbering: num =>
  ((counter(heading.where(level: 1)).get() + (num,)).map(str).join(".")))

  // Настройка таблиц
  show figure.where(kind: table): set figure.caption(position: top)
  show figure.where(kind: table): set figure(supplement: [Таблица])
  show figure.where(kind: table): set figure(numbering: num =>
  ((counter(heading.where(level: 1)).get() + (num,)).map(str).join(".")))
  // Разбивать таблицы по страницам
  show figure: set block(breakable: true)

  // Настройка списков
  set enum(indent: 2.5em)
  set list(indent: 2.5em)

  // Set that we're in the body
  state("section").update("body")

  set page(
    numbering: "1", // Установка сквозной нумерации страниц
    number-align: center + bottom, // Нумерация страниц сверху, по центру
  )
  // counter(page).update(1)

  // Содержание
  // #align(right)[Стр.]
  outline(title: "Содержание", indent: 1.5em, depth: 3)

  body
}

// Нужно начать первый абзац в разделе с этой функции для отступа первой строки
#let indent-par(it) = par[#h(2.5em)#it]

// Set up the styling of the appendix.
#let phd-appendix(body) = {
  // Reset the title numbering.
  counter(heading).update(0)

  // Number headings using letters.
  show heading.where(level: 1): set heading(numbering: "Приложение A. ", supplement: [Приложение])
  show heading.where(level: 2): set heading(numbering: "A.1 ", supplement: [Приложение])

  // Set the numbering of the figures.
  set figure(numbering: (x) => locate(loc => {
    let idx = numbering("A", counter(heading).at(loc).first())
    [#idx.#numbering("1", x)]
  }))

  // Additional heading styling to update sub-counters.
  show heading: it => {
    appendix_count.step() // Обновление счетчика приложений
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

