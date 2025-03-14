#import "../lib.typ": *

= Глава 1. Обзор структуры данных суффиксного дерева и алгоритмов его построения<theory>

== Понятие суффиксного дерева и его применения

#figure(
  image("../images/suffix-tree.png", width: 80%),
  caption: [Схема суффиксного дерева для строки _abrakadabra_.],
)

В компьютерных науках суффиксным деревом принято называть бор#footnote(
  [Префиксное дерево (бор) --- структура данных, представляющая из себя дерево с
    символами на ребрах. При прохождении от корня к произвольному листу указанного
    дерева последовательная запись символов на ребрах образует закодированную
    строку.],
), построенный на суффиксах некоторой строки. Такая
структура данных позволяет решать набор задач анализа строк за линейное время, в отличие от
тривиальных решений указанных задач, которые занимают асимтотически большее
время. К таким задачам можно отнести:
- Поиск количества различных подстрок данной строки
- Поиск наибольшей общей подстроки двух строк
- Нахождение суффиксного массива и массива _lcp_ (longest common prefix) исходной
- Поиск всех вхождений подстроки (в том числе регулярного выражения)

Зачастую для реализации структуры данных суффиксного дерева используется
древесная структура с произвольным количеством дочерних узлов в каждом узле
дерева. Для реализации большинства алгоритмов построения суффиксного дерева
необходимо добавление в конец изначального слова защитного символа, не входящего
в "алфавит", на котором построено указанное слово (Рисунок @image-abbabac).

#figure(
  image("../images/abbabac.png", width: 50%),
  caption: [Схема суффиксного дерева для строки _abbabac\$_, где _\$_ --- защитный символ,
    значения в листьях --- индексы, по которым встречаются закодированные суффиксы.],
) <image-abbabac>

== "Наивный" алгоритм построения суффиксного дерева

Для построения сжатого суффиксного дерева в учебных целях часто рассматривается
"наивный" алгоритм, который так называется по причине его низкой
производительности. Ход алгоритма заключается в переборе всех суффиксов от
самого длинного (непосредственно самой строки / последовательности) до самого
короткого. При этом если в строящемся дереве уже существует суффикс, совпадающий
с добавляемым суффиксом некоторым префиксом, указанный префикс выносится в
отдельный узел дерева, а его дочерними элементами становятся различающиеся части
указанных суффиксов.

Описанный алгоритм является простейшим из рассматриваемых в работе и имеет
временную сложность в $O(n^2)$ и пространственную сложность в $O(n)$. Также
недостатком описанного алгоритма является тот факт, что это _offline_ алгоритм,
то есть для его работы необходимо заранее знать всю изначальную строку целиком.

== Алгоритм МакКрейта

Алгоритм построения суффиксного дерева, предложенный МакКрейтом в 1976 году
(также называемый алгоритмом _mcc_), схож с рассматриваемым в предыдущем разделе "наивным"
алгоритмом тем, что в нем рассматриваются суффиксы в порядке уменьшения длин
суффиксов. Отличие же заключается в том, что для быстрого вычисления места,
откуда нужно продолжить построение нового суффикса, алгоритм добавляет
суффиксную ссылку#footnote(
  [Пусть $x alpha$ обозначает произвольную строку, где $x$ --- ее первый символ, а $alpha$
    --- оставшаяся подстрока (возможно пустая). Если для внутренней вершины $v$ с
    путевой меткой $x alpha$ существует другая вершина $s(v)$ с путевой меткой $alpha$,
    то ссылка из $v$ в $s(v)$ называется суффиксной ссылкой.],
) в каждой вершине. Данная операция позволяет снизить временную сложность с $O(n^2)$ до $O(n)$.

Основополагающей идеей алгоритма является поддержание двух инвариантов:
+ Для всех вершин, кроме, возможно, последней добавленной, известны суффиксные
  ссылки.
+ Суффиксная ссылка всегда ведет в вершину дерева, а не в середину ребра.

Использование указанных инвариантов позволяет сократить временную сложность
одной итерации алгоритма с $O(n)$ до $O(1)$, так как теперь работа алгоритма
сводится к построению еще не существующих суффиксных ссылок, что позволяет
снизить общую временную сложность алгоритма до $O(n)$.

Преимуществом алгоритма МакКрейта в сравнении с предшествующим ему исторически
алгоритмом Вайнера (1973 год) стала значительная экономность в отношении памяти,
затрачиваемой алгоритмом (алгоритм МакКрейта обладает пространственной
сложностью в $O(n)$). Алгоритм Вайнера для своей работы требовал хранения в
каждом узле двух массивов размера алфавита, на котором построено слово, что
делало его крайне затратным в отношении используемой памяти.

Недостатком же рассматриваемого алгоритма является то, что он также как и "наивный"
алгоритм является _offline_ алгоритмом, что ограничивает его применение в
некоторых случаях.

== Алгоритм Укконена

