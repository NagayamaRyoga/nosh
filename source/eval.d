import std.algorithm : map;
import std.array : array, join;
import std.conv : ConvException, to;
import std.file : chdir;
import std.process : Config, environment, Pid, pipe, ProcessException, spawnProcess, wait;
import std.stdio : File, stderr, stdin, stdout;
import ast : Command, CommandElement, Dispatcher, PipeCommand, SimpleCommand, Word;

import std.stdio;

string homeDir()
{
    return environment.get("HOME");
}

class Evaluator
{
    mixin Dispatcher;

    private int _lastExitStatus = 0;

    void run(Command node)
    {
        try
        {
            auto pids = dispatch!"eval"(node, stdin, stdout, stderr);

            foreach (pid; pids)
            {
                _lastExitStatus = pid.wait();
            }
        }
        catch (ProcessException e)
        {
            stderr.writeln(e.message);

            _lastExitStatus = 127;
        }
    }

    private Pid[] eval(PipeCommand node, File stdin, File stdout, File stderr)
    {
        auto p = pipe();
        auto readEnd = p.readEnd;
        auto writeEnd = p.writeEnd;

        // 左辺
        auto leftPids = dispatch!"eval"(node.left, stdin, writeEnd, node.all ? writeEnd : stderr);

        // 右辺
        auto rightPids = dispatch!"eval"(node.right, readEnd, stdout, stderr);

        return leftPids ~ rightPids;
    }

    private Pid[] eval(SimpleCommand node, File stdin, File stdout, File stderr)
    {
        auto args = node.elements.map!(el => eval(el)).array;

        switch (args[0])
        {
        case "cd":
            return builtinCd(args);

        case "exit":
            return builtinExit(args);

        default:
            // コマンドを実行する
            auto pid = spawnProcess(args, stdin, stdout, stderr, null,
                    Config.retainStdin | Config.retainStdout | Config.retainStderr);
            return [pid];
        }
    }

    private string eval(CommandElement node)
    {
        return node.words.map!(w => eval(w)).join("");
    }

    private string eval(Word word)
    {
        return word.text;
    }

    /**
     * cd コマンド
     */
    private Pid[] builtinCd(string[] args)
    {
        const dir = args.length > 1 ? args[1] : homeDir();
        chdir(dir);

        return [];
    }

    /**
     * exit コマンド
     */
    private Pid[] builtinExit(string[] args)
    {
        import core.stdc.stdlib : exit;

        if (args.length > 1)
        {
            try
            {
                _lastExitStatus = args[1].to!int;
            }
            catch (ConvException e)
            {
                stderr.writeln("exit: numeric argument required");
                _lastExitStatus = 1;
            }
        }

        exit(_lastExitStatus);
    }
}
