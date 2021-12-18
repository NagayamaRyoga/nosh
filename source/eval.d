import std.algorithm : map;
import std.array : array, join;
import std.process : Pid, pipe, ProcessException, spawnProcess, wait;
import std.stdio : File, stderr, stdin, stdout;
import ast : Command, CommandElement, Dispatcher, PipeCommand, SimpleCommand, Word;

class Evaluator
{
    mixin Dispatcher;

    void run(Command node)
    {
        try
        {
            auto pids = dispatch!"eval"(node, stdin, stdout, stderr);

            foreach (pid; pids)
            {
                pid.wait();
            }
        }
        catch (ProcessException e)
        {
            stderr.writeln(e.message);
        }
    }

    private Pid[] eval(PipeCommand node, File stdin, File stdout, File stderr)
    {
        auto p = pipe();
        auto readEnd = p.readEnd();
        auto writeEnd = p.writeEnd();

        // 左辺
        auto leftPids = dispatch!"eval"(node.left, stdin, writeEnd, stderr);

        // 右辺
        auto rightPids = dispatch!"eval"(node.right, readEnd, stdout, stderr);

        return leftPids ~ rightPids;
    }

    private Pid[] eval(SimpleCommand node, File stdin, File stdout, File stderr)
    {
        auto args = node.elements.map!(el => eval(el)).array;

        // コマンドを実行する
        auto pid = spawnProcess(args, stdin, stdout, stderr);
        return [pid];
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