Алгоритм Укконена построения суффиксного дерева (также называемый алгоритмом _ukk_),
аналогично алгоритму МакКрейта, требует линейное количество времени и памяти
(амортизированная оценка), а также является _online_ алгоритмом, в чем и
заключается его главное преимущество. @book-ukkonen Подобная скорость и экономность
по отношению к затрачиваемой памяти обусловлена рядом оптимизаций, которые
применены к простейшему алгоритму построения суффиксного дерева, который требует
порядка $O(n^3)$ времени для своей работы.

#figure(
  image("../images/ukkonen.png", width: 80%),
  caption: [Построение суффиксного дерева за $O(n^3)$ для слова _abca\$_.],
) <image-ukkonen>

Как можно видеть на рисунке @image-ukkonen, суть алгоритма с временной сложностью
в $O(n^3)$ --- последовательно добавлять в суффиксное дерево еще не существующий
в нем суффикс и продлевать существующие. Укконен предложил оптимизировать
указанный алгоритм следующими тремя способами:
+ Так как при добавлении символа к листу дерева образуется новый лист, можно по
  умолчанию создавать лист до конца строки, что можно выразить в равенстве
  бесконечности индекса правой границы рассматриваемой подстроки.
+ Прохождение по ребру дерева для большего суффикса означает, что прохождение по
  этому ребру для меньших суффиксов уже произошло, поэтому алгоритм не будет
  повторять это действие для меньших суффиксов.
+ Для увеличения скорости работы алгоритма и уменьшения затрачиваемого
  пространства вводятся суффиксные ссылки. Работа алгоритма сводится к повторению
  фаз, использующих последовательно 3 правила продления суффикса (продление листа,
  создание развилки, ничего не делать) и вводится лемма, гласящая о том, что при
  применении 3-го типа продления в продолжении суффикса, начинающегося в позиции $j$ оно
  же и будет применяться во всех дальнейших продолжениях (от $j+1$ по $i$) до
  конца фазы.

Не смотря на свои преимущества при сравнении с вышеупомянутыми алгоритмами,
алгоритм Укконена имеет следующие недостатки:
+ При подробном рассмотрении работы алгоритма, можно заметить, что настоящая
  временная сложность алгоритма --- $O(n dot |Sigma|)$, где $Sigma$ --- алфавит,
  на котором построено слово. По этой причине алгоритм Укконена принимает
  временную сложность в $approx O(n^2)$ при построении суффиксных деревьев для
  нерегулярных слов (слов с редким повторением символов).
+ Константная оценка времени работы одной итерации алгоритма является
  амортизированной, в худшем случае алгоритм совершает одну свою итерацию с
  временной сложностью в $O(n)$, что опять приводит к общей временной сложности
  работы алгоритма в $O(n^2)$.
+ В силу особенностей работы алгоритма, объем памяти, занимаемый созданным
  деревом, может в несколько раз превышать объем памяти, занимаемый входными
  данными, однако он все еще оценивается в $O(n)$.

== Сравнение алгоритмов

Каждый из рассмотренных алгоритмов имеет оценку по пространственной сложности в $O(n)$.
Рассмотрим алгоритмы с точки зрения их временной сложности (Таблица @table-time-complexity).

#figure(
  table(
    columns: 3,
    rows: 4,
    table.header(
      table.cell(rowspan: 2)[Алгоритм],
      table.cell(colspan: 2)[Временная сложность],
      [Амортизированная],
      [Худший случай],
    ),

    ["Наивный" алгоритм], [$O(n^2)$], [$O(n^2)$],
    [Алгоритм МакКрейта], [$O(n)$], [$O(n)$],
    [Алгоритм Укконена],
    [$O(n)$],
    [$O( n^2 )$#footnote([Может принимать сложность $O(n^2)$ в случаях с большим изначальным алфавитом и
        обработке нерегулярных слов.])],
  ),
  caption: [Сравнение временной сложности рассмотренных алгоритмов построения суффиксного
    дерева.],
) <table-time-complexity>

Мы можем сразу же убрать "наивный" алгоритм построения суффиксного дерева из
рассмотрения, так как он очевидно проигрывает в производительности остальным
рассматриваемым алгоритмам. В выборе между алгоритмом МакКрейта и алгоритмом
Укконена построения суффиксного дерева ключевым решающим фактором становится
возможность алгоритма работать в режиме _online_. Алгоритм Укконена обладает
такой возможностью, что позволит нам при проектировании классов суффиксного
дерева добавить помимо класса обыкновенного сжатого суффиксного дерева также
класс сжатого суффиксного дерева, работающего в режиме _online_.

== Сравнение суффиксного дерева со сбалансированным деревом поиска в задачах анализа строк

