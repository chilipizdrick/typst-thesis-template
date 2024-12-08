#include <algorithm>
#include <chrono>
#include <fstream>
#include <string>

#include "SuffixTree.h"

std::string read_file_to_string(std::string path) {
    std::ifstream ifs(path);
    return std::string((std::istreambuf_iterator<char>(ifs)),
                       (std::istreambuf_iterator<char>()));
}

int main(int argc, char *argv[]) {
    SuffixTree tree;
    if (argc < 2) {
        std::cout << "usage: suffixtree [mode] <input_string>\n";
        exit(1);
    } else {
        std::string flag = static_cast<std::string>(argv[1]);

        if (flag == "-v" || flag == "--viz") {
            std::string input = argv[2];
            if (input[input.size() - 1] != '$')
                input += '$';
            tree.construct(input);
            std::cout << tree.tree_graph() << "\n";

        } else if (flag == "-r" || flag == "--raw") {
            std::string input = argv[2];
            if (input[input.size() - 1] != '$')
                input += '$';
            tree.construct(input);
            std::cout << tree << "\n";

        } else if (flag == "-c" || flag == "--construct") {
            SuffixTree input_tree;
            std::ifstream fs(argv[2]);
            fs >> input_tree;
            std::cout << input_tree << "\n";

        } else if (flag == "-l" || flag == "--lrs") {
            std::string input = read_file_to_string(argv[2]);
            std::transform(
                input.begin(), input.end(), input.begin(),
                [](unsigned char c) { return std::tolower(c); });
            auto start = std::chrono::high_resolution_clock::now();
            tree.construct(input);
            std::string lrs = tree.LRS();
            auto stop = std::chrono::high_resolution_clock::now();
            std::cout << "Longest repeating substring of privided "
                         "file is\n\""
                      << lrs << "\"\n";
            std::cout << "Execution time: "
                      << std::chrono::duration_cast<std::chrono::milliseconds>(
                             stop - start)
                             .count()
                      << "ms\n";

        } else if (flag == "-t" || flag == "--test") {
            int test_number = std::stoi(argv[2]);

            if (test_number == 1) {
                std::string input = "abbabab$";
                std::string suffix = "abab$";
                tree.construct(input);
                std::cout << "Start index of suffix \"" << suffix
                          << "\" of string \"" << input << "\" is "
                          << tree.find_suffix(suffix) << "\n";

            } else if (test_number == 2) {
                std::string input = "abbabab$";
                std::string suffix = "cab$";
                tree.construct(input);
                std::cout << "Start index of suffix \"" << suffix
                          << "\" of string \"" << input << "\" is "
                          << tree.find_suffix(suffix) << "\n";

            } else if (test_number == 3) {
                std::string input = "ATCGATCGA$";
                tree.construct(input);
                std::cout
                    << "Longest repeating substring of string \""
                    << input << "\" is \"" << tree.LRS() << "\"\n";
            }

        } else {
            std::cout << "unknown command flag\n";
            exit(1);
        }
    }
}
