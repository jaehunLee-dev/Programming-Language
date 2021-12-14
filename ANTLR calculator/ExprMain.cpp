#include <iostream>
#include "ExprBaseListener.h"
#include "ExprLexer.h"
#include "ExprParser.h"
#include <string.h>
#include <fstream>
#include <map>
#include <stack>
using namespace std;
using namespace antlr4;
using namespace antlr4::tree;

class EvalListener : public ExprBaseListener {
	// C++ STL map for variables' integer value for assignment
	map<string, string> vars;
	string var = "";
	// C++ STL stack for expression tree evaluation
	stack<double> evalStack;
	stack<char> opStack;
	string exp="";
	bool isId = false;
	bool isAssn = false;
	string assnId = "";
	int turn = 0;
public:
	int getPrec(char op){
		switch(op){
			case '*':
			case '/':
				return 3;
			case '+':
			case '-':
				return 2;
			case '(':
				return 1;
		}
		return -1;
	}

	int cmpPrec(char op1, char op2){
		int num1 = getPrec(op1);
		int num2 = getPrec(op2);
		if (num1 >num2) return 1;
		else if (num1 < num2) return -1;
		else return 0;
	}
	virtual void exitProg(ExprParser::ProgContext *ctx){
//		cout << "exitProg: " << endl;
	}

	virtual void exitExpr(ExprParser::ExprContext *ctx){

//		cout << "exitExpr: " << endl;
	}

	virtual void visitTerminal(tree::TerminalNode *node){
//		cout <<"Terminal: " << node->getText() << endl;

		if (node->getSymbol()->getType() == ExprLexer::REAL || node->getSymbol()->getType() == ExprLexer::INT){
			if (isAssn){
				vars.insert(make_pair(assnId,node->getText()));
			}
			else
				exp = exp + " " + node->getText();
		}

		else if (node->getText().compare("=") == 0){
			isAssn = true;
		}

		else if (node->getSymbol()->getType() == ExprLexer::ID){
			assnId = node->getText();
			if (vars.count(assnId)){
				exp = exp + " " +vars[assnId]; 
			}
		}

		else if (node->getSymbol()->getText().compare(";") == 0){
			if (isAssn){
				isAssn = false;
			       	return;
			}
			while (!opStack.empty()){
				char ch_temp[2];
				ch_temp[1] = '\0';
				ch_temp[0] = opStack.top();
                                string str_temp(ch_temp);
                                exp = exp + " " + str_temp;
				opStack.pop();
			}
		//	cout << exp <<"\n";
			char exp_ch[1000] ="";
			strcpy(exp_ch,exp.c_str());
			char* postfix = strtok(exp_ch," ");
			while (postfix != NULL){
				if (atof(postfix) != 0 || !strcmp(postfix,"0")){	//if it is number
					evalStack.push(atof(postfix));
				}
				else{							//if it is op
					double tnum1 = evalStack.top();
                                        evalStack.pop();
                                        double tnum2 = evalStack.top();
                                        evalStack.pop();
					switch(postfix[0]){
						case '+':
							evalStack.push(tnum2+tnum1);
							break;
						case '-':
							evalStack.push(tnum2-tnum1);
							break;
						case '*':
                                                        evalStack.push(tnum1*tnum2);
							break;
                                                case '/':
                                                        evalStack.push(tnum2/tnum1);
							break;
					}
				}
				postfix = strtok(NULL, " ");
			}
			double result = evalStack.top();
			evalStack.pop();
			isId = false;
			isAssn = false;
			assnId = "";
			cout <<result << '\n';
			exp = "";
		}
		else {	//op case
			char temp[10];
			strcpy(temp,node->getText().c_str());
			//temp = node->getText().c_str();
			switch(temp[0]){
				char ch_temp[2];
				ch_temp[1] = '\0';
				case '(' :
					opStack.push('(');
					break;
				case ')' :
					while (opStack.top() != '('){
						ch_temp[0] = opStack.top();
						ch_temp[1] = '\0';
						string str_temp(ch_temp);
						exp = exp + " " + str_temp;
						//cout << exp << '\n';
						opStack.pop();
					}
					opStack.pop();
					break;
				case '+':
				case '-':
				case '*':
				case '/':
					while(!opStack.empty() && cmpPrec(opStack.top(),temp[0]) >= 0){
							ch_temp[0] = opStack.top();
							string str_temp(ch_temp);
							exp = exp + " "+ str_temp;
							//cout << exp <<'\n';
							opStack.pop();
							}
					opStack.push(temp[0]);
					break;
			}
		}


	}
};
int main(int argc, const char* argv[]){
	if (argc < 2){
		cerr << "[Usage] " << argv[0] << "	<input-file>\n";
		exit(0);
	}
	std::ifstream stream;
	stream.open(argv[1]);
	if (stream.fail()){
		cerr << argv[1] <<" : file open fail\n";
		exit(0);
	}


	//cout <<"** Expression Eval with ANTLR listener **";
	ANTLRInputStream input(stream);
	ExprLexer lexer(&input);
	CommonTokenStream tokens(&lexer);
	ExprParser parser(&tokens);
	ParseTree *tree = parser.prog();

	//cout << tree->toStringTree(&parser) << endl;

	ParseTreeWalker walker;
	EvalListener listener;

	walker.walk(&listener, tree);
}