Сравним суффиксное дерево с более универсальной структурой данных, предназначенной
для сравнительно быстрого поиска (за $O(log(n))$) по некоторому множеству --- сбалансированным деревом поиска.
Для хранения всех суффиксов некоторой строки в сбалансированном дереве поиска
можно сравнивать данные суффиксы в лексико-графическом порядке при их добавлении
в дерево поиска. При этом для экономии памяти мы не будем хранить суффиксы в виде
строк, а только их начальные индексы. Не смотря на то, что такая структура дерева
поиска может показаться похожей на суффиксное дерево, она не позволяет эффективно
решать некоторые задачи, которые решаются с использованием суффиксного дерева за
линейное время. Это обусловлено тем, что а таком случае дерево поиска не
хранит подстроки изначальной строки, а только ее суффиксы. Сравним временную и
пространственную сложности построения суффиксного дерева и предложенного
сбалансированного дерева поиска (Таблица @table-suffix-tree-search-tree-comparison).

#figure(
  table(
    columns: 5,
    rows: 3,
    table.header(
      table.cell(rowspan: 2)[Структура данных],
      table.cell(colspan: 2)[Временная сложность],
      table.cell(colspan: 2)[Пространственная сложность],
      [Аморт.],
      [Худш.],
      [Аморт.],
      [Худш.],
    ),

    [Сбал. дерево поиска], [$O(n)$], [$O(n^2)$], [$O(n)$], [$O(n)$],
    [Суффиксное дерево], [$O(n)$], [$O(n^2)$], [$O(n)$], [$O(n^2)$],
  ),
  caption: [Сравнение временной и пространственной сложности алгоритмов
    построения сбалансированного дерева поиска и суффиксного дерева.
    #footnote([Рассматривается суффиксное дерево построенное, при помощи алгоритма
      Укконена.])],
) <table-suffix-tree-search-tree-comparison>

Анализируя таблицу @table-suffix-tree-search-tree-comparison, можно предположить,
что сбалансированное дерево поиска справляется с задачами
анализа и поиска строк эффективнее, чем суффиксное дерево, однако задачи,
решаемые с применением суффиксного дерева за линейное время,
принимают большую временную сложность при использовании сбалансированного дерева
поиска (в силу отличающейся структуры дерева), что представлено в
таблице @table-task-comparison.

#figure(
  table(
    columns: 3,
    rows: 3,
    table.header(
      [Задача],
      [Суффиксное дерево],
      [Сбал. дерево поиска],
    ),

    [Проверка на вхождение суффикса], [$O(m)$], [$O(m)$],
    [Проверка на вхождение подстроки], [$O(m)$], [$O(m^2)$],
    [Поиск повтор. подстрок], [$O(m)$], [$O(m dot n)$],
    [Поиск совпадений с регулярным выражением], [$O(n)$], [$O(m dot n)$],
    [Поиск длиннейшей / кротчайшей повторяющейся подстроки],
    [$O(n)$],
    [$O(n^3)$],
  ),
  caption: [Сравнение временной сложности алгоритмов, решающих прикладные задачи
    анализа строк с применением суффиксного дерева и сбалансированного дерева поиска.
    #footnote[$n$ --- длина исходной строки, $m$ --- длина искомой / анализируемой подстроки.]],
) <table-task-comparison>

== Итоги исследования

Большинство задач, которые решаются быстрее при построении суффиксного дерева,
имеют собственные алгоритмы решения, обладающие временной и пространственной
сложностями, сопоставимыми с временной и пространственной сложностями построения
суффиксного дерева, однако суффиксное дерево позволяет решить множество подобных
задач за меньшее время. Однако существуют и те задачи, которые не имеют более
простого алгоритма решения с сопоставимыми временной и пространственной
сложностями. Одна из таких задач --- поиск длиннейшей повторяющейся подстроки за $O(n)$.
Эта задача была взята для проверки работы реализованного суффиксного дерева.

Для реализации структуры данных суффиксного дерева была выбрана древесная
структура данных с произвольным количеством дочерних узлов для каждого узла.
Узлы построенного дерева не будут хранить подстроки входной строки, в целях
экономии занимаемого пространства будут использованы индексы, соответствующие
началу и концу произвольной подстроки. Каждый узел дерева будет хранить
суффиксную ссылку на идентичный узел в другом месте дерева (если таковая
существует, это необходимо для оптимальной работы рассмотренных в работе
алгоритмов, в частности алгоритма Укконена), а также ассоциативный массив (хеш-таблицу) дочерних узлов
по их уникальным идентификаторам (выбор хеш таблицы обусловлен возможностью
добавления элемента и доступа к нему с временной сложностью в $O(1)$).

Используемый алгоритм построения дерева --- алгоритм Укконена. Данный выбор
обусловлен возможностью реализовать наиболее универсальный класс суффиксного
дерева, в том числе способный работать в режиме _online_. В случае необходимости
оптимальной работы реализуемой структуры данных на больших алфавитах и
нерегулярных словах / последовательностях стоит прибегнуть к использованию
алгоритма МакКрейта, однако это решение приведет к потере возможности строить
суффиксное дерево в режиме реального времени.

Суффиксное дерево позволяет значительно эффективнее решать прикладные задачи
анализа строк. При сравнении со сбалансированным деревом поиска суффиксное
дерево показывает лучшие (по временной сложности применяемого для
решения задачи алгоритма) результаты при решении указанных задач.

