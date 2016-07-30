module app;

import std.stdio;
import std.utf;
import std.string;
import std.range;
import std.conv;
import core.exception;
import core.stdc.stdlib;
import std.file;
import std.algorithm;

/*
* Created by Mitchell Nuckols on 7/26/16
* Feel free to modify this as much as you want.
*
* TODO: Fix the range violation being caused by the dynamic array (I'll probably just turn it into a 2D list in the future)
* IDEA TIME:
* 1. Vars are implemented literally like stacks, so, why not just have vars be mini stacks with full funcitonality
*   Like, allow vars to be manipulated like stacks, and then push them to the actual stack with a command. Might be
*   cool. I'll probably add that later
*
*/

wchar[][] program;
int x, y, dir, velX = 1, velY = 0; // 0: right (default) 1: down/right 2: down 3: down/left 4: left 5: up/left 6: up 7: up/right
double[] stack;
double[][wstring] vars;

void createMatrix(string fileN, int startLine) {
    File file = File(fileN, "r");

    int currentLine = 0;

    while(!file.eof()) {
        auto line = file.readln();
        if(line.startsWith("#") || line.startsWith("\n")) continue; // Comments are ignored
        if(currentLine < startLine && startLine != -1) continue; // Allows the specification of what line to start running the program

        program ~= toUTF16(chomp(line)).dup;
    }

    file.close();

    int longest;
    for(int y = 0; y < program.length; y++) {
        longest = (program[y].length > longest ? program[y].length : longest);
        /++write(y, " ", program[y].length);
        for(int x = 0; x < program[y].length; x++) {
            write(" ", program[y][x]);
        }
        writeln();++/
    }

    int dif;
    for(int y = 0; y < program.length; y++) {
        dif = longest - program[y].length;
        while(dif > 0) {
            program[y] ~= '　';
            dif--;
        }
        dif = 0;
    }
}

void executeProgram() {
    while(true) {
        tick();
    }
}

void tick() {
    try {
        callInstruction(program[y][x]); /* Throws a violation because trying to access index of a
                                           dynamic array whose size was not defined at compile time */
    }catch(StackException se) {
        writeln(se.toString());
        exit(-1);
    }

    // Move head along 2D array based of of direction
    x += velX;
    y += velY;
}

void callInstruction(wchar instruction) {
    //writeln("(", x, ",", y, "): ", + instruction);
    switch(instruction) {
    case 'ほ':
        setDirection(0);
        break;
    case 'ば':
        setDirection(1);
        break;
    case 'べ':
        setDirection(2);
        break;
    case 'び':
        setDirection(3);
        break;
    case 'ぼ':
        setDirection(4);
        break;
    case 'は':
        setDirection(5);
        break;
    case 'へ':
        setDirection(6);
        break;
    case 'ひ':
        setDirection(7);
        break;
    case 'い':
        pushStringLiteral();
        break;
    case 'え':
        pushNumLiteral();
        break;
    case 'ろ':
        printStack();
        break;
    case 'る':
        printStackAsChars();
        break;
    case 'あ':
        add();
        break;
    case 'す':
        sub();
        break;
    case 'む':
        mult();
        break;
    case 'で':
        div();
        break;
    case 'ど':
        dupS();
        break;
    case 'さ':
        swapS();
        break;
    case 'お':
        overS();
        break;
    case 'ら':
        rotS();
        break;
    case 'け':
        exit(0);
        break;
    case 'や':
        evalConditional();
        break;
    case 'に':
        inc();
        break;
    case 'な':
        dec();
        break;
    case 'ぽ':
        pop();
        break;
    case 'ん':
        readLine();
        break;
    case 'ね':
        readInt();
        break;
    case 'り':
        reverse(stack);
        break;
    case 'そ':
        sort(stack);
        break;
    case 'き':
        emptyS();
        break;
    case 'ぶ':
        defineVar();
        break;
    case 'ふ':
        fetchVar();
        break;
    case 'ぷ':
        printVars();
        break;
    default: break;
    }
}

void setDirection(int direction) {
    final switch(direction) {
    case 0:
        dir = 0;
        velX = 1;
        velY = 0;
        break;
    case 1:
        dir = 1;
        velX = 1;
        velY = 1;
        break;
    case 2:
        dir = 2;
        velX = 0;
        velY = 1;
        break;
    case 3:
        dir = 3;
        velX = -1;
        velY = 1;
        break;
    case 4:
        dir = 4;
        velX = -1;
        velY = 0;
        break;
    case 5:
        dir = 5;
        velX = -1;
        velY = -1;
        break;
    case 6:
        dir = 6;
        velX = 0;
        velY = -1;
        break;
    case 7:
        dir = 7;
        velX = 1;
        velY = -1;
        break;
    }
}

