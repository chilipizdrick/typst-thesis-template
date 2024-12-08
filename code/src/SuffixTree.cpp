#include <algorithm>
#include <cassert>
#include <cctype>
#include <iostream>
#include <string>
#include <utility>

#include "SuffixTree.h"

Node::Node(Node *parent, int begin_index, int *end_index, int ID) {
    this->parent = parent;
    this->begin_index = begin_index;
    this->end_index = end_index;
    this->ID = ID;
    suffix_link = nullptr;
}

void Node::add_child(const SuffixTree &tree, Node *child_to_add) {
    int key = get_key(tree, child_to_add, child_to_add->begin_index);
    children[key] = child_to_add;
}

void Node::remove_child(const SuffixTree &tree,
                        Node *child_to_remove) {
    int key =
        get_key(tree, child_to_remove, child_to_remove->begin_index);
    children.erase(key);
}

int Node::get_key(const SuffixTree &tree, Node *node,
                  int index) const {
    char ch = tree.get_char_at_index(index);
    return (ch != '$' ? ch * (-1) : index);
}

void Node::split_edge(const SuffixTree &tree, int char_index,
                      int new_node_ID) {
    Node *new_node = new Node(parent, begin_index,
                              new int(char_index), new_node_ID);

    parent->remove_child(tree, this);
    parent->add_child(tree, new_node);

    this->parent = new_node;
    this->begin_index = char_index + 1;
    new_node->add_child(tree, this);
}

Node *Node::get_child(const SuffixTree &tree, int char_index) {
    int key = get_key(tree, this, char_index);
    std::map<int, Node *>::iterator it = children.find(key);
    if (it != children.end())
        return it->second;
    else
        return nullptr;
}

Suffix::Suffix(Node *n, int c) : node(n), char_index(c) {
    new_internal_node = false;
}

bool Suffix::ends_at_node() const {
    return char_index == *node->end_index;
}

bool Suffix::ends_at_leaf() const {
    return node->is_leaf() && ends_at_node();
}

bool Suffix::continues_with_char(const SuffixTree &tree,
                                 int tree_index) const {
    char ch = tree.get_char_at_index(tree_index);
    bool terminal(ch == '$');
    return (ends_at_node() &&
            node->get_child(tree, tree_index) != nullptr) ||
           (!ends_at_node() &&
            tree.get_char_at_index(char_index + 1) == ch &&
            (!terminal || char_index + 1 == tree_index));
}

Node *Suffix::walk_up(int &begin_index, int &end_index) const {
    if (ends_at_node() && node->suffix_link != nullptr) {
        begin_index = *node->end_index;
        end_index = *node->end_index - 1;
        return node;
    } else {
        begin_index = node->begin_index;
        end_index = char_index;
        return node->parent;
    }
}

bool Suffix::RULE2_conditions(const SuffixTree &tree,
                              int tree_index) const {
    return !ends_at_leaf() && !continues_with_char(tree, tree_index);
}

SuffixTree::SuffixTree() {
    // Использование уникальных идентификаторов для узлов не
    // необходимо для работы алгоритма, но упрощает задачу
    // визуализации и хранения дерева, а также позволяет
    // эффективнее реализовывать некоторые алгоритмы поиска
    // в построенном дереве.
    internal_node_ID = 0;

    current_end = new int(0);
    root = new Node(nullptr, 1, current_end, internal_node_ID);
}

// Функция построения суффиксного дерева.
void SuffixTree::construct(std::string s) {
    length = s.length();
    tree_string = s;

    (*current_end)++;
    last_leaf_extension = new Node(root, 1, current_end, 1);
    root->add_child(*this, last_leaf_extension);

    for (int i = 1; i < length; i++)
        SPA(i);
}

// Реализация однопроходного алгоритма построения
// суффиксного дерева.

// Однофазный алгоритм построения суффиксного дерева (Single
// Phase Algorithm)
void SuffixTree::SPA(int i) {
    Suffix previous_suffix(last_leaf_extension, *current_end);
    (*current_end)++;
    for (int j = (last_leaf_extension->ID + 1); j <= i + 1; j++) {
        Rule rule_applied = SEA(previous_suffix, j, i);
        if (rule_applied == RULE_3)
            break;
    }
}

// Алгоритм одиночного продления суффикса (Single Extension
// Algorithm)
SuffixTree::Rule SuffixTree::SEA(Suffix &previous_suffix, int j,
                                 int i) {
    int begin_index, end_index;
    Node *origin = previous_suffix.walk_up(begin_index, end_index);
    Suffix suffix =
        (origin == root ? get_suffix(root, j, i)
                        : get_suffix(origin->suffix_link, begin_index,
                                     end_index));

    Rule rule_applied;
    if (suffix.RULE2_conditions(*this, i + 1)) {
        RULE2(suffix, i + 1, j);
        rule_applied = RULE_2;
    } else {
        rule_applied = RULE_3;
    }

    if (previous_suffix.new_internal_node)
        previous_suffix.node->suffix_link = suffix.node;

    previous_suffix = suffix;
    return rule_applied;
}

Suffix SuffixTree::get_suffix(Node *origin, int begin_index,
                              int end_index) {
    int char_index = *origin->end_index;

    while (begin_index <= end_index) {
        origin = origin->get_child(*this, begin_index);
        if (origin->edge_length() < end_index - begin_index + 1)
            char_index = *origin->end_index;
        else
            char_index =
                origin->begin_index + (end_index - begin_index);
        begin_index += origin->edge_length();
    }
    return Suffix(origin, char_index);
}

