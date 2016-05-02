#include <iostream>
#include <sstream>      // std::istringstream
#include <fstream>
#include <string>
#include <algorithm>
#include <list>
#include <unordered_map>
#include<iterator>

using namespace std;

//Patch for namespace, bugfix is not updated for c++ at school computers
namespace patch
{
    template < typename T > std::string to_string( const T& n )
    {
        std::ostringstream stm ;
        stm << n ;
        return stm.str() ;
    }
}

int main()
{
    //Load all files, split a sentence at '.',
    //convert to lower case
    string line, result, word, oss;
    char delimiter('.');
    ifstream myfile;
    ofstream translatedFile;

    // Hashtable dictionary to replace word with integer
    std::unordered_map<std::string, int> hashTable;

    for(int i = 1; i < 11; i++) {
        // Get file names
        if( i == 10 ) {
            oss  = "../Lab3.2/" + patch::to_string(i) + ".txt";
            myfile.open(oss);
            oss  = "../translated/" + patch::to_string(i) + "t.txt";
            translatedFile.open(oss);

        } else {
            oss  = "../Lab3.2/0" + patch::to_string(i) + ".txt";
            myfile.open(oss);
            oss  = "../translated/0" + patch::to_string(i) + "t.txt";
            translatedFile.open(oss);
        }

        if (myfile.is_open()) {
            // Get every sentence and turn them into integer sentences,
            // one line per sentence (into the new file)
            while( getline(myfile, line, delimiter) ) {
                // Strip the line of unnecessary stuff
                std::transform(line.begin(), line.end(), line.begin(), ::tolower);
                std::remove_copy_if(line.begin(), line.end(), std::back_inserter(result), //Store output
                        std::ptr_fun<int, int>(&std::ispunct));

                // Transform the word from the line into ints with hash table
                // and write to file
                istringstream iss(result);
                while(iss >> word) {
                    // Put word into hash table
                    auto got = hashTable.find(word);
                    if(got == hashTable.end()){
                        // Not found, insert word and key
                        hashTable.insert(std::make_pair(word, hashTable.size()));
                        translatedFile <<  hashTable.size()-1 << " ";
                        // Insert into text file
                    } else {
                        // Found, insert into new text file
                        translatedFile <<  got->second << " ";
                    }
                }
                translatedFile << endl;

                //Clear result
                result = "";
            }
            myfile.close();
            translatedFile.close();
        } else cout << "Unable to open file";
    }

    cout << "Done with hashing files" << endl;
    cout << "Dictionary size: " << hashTable.size() << endl;
    cout << "\nChecking for plagiarization" << endl;

    /*std::list<int> lista = hashTable["and"];
    while(!lista.empty()) {
        cout << lista.front() << " ";
        lista.pop_front();
    }*/

    string comparedLine;
    int copiedLines, readLines, atLine, numWords;
    bool beenThere = false;
    ifstream file, compare;
    ofstream newfile;

    newfile.open("../translated/result.txt");
    if (!newfile.is_open()) cout << "Could not write to new file\n";

    //Go through all files and see which lines are copied.
    for(int i = 1; i < 11; ++i) {
        string oss;
        cout << "Comparing file " << i << endl;

        if( i == 10 ) {
            oss  = "../translated/" + patch::to_string(i) + "t.txt";
        } else {
            oss  = "../translated/0" + patch::to_string(i) + "t.txt";
        }

        file.open(oss);

        if (file.is_open()) {
            atLine = 0; numWords = 0;
            // Get first line of text document that is going to be compared
            while(getline(file, line)) {
                // Count words in this line, only sentences with several words will count
                istringstream stream(line);
                numWords = distance(istream_iterator<string>(stream), istream_iterator<string>());
                atLine++;

                // Go through all files except i and check amount of copied lines.
                for(int j = 1; j < 11; ++j) {
                    copiedLines = 0;
                    if (j == i) {
                        continue; // Do not compare file with itself
                    } else if( j == 10 ) {
                        oss  = "../translated/" + patch::to_string(j) + "t.txt";
                    } else {
                        oss  = "../translated/0" + patch::to_string(j) + "t.txt";
                    }
                    compare.open(oss);

                    if(compare.is_open()) {
                        // Get lines in comparable file
                        while (getline(compare, comparedLine)) {
                            readLines++;
                            // Compare lines and don't compare one word lines
                            if (numWords > 1 && comparedLine == line) {
                                if (!beenThere) {
                                    beenThere = true;
                                    if (i == 10)
                                        newfile << "\n*** Compare textfile translated/" << i << ".txt ***\n\n";
                                    else
                                        newfile << "\n*** Compare textfile translated/0" << i << ".txt ***\n\n";
                                }
                                if (j == 10)
                                    newfile << "Line " << atLine << " is similar to " << j << ".txt at line " << readLines << "\n";
                                else
                                    newfile << "Line " << atLine << " is similar to 0" << j << ".txt at line " << readLines << "\n";

                                newfile << "\"";
                                // Translate from integers to words
                                stringstream stream (line);
                                for(string currword; stream >> currword;) {
                                    for (auto it = hashTable.begin(), end = hashTable.end();
                                            it != end; ++it) {
                                        if(it->second == atoi(currword.c_str())){
                                            newfile << it->first << " ";
                                            break;
                                        }
                                    }
                                }
                                newfile << "\"\n\n";
                            }
                        }
                        compare.close();
                        readLines = 0;

                    } else cout << "Unable to open compare file";
                }
            }
            file.close();
        } else cout << "Unable to open file";
        cout << endl;
        beenThere = false;
    }
    newfile.close();
    return 0;
}