void setDirection(wchar direction) {
    final switch(direction) {
    case 'ほ':
        setDirection(0);
        break;
    case 'ば':
        setDirection(1);
        break;
    case 'べ':
        setDirection(2);
        break;
    case 'び':
        setDirection(3);
        break;
    case 'ぼ':
        setDirection(4);
        break;
    case 'は':
        setDirection(5);
        break;
    case 'へ':
        setDirection(6);
        break;
    case 'ひ':
        setDirection(7);
        break;
    }
}

void pushStringLiteral() {
    if(program[y + velY][x + velX] == '「' || program[y + velY][x + velX] == '」') {
        x += velX + velX;
        y += velY + velY;
        while(program[y][x] != '」' && program[y][x] != '「') {
            // write(cast(wchar) program[y][x]);
            push(to!double(program[y][x]));
            x += velX;
            y += velY;
        }
        //writeln();
    }
}

void pushNumLiteral() {
    if(program[y + velY][x + velX] == '「' || program[y + velY][x + velX] == '」') {
        wstring numLiteral = "";
        double[] nums;
        bool mul;

        x += velX + velX;
        y += velY + velY;
        while(program[y][x] != '」' && program[y][x] != '「') {
            if(program[y][x] == '、') {
                nums ~= to!double(numLiteral);
                numLiteral = "";
                mul = true;
            }else {
                numLiteral ~= program[y][x];
            }
            x += velX;
            y += velY;
        }

        nums ~= to!double(numLiteral);

        if(mul) {
            foreach(num; nums) {
                push(num);
            }
        }else {
            push(to!double(numLiteral));
        }
    }
}

void printStack() {
    writeln(stack);
}

void printStackAsChars() {
    foreach(value; stack) {
        //if(value > 255) continue;
        write(cast(wchar) value);
    }
    writeln();
}

void printTOS() {

}

void add() {
    if(stack.length < 2) throw new StackException("Cannot preform `add`. Stack length is less than 2");
    auto a = pop();
    auto b = pop();
    push(a + b);
}

void sub() {
    if(stack.length < 2) throw new StackException("Cannot preform `sub`. Stack length is less than 2");
    auto a = pop();
    auto b = pop();
    push(a - b);
}

void mult() {
    if(stack.length < 2) throw new StackException("Cannot preform `mult`. Stack length is less than 2");
    auto a = pop();
    auto b = pop();
    push(a * b);
}

void div() {
    if(stack.length < 2) throw new StackException("Cannot preform `div`. Stack length is less than 2");
    auto a = pop();
    auto b = pop();
    push(a / b);
}

void dupS() {
    if(stack.length < 1) throw new StackException("Cannot preform `dup`. Stack length is less than 1");
    auto x = pop();
    push(x);
    push(x);
}

void swapS() {
    if(stack.length < 2) throw new StackException("Cannot preform `swap`. Stack length is less than 2");
    auto a = pop();
    auto b = pop();
    push(a);
    push(b);
}

void overS() {
    if(stack.length < 2) throw new StackException("Cannot preform `over`. Stack length is less than 2");
    auto a = pop();
    auto b = pop();
    push(b);
    push(a);
    push(b);
}

void rotS() {
    if(stack.length < 3) throw new StackException("Cannot preform `rot`. Stack length is less than 3");
    auto a = pop();
    auto b = pop();
    auto c = pop();
    push(a);
    push(c);
    push(b);
}

void inc() {
    if(stack.length < 1) throw new StackException("Cannot preform `inc`. Stack length is less than 1");
    auto a = pop();
    a++;
    push(a);
}

void dec() {
    if(stack.length < 1) throw new StackException("Cannot preform `dec`. Stack length is less than 1");
    auto a = pop();
    a--;
    push(a);
}