std::string SuffixTree::get_substr(int start_pos, int end_pos) {
    if (start_pos > end_pos)
        return std::string();
    // Алгоритм воспринимает исходную строку как
    // 1-индексированную для удобства восприятия
    // пользователя.
    return tree_string.substr(start_pos - 1, end_pos - start_pos + 1);
}

char SuffixTree::get_char_at_index(int index) const {
    return tree_string[index - 1];
}

void SuffixTree::RULE2(Suffix &suffix, int char_index,
                       int new_leaf_ID) {
    if (!suffix.ends_at_node()) {
        suffix.node->split_edge(*this, suffix.char_index,
                                --internal_node_ID);
        suffix.node = suffix.node->parent;
        suffix.new_internal_node = true;
    }
    Node *new_leaf =
        new Node(suffix.node, char_index, current_end, new_leaf_ID);
    suffix.node->add_child(*this, new_leaf);
    last_leaf_extension = new_leaf;
}

std::string SuffixTree::tree_graph() {
    return "digraph g{\n" + node_graph(root) + "}";
}

std::string SuffixTree::node_graph(Node *parent) {
    std::map<int, Node *>::iterator it = parent->children.begin();
    std::stringstream buffer;
    buffer << parent->ID
           << "[shape=" << ((parent->ID <= 0) ? "point" : "plaintext")
           << "];\n";
    for (; it != parent->children.end(); it++) {
        Node *child_node = it->second;
        buffer << parent->ID << "->" << child_node->ID
               << " [label = \""
               << get_substr(child_node->begin_index,
                             *(child_node->end_index))
               << "\"];\n"
               << node_graph(child_node);
    }
    Node *suffix_link = parent->suffix_link;
    if (suffix_link)
        buffer << "\"" << parent->ID << "\" -> " << "\""
               << suffix_link->ID
               << "\" [style=dashed arrowhead=otriangle];\n";
    return buffer.str();
}

std::ostream &operator<<(std::ostream &os, const Node &node) {
    std::string suffix_node_id =
        node.suffix_link != nullptr
            ? std::to_string(node.suffix_link->ID)
            : "-";
    os << "{ " << node.ID << " " << node.begin_index << " "
       << *node.end_index << " " << suffix_node_id << " ";
    os << " [ ";
    if (!node.children.empty()) {
        for (auto const &[id, node] : node.children) {
            os << id << " " << *node;
        }
    }
    os << " ] ";
    return os << "} ";
}

std::ostream &operator<<(std::ostream &os, const SuffixTree &tree) {
    os << tree.tree_string << "\n";
    os << *tree.root;
    return os;
}

std::istream &operator>>(std::istream &is, Node &node) {
    std::string opening_bracket;
    is >> opening_bracket;
    assert(opening_bracket == "{");

    is >> node.ID >> node.begin_index >> *node.end_index;

    node.suffix_link = nullptr;
    std::string suffix_link_str;
    is >> suffix_link_str;
    if (suffix_link_str != "-") {
        int suffix_link_id = std::stoi(suffix_link_str);
        node.suffix_link = nullptr;
    }

    std::string opening_sqbracket;
    is >> opening_sqbracket;
    assert(opening_sqbracket == "[");

    std::string mystery_symbol;
    is >> mystery_symbol;
    while (mystery_symbol != "]") {
        int tmp_id;
        tmp_id = std::stoi(mystery_symbol);
        Node *tmp_node = new Node(nullptr, 0, new int(0), 0);
        is >> *tmp_node;
        node.children[tmp_id] = tmp_node;
        is >> mystery_symbol;
    }

    std::string closing_bracket;
    is >> closing_bracket;
    assert(closing_bracket == "}");
    return is;
}

std::istream &operator>>(std::istream &is, SuffixTree &tree) {
    std::string tree_string;
    is >> tree_string;
    Node *node = new Node(nullptr, 0, new int(0), 0);
    is >> *node;
    tree.construct(tree_string);
    return is;
}

int SuffixTree::find_suffix(const std::string &suffix) {
    Node *curr_node = this->root;
    int curr_index = 0;
    while (curr_index < suffix.size()) {
        Node *initial_node = curr_node;
        for (auto const &[_, node] : curr_node->children) {
            if (this->tree_string.substr(node->begin_index - 1,
                                         node->edge_length()) ==
                suffix.substr(curr_index, node->edge_length())) {
                curr_node = node;
                curr_index += node->edge_length();
                break;
            }
        }
        if (initial_node == curr_node)
            return -1;
    }
    return curr_node->ID;
}

std::string SuffixTree::LRS(Node *node, std::string curr_string) {
    std::vector<std::string> lrs_variants(node->children.size());
    for (auto const &[_, child_node] : node->children) {
        if (child_node->is_leaf()) {
            lrs_variants.push_back(curr_string + "");
            continue;
        }
        if (child_node->children.size() < 2) {
            lrs_variants.push_back(curr_string + "");
            continue;
        }
        lrs_variants.push_back(LRS(
            child_node,
            curr_string +
                this->tree_string.substr(child_node->begin_index - 1,
                                         child_node->edge_length())));
    }
    return *std::max_element(
        lrs_variants.begin(), lrs_variants.end(),
        [](const std::string &a, const std::string &b) {
            return a.size() < b.size();
        });
}

std::string SuffixTree::LRS() { return LRS(this->root, ""); }
