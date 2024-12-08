#include <cstdlib>
#include <iostream>
#include <map>
#include <sstream>
#include <string>
#include <vector>

class Node;
class Suffix;
class SuffixTree;

class Node {
    friend class SuffixTree;
    friend class Suffix;

    friend std::ostream &operator<<(std::ostream &, const Node &);
    friend std::istream &operator>>(std::istream &, Node &);
    friend std::istream &operator>>(std::istream &is,
                                    SuffixTree &tree);

  private:
    Node(Node *, int, int *, int);
    int edge_length() { return *end_index - begin_index + 1; }
    void add_child(const SuffixTree &, Node *);
    void remove_child(const SuffixTree &, Node *);
    bool is_leaf() { return children.empty(); }
    void split_edge(const SuffixTree &, int, int);
    Node *get_child(const SuffixTree &, int char_index);
    int get_key(const SuffixTree &, Node *, int) const;

    Node *parent;
    std::map<int, Node *> children;
    Node *suffix_link;
    int begin_index;
    int *end_index;
    int ID;
};

class Suffix {
    friend class SuffixTree;

  private:
    Suffix(Node *, int);
    Node *node;
    bool new_internal_node;
    int char_index;
    bool ends_at_node() const;
    bool ends_at_leaf() const;
    bool continues_with_char(const SuffixTree &, int) const;
    bool RULE2_conditions(const SuffixTree &, int) const;
    Node *walk_up(int &, int &) const;
};

class SuffixTree {
  public:
    SuffixTree();
    void construct(std::string);
    std::string tree_graph();
    char get_char_at_index(int) const;

    int find_suffix(const std::string &);
    std::string LRS();
    std::string LRS(Node *, std::string);

    friend std::ostream &operator<<(std::ostream &,
                                    const SuffixTree &);
    friend std::istream &operator>>(std::istream &, SuffixTree &);

  private:
    std::string tree_string;
    std::string node_graph(Node *parent);
    std::string get_substr(int, int);
    // Объявление возможных правил, по которым будет происходить
    // удлинение суффикса
    enum Rule { RULE_2, RULE_3 };

    void SPA(int);

    Rule SEA(Suffix &, int, int);

    Suffix get_suffix(Node *, int, int);

    void RULE2(Suffix &, int, int);

    Node *root;
    int internal_node_ID;
    int length;
    int *current_end;
    Node *last_leaf_extension;
};