void evalConditional() {
    // writeln("Conditional");
    int lookAheadX = x;
    int lookAheadY = y;

    // writeln("Start: ", x, " ", y);

    if(program[lookAheadY + velY][lookAheadX + velX] == '｛') {
        wstring conditional = "";

        lookAheadX += velX + velX;
        lookAheadY += velY + velY;
        while(program[lookAheadY][lookAheadX] != '｝') {
            conditional ~= program[lookAheadY][lookAheadX];
            lookAheadX += velX;
            lookAheadY += velY;
            // writeln(lookAheadX, " ", lookAheadY);
        }

        wstring[] condition = conditional.split('；');

        auto check = pop();
        push(check);

        // writeln(condition);

        final switch(condition[0].dup[0]) { // TODO: Add some conditions for conditionals
        case 'わ':
            if(check == to!double(condition[1])) {
                // writeln(true);
                setDirection(condition[2].dup[0]);
            }else {
                // writeln(false);
                setDirection(condition[3].dup[0]);
            }
            break;
        case 'が':
            if(check < to!double(condition[1])) {
                setDirection(condition[2].dup[0]);
            }else {
                setDirection(condition[3].dup[0]);
            }
            break;
        case 'か':
            if(check > to!double(condition[1])) {
                setDirection(condition[2].dup[0]);
            }else {
                setDirection(condition[3].dup[0]);
            }
            break;
        case 'て':
            if(check <= to!double(condition[1])) {
                setDirection(condition[2].dup[0]);
            }else {
                setDirection(condition[3].dup[0]);
            }
            break;
        case 'で':
            if(check >= to!double(condition[1])) {
                setDirection(condition[2].dup[0]);
            }else {
                setDirection(condition[3].dup[0]);
            }
            break;
        case 'の':
            if(stack.length == 0) {
                setDirection(condition[2].dup[0]);
            }else {
                setDirection(condition[3].dup[0]);
            }
            break;
        }

        // writeln("End: ", x, " ", y);

    }
}

void readLine() {
    wchar[] input = toUTF16(strip(readln())).dup;

    foreach(c; input) {
        push(to!double(c));
    }
}

void readInt() {
    int input;

    readf(" %s", &input);

    push(to!double(input));
}

void emptyS() {
    if(stack.length < 1) throw new StackException("Cannot preform `empty`. Stack length is less than 1");
    while(stack.length > 0) {
        stack.popBack();
    }
}

void defineVar() {

    double[] var;
    bool declaration = false;
    bool multNum = false;
    wstring defineLine = "";

    if(program[y + velY][x + velX] == '「' || program[y + velY][x + velX] == '」') {
        x += velX + velX;
        y += velY + velY;
        while(program[y][x] != '」' && program[y][x] != '「') {
            defineLine ~= program[y][x];
            // writeln(program[y][x]);
            // writeln("Line: ", defineLine);
            if(program[y][x] == '；') declaration = true;
            if(program[y][x] == '、' && declaration) multNum = true;
            x += velX;
            y += velY;
        }
    }

    if(declaration == false) {
        var ~= pop();
        vars[defineLine] = var;
    }else {
        // writeln("Line: ", defineLine);
        wstring[] splitDeclaration = defineLine.split('；');
        // writeln(splitDeclaration);
        if(multNum == false) {
            var ~= to!double(splitDeclaration[1]);
            vars[splitDeclaration[0]] = var;
        }else {
            wstring[] nums = splitDeclaration[1].split('、');

            foreach(num; nums) {
                var ~= to!double(num);
            }

            vars[splitDeclaration[0]] = var;
        }
    }
}

void fetchVar() {
    wstring varName = "";

    if(program[y + velY][x + velX] == '「' || program[y + velY][x + velX] == '」') {
        x += velX + velX;
        y += velY + velY;
        while(program[y][x] != '」' && program[y][x] != '「') {
            varName ~= program[y][x];
            x += velX;
            y += velY;
        }
    }

    foreach(var; vars[varName]) {
        push(var);
    }
}

void printVars() {
    foreach(key, value; vars) {
        writeln(key, ": ", value);
    }
}

void push(double value) {
    stack.assumeSafeAppend() ~= value;
}

auto pop() {
    if(stack.length < 1) throw new StackException("Cannot preform `pop`. Stack length is less than 1");
    auto popped = stack.back();
    stack.popBack();
    return popped;
}

/*auto getAt(int x, int y) {
    int currLine = 0;
    int currColumn = 0;

    foreach(line; program) {
        foreach(column; line) {
            if(currLine == y && currColumn == x) return column;
            currColumn++;
        }
        currLine++;
    }

    return null;
}

// Yay for workarounds

auto getRow(int y) {
    int currLine = 0;

    foreach(line; program) {
        if(currLine == y) return line;
        currLine++;
    }

    return null;
}*/

void main(string[] args){
    string fileName;
    int startLine = -1;

    if(args[1] != null && args[1].endsWith(".path") && exists(args[1])) {
        fileName = args[1];
    }else {
        writeln("Error! invalid file specified!");
        exit(-1);
    }

    createMatrix(fileName, startLine);
    executeProgram();

}

class StackException : Exception {
    this(string msg) {
        //writeln("ERROR: ", msg);
        super(msg);
    }
}