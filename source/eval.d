import std.algorithm : map;
import std.array : array, join;
import std.process : ProcessException, spawnProcess, wait;
import std.stdio : stderr;
import ast : Command, CommandElement, Dispatcher, SimpleCommand, Word;

// コマンドを実行する
void execute(string[] args)
{
    try
    {
        spawnProcess(args).wait();
    }
    catch (ProcessException e)
    {
        stderr.writeln(e.message);
    }
}

class Evaluator
{
    mixin Dispatcher;

    void run(Command node)
    {
        dispatch!"eval"(node);
    }

    private void eval(SimpleCommand node)
    {
        auto args = node.elements.map!(el => eval(el)).array;

        execute(args);
    }

    private string eval(CommandElement node)
    {
        return node.words.map!(w => eval(w)).join("");
    }

    private string eval(Word word)
    {
        return word.text;
    }
}
